import { HttpsError, onCall } from "firebase-functions/v2/https";
import {
  isCountryLesson,
  isCountryLessonAllowed,
  isLessonUnlocked,
  lessonsToCheck,
  unitBonusFor,
} from "../shared/lessonPath";
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
import { bumpFriendChallenges } from "../social/challengeProgress";
import { trackReferralActiveDay } from "../referrals/referralReward";

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

    const idemKey = idempotencyKey("completeLesson", uid, lessonId, attemptId);
    const idemRef = db().collection("_idempotency").doc(encodeKey(idemKey));
    const idemSnap = await tx.get(idemRef);
    if (idemSnap.exists) {
      const stored = idemSnap.data() as {
        hooksDone?: unknown;
        firstCompletion?: unknown;
        dayKey?: unknown;
        result?: Record<string, unknown>;
      };
      const currentGame = normalizeGameState(gameSnap.data());
      const cached = stored.result ?? {};
      return {
        xpGained: typeof cached.xpGained === "number" ? cached.xpGained : 0,
        seedsGained: typeof cached.seedsGained === "number" ? cached.seedsGained : 0,
        newStreak:
          typeof cached.newStreak === "number"
            ? cached.newStreak
            : currentGame.streak.current,
        levelUp: cached.levelUp === true,
        newLevel:
          typeof cached.newLevel === "number" ? cached.newLevel : currentGame.level,
        alreadyCompleted: true,
        firstCompletion: stored.firstCompletion === true,
        unitCompleted:
          typeof cached.unitCompleted === "string" ? cached.unitCompleted : null,
        unitBonusXp: typeof cached.unitBonusXp === "number" ? cached.unitBonusXp : 0,
        unitBonusSeeds:
          typeof cached.unitBonusSeeds === "number" ? cached.unitBonusSeeds : 0,
        dayKey: typeof stored.dayKey === "string" ? stored.dayKey : today,
        hooksDone: stored.hooksDone === true,
        idemKey,
      };
    }

    const baseGame = gameSnap.exists
      ? normalizeGameState(gameSnap.data())
      : normalizeGameState(initialGameStatePayload());

    // A fresh `attemptId` can never be used to farm XP: first completion pays once per lesson
    // (lessonId is whitelisted), replays only earn a small practice XP capped per local day.
    const alreadyCompletedBefore = existingProgressSnap.exists;

    // Country modules: only for the user's country (or generic `*`).
    if (isCountryLesson(lessonId)) {
      const countryCode =
        typeof userSnap.data()?.countryCode === "string"
          ? (userSnap.data()?.countryCode as string)
          : null;
      if (!isCountryLessonAllowed(lessonId, countryCode)) {
        throw new HttpsError(
          "failed-precondition",
          "This lesson is not available for your country."
        );
      }
    }

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

    const clientPayload = {
      xpGained,
      seedsGained,
      newStreak: nextStreak.current,
      levelUp,
      newLevel,
      alreadyCompleted: false,
      firstCompletion: !alreadyCompletedBefore,
      unitCompleted: unitBonus?.unitId ?? null,
      unitBonusXp: unitBonus?.xp ?? 0,
      unitBonusSeeds: unitBonus?.seeds ?? 0,
    };

    tx.set(idemRef, {
      key: idemKey,
      processedAt: FieldValue.serverTimestamp(),
      hooksDone: false,
      firstCompletion: !alreadyCompletedBefore,
      dayKey: today,
      result: clientPayload,
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
      ...clientPayload,
      dayKey: today,
      hooksDone: false,
      idemKey,
    };
  });

  // Post-TX hooks are re-runnable when the same attemptId retries after a crash.
  // Quest/challenge bumps are gated by a per-attempt hook marker so retries never double-count.
  const needsHooks = result.hooksDone !== true;
  if (needsHooks) {
    const hooksMarkerRef = db()
      .collection("_idempotency")
      .doc(encodeKey(idempotencyKey("completeLessonHooks", uid, lessonId, attemptId)));
    let runHooks = false;
    try {
      await hooksMarkerRef.create({ processedAt: FieldValue.serverTimestamp() });
      runHooks = true;
    } catch (err) {
      // ALREADY_EXISTS: another retry already claimed the hooks for this attemptId.
      if ((err as { code?: number }).code !== 6) throw err;
    }
    if (runHooks) {
      await advanceLessonQuests(uid);
      if (result.firstCompletion) {
        await bumpFriendChallenges(uid, "lesson_complete");
      }
      if (typeof result.dayKey === "string") {
        await trackReferralActiveDay(uid, result.dayKey);
      }
    }
    if (typeof result.idemKey === "string") {
      await db()
        .collection("_idempotency")
        .doc(encodeKey(result.idemKey))
        .set({ hooksDone: true }, { merge: true });
    }
  }

  logger.info("lesson completed", {
    uid,
    lessonId,
    score,
    attemptId,
    xpGained: result.xpGained,
    newStreak: result.newStreak,
    unitCompleted: result.unitCompleted,
    hooksReplayed: result.alreadyCompleted && needsHooks,
  });

  // Strip internal hook fields from the callable response.
  const {
    dayKey: _dayKey,
    hooksDone: _hooksDone,
    idemKey: _idemKey,
    ...clientResult
  } = result as typeof result & {
    dayKey?: string;
    hooksDone?: boolean;
    idemKey?: string;
  };
  return clientResult;
});

async function advanceLessonQuests(uid: string): Promise<void> {
  const snap = await db()
    .collection(`users/${uid}/quests`)
    .where("type", "in", ["COMPLETE_LESSON", "daily_lesson"])
    .where("status", "==", "active")
    .limit(5)
    .get();

  if (snap.empty) return;

  await Promise.all(
    snap.docs.map((doc) =>
      db().runTransaction(async (tx) => {
        const live = await tx.get(doc.ref);
        if (!live.exists) return;
        const data = live.data() as {
          status?: string;
          target?: number;
          progress?: number;
        };
        if (data.status !== "active") return;
        const target = Math.max(1, data.target ?? 1);
        const next = Math.min(target, (data.progress ?? 0) + 1);
        tx.update(doc.ref, {
          progress: next,
          ...(next >= target
            ? { status: "completed", completedAt: FieldValue.serverTimestamp() }
            : {}),
        });
      })
    )
  );
}
