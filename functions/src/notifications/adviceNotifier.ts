import { onSchedule } from "firebase-functions/v2/scheduler";
import { FieldValue } from "firebase-admin/firestore";
import { normalizeGameState } from "../shared/gameState";
import { deadlineGuard } from "../shared/pagination";
import {
  localDateKey,
  localMinuteOfDay,
  minuteInWindow,
  resolveUserTime,
  shiftDateKey,
} from "../shared/timezone";
import { readMonthlyIncomeCents, effectiveTransactionCents } from "../shared/budgetDay";
import {
  ADVICE_MIN_GAP_DAYS,
  AdviceFocus,
  AdviceInput,
  LessonResultSummary,
  RecentAdvice,
  buildAdviceContext,
  chooseAdviceFocus,
  dateKeyDiffDays,
} from "../shared/advice";
import { logger } from "../shared/logger";
import { callGeminiJson } from "../ai/geminiClient";
import {
  UserProfile,
  canConsumeDailyQuota,
  db,
  forEachUserInLocalWindow,
  hasActiveDevice,
  isQuietHour,
  sendToUser,
} from "./delivery";
import { AdviceAi, composeAdvice } from "./adviceCompose";

const TIMEOUT_SECONDS = 540;

/** Lunch time, local: a calm moment, away from the 18:00 streak reminder. */
const ADVICE_WINDOW: [number, number] = [12 * 60, 14 * 60];

/**
 * Personalised advice push, every 15 minutes for the users whose local time is inside the window.
 *
 * Only users who turned "tips" on and finished onboarding are visited. What to talk about comes
 * from rules over their real data (budget, spending, goal, lesson results, what was said
 * recently); the AI only words it, with aggregated figures and no free text or identity. A push
 * is sent at most every {@link ADVICE_MIN_GAP_DAYS} days and counts toward the daily push cap.
 */
export const adviceNotifier = onSchedule(
  {
    schedule: "every 15 minutes",
    region: "us-central1",
    timeoutSeconds: TIMEOUT_SECONDS,
    memory: "512MiB",
  },
  async (_event) => {
    const now = new Date();
    const shouldStop = deadlineGuard(TIMEOUT_SECONDS);
    await forEachUserInLocalWindow(now, ADVICE_WINDOW, "adviceNotifier", shouldStop, (uid, profile) =>
      maybeSendAdvice(uid, profile, now, geminiAdviceAi)
    );
  }
);

/** The real model call. Returns null (so the template is used) when no API key is configured. */
const geminiAdviceAi: AdviceAi = async (prompt) => {
  const apiKey = process.env.GEMINI_API_KEY ?? "";
  if (!apiKey) return null;
  return callGeminiJson({
    apiKey,
    parts: [{ text: prompt }],
    maxOutputTokens: 512,
    contextLabel: "adviceNotifier",
  });
};

export async function maybeSendAdvice(
  uid: string,
  profile: UserProfile,
  now: Date,
  ai: AdviceAi
): Promise<void> {
  const raw = profile as unknown as Record<string, unknown>;
  if (profile.notifPrefs?.tips !== true) return;
  if (raw.onboardingDone !== true) return;

  const time = resolveUserTime(raw);
  if (!minuteInWindow(localMinuteOfDay(now, time), ADVICE_WINDOW[0], ADVICE_WINDOW[1])) return;
  if (isQuietHour(now, time)) return;

  const today = localDateKey(now, time);
  const stateRef = db().doc(`users/${uid}/notifState/advice`);
  const lastSent: unknown = (await stateRef.get()).data()?.lastSentDate;
  if (typeof lastSent === "string" && dateKeyDiffDays(today, lastSent) < ADVICE_MIN_GAP_DAYS) {
    return;
  }

  if (!(await hasActiveDevice(uid))) return;

  const [input, history] = await Promise.all([
    loadAdviceInput(uid, raw, today),
    loadAdviceHistory(uid, today),
  ]);
  const { recent, recentTitles } = history;
  const ctx = buildAdviceContext(input);
  const focus = chooseAdviceFocus(ctx, recent);
  if (!focus) return;

  if (!(await canConsumeDailyQuota(uid, today))) return;

  const locale = profile.locale === "en" ? "en" : "fr";
  const advice = await composeAdvice({ ai, focus, ctx, locale, recentTitles });
  if (advice.rejected.length > 0) {
    logger.warn("advice AI answer not used", { uid, focus, reasons: advice.rejected });
  }

  await Promise.all([
    db().collection(`users/${uid}/adviceHistory`).add({
      day: today,
      focus,
      title: advice.title,
      body: advice.body,
      source: advice.source,
      locale,
      createdAt: FieldValue.serverTimestamp(),
    }),
    // Same advice on the app's coach card, so tapping the push lands on matching content.
    db().doc(`users/${uid}/insights/advice_${today}`).set({
      title: advice.title,
      content: advice.body,
      recommendedLessonId: advice.recommendedLessonId,
      focusTopic: insightTopic(focus),
      locale,
      dismissed: false,
      source: "push_advice",
      createdAt: FieldValue.serverTimestamp(),
    }),
    stateRef.set({ lastSentDate: today }, { merge: true }),
  ]);

  await sendToUser(uid, advice.title, advice.body, {
    type: "ADVICE",
    focus,
    route: advice.route,
  });
  logger.info("advice sent", { uid, focus, source: advice.source });
}

