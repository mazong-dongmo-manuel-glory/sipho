import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { z } from "zod";
import { normalizeGameState } from "../shared/gameState";
import { SHOP_ITEM_IDS, planPurchase } from "../shared/shop";
import {
  SECURE_CALLABLE_OPTIONS,
  enforceRateLimit,
  parseInput,
  requireAuthUid,
} from "../shared/security";
import { logger } from "../shared/logger";

const db = (): Firestore => getFirestore();

const BuyShopItemInputSchema = z.object({
  itemId: z.enum(SHOP_ITEM_IDS, { errorMap: () => ({ message: "Unknown itemId" }) }),
});

function ownedItemsOf(raw: unknown): string[] {
  return Array.isArray(raw)
    ? (raw as unknown[]).filter((id): id is string => typeof id === "string")
    : [];
}

/**
 * Callable: spends seeds on a shop item, atomically.
 *
 * The price, the one-per-account rule for cosmetics and the freeze stock cap are all decided here
 * from the stored game state; nothing the client sends but the item id is trusted. A refused
 * purchase throws `failed-precondition` with `details.reason` (`already-owned`, `max-stock`,
 * `insufficient-seeds`).
 */
export const buyShopItem = onCall(SECURE_CALLABLE_OPTIONS, async (request) => {
  const uid = requireAuthUid(request);
  const { itemId } = parseInput(BuyShopItemInputSchema, request.data);

  await enforceRateLimit({
    uid,
    action: "buyShopItem",
    maxRequests: 30,
    windowMs: 60 * 60 * 1000,
  });

  const gameRef = db().doc(`users/${uid}/game/state`);

  const result = await db().runTransaction(async (tx) => {
    const snap = await tx.get(gameRef);
    if (!snap.exists) {
      throw new HttpsError("failed-precondition", "No game state yet.", {
        reason: "insufficient-seeds",
      });
    }

    const game = normalizeGameState(snap.data());
    const plan = planPurchase(itemId, {
      gems: game.gems,
      freezes: game.streak.freezes,
      ownedItems: ownedItemsOf(snap.data()?.ownedItems),
    });
    if (!plan.ok) {
      throw new HttpsError("failed-precondition", `Purchase refused: ${plan.reason}.`, {
        reason: plan.reason,
      });
    }

    const update: Record<string, unknown> = {
      gems: plan.gemsAfter,
      updatedAt: FieldValue.serverTimestamp(),
    };
    if (plan.grantsItem) update.ownedItems = FieldValue.arrayUnion(plan.item.id);
    // Whole streak object (not a dotted path): safe even for a legacy numeric `streak` field.
    else update.streak = { ...game.streak, freezes: plan.freezesAfter };
    tx.update(gameRef, update);

    return {
      itemId: plan.item.id,
      price: plan.item.price,
      gems: plan.gemsAfter,
      freezes: plan.freezesAfter,
    };
  });

  logger.info("shop purchase", { uid, itemId, price: result.price });
  return result;
});
