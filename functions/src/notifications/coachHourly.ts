import { onSchedule } from "firebase-functions/v2/scheduler";
import { FieldValue } from "firebase-admin/firestore";
import { normalizeGameState } from "../shared/gameState";
import { deadlineGuard, forEachDocument } from "../shared/pagination";
import {
  localDateKey,
  localMinuteOfDay,
  offsetRangesForLocalWindow,
  resolveUserTime,
} from "../shared/timezone";
import { readMonthlyIncomeCents } from "../shared/budgetDay";
import {
  COACH_ACTIVE_HOUR_END,
  COACH_ACTIVE_HOUR_START,
  COACH_RECENT_WINDOW,
  CoachLocale,
  coachRoll,
  computeEducationProgress,
  pickCoachTip,
} from "../shared/coach";
import { logger } from "../shared/logger";
import {
  UserProfile,
  canConsumeDailyQuota,
  db,
  hasActiveDevice,
  isQuietHour,
  sendToUser,
} from "./delivery";

const TIMEOUT_SECONDS = 540;

/**
 * First 12 minutes of each local hour (08:00–21:12): refresh the in-app coach tip.
 * FCM is optional and still respects the daily engagement cap (max 2) + tips opt-in.
 */
export const coachHourly = onSchedule(
  {
    schedule: "every 1 hours",
    region: "us-central1",
    timeoutSeconds: TIMEOUT_SECONDS,
    memory: "512MiB",
  },
  async (_event) => {
    const now = new Date();
    const shouldStop = deadlineGuard(TIMEOUT_SECONDS);

    // Visit every offset that could be in an active hour's first 12 minutes.
    // We re-check exact local time with the IANA zone inside the handler.
    for (let hour = COACH_ACTIVE_HOUR_START; hour <= COACH_ACTIVE_HOUR_END; hour++) {
      const window: [number, number] = [hour * 60, hour * 60 + 12];
      for (const [lo, hi] of offsetRangesForLocalWindow(now, window[0], window[1])) {
        const result = await forEachDocument(
          db()
            .collection("users")
            .where("utcOffsetMinutes", ">=", lo)
            .where("utcOffsetMinutes", "<=", hi),
          (doc) => maybeRefreshCoach(doc.id, doc.data() as UserProfile, now),
          { label: "coachHourly", shouldStop }
        );
        if (result.stoppedEarly) return;
      }
    }
  }
);

export async function maybeRefreshCoach(
  uid: string,
  profile: UserProfile,
  now: Date
): Promise<void> {
  const raw = profile as unknown as Record<string, unknown>;
  if (raw.onboardingDone !== true) return;
  // In-app tips follow the same opt-in as "Conseils" / tips channel.
  if (profile.notifPrefs?.tips !== true) return;

  const time = resolveUserTime(raw);
  if (isQuietHour(now, time)) return;

  const minute = localMinuteOfDay(now, time);
  const hour = Math.floor(minute / 60);
  const minuteOfHour = minute % 60;
  if (hour < COACH_ACTIVE_HOUR_START || hour > COACH_ACTIVE_HOUR_END) return;
  if (minuteOfHour > 12) return;

  const today = localDateKey(now, time);
  const hourKey = `${today}T${String(hour).padStart(2, "0")}`;

  const progressRef = db().doc(`users/${uid}/coach/progress`);
  const currentRef = db().doc(`users/${uid}/coach/current`);

  // Idempotent per local hour.
  const currentSnap = await currentRef.get();
  if (currentSnap.data()?.hourKey === hourKey) return;

  const [gameSnap, goalsSnap, underSnap, progressSnap] = await Promise.all([
    db().doc(`users/${uid}/game/state`).get(),
    db().collection(`users/${uid}/goals`).limit(1).get(),
    db()
      .collection(`users/${uid}/dailyXp`)
      .where("fromBudgetDay", ">", 0)
      .limit(20)
      .get()
      .catch(() => null),
    progressRef.get(),
  ]);

  const game = gameSnap.exists
    ? normalizeGameState(gameSnap.data())
    : normalizeGameState(undefined);

  const legacyLessons = Array.isArray(raw.completedLessonIds)
    ? (raw.completedLessonIds as unknown[]).filter((x): x is string => typeof x === "string")
    : [];
  // Prefer lessonProgress count when available (more accurate after migrations).
  let lessonsCompleted = legacyLessons.length;
  try {
    const lp = await db().collection(`users/${uid}/lessonProgress`).count().get();
    lessonsCompleted = Math.max(lessonsCompleted, lp.data().count);
  } catch {
    /* count may need index; fall back to profile array */
  }

  const education = computeEducationProgress({
    lessonsCompleted,
    streakBest: game.streak.best,
    level: game.level,
    hasIncome: readMonthlyIncomeCents(raw) > 0,
    hasGoal: !goalsSnap.empty,
    underBudgetDayCount: underSnap?.size ?? 0,
  });

  const prev = progressSnap.data() as
    | {
        lastTipId?: unknown;
        recentTipIds?: unknown;
        tipCount?: unknown;
      }
    | undefined;
  const lastTipId =
    typeof prev?.lastTipId === "string" ? prev.lastTipId : null;
  const recentTipIds = Array.isArray(prev?.recentTipIds)
    ? prev.recentTipIds.filter((x): x is string => typeof x === "string")
    : [];

  const locale: CoachLocale = profile.locale === "en" ? "en" : "fr";
  const roll = coachRoll(uid, hourKey);
  const picked = pickCoachTip({
    stage: education.stage,
    lastTipId,
    recentTipIds,
    locale,
    roll,
  });
  if (!picked) return;

  const nextRecent = [
    picked.tip.id,
    ...recentTipIds.filter((id) => id !== picked.tip.id),
  ].slice(0, COACH_RECENT_WINDOW);

  const tipCount =
    (typeof prev?.tipCount === "number" ? Math.trunc(prev.tipCount) : 0) + 1;

  await progressRef.set(
    {
      stage: education.stage,
      stageId: education.stageId,
      educationScore: education.educationScore,
      lessonsCompleted: education.lessonsCompleted,
      lastTipId: picked.tip.id,
      lastTipAt: FieldValue.serverTimestamp(),
      recentTipIds: nextRecent,
      tipCount,
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  await currentRef.set({
    tipId: picked.tip.id,
    category: picked.tip.category,
    emoji: picked.tip.emoji,
    title: picked.title,
    body: picked.body,
    stage: education.stage,
    stageId: education.stageId,
    educationScore: education.educationScore,
    hourKey,
    dayKey: today,
    locale,
    createdAt: FieldValue.serverTimestamp(),
  });

  // Push only if quota remains (still max 2 engagement/day project-wide).
  if (await hasActiveDevice(uid)) {
    const allowed = await canConsumeDailyQuota(uid, today);
    if (allowed) {
      await sendToUser(
        uid,
        `${picked.tip.emoji} ${picked.title}`,
        picked.body,
        { route: "/home", type: "coach_tip", tipId: picked.tip.id }
      );
    }
  }

  logger.info("coach tip refreshed", {
    uid,
    tipId: picked.tip.id,
    stage: education.stageId,
    hourKey,
  });
}
