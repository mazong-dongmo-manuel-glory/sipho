import 'package:flutter/material.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_radius.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/app/theme/app_text_styles.dart';
import 'package:sipho/core/money/money.dart';
import 'package:sipho/core/money/money_formatter.dart';
import 'package:sipho/core/widgets/gauge_circular.dart';

class RemainingBudgetCard extends StatelessWidget {
  final Money remaining;
  final Money income;
  final Money fixed;
  final Money spent;
  final double progressPercent; // 0.0 to 1.0

  const RemainingBudgetCard({
    super.key,
    required this.remaining,
    required this.income,
    required this.fixed,
    required this.spent,
    required this.progressPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reste à vivre',
                style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Novembre',
                  style: AppTextStyles.labelSm.copyWith(color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GaugeCircular(
                    progress: progressPercent,
                    strokeWidth: 14,
                    color: AppColors.primary,
                    backgroundColor: AppColors.border,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        MoneyFormatter.format(remaining),
                        style: AppTextStyles.displayLg.copyWith(fontSize: 32),
                      ),
                      Text(
                        'disponible',
                        style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('Revenu', MoneyFormatter.format(income)),
              _buildMetric('Fixes', MoneyFormatter.format(fixed)),
              _buildMetric('Dépensé', MoneyFormatter.format(spent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.labelSm),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.bodySemiBold),
      ],
    );
  }
}

