import { HttpsError, onCall } from "firebase-functions/v2/https";
import { isLessonUnlocked, lessonsToCheck, unitBonusFor } from "../shared/lessonPath";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { CompleteLessonInputSchema } from "../shared/validators";
import { XP_CONFIG, xpToLevel } from "../shared/xpConfig";
import { idempotencyKey, encodeKey } from "../shared/idempotency";
import {
  SECURE_CALLABLE_OPTIONS,
  enforceRateLimit,
  parseInput,
  requireAuthUid,
} from "../shared/security";
import { localDateKey, resolveUserTime } from "../shared/timezone";
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
  const now = new Date();

  const result = await db().runTransaction(async (tx) => {
    const [userSnap, gameSnap, existingProgressSnap] = await Promise.all([
      tx.get(userRef),
      tx.get(gameRef),
      tx.get(lessonProgressRef),
    ]);

    // Everything below that decides unlocking and the unit bonus is read before any write.
    const relatedRefs = lessonsToCheck(lessonId).map((id) =>
      db().doc(`users/${uid}/lessonProgress/${id}`)
    );
    const relatedSnaps = relatedRefs.length > 0 ? await tx.getAll(...relatedRefs) : [];
    const completedBefore = new Set<string>();
    const legacyCompleted: unknown = userSnap.data()?.completedLessonIds;
    if (Array.isArray(legacyCompleted)) {
      for (const id of legacyCompleted as unknown[]) {
        if (typeof id === "string") completedBefore.add(id);
      }
    }
    for (const snap of relatedSnaps) if (snap.exists) completedBefore.add(snap.id);
    if (existingProgressSnap.exists) completedBefore.add(lessonId);

    const today = localDateKey(now, resolveUserTime(userSnap.data()));
    const dailyRef = db().doc(`users/${uid}/dailyXp/${today}`);
    const dailySnap = await tx.get(dailyRef);

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
        unitCompleted: null as string | null,
        unitBonusXp: 0,
        unitBonusSeeds: 0,
      };
    }

    const baseGame = gameSnap.exists
      ? normalizeGameState(gameSnap.data())
      : normalizeGameState(initialGameStatePayload());

    // A fresh `attemptId` can never be used to farm XP: first completion pays once per lesson
    // (lessonId is whitelisted), replays only earn a small practice XP capped per local day.
    const alreadyCompletedBefore = existingProgressSnap.exists;

    // The path is enforced here, not only in the app: a locked lesson earns nothing.
    if (!alreadyCompletedBefore && !isLessonUnlocked(lessonId, completedBefore)) {
      throw new HttpsError(
        "failed-precondition",
        "This lesson is locked: finish the previous lesson first."
      );
    }

    const isPerfect = score === 100;
    const replayXpToday =
      typeof dailySnap.data()?.fromLessonReplays === "number"
        ? (dailySnap.data()?.fromLessonReplays as number)
        : 0;
    const replayXp = Math.max(
      0,
      Math.min(XP_CONFIG.lessonReplay, XP_CONFIG.lessonReplayMax - replayXpToday)
    );
    let xpGained = alreadyCompletedBefore
      ? replayXp
      : isPerfect
        ? XP_CONFIG.lessonPerfect
        : XP_CONFIG.lessonComplete;

    const { nextStreak, streakBonus } = computeNextStreak(baseGame.streak, today);
    if (streakBonus && !alreadyCompletedBefore) {
      xpGained += XP_CONFIG.lessonBonusStreak;
    }

    let seedsGained = alreadyCompletedBefore ? 0 : isPerfect ? 5 : score >= 70 ? 3 : 1;

    // One-time unit bonus, on the first completion of the unit's last missing lesson.
    const unitBonus = unitBonusFor(lessonId, completedBefore);
    if (unitBonus) {
      xpGained += unitBonus.xp;
      seedsGained += unitBonus.seeds;
    }

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

    if (alreadyCompletedBefore && replayXp > 0) {
      tx.set(
        dailyRef,
        {
          fromLessonReplays: replayXpToday + replayXp,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    }

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
        // Latest attempt, next to the best one: the advice notifications read it to see which
        // lessons the learner has not mastered yet.
        lastScore: score,
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
      unitCompleted: unitBonus?.unitId ?? null,
      unitBonusXp: unitBonus?.xp ?? 0,
      unitBonusSeeds: unitBonus?.seeds ?? 0,
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
    unitCompleted: result.unitCompleted,
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
