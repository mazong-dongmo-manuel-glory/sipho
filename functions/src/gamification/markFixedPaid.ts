import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { MarkFixedPaidInputSchema } from "../shared/validators";
import { XP_CONFIG, xpToLevel } from "../shared/xpConfig";
import { idempotencyKey, encodeKey } from "../shared/idempotency";
import {
  SECURE_CALLABLE_OPTIONS,
  enforceRateLimit,
  parseInput,
  requireAuthUid,
} from "../shared/security";
import { initialGameStatePayload, normalizeGameState } from "../shared/gameState";
import { logger } from "../shared/logger";

const db = (): Firestore => getFirestore();

/**
 * Callable: mark a fixed expense from `users/{uid}/fixedExpenses/{fixedId}`
 * as paid for `monthKey` and award server-side XP once per month.
 */
export const markFixedPaid = onCall(SECURE_CALLABLE_OPTIONS, async (request) => {
  const uid = requireAuthUid(request);
  const { fixedId, monthKey } = parseInput(MarkFixedPaidInputSchema, request.data);

  await enforceRateLimit({
    uid,
    action: "markFixedPaid",
    maxRequests: 30,
    windowMs: 60 * 60 * 1000,
  });

  const fixedRef = db().doc(`users/${uid}/fixedExpenses/${fixedId}`);
  const monthFixedRef = db().doc(`users/${uid}/months/${monthKey}/fixed/${fixedId}`);
  const monthRef = db().doc(`users/${uid}/months/${monthKey}`);
  const gameRef = db().doc(`users/${uid}/game/state`);
  const idemKey = idempotencyKey("markFixedPaid", uid, fixedId, monthKey);
  const idemRef = db().collection("_idempotency").doc(encodeKey(idemKey));

  const outcome = await db().runTransaction(async (tx) => {
    const [fixedSnap, idemSnap, gameSnap] = await Promise.all([
      tx.get(fixedRef),
      tx.get(idemRef),
      tx.get(gameRef),
    ]);

    if (!fixedSnap.exists) {
      throw new HttpsError("not-found", "Fixed expense not found.");
    }

    if (idemSnap.exists) {
      return { xpGained: 0, levelUp: false, alreadyPaid: true };
    }

    const baseGame = gameSnap.exists
      ? normalizeGameState(gameSnap.data())
      : normalizeGameState(initialGameStatePayload());

    const xpGained = XP_CONFIG.fixedPaid;
    const newXp = baseGame.xp + xpGained;
    const newLevel = xpToLevel(newXp);
    const levelUp = newLevel > baseGame.level;

    tx.set(idemRef, {
      key: idemKey,
      processedAt: FieldValue.serverTimestamp(),
    });

    tx.set(
      monthFixedRef,
      { paidAt: FieldValue.serverTimestamp(), paid: true },
      { merge: true }
    );

    tx.set(
      monthRef,
      {
        [`fixedPaid.${fixedId}.paid`]: true,
        [`fixedPaid.${fixedId}.paidAt`]: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    tx.set(
      gameRef,
      {
        xp: newXp,
        level: newLevel,
        gems: baseGame.gems,
        weeklyXp: baseGame.weeklyXp + xpGained,
        streak: baseGame.streak,
        leagueId: baseGame.leagueId,
        badges: baseGame.badges,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return { xpGained, levelUp, alreadyPaid: false };
  });

  logger.info("fixed expense marked paid", {
    uid,
    fixedId,
    monthKey,
    xpGained: outcome.xpGained,
    alreadyPaid: outcome.alreadyPaid,
  });

  return outcome;
});
