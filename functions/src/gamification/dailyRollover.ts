import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore, FieldValue, Firestore, Timestamp } from "firebase-admin/firestore";
import { normalizeGameState } from "../shared/gameState";
import { userLocalDateKey } from "../shared/security";
import { logger } from "../shared/logger";

const db = (): Firestore => getFirestore();

/**
 * Hourly scheduler: end-of-day streak & quest rollover per user's local timezone.
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
    const targetOffsets = [-currentHourUtc, 24 - currentHourUtc].filter(
      (offset) => offset >= -12 && offset <= 14
    );

    logger.info("dailyRollover started", { currentHourUtc, targetOffsets });

    for (const offset of targetOffsets) {
      const usersSnap = await db()
        .collection("users")
        .where("timezoneOffset", "==", offset)
        .limit(500)
        .get();

      logger.info("processing rollover batch", { offset, count: usersSnap.size });

      await Promise.allSettled(
        usersSnap.docs.map((doc) => processUserRollover(doc.id, offset, now))
      );
    }

    logger.info("dailyRollover completed");
  }
);

async function processUserRollover(
  uid: string,
  offsetHours: number,
  now: Date
): Promise<void> {
  const gameRef = db().doc(`users/${uid}/game/state`);
  const publicRef = db().doc(`publicProfiles/${uid}`);
  const gameSnap = await gameRef.get();
  if (!gameSnap.exists) return;

  const game = normalizeGameState(gameSnap.data());
  const yesterday = new Date(now.getTime() - 86_400_000);
  const yesterdayKey = userLocalDateKey(yesterday, offsetHours);
  const todayKey = userLocalDateKey(now, offsetHours);

  const activeRecently =
    game.streak.lastActiveDay === yesterdayKey ||
    game.streak.lastActiveDay === todayKey;

  if (!activeRecently && game.streak.current > 0) {
    if (game.streak.freezes > 0) {
      await gameRef.update({
        "streak.freezes": game.streak.freezes - 1,
        "streak.lastActiveDay": yesterdayKey,
        updatedAt: FieldValue.serverTimestamp(),
      });
      logger.info("streak freeze applied", { uid });
    } else {
      const wasStreak = game.streak.current;
      await Promise.all([
        gameRef.update({
          "streak.current": 0,
          updatedAt: FieldValue.serverTimestamp(),
        }),
        publicRef.set(
          { streak: 0, updatedAt: FieldValue.serverTimestamp() },
          { merge: true }
        ),
        db().collection(`users/${uid}/events`).add({
          type: "STREAK_BROKEN",
          wasStreak,
          at: FieldValue.serverTimestamp(),
        }),
      ]);
      logger.info("streak broken", { uid, wasStreak });
    }
  }

  const expiredQuestsSnap = await db()
    .collection(`users/${uid}/quests`)
    .where("type", "==", "daily")
    .where("status", "==", "active")
    .where("expiresAt", "<=", Timestamp.fromDate(now))
    .get();

  if (!expiredQuestsSnap.empty) {
    const batch = db().batch();
    for (const doc of expiredQuestsSnap.docs) {
      batch.update(doc.ref, { status: "expired" });
    }
    await batch.commit();
    logger.info("expired daily quests", { uid, count: expiredQuestsSnap.size });
  }
}
