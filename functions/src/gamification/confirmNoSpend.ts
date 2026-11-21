import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { SECURE_CALLABLE_OPTIONS, enforceRateLimit, requireAuthUid } from "../shared/security";
import { computeNextStreak, initialGameStatePayload, normalizeGameState } from "../shared/gameState";
import { localDateKey, resolveUserTime } from "../shared/timezone";
import { logger } from "../shared/logger";
import { bumpFriendChallenges } from "../social/challengeProgress";
import { trackReferralActiveDay } from "../referrals/referralReward";

const db = (): Firestore => getFirestore();

/**
 * Callable: "I spent nothing today" (README 5.3). Counts as the day's useful action, so it
 * prolongs the streak, and it makes the day eligible for the "journée sous budget" reward that
 * `dailyRollover` evaluates at the end of the day. It never awards XP by itself.
 *
 * Refused when an expense is already logged today (nothing to confirm). Idempotent per local day.
 */
export const confirmNoSpend = onCall(SECURE_CALLABLE_OPTIONS, async (request) => {
  const uid = requireAuthUid(request);

  await enforceRateLimit({
    uid,
    action: "confirmNoSpend",
    maxRequests: 10,
    windowMs: 60 * 60 * 1000,
  });

  const userRef = db().doc(`users/${uid}`);
  const userSnap = await userRef.get();
  const today = localDateKey(new Date(), resolveUserTime(userSnap.data()));

  const logged = await db()
    .collection(`users/${uid}/transactions`)
    .where("date", "==", today)
    .limit(1)
    .get();
  if (!logged.empty) {
    throw new HttpsError("failed-precondition", "An expense is already logged today.");
  }

  const gameRef = db().doc(`users/${uid}/game/state`);
  const dailyRef = db().doc(`users/${uid}/dailyXp/${today}`);
  const publicRef = db().doc(`publicProfiles/${uid}`);

  const result = await db().runTransaction(async (tx) => {
    const [dailySnap, gameSnap] = await Promise.all([tx.get(dailyRef), tx.get(gameRef)]);
    const base = gameSnap.exists
      ? normalizeGameState(gameSnap.data())
      : normalizeGameState(initialGameStatePayload());

    if (dailySnap.data()?.noSpend === true) {
      return { alreadyConfirmed: true, streak: base.streak.current };
    }

    const { nextStreak } = computeNextStreak(base.streak, today);

    tx.set(
      gameRef,
      {
        xp: base.xp,
        level: base.level,
        gems: base.gems,
        weeklyXp: base.weeklyXp,
        streak: nextStreak,
        badges: base.badges,
        leagueId: base.leagueId,
        // Lets the client hide the "no spending today" button once confirmed.
        noSpendDay: today,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
    tx.set(
      dailyRef,
      { noSpend: true, updatedAt: FieldValue.serverTimestamp() },
      { merge: true }
    );
    tx.set(
      publicRef,
      {
        level: base.level,
        streak: nextStreak.current,
        league: base.leagueId,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
    if (userSnap.exists) {
      tx.set(
        userRef,
        { lastActiveDate: today, lastActiveAt: FieldValue.serverTimestamp() },
        { merge: true }
      );
    }
    return { alreadyConfirmed: false, streak: nextStreak.current };
  });

  if (!result.alreadyConfirmed) {
    await bumpFriendChallenges(uid, "activity_day", today);
    await trackReferralActiveDay(uid, today);
  }

  logger.info("no spend confirmed", { uid, today, ...result });
  return { dayKey: today, ...result };
});
