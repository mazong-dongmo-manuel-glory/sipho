import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_radius.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/app/theme/app_text_styles.dart';
import 'package:sipho/core/widgets/gauge_horizontal.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Budgets')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            const Text('Budgets par catégorie', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.md),
            _buildCategoryRow('Restos', '180 \$ / 200 \$', 0.90, AppColors.budgetWarn, '🍔'),
            _buildCategoryRow('Épicerie', '240 \$ / 400 \$', 0.60, AppColors.budgetOk, '🛒'),
            _buildCategoryRow('Shopping', '120 \$ / 150 \$', 0.80, AppColors.budgetWarn, '🛍️'),
            _buildCategoryRow('Loisirs', '95 \$ / 100 \$', 0.95, AppColors.budgetOver, '🎮'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(String name, String amounts, double percent, Color color, String emoji) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$emoji $name', style: AppTextStyles.bodySemiBold),
              Text(amounts, style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GaugeHorizontal(
            progress: percent,
            color: color,
            backgroundColor: AppColors.border,
          ),
        ],
      ),
    );
  }
}

