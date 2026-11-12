import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { MarkFixedPaidInputSchema } from "../shared/validators";
import { XP_CONFIG, xpToLevel } from "../shared/xpConfig";
import { idempotencyKey, checkAndMarkIdempotencyKey } from "../shared/idempotency";
import { logger } from "../shared/logger";

const db = () => getFirestore();

/**
 * Callable: mark a fixed expense as paid for the month and award XP.
 *
 * Client sends: { fixedId, monthKey (YYYY-MM) }
 * Server returns: { xpGained, levelUp }
 */
export const markFixedPaid = onCall(
  { region: "us-central1", enforceAppCheck: true },
  async (request) => {
    if (!request.auth) throw new HttpsError("unauthenticated", "Login required");
    const uid = request.auth.uid;

    const parsed = MarkFixedPaidInputSchema.safeParse(request.data);
    if (!parsed.success) {
      throw new HttpsError("invalid-argument", parsed.error.message);
    }
    const { fixedId, monthKey } = parsed.data;

    // Idempotency: one XP grant per fixed expense per month
    const ikey = idempotencyKey("markFixedPaid", uid, fixedId, monthKey);
    if (await checkAndMarkIdempotencyKey(ikey)) {
      logger.info("markFixedPaid: duplicate skipped", { uid, fixedId, monthKey });
      return { xpGained: 0, levelUp: false, alreadyPaid: true };
    }

    // Validate fixed expense belongs to user
    const fixedRef = db().doc(`users/${uid}/fixed/${fixedId}`);
    const fixedSnap = await fixedRef.get();
    if (!fixedSnap.exists) throw new HttpsError("not-found", "Fixed expense not found");

    const monthFixedRef = db().doc(`users/${uid}/months/${monthKey}/fixed/${fixedId}`);
    const gameRef = db().doc(`users/${uid}/game/state`);

    const batch = db().batch();
    batch.set(monthFixedRef, { paidAt: FieldValue.serverTimestamp(), paid: true }, { merge: true });

    // Award XP
    const xpGained = XP_CONFIG.fixedPaid;
    batch.update(gameRef, {
      xp: FieldValue.increment(xpGained),
      updatedAt: FieldValue.serverTimestamp(),
    });

    await batch.commit();

    // Update level
    const gameSnap = await gameRef.get();
    const newXp = (gameSnap.data()?.xp ?? 0) as number;
    const oldLevel = (gameSnap.data()?.level ?? 0) as number;
    const newLevel = xpToLevel(newXp);
    const levelUp = newLevel > oldLevel;
    if (levelUp) {
      await gameRef.update({ level: newLevel });
    }

    logger.info("fixed expense marked paid", { uid, fixedId, monthKey, xpGained });

    return { xpGained, levelUp, alreadyPaid: false };
  }
);
