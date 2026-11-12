import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import { logger } from "../shared/logger";

const db = () => getFirestore();

/**
 * Hourly scheduler: handles end-of-day processing for each user based on
 * their local timezone.
 *
 * Responsibilities:
 *   1. Detect users whose local day just ended (past midnight)
 *   2. Break streaks for users who didn't complete a lesson
 *   3. Apply streak freezes (seeds cost)
 *   4. Expire daily quests
 *   5. Roll over uncompleted daily quests
 */
export const dailyRollover = onSchedule(
  {
    schedule: "every 1 hours",
    region: "us-central1",
    timeoutSeconds: 540,
  },
  async (_event) => {
    const now = new Date();
    const currentHourUtc = now.getUTCHours();

    // We process users whose UTC offset maps to midnight ± 30 min
    // e.g. currentHourUtc=5 → process UTC-5 (EST) users
    const targetOffsets = [-currentHourUtc]; // e.g. if 5 UTC, process UTC-5

    logger.info("dailyRollover started", { currentHourUtc, targetOffsets });

    // Fetch users with matching timezone offsets
    for (const offset of targetOffsets) {
      const usersSnap = await db()
        .collection("users")
        .where("timezoneOffset", "==", offset)
        .limit(500) // process in batches
        .get();

      logger.info("processing rollover batch", { offset, count: usersSnap.size });

      const promises = usersSnap.docs.map((doc) => processUserRollover(doc.id, now));
      await Promise.allSettled(promises);
    }

    logger.info("dailyRollover completed");
  }
);

async function processUserRollover(uid: string, now: Date): Promise<void> {
  const gameRef = db().doc(`users/${uid}/game/state`);
  const gameSnap = await gameRef.get();
  if (!gameSnap.exists) return;

  const game = gameSnap.data() as {
    streak: number;
    lastLessonDate?: string;
    seeds: number;
    freezesAvailable?: number;
  };

  const yesterday = new Date(now);
  yesterday.setDate(yesterday.getDate() - 1);
  const yesterdayKey = yesterday.toISOString().slice(0, 10);

  // Did the user complete a lesson yesterday?
  const lessonDone = game.lastLessonDate === yesterdayKey;

  if (!lessonDone && game.streak > 0) {
    // Check for streak freeze
    const hasFreeze = (game.freezesAvailable ?? 0) > 0;

    if (hasFreeze) {
      // Use a freeze
      await gameRef.update({
        freezesAvailable: FieldValue.increment(-1),
        updatedAt: FieldValue.serverTimestamp(),
      });
      logger.info("streak freeze applied", { uid });
    } else {
      // Break streak
      await gameRef.update({
        streak: 0,
        updatedAt: FieldValue.serverTimestamp(),
      });
      logger.info("streak broken", { uid, wasStreak: game.streak });

      // Record broken streak event for notification
      await db().collection(`users/${uid}/events`).add({
        type: "STREAK_BROKEN",
        wasStreak: game.streak,
        at: FieldValue.serverTimestamp(),
      });
    }
  }

  // ── Expire daily quests ───────────────────────────────────────────────────
  const expiredQuestsSnap = await db()
    .collection(`users/${uid}/quests`)
    .where("type", "==", "daily")
    .where("status", "==", "active")
    .where("expiresAt", "<=", Timestamp.fromDate(now))
    .get();

  const batch = db().batch();
  for (const doc of expiredQuestsSnap.docs) {
    batch.update(doc.ref, { status: "expired" });
  }
  await batch.commit();

  if (expiredQuestsSnap.size > 0) {
    logger.info("expired daily quests", { uid, count: expiredQuestsSnap.size });
  }
}
