/**
 * Seeds shop: catalog and purchase rules (pure, no Firestore access).
 *
 * Seeds are earned in the app and never bought with money (README 5.3), so the shop is the only
 * place they are spent. The server prices everything: the client only displays the catalog.
 *
 * Keep ids and prices in sync with `kShopItems` in the Flutter app
 * (app/lib/features/profile/domain/shop_catalog.dart).
 */
export const SHOP_ITEMS = [
  { id: "sun_hat", price: 120, kind: "cosmetic" },
  { id: "cool_glasses", price: 80, kind: "cosmetic" },
  { id: "scarf_green", price: 150, kind: "cosmetic" },
  { id: "scarf_clay", price: 150, kind: "cosmetic" },
  { id: "flowered_nest", price: 200, kind: "cosmetic" },
  { id: "streak_freeze", price: 60, kind: "freeze" },
] as const;

export type ShopItemId = (typeof SHOP_ITEMS)[number]["id"];
export type ShopItem = (typeof SHOP_ITEMS)[number];

/** README 5.3: at most 2 streak freezes in stock. */
export const MAX_STREAK_FREEZES = 2;

export const SHOP_ITEM_IDS = SHOP_ITEMS.map((item) => item.id) as unknown as [
  ShopItemId,
  ...ShopItemId[],
];

export function shopItem(id: string): ShopItem | null {
  return SHOP_ITEMS.find((item) => item.id === id) ?? null;
}

export interface PurchaseState {
  gems: number;
  freezes: number;
  ownedItems: readonly string[];
}

export type PurchaseRefusal = "unknown-item" | "already-owned" | "max-stock" | "insufficient-seeds";

export type PurchasePlan =
  | { ok: true; item: ShopItem; gemsAfter: number; freezesAfter: number; grantsItem: boolean }
  | { ok: false; reason: PurchaseRefusal };

/**
 * Decides a purchase. A cosmetic is bought once; a freeze can be bought while the stock is
 * below {@link MAX_STREAK_FREEZES}. The stock check comes before the price check so a user at the
 * cap is told it is full rather than that they are short of seeds.
 */
export function planPurchase(itemId: string, state: PurchaseState): PurchasePlan {
  const item = shopItem(itemId);
  if (!item) return { ok: false, reason: "unknown-item" };

  if (item.kind === "cosmetic") {
    if (state.ownedItems.includes(item.id)) return { ok: false, reason: "already-owned" };
  } else if (state.freezes >= MAX_STREAK_FREEZES) {
    return { ok: false, reason: "max-stock" };
  }

  if (state.gems < item.price) return { ok: false, reason: "insufficient-seeds" };

  return {
    ok: true,
    item,
    gemsAfter: state.gems - item.price,
    freezesAfter: item.kind === "freeze" ? state.freezes + 1 : state.freezes,
    grantsItem: item.kind === "cosmetic",
  };
}
