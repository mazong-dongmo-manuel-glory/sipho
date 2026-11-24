import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/firebase/cloud_functions_service.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../../core/widgets/sipho_mascot.dart';
import '../../gamification/data/game_state_provider.dart';
import '../../gamification/domain/game_state.dart';
import '../../profile/domain/shop_catalog.dart';

/// Frame 22 · Boutique · achats + équipement cosmétiques.
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  String? _busyId;

  String _trailing(AppLocalizations l10n, GameState game, ShopItem item) {
    if (item.kind == ShopItemKind.freeze) {
      if (game.freezes >= kMaxStreakFreezes) return l10n.shopStockFull;
      if (game.seeds < item.priceSeeds) return l10n.shopNotEnough;
      return l10n.shopFreezeStock(game.freezes, kMaxStreakFreezes);
    }
    if (game.equippedItems.contains(item.id)) {
      return Localizations.localeOf(context).languageCode == 'fr'
          ? 'Porté'
          : 'Wearing';
    }
    if (game.ownedItems.contains(item.id)) return l10n.shopOwned;
    if (game.seeds < item.priceSeeds) return l10n.shopNotEnough;
    return '${item.priceSeeds}';
  }

  bool _canBuy(GameState game, ShopItem item) {
    if (item.kind == ShopItemKind.freeze) {
      return game.freezes < kMaxStreakFreezes && game.seeds >= item.priceSeeds;
    }
    return !game.ownedItems.contains(item.id) && game.seeds >= item.priceSeeds;
  }

  Future<void> _buy(ShopItem item, String label, AppLocalizations l10n) async {
    if (_busyId != null) return;
    setState(() => _busyId = item.id);
    final result =
        await ref.read(cloudFunctionsServiceProvider).buyShopItem(itemId: item.id);
    if (!mounted) return;
    setState(() => _busyId = null);

    if (result['status'] == 'error') {
      final reason = result['reason']?.toString();
      final msg = switch (reason) {
        'already-owned' => l10n.shopRefusedOwned,
        'max-stock' => l10n.shopRefusedStock,
        'insufficient-seeds' => l10n.shopRefusedSeeds,
        _ => l10n.shopError,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: SiphoColors.primaryDark),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.shopBought(label)),
        backgroundColor: SiphoColors.primaryDark,
      ),
    );
  }

  Future<void> _toggleEquip(
    ShopItem item,
    String label,
    AppLocalizations l10n,
    GameState game,
  ) async {
    if (_busyId != null || item.kind != ShopItemKind.cosmetic) return;
    if (!game.ownedItems.contains(item.id)) return;
    final wear = !game.equippedItems.contains(item.id);
    setState(() => _busyId = item.id);
    final result = await ref.read(cloudFunctionsServiceProvider).equipShopItem(
          itemId: item.id,
          equipped: wear,
        );
    if (!mounted) return;
    setState(() => _busyId = null);
    if (result['status'] == 'error') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.shopError),
          backgroundColor: SiphoColors.primaryDark,
        ),
      );
      return;
    }
    final fr = Localizations.localeOf(context).languageCode == 'fr';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wear
              ? (fr ? 'Sipho porte $label' : 'Sipho is wearing $label')
              : (fr ? '$label retiré' : '$label removed'),
        ),
        backgroundColor: SiphoColors.primaryDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final game = ref.watch(gameStateProvider);
    final isFr = Localizations.localeOf(context).languageCode == 'fr';

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Text(
              l10n.shopTitle,
              style: SiphoTypography.title.copyWith(
                fontSize: 28,
                color: SiphoPalette.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.seedsLabel(game.seeds)} · ${l10n.shopNote}',
              style: SiphoTypography.body.copyWith(
                fontSize: 16,
                color: SiphoPalette.textSecondary(context),
              ),
            ),
            const SizedBox(height: 16),
            const SiphoMascot(size: 96),
            const SizedBox(height: 8),
            Text(
              isFr
                  ? 'Tap un objet possédé pour l’équiper.'
                  : 'Tap an owned item to wear it.',
              style: SiphoTypography.label.copyWith(
                fontWeight: FontWeight.w700,
                color: SiphoPalette.textSecondary(context),
              ),
            ),
            const SizedBox(height: 20),
            ...kShopItems.map(
              (item) {
                final label = isFr ? item.labelFr : item.labelEn;
                final canBuy = _canBuy(game, item);
                final owned = game.ownedItems.contains(item.id);
                final busy = _busyId == item.id;
                return Column(
                  children: [
                    SiphoListRow(
                      title: label,
                      subtitle: item.kind == ShopItemKind.freeze
                          ? l10n.shopFreezeStock(game.freezes, kMaxStreakFreezes)
                          : owned
                              ? (game.equippedItems.contains(item.id)
                                  ? (isFr ? 'Équipé · taper pour retirer' : 'Equipped · tap to remove')
                                  : (isFr ? 'Possédé · taper pour porter' : 'Owned · tap to wear'))
                              : '${item.priceSeeds}',
                      trailing: busy ? '…' : _trailing(l10n, game, item),
                      showChevron: (canBuy || owned) && !busy,
                      onTap: busy
                          ? null
                          : owned && item.kind == ShopItemKind.cosmetic
                              ? () => _toggleEquip(item, label, l10n, game)
                              : canBuy
                                  ? () => _buy(item, label, l10n)
                                  : null,
                    ),
                    const SiphoSeparator(
                      margin: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
