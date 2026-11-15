import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/features/gamification/data/game_state_repository.dart';
import 'package:sipho/features/profile/data/shop_repository.dart';
import 'package:sipho/features/profile/domain/shop_catalog.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  /// Item being bought: one purchase at a time, so a double tap cannot buy twice.
  String? _buying;

  Future<void> _buy(ShopItem item, AppLocalizations l10n) async {
    if (_buying != null) return;
    setState(() => _buying = item.id);
    String message;
    try {
      await ref.read(shopRepositoryProvider).buy(item.id);
      unawaited(ref.read(feedbackServiceProvider).play(SiphoCue.questClaimed));
      message = l10n.shopBought(shopItemTitle(l10n, item.id));
    } on ShopException catch (error) {
      switch (error.refusal) {
        case ShopRefusal.alreadyOwned:
          message = l10n.shopRefusedOwned;
        case ShopRefusal.maxStock:
          message = l10n.shopRefusedStock;
        case ShopRefusal.insufficientSeeds:
          message = l10n.shopRefusedSeeds;
        case ShopRefusal.other:
          message = l10n.shopError;
      }
    }
    if (!mounted) return;
    setState(() => _buying = null);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final game = ref.watch(gameStateStreamProvider).valueOrNull;
    final extras = ref.watch(gameExtrasStreamProvider).valueOrNull;
    final gems = game?.gems ?? 0;
    final freezes = game?.streak.freezes ?? 0;
    final owned = extras?.ownedItems ?? const <String>{};

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            8,
            AppSpacing.pagePadding,
            16,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: _Pill(
                    AppColors.flamePill,
                    AppColors.flameText,
                    '🔥  ${game?.streak.current ?? '—'}',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _Pill(
                    AppColors.seedPill,
                    AppColors.seedText,
                    '🌾  ${game != null ? gems : '—'}',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _Pill(
                    AppColors.mint,
                    AppColors.primaryDark,
                    l10n.homeLevelPill(game?.level ?? 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.shopTitle,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.2,
                color: AppColors.primaryDark,
              ),
            ),
            Text(
              l10n.shopSubtitle,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: kShopItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 178,
                crossAxisSpacing: 9,
                mainAxisSpacing: 13,
              ),
              itemBuilder: (context, index) {
                final item = kShopItems[index];
                final status = shopItemStatus(
                  item,
                  gems: gems,
                  freezes: freezes,
                  owned: owned,
                );
                return _Card(
                  item: item,
                  title: shopItemTitle(l10n, item.id),
                  note: item.kind == ShopItemKind.freeze
                      ? l10n.shopFreezeStock(freezes, kMaxStreakFreezes)
                      : null,
                  status: status,
                  label: switch (status) {
                    ShopItemStatus.available => l10n.shopBuy,
                    ShopItemStatus.owned => l10n.shopOwned,
                    ShopItemStatus.tooExpensive => l10n.shopNotEnough,
                    ShopItemStatus.stockFull => l10n.shopStockFull,
                  },
                  loading: _buying == item.id,
                  onBuy: game != null &&
                          _buying == null &&
                          status == ShopItemStatus.available
                      ? () => _buy(item, l10n)
                      : null,
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              l10n.shopNote,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.item,
    required this.title,
    required this.status,
    required this.label,
    required this.loading,
    required this.onBuy,
    this.note,
  });

  final ShopItem item;
  final String title;
  final String? note;
  final ShopItemStatus status;
  final String label;
  final bool loading;
  final VoidCallback? onBuy;

  @override
  Widget build(BuildContext context) {
    final owned = status == ShopItemStatus.owned;
    final available = status == ShopItemStatus.available;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: owned ? AppColors.mint : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: owned ? AppColors.primary : AppColors.border),
      ),
      child: Column(
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 40)),
          if (item.stripe != null)
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: item.stripe,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          const Spacer(),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          Text(
            note ?? '🌾  ${item.price}',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.warnBrown,
            ),
          ),
          if (note != null)
            Text(
              '🌾  ${item.price}',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.warnBrown,
              ),
            ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onBuy,
            child: Container(
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: available ? AppColors.mint : AppColors.border,
                borderRadius: BorderRadius.circular(9),
              ),
              child: loading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: available
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.background, this.foreground, this.label);

  final Color background;
  final Color foreground;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}
