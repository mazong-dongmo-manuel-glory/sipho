import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { normalizeGameState, repairStreakState } from "../shared/gameState";
import { localDateKey, resolveUserTime } from "../shared/timezone";
import {
  SECURE_CALLABLE_OPTIONS,
  enforceRateLimit,
  requireAuthUid,
} from "../shared/security";
import { logger } from "../shared/logger";

const db = (): Firestore => getFirestore();

/**
 * Callable: repair a broken streak within 24 h using one freeze (README §5.3).
 */
export const repairStreak = onCall(SECURE_CALLABLE_OPTIONS, async (request) => {
  const uid = requireAuthUid(request);
  await enforceRateLimit({
    uid,
    action: "repairStreak",
    maxRequests: 10,
    windowMs: 60 * 60 * 1000,
  });

  const userSnap = await db().doc(`users/${uid}`).get();
  if (!userSnap.exists) {
    throw new HttpsError("failed-precondition", "Profile missing.");
  }
  const time = resolveUserTime(userSnap.data() ?? {});
  const today = localDateKey(new Date(), time);

  const gameRef = db().doc(`users/${uid}/game/state`);
  const publicRef = db().doc(`publicProfiles/${uid}`);

  const result = await db().runTransaction(async (tx) => {
    const snap = await tx.get(gameRef);
    if (!snap.exists) {
      throw new HttpsError("failed-precondition", "Game state missing.");
    }
    const game = normalizeGameState(snap.data());
    const repaired = repairStreakState(game.streak, today);
    if (!repaired) {
      if (game.streak.freezes < 1) {
        throw new HttpsError("failed-precondition", "no-freeze");
      }
      throw new HttpsError("failed-precondition", "not-repairable");
    }

    tx.update(gameRef, {
      streak: repaired,
      updatedAt: FieldValue.serverTimestamp(),
    });
    tx.set(
      publicRef,
      { streak: repaired.current, updatedAt: FieldValue.serverTimestamp() },
      { merge: true }
    );
    return repaired;
  });

  logger.info("streak repaired", { uid, current: result.current });
  return {
    current: result.current,
    best: result.best,
    freezes: result.freezes,
  };
});
