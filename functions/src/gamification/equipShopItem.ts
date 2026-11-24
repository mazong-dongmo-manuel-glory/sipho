import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue, Firestore } from "firebase-admin/firestore";
import { z } from "zod";
import { SHOP_ITEM_IDS, shopItem } from "../shared/shop";
import {
  SECURE_CALLABLE_OPTIONS,
  enforceRateLimit,
  parseInput,
  requireAuthUid,
} from "../shared/security";
import { logger } from "../shared/logger";

const db = (): Firestore => getFirestore();

const EquipShopItemInputSchema = z.object({
  itemId: z.enum(SHOP_ITEM_IDS, { errorMap: () => ({ message: "Unknown itemId" }) }),
  equipped: z.boolean(),
});

function stringList(raw: unknown): string[] {
  return Array.isArray(raw)
    ? (raw as unknown[]).filter((id): id is string => typeof id === "string")
    : [];
}

/**
 * Callable: wear / unwear a cosmetic the user already owns.
 * Freezes are not wearable. Writes `game/state.equippedItems` (server-only field).
 */
export const equipShopItem = onCall(SECURE_CALLABLE_OPTIONS, async (request) => {
  const uid = requireAuthUid(request);
  const { itemId, equipped } = parseInput(EquipShopItemInputSchema, request.data);

  await enforceRateLimit({
    uid,
    action: "equipShopItem",
    maxRequests: 60,
    windowMs: 60 * 60 * 1000,
  });

  const item = shopItem(itemId);
  if (!item || item.kind !== "cosmetic") {
    throw new HttpsError("invalid-argument", "Only cosmetics can be equipped.");
  }

  const gameRef = db().doc(`users/${uid}/game/state`);
  const result = await db().runTransaction(async (tx) => {
    const snap = await tx.get(gameRef);
    if (!snap.exists) {
      throw new HttpsError("failed-precondition", "No game state yet.");
    }
    const owned = stringList(snap.data()?.ownedItems);
    if (!owned.includes(itemId)) {
      throw new HttpsError("failed-precondition", "Item not owned.", {
        reason: "not-owned",
      });
    }

    const current = stringList(snap.data()?.equippedItems);
    let next: string[];
    if (equipped) {
      next = current.includes(itemId) ? current : [...current, itemId];
    } else {
      next = current.filter((id) => id !== itemId);
    }

    tx.update(gameRef, {
      equippedItems: next,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return { itemId, equipped, equippedItems: next };
  });

  logger.info("shop equip", { uid, itemId, equipped });
  return result;
});
