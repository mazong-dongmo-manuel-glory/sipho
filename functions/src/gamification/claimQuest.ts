import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { z } from "zod";
import { xpToLevel } from "../shared/xpConfig";
import { initialGameStatePayload, normalizeGameState } from "../shared/gameState";
import {
  SECURE_CALLABLE_OPTIONS,
  enforceRateLimit,
  parseInput,
  requireAuthUid,
} from "../shared/security";
import { logger } from "../shared/logger";
import { classifyClaim, questRewardGems, questRewardXp } from "../shared/questClaim";

const db = (): Firestore => getFirestore();

const ClaimQuestInputSchema = z.object({
  questId: z
    .string()
    .trim()
    .min(1)
    .max(100)
    .regex(/^[a-zA-Z0-9_-]+$/, "Invalid questId"),
});

/**
 * Callable: atomically claims a completed quest from `users/{uid}/quests/{questId}`
 * and awards server-side XP + gems/seeds into `users/{uid}/game/state`.
 */
export const claimQuest = onCall(SECURE_CALLABLE_OPTIONS, async (request) => {
  const uid = requireAuthUid(request);
  const { questId } = parseInput(ClaimQuestInputSchema, request.data);

  await enforceRateLimit({
    uid,
    action: "claimQuest",
    maxRequests: 30,
    windowMs: 60 * 60 * 1000,
  });

  const questRef = db().doc(`users/${uid}/quests/${questId}`);
  const gameRef = db().doc(`users/${uid}/game/state`);
  const publicRef = db().doc(`publicProfiles/${uid}`);

  const outcome = await db().runTransaction(async (tx) => {
    const [questSnap, gameSnap] = await Promise.all([
      tx.get(questRef),
      tx.get(gameRef),
    ]);

    if (!questSnap.exists) {
      throw new HttpsError("not-found", "Quest not found.");
    }

    const qData = questSnap.data() as {
      status?: unknown;
      progress?: unknown;
      target?: unknown;
      rewardXp?: unknown;
      rewardGems?: unknown;
    };

    const decision = classifyClaim(qData);
    if (decision === "already-claimed") {
      return { xpGained: 0, gemsGained: 0, levelUp: false, alreadyClaimed: true };
    }
    if (decision === "expired") {
      throw new HttpsError("failed-precondition", "Quest has expired.");
    }
    if (decision === "not-completed") {
      throw new HttpsError("failed-precondition", "Quest is not completed yet.");
    }

    const rewardXp = questRewardXp(qData.rewardXp);
    const rewardGems = questRewardGems(qData.rewardGems);

    const baseGame = gameSnap.exists
      ? normalizeGameState(gameSnap.data())
      : normalizeGameState(initialGameStatePayload());

    const newXp = baseGame.xp + rewardXp;
    const newLevel = xpToLevel(newXp);
    const levelUp = newLevel > baseGame.level;

    tx.update(questRef, {
      status: "claimed",
      claimedAt: FieldValue.serverTimestamp(),
    });

    tx.set(
      gameRef,
      {
        xp: newXp,
        level: newLevel,
        gems: baseGame.gems + rewardGems,
        weeklyXp: baseGame.weeklyXp + rewardXp,
        streak: baseGame.streak,
        leagueId: baseGame.leagueId,
        badges: baseGame.badges,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    tx.set(
      publicRef,
      {
        level: newLevel,
        streak: baseGame.streak.current,
        league: baseGame.leagueId,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return {
      xpGained: rewardXp,
      gemsGained: rewardGems,
      levelUp,
      alreadyClaimed: false,
    };
  });

  logger.info("quest claimed", {
    uid,
    questId,
    xpGained: outcome.xpGained,
    alreadyClaimed: outcome.alreadyClaimed,
  });

  return outcome;
});
