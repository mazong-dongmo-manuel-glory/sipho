import 'package:flutter/material.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      _Item('🎩', l10n.shopHat, '120'),
      _Item('🕶️', l10n.shopGlasses, '80'),
      _Item('🧣', l10n.shopScarfGreen, '150', stripe: AppColors.primary),
      _Item('🧣', l10n.shopScarfClay, '150', stripe: AppColors.terracotta),
      _Item('🌿', l10n.shopNest, '200'),
      _Item('❄️', l10n.shopFreeze, '60'),
    ];
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
                const Expanded(
                    child: _Pill(
                        AppColors.flamePill, AppColors.flameText, '🔥  12')),
                const SizedBox(width: 16),
                const Expanded(
                    child: _Pill(
                        AppColors.seedPill, AppColors.seedText, '🌾  340')),
                const SizedBox(width: 16),
                Expanded(
                  child: _Pill(AppColors.mint, AppColors.primaryDark,
                      l10n.homeLevelPill(7)),
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
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 165,
                crossAxisSpacing: 9,
                mainAxisSpacing: 13,
              ),
              itemBuilder: (context, index) =>
                  _Card(item: items[index], buy: l10n.shopBuy),
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

class _Item {
  const _Item(this.emoji, this.title, this.price, {this.stripe});

  final String emoji;
  final String title;
  final String price;
  final Color? stripe;
}

class _Card extends StatelessWidget {
  const _Card({required this.item, required this.buy});

  final _Item item;
  final String buy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
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
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          Text(
            '🌾  ${item.price}',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.warnBrown,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              buy,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
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
