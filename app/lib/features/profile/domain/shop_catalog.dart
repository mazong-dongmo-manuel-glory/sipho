import 'package:flutter/material.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';

/// What buying an item does.
enum ShopItemKind {
  /// Bought once, kept for good.
  cosmetic,

  /// Adds one to the streak-freeze stock, up to [kMaxStreakFreezes].
  freeze,
}

/// An item of the seeds shop. The server owns the real price and rules
/// (`functions/src/shared/shop.ts`); this only describes how to show it.
class ShopItem {
  const ShopItem(this.id, this.emoji, this.price, this.kind, {this.stripe});

  final String id;
  final String emoji;
  final int price;
  final ShopItemKind kind;
  final Color? stripe;
}

/// At most this many streak freezes in stock (README 5.3).
const int kMaxStreakFreezes = 2;

const List<ShopItem> kShopItems = [
  ShopItem('sun_hat', '🎩', 120, ShopItemKind.cosmetic),
  ShopItem('cool_glasses', '🕶️', 80, ShopItemKind.cosmetic),
  ShopItem('scarf_green', '🧣', 150, ShopItemKind.cosmetic,
      stripe: AppColors.primary),
  ShopItem('scarf_clay', '🧣', 150, ShopItemKind.cosmetic,
      stripe: AppColors.terracotta),
  ShopItem('flowered_nest', '🌿', 200, ShopItemKind.cosmetic),
  ShopItem('streak_freeze', '❄️', 60, ShopItemKind.freeze),
];

String shopItemTitle(AppLocalizations l10n, String id) {
  switch (id) {
    case 'sun_hat':
      return l10n.shopHat;
    case 'cool_glasses':
      return l10n.shopGlasses;
    case 'scarf_green':
      return l10n.shopScarfGreen;
    case 'scarf_clay':
      return l10n.shopScarfClay;
    case 'flowered_nest':
      return l10n.shopNest;
    case 'streak_freeze':
      return l10n.shopFreeze;
    default:
      return id;
  }
}

/// How the buy button of an item looks and behaves right now.
enum ShopItemStatus { available, owned, tooExpensive, stockFull }

/// What a user can do with [item], given their seeds, freeze stock and purchases.
/// The server decides again when the purchase is made; this only drives the UI.
ShopItemStatus shopItemStatus(
  ShopItem item, {
  required int gems,
  required int freezes,
  required Set<String> owned,
}) {
  if (item.kind == ShopItemKind.cosmetic) {
    if (owned.contains(item.id)) return ShopItemStatus.owned;
  } else if (freezes >= kMaxStreakFreezes) {
    return ShopItemStatus.stockFull;
  }
  return gems < item.price
      ? ShopItemStatus.tooExpensive
      : ShopItemStatus.available;
}

/// Why the server refused a purchase (`details.reason` of the error).
enum ShopRefusal { alreadyOwned, maxStock, insufficientSeeds, other }

ShopRefusal shopRefusalFromReason(Object? reason) {
  switch (reason) {
    case 'already-owned':
      return ShopRefusal.alreadyOwned;
    case 'max-stock':
      return ShopRefusal.maxStock;
    case 'insufficient-seeds':
      return ShopRefusal.insufficientSeeds;
    default:
      return ShopRefusal.other;
  }
}
