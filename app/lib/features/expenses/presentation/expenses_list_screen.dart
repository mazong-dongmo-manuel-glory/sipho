import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';

class ExpensesListScreen extends ConsumerWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dépenses'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Novembre 2026', style: AppTextStyles.h2),
                Text('Total: 468,50 \$', style: AppTextStyles.bodySemiBold),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildExpenseTile('Resto Le Petit Nid', '18,50 \$', 'Aujourd\'hui', '🍔', false),
            _buildExpenseTile('Marché Jean-Talon', '64,20 \$', 'Hier', '🛒', true),
            _buildExpenseTile('Café Nomad', '5,75 \$', '10 nov.', '☕', false),
            _buildExpenseTile('Pharmacie Santé', '22,40 \$', '09 nov.', '💊', true),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTile(String merchant, String amount, String date, String emoji, bool isScanned) {
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
                Row(
                  children: [
                    Text(merchant, style: AppTextStyles.bodySemiBold),
                    if (isScanned) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('📷 scan', style: TextStyle(fontSize: 10)),
                      ),
                    ],
                  ],
                ),
                Text(date, style: AppTextStyles.labelSm),
              ],
            ),
          ),
          Text(amount, style: AppTextStyles.bodySemiBold),
        ],
      ),
    );
  }
}

