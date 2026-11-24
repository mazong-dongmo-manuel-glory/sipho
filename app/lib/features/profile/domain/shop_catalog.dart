/// Catalogue boutique — ids/prix alignés sur `functions/src/shared/shop.ts`.
enum ShopItemKind { cosmetic, freeze }

class ShopItem {
  final String id;
  final String labelFr;
  final String labelEn;
  final int priceSeeds;
  final ShopItemKind kind;

  const ShopItem({
    required this.id,
    required this.labelFr,
    required this.labelEn,
    required this.priceSeeds,
    this.kind = ShopItemKind.cosmetic,
  });
}

const kMaxStreakFreezes = 2;

const kShopItems = <ShopItem>[
  ShopItem(id: 'sun_hat', labelFr: 'Chapeau soleil', labelEn: 'Sun hat', priceSeeds: 120),
  ShopItem(id: 'cool_glasses', labelFr: 'Lunettes cool', labelEn: 'Cool glasses', priceSeeds: 80),
  ShopItem(id: 'scarf_green', labelFr: 'Écharpe wax verte', labelEn: 'Green wax scarf', priceSeeds: 150),
  ShopItem(id: 'scarf_clay', labelFr: 'Écharpe terre cuite', labelEn: 'Clay scarf', priceSeeds: 150),
  ShopItem(id: 'flowered_nest', labelFr: 'Nid fleuri', labelEn: 'Flowered nest', priceSeeds: 200),
  ShopItem(
    id: 'streak_freeze',
    labelFr: 'Gel de série',
    labelEn: 'Streak freeze',
    priceSeeds: 60,
    kind: ShopItemKind.freeze,
  ),
];
