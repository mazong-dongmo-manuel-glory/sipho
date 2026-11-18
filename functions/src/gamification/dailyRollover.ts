import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { normalizeGameState } from "../shared/gameState";
import { deadlineGuard, forEachDocument } from "../shared/pagination";
import { ensureDailyQuests, expireDailyQuests } from "../shared/dailyQuests";
import { awardBudgetDayIfEarned } from "./budgetDay";
import {
  localDateKey,
  offsetRangesForLocalWindow,
  resolveUserTime,
  shiftDateKey,
} from "../shared/timezone";
import { logger } from "../shared/logger";

const db = (): Firestore => getFirestore();

const TIMEOUT_SECONDS = 540;

/**
 * Users whose (stored) UTC offset puts them between 00:00 and 03:00 local are examined each hour.
 * The window is deliberately wider than one run: the stored offset can lag behind a DST change,
 * and `lastRolloverDay` makes each user's rollover run exactly once per local day regardless.
 */
const ROLLOVER_WINDOW_START_MINUTE = 0;
const ROLLOVER_WINDOW_END_MINUTE = 3 * 60;

/**
 * Hourly scheduler: end-of-day streak & daily-quest rollover per user's local day.
 *
 * Users are paginated (no 500-user cap) and located by `utcOffsetMinutes` (half-hour zones
 * supported); the day boundary itself is computed from the IANA `timezone` (DST-correct).
 */
export const dailyRollover = onSchedule(
  {
    schedule: "every 1 hours",
    region: "us-central1",
    timeoutSeconds: TIMEOUT_SECONDS,
  },
  async (_event) => {
    const now = new Date();
    const shouldStop = deadlineGuard(TIMEOUT_SECONDS);
    const ranges = offsetRangesForLocalWindow(
      now,
      ROLLOVER_WINDOW_START_MINUTE,
      ROLLOVER_WINDOW_END_MINUTE
    );
    logger.info("dailyRollover started", { ranges: JSON.stringify(ranges) });

    let processed = 0;
    let failed = 0;
    for (const [lo, hi] of ranges) {
      const result = await forEachDocument(
        db()
          .collection("users")
          .where("utcOffsetMinutes", ">=", lo)
          .where("utcOffsetMinutes", "<=", hi),
        (doc) => processUserRollover(doc.id, doc.data(), now),
        { label: "dailyRollover", shouldStop }
      );
      processed += result.processed;
      failed += result.failed;
      if (result.stoppedEarly) break;
    }

    logger.info("dailyRollover completed", { processed, failed });
  }
);

export async function processUserRollover(
  uid: string,
  userData: Record<string, unknown>,
  now: Date
): Promise<void> {
  const time = resolveUserTime(userData);
  const todayKey = localDateKey(now, time);
  const yesterdayKey = shiftDateKey(todayKey, -1);
  const locale = userData.locale === "en" ? "en" : "fr";

  const gameRef = db().doc(`users/${uid}/game/state`);
  const publicRef = db().doc(`publicProfiles/${uid}`);

  const gameProbe = await gameRef.get();
  if (gameProbe.exists && gameProbe.data()?.lastRolloverDay === todayKey) return;

  // Quests first: idempotent (deterministic ids), so a failure below just retries next hour.
  await expireDailyQuests(db(), uid, now);
  await ensureDailyQuests(db(), uid, time, locale, now);

  // "Journée sous budget" for the day that just ended. Idempotent (marker per day); a failure
  // here must never block the streak below, so it is logged and skipped.
  try {
    await awardBudgetDayIfEarned(uid, userData, yesterdayKey);
  } catch (err) {
    logger.error("budget day evaluation failed", { uid, dayKey: yesterdayKey, err: String(err) });
  }

  if (!gameProbe.exists) return;

  // Streak + marker in ONE transaction so a retry can never consume a freeze twice.
  await db().runTransaction(async (tx) => {
    const snap = await tx.get(gameRef);
    if (!snap.exists || snap.data()?.lastRolloverDay === todayKey) return;

    const game = normalizeGameState(snap.data());
    const activeRecently =
      game.streak.lastActiveDay === yesterdayKey || game.streak.lastActiveDay === todayKey;

    if (!activeRecently && game.streak.current > 0) {
      if (game.streak.freezes > 0) {
        tx.update(gameRef, {
          "streak.freezes": game.streak.freezes - 1,
          "streak.lastActiveDay": yesterdayKey,
          lastRolloverDay: todayKey,
          updatedAt: FieldValue.serverTimestamp(),
        });
        logger.info("streak freeze applied", { uid });
      } else {
        const brokenAt = now.toISOString();
        tx.update(gameRef, {
          "streak.current": 0,
          "streak.brokenAt": brokenAt,
          "streak.brokenCurrent": game.streak.current,
          lastRolloverDay: todayKey,
          updatedAt: FieldValue.serverTimestamp(),
        });
        tx.set(
          publicRef,
          { streak: 0, updatedAt: FieldValue.serverTimestamp() },
          { merge: true }
        );
        tx.set(db().collection(`users/${uid}/events`).doc(), {
          type: "STREAK_BROKEN",
          wasStreak: game.streak.current,
          at: FieldValue.serverTimestamp(),
        });
        logger.info("streak broken", { uid, wasStreak: game.streak.current });
      }
      return;
    }

    tx.update(gameRef, { lastRolloverDay: todayKey });
  });
}
