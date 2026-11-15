import {
  MAX_STREAK_FREEZES,
  SHOP_ITEMS,
  SHOP_ITEM_IDS,
  planPurchase,
  shopItem,
} from "../shared/shop";

const rich = { gems: 1000, freezes: 0, ownedItems: [] as string[] };

describe("seeds shop", () => {
  test("ids are unique and every price is a positive integer", () => {
    expect(new Set(SHOP_ITEM_IDS).size).toBe(SHOP_ITEMS.length);
    for (const item of SHOP_ITEMS) {
      expect(Number.isInteger(item.price)).toBe(true);
      expect(item.price).toBeGreaterThan(0);
    }
    expect(shopItem("nope")).toBeNull();
  });

  test("an unknown item is refused", () => {
    expect(planPurchase("nope", rich)).toEqual({ ok: false, reason: "unknown-item" });
  });

  test("buying a cosmetic spends its price and grants it", () => {
    const plan = planPurchase("sun_hat", rich);
    expect(plan).toMatchObject({ ok: true, gemsAfter: 1000 - 120, freezesAfter: 0, grantsItem: true });
  });

  test("a cosmetic can only be bought once", () => {
    expect(planPurchase("sun_hat", { ...rich, ownedItems: ["sun_hat"] })).toEqual({
      ok: false,
      reason: "already-owned",
    });
    // owning another item does not block it
    expect(planPurchase("sun_hat", { ...rich, ownedItems: ["cool_glasses"] }).ok).toBe(true);
  });

  test("not enough seeds is refused, exact price is enough", () => {
    expect(planPurchase("scarf_green", { ...rich, gems: 149 })).toEqual({
      ok: false,
      reason: "insufficient-seeds",
    });
    expect(planPurchase("scarf_green", { ...rich, gems: 150 })).toMatchObject({
      ok: true,
      gemsAfter: 0,
    });
  });

  test("a freeze adds one to the stock and grants no item", () => {
    expect(planPurchase("streak_freeze", { ...rich, freezes: 1 })).toMatchObject({
      ok: true,
      gemsAfter: 1000 - 60,
      freezesAfter: 2,
      grantsItem: false,
    });
  });

  test("the freeze stock is capped, and the cap is reported before the price", () => {
    expect(planPurchase("streak_freeze", { ...rich, freezes: MAX_STREAK_FREEZES })).toEqual({
      ok: false,
      reason: "max-stock",
    });
    expect(planPurchase("streak_freeze", { gems: 0, freezes: MAX_STREAK_FREEZES, ownedItems: [] })).toEqual({
      ok: false,
      reason: "max-stock",
    });
    expect(planPurchase("streak_freeze", { gems: 10, freezes: 0, ownedItems: [] })).toEqual({
      ok: false,
      reason: "insufficient-seeds",
    });
  });

  test("a freeze can be bought again and again while under the cap", () => {
    expect(planPurchase("streak_freeze", { ...rich, ownedItems: ["streak_freeze"] }).ok).toBe(true);
  });
});
