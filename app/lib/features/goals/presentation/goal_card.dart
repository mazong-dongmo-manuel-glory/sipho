import 'package:flutter/material.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/money/money.dart';
import 'package:sipho/core/money/money_formatter.dart';
import 'package:sipho/core/widgets/gauge_horizontal.dart';
import 'package:sipho/features/goals/domain/goal.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.currency,
    this.onTap,
    this.onDeposit,
    this.onDelete,
  });

  final Goal goal;
  final String currency;
  final VoidCallback? onTap;
  final VoidCallback? onDeposit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final savedText = MoneyFormatter.format(
      Money(cents: goal.savedCents, currency: currency),
      locale: locale,
    );
    final targetText = MoneyFormatter.format(
      Money(cents: goal.targetCents, currency: currency),
      locale: locale,
    );

    final pct = (goal.progress * 100).toInt();

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap ?? onDeposit,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: goal.isCompleted
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.border,
              width: goal.isCompleted ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: goal.isCompleted
                          ? AppColors.mint
                          : AppColors.seedPill,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      goal.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$savedText / $targetText',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: goal.isCompleted
                          ? AppColors.mint
                          : AppColors.seedPill,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      goal.isCompleted ? l10n.goalCompleted : '$pct %',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: goal.isCompleted
                            ? AppColors.primary
                            : AppColors.primaryDark,
                      ),
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      color: AppColors.textSecondary,
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              GaugeHorizontal(
                spentCents: goal.savedCents,
                totalCents: goal.targetCents,
                color: goal.isCompleted
                    ? AppColors.primary
                    : AppColors.categoryGold,
                height: 10,
              ),
              if (onDeposit != null && !goal.isCompleted) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onDeposit,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.add_circle_outline,
                        size: 16, color: AppColors.primary),
                    label: Text(
                      l10n.goalDepositBtn,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
