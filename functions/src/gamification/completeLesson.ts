import { onCall } from "firebase-functions/v2/https";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { CompleteLessonInputSchema } from "../shared/validators";
import { XP_CONFIG, xpToLevel } from "../shared/xpConfig";
import { idempotencyKey, encodeKey } from "../shared/idempotency";
import {
  SECURE_CALLABLE_OPTIONS,
  enforceRateLimit,
  parseInput,
  requireAuthUid,
  userLocalDateKey,
} from "../shared/security";
import {
  computeNextStreak,
  initialGameStatePayload,
  normalizeGameState,
} from "../shared/gameState";
import { logger } from "../shared/logger";

const db = (): Firestore => getFirestore();

/**
 * Callable: validate lesson completion, award XP and gems/seeds, update streak,
 * and sync public profile without ever exposing money amounts.
 */
export const completeLesson = onCall(SECURE_CALLABLE_OPTIONS, async (request) => {
  const uid = requireAuthUid(request);
  const { lessonId, score, durationSeconds, attemptId } = parseInput(
    CompleteLessonInputSchema,
    request.data
  );

  await enforceRateLimit({
    uid,
    action: "completeLesson",
    maxRequests: 25,
    windowMs: 60 * 60 * 1000,
  });

  const userRef = db().doc(`users/${uid}`);
  const gameRef = db().doc(`users/${uid}/game/state`);
  const lessonProgressRef = db().doc(`users/${uid}/lessonProgress/${lessonId}`);
  const lessonHistoryRef = db().doc(`users/${uid}/lessonHistory/${lessonId}`);
  const publicRef = db().doc(`publicProfiles/${uid}`);

  const result = await db().runTransaction(async (tx) => {
    const [userSnap, gameSnap, existingProgressSnap] = await Promise.all([
      tx.get(userRef),
      tx.get(gameRef),
      tx.get(lessonProgressRef),
    ]);

    const tzOffset =
      typeof userSnap.data()?.timezoneOffset === "number"
        ? (userSnap.data()?.timezoneOffset as number)
        : 0;
    const today = userLocalDateKey(new Date(), tzOffset);

    const idemKey = idempotencyKey("completeLesson", uid, lessonId, attemptId ?? today);
    const idemRef = db().collection("_idempotency").doc(encodeKey(idemKey));
    const idemSnap = await tx.get(idemRef);
    if (idemSnap.exists) {
      const currentGame = normalizeGameState(gameSnap.data());
      return {
        xpGained: 0,
        seedsGained: 0,
        newStreak: currentGame.streak.current,
        levelUp: false,
        newLevel: currentGame.level,
        alreadyCompleted: true,
      };
    }

    const baseGame = gameSnap.exists
      ? normalizeGameState(gameSnap.data())
      : normalizeGameState(initialGameStatePayload());

    // Replay of an already-mastered lesson gives capped practice XP (prevents XP farming).
    const alreadyCompletedBefore = existingProgressSnap.exists;
    const isPerfect = score === 100;
    let xpGained = alreadyCompletedBefore
      ? 2
      : isPerfect
        ? XP_CONFIG.lessonPerfect
        : XP_CONFIG.lessonComplete;

    const { nextStreak, streakBonus } = computeNextStreak(baseGame.streak, today);
    if (streakBonus && !alreadyCompletedBefore) {
      xpGained += XP_CONFIG.lessonBonusStreak;
    }

    const seedsGained = alreadyCompletedBefore ? 0 : isPerfect ? 5 : score >= 70 ? 3 : 1;
    const newXp = baseGame.xp + xpGained;
    const newLevel = xpToLevel(newXp);
    const levelUp = newLevel > baseGame.level;

    tx.set(idemRef, {
      key: idemKey,
      processedAt: FieldValue.serverTimestamp(),
    });

    tx.set(
      gameRef,
      {
        xp: newXp,
        level: newLevel,
        gems: baseGame.gems + seedsGained,
        weeklyXp: baseGame.weeklyXp + xpGained,
        streak: nextStreak,
        badges: baseGame.badges,
        leagueId: baseGame.leagueId,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    tx.set(
      lessonProgressRef,
      {
        lessonId,
        bestScore: Math.max(
          score,
          typeof existingProgressSnap.data()?.bestScore === "number"
            ? (existingProgressSnap.data()?.bestScore as number)
            : 0
        ),
        attempts: FieldValue.increment(1),
        lastDurationSeconds: durationSeconds,
        completedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    tx.set(lessonHistoryRef, {
      lessonId,
      score,
      durationSeconds,
      completedAt: FieldValue.serverTimestamp(),
      xpGained,
      seedsGained,
    });

    if (userSnap.exists) {
      tx.update(userRef, {
        completedLessonIds: FieldValue.arrayUnion(lessonId),
        lastActiveDate: today,
        lastActiveAt: FieldValue.serverTimestamp(),
      });
    }

    tx.set(
      publicRef,
      {
        level: newLevel,
        streak: nextStreak.current,
        league: baseGame.leagueId,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return {
      xpGained,
      seedsGained,
      newStreak: nextStreak.current,
      levelUp,
      newLevel,
      alreadyCompleted: false,
    };
  });

  if (!result.alreadyCompleted) {
    await advanceLessonQuests(uid);
  }

  logger.info("lesson completed", {
    uid,
    lessonId,
    score,
    xpGained: result.xpGained,
    newStreak: result.newStreak,
  });

  return result;
});

async function advanceLessonQuests(uid: string): Promise<void> {
  const snap = await db()
    .collection(`users/${uid}/quests`)
    .where("type", "in", ["COMPLETE_LESSON", "daily_lesson"])
    .where("status", "==", "active")
    .limit(5)
    .get();

  if (snap.empty) return;

  const batch = db().batch();
  for (const doc of snap.docs) {
    const data = doc.data() as { target?: number; progress?: number };
    const target = Math.max(1, data.target ?? 1);
    const next = Math.min(target, (data.progress ?? 0) + 1);
    batch.update(doc.ref, {
      progress: next,
      ...(next >= target
        ? { status: "completed", completedAt: FieldValue.serverTimestamp() }
        : {}),
    });
  }
  await batch.commit();
}
