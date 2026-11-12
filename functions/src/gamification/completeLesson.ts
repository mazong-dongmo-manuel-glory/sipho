import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { CompleteLessonInputSchema } from "../shared/validators";
import { XP_CONFIG, xpToLevel } from "../shared/xpConfig";
import { idempotencyKey, checkAndMarkIdempotencyKey } from "../shared/idempotency";
import { logger } from "../shared/logger";

const db = () => getFirestore();

/**
 * Callable: validate lesson completion, award XP and seeds, update streak.
 *
 * Client sends: { lessonId, score (0-100), durationSeconds }
 * Server returns: { xpGained, seedsGained, newStreak, levelUp }
 */
export const completeLesson = onCall(
  { region: "us-central1", enforceAppCheck: true },
  async (request) => {
    if (!request.auth) throw new HttpsError("unauthenticated", "Login required");
    const uid = request.auth.uid;

    // Validate input
    const parsed = CompleteLessonInputSchema.safeParse(request.data);
    if (!parsed.success) {
      throw new HttpsError("invalid-argument", parsed.error.message);
    }
    const { lessonId, score, durationSeconds } = parsed.data;

    // Idempotency: use attempt token from client if present, else uid+lesson+day
    const attemptId = (request.data as { attemptId?: string }).attemptId ??
      new Date().toISOString().slice(0, 10);
    const ikey = idempotencyKey("completeLesson", uid, lessonId, attemptId);
    if (await checkAndMarkIdempotencyKey(ikey)) {
      logger.info("completeLesson: duplicate attempt skipped", { uid, lessonId });
      throw new HttpsError("already-exists", "Lesson already completed with this attempt ID");
    }

    // Load game state
    const gameRef = db().doc(`users/${uid}/game/state`);
    const gameSnap = await gameRef.get();
    if (!gameSnap.exists) throw new HttpsError("not-found", "Game state not found");
    const game = gameSnap.data() as {
      xp: number;
      seeds: number;
      level: number;
      streak: number;
      lastLessonDate?: string;
    };

    // ── XP calculation ────────────────────────────────────────────────────────
    const isPerfect = score === 100;
    let xpGained = isPerfect ? XP_CONFIG.lessonPerfect : XP_CONFIG.lessonComplete;

    // Streak bonus
    const today = new Date().toISOString().slice(0, 10);
    const { newStreak, streakBonus } = calculateStreak(game.streak, game.lastLessonDate, today);
    if (streakBonus) xpGained += XP_CONFIG.lessonBonusStreak;

    // ── Seeds (virtual currency for power-ups) ────────────────────────────────
    const seedsGained = isPerfect ? 5 : score >= 70 ? 3 : 1;

    // ── Persist ───────────────────────────────────────────────────────────────
    const oldLevel = game.level;
    const newXp = game.xp + xpGained;
    const newLevel = xpToLevel(newXp);

    const batch = db().batch();
    batch.update(gameRef, {
      xp: FieldValue.increment(xpGained),
      seeds: FieldValue.increment(seedsGained),
      streak: newStreak,
      lastLessonDate: today,
      level: newLevel,
      updatedAt: FieldValue.serverTimestamp(),
    });

    // Record lesson history
    batch.set(db().doc(`users/${uid}/lessonHistory/${lessonId}`), {
      lessonId,
      score,
      durationSeconds,
      completedAt: FieldValue.serverTimestamp(),
      xpGained,
      seedsGained,
    });

    // Update quest progress
    batch.set(db().collection(`users/${uid}/questProgress`).doc(), {
      type: "COMPLETE_LESSON",
      lessonId,
      timestamp: FieldValue.serverTimestamp(),
    });

    await batch.commit();

    logger.info("lesson completed", { uid, lessonId, score, xpGained, newStreak });

    return {
      xpGained,
      seedsGained,
      newStreak,
      levelUp: newLevel > oldLevel,
      newLevel,
    };
  }
);

// ─── Helper ───────────────────────────────────────────────────────────────────

function calculateStreak(
  currentStreak: number,
  lastLessonDate: string | undefined,
  today: string
): { newStreak: number; streakBonus: boolean } {
  if (!lastLessonDate) return { newStreak: 1, streakBonus: false };

  const last = new Date(lastLessonDate);
  const now = new Date(today);
  const diffDays = Math.floor((now.getTime() - last.getTime()) / 86_400_000);

  if (diffDays === 0) {
    // Already completed today — maintain streak, no bonus
    return { newStreak: currentStreak, streakBonus: false };
  } else if (diffDays === 1) {
    // Consecutive day
    const newStreak = currentStreak + 1;
    return { newStreak, streakBonus: newStreak >= 7 };
  } else {
    // Streak broken
    return { newStreak: 1, streakBonus: false };
  }
}