function insightTopic(focus: AdviceFocus): "spending" | "goal" | "general" {
  if (focus === "budget_over" || focus === "top_category" || focus === "no_tracking") {
    return "spending";
  }
  return focus === "goal" ? "goal" : "general";
}

/** Reads the learner's facts: integer cents, lesson scores, goal. No free text, no identity. */
async function loadAdviceInput(
  uid: string,
  userData: Record<string, unknown>,
  today: string
): Promise<AdviceInput> {
  const monthStart = `${today.slice(0, 7)}-01`;
  const weekStart = shiftDateKey(today, -7);

  const [fixedSnap, monthSnap, weekSnap, progressSnap, gameSnap] = await Promise.all([
    db().collection(`users/${uid}/fixedExpenses`).where("active", "==", true).get(),
    db()
      .collection(`users/${uid}/transactions`)
      .where("date", ">=", monthStart)
      .where("date", "<=", today)
      .get(),
    db().collection(`users/${uid}/transactions`).where("date", ">=", weekStart).limit(1).get(),
    db().collection(`users/${uid}/lessonProgress`).get(),
    db().doc(`users/${uid}/game/state`).get(),
  ]);

  let fixedCents = 0;
  for (const doc of fixedSnap.docs) {
    const amount: unknown = doc.data().amountCents;
    if (typeof amount === "number" && amount > 0) fixedCents += Math.trunc(amount);
  }

  let variableCents = 0;
  let monthTransactionCount = 0;
  const categoryCents: Record<string, number> = {};
  for (const doc of monthSnap.docs) {
    const data = doc.data();
    const cents = effectiveTransactionCents(data);
    if (cents <= 0) continue;
    const category = typeof data.category === "string" ? data.category : "other";
    categoryCents[category] = (categoryCents[category] ?? 0) + cents;
    variableCents += cents;
    monthTransactionCount++;
  }

  const lessons: LessonResultSummary[] = progressSnap.docs.map((doc) => {
    const data = doc.data();
    const best = typeof data.bestScore === "number" ? data.bestScore : 100;
    return {
      lessonId: doc.id,
      // Older records have no `lastScore`: their best score is the best guess.
      lastScore: typeof data.lastScore === "number" ? data.lastScore : best,
      bestScore: best,
      attempts: typeof data.attempts === "number" ? data.attempts : 1,
    };
  });

  const completed = Array.isArray(userData.completedLessonIds)
    ? userData.completedLessonIds.filter((x): x is string => typeof x === "string")
    : [];

  return {
    incomeCents: readMonthlyIncomeCents(userData),
    fixedCents,
    variableCents,
    categoryCents,
    monthTransactionCount,
    loggedLastWeek: !weekSnap.empty,
    currency: typeof userData.currency === "string" ? userData.currency : "CAD",
    goal: typeof userData.goal === "string" ? userData.goal : "",
    completedLessonIds: completed,
    lessons,
    streak: normalizeGameState(gameSnap.data()).streak.current,
  };
}

/** What was said lately: the focuses (to respect cooldowns) and the last titles (to vary wording). */
async function loadAdviceHistory(
  uid: string,
  today: string
): Promise<{ recent: RecentAdvice[]; recentTitles: string[] }> {
  const snap = await db()
    .collection(`users/${uid}/adviceHistory`)
    .orderBy("createdAt", "desc")
    .limit(8)
    .get();
  const recent: RecentAdvice[] = [];
  const recentTitles: string[] = [];
  for (const doc of snap.docs) {
    const data = doc.data();
    if (typeof data.title === "string" && recentTitles.length < 3) recentTitles.push(data.title);
    if (typeof data.day !== "string" || typeof data.focus !== "string") continue;
    recent.push({
      focus: data.focus as AdviceFocus,
      daysAgo: Math.max(0, dateKeyDiffDays(today, data.day)),
    });
  }
  return { recent, recentTitles };
}
