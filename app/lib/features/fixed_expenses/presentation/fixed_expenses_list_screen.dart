import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_radius.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/app/theme/app_text_styles.dart';

class FixedExpensesListScreen extends ConsumerWidget {
  const FixedExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon Socle (dépenses fixes)'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: AppRadius.cardRadius,
              ),
              child: Row(
                children: [
                  const Text('🪺', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total socle mensuel',
                        style: AppTextStyles.label.copyWith(color: AppColors.cream),
                      ),
                      const Text(
                        '1 690 \$ / mois',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Dépenses récurrentes', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            _buildItem('Loyer', '950 \$', 'Le 1er du mois', '🏠', true),
            _buildItem('Internet', '75 \$', 'Le 15 du mois', '📶', false),
            _buildItem('Électricité', '60 \$', 'Le 20 du mois', '💡', false),
            _buildItem('Téléphone', '45 \$', 'Le 5 du mois', '📱', true),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String title, String amount, String date, String emoji, bool paid) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySemiBold),
                Text(date, style: AppTextStyles.labelSm),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: AppTextStyles.bodySemiBold),
              Text(
                paid ? 'Payé ✓' : 'À venir',
                style: AppTextStyles.labelSm.copyWith(
                  color: paid ? AppColors.success : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

