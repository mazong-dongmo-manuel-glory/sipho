import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_radius.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/money/money.dart';
import 'package:sipho/core/money/money_formatter.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/goals/data/goal_repository.dart';
import 'package:sipho/features/goals/domain/goal.dart';
import 'package:sipho/features/goals/presentation/add_goal_sheet.dart';
import 'package:sipho/features/goals/presentation/deposit_goal_sheet.dart';

class HomeGoalTrackerSection extends ConsumerWidget {
  const HomeGoalTrackerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(userFinanceProvider).valueOrNull;
    final currency = (finance?.currency.isNotEmpty ?? false) ? finance!.currency : 'CAD';
    final goalsAsync = ref.watch(userGoalsProvider);

    return goalsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (goals) {
        if (goals.isEmpty) {
          return _EmptyGoalPromptCard(currency: currency);
        }

        // Active (incomplete) goals first, otherwise latest completed
        final activeGoals = goals.where((g) => !g.isCompleted).toList();
        final mainGoal = activeGoals.isNotEmpty ? activeGoals.first : goals.first;

        return _ActiveGoalTrackerCard(
          goal: mainGoal,
          currency: currency,
          totalGoalsCount: goals.length,
        );
      },
    );
  }
}

class _EmptyGoalPromptCard extends ConsumerWidget {
  const _EmptyGoalPromptCard({required this.currency});

  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text('🎯', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.profileGoals,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.goalEmptySubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              showAddGoalSheet(context, currency: currency);
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.mint,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              l10n.addGoalBtn,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveGoalTrackerCard extends ConsumerWidget {
  const _ActiveGoalTrackerCard({
    required this.goal,
    required this.currency,
    required this.totalGoalsCount,
  });

  final Goal goal;
  final String currency;
  final int totalGoalsCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    final savedStr = MoneyFormatter.format(
      Money(cents: goal.savedCents, currency: currency),
      locale: locale.startsWith('fr') ? 'fr_CA' : 'en_US',
    );
    final targetStr = MoneyFormatter.format(
      Money(cents: goal.targetCents, currency: currency),
      locale: locale.startsWith('fr') ? 'fr_CA' : 'en_US',
    );
    final percent = (goal.progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.accent, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(goal.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            goal.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        if (goal.isCompleted) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.mint,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n.goalReachedBadge,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '$savedStr / $targetStr ($percent %)',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  showDepositGoalSheet(
                    context,
                    goal: goal,
                    currency: currency,
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    l10n.goalSaveQuick,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                goal.isCompleted ? AppColors.primary : AppColors.accent,
              ),
            ),
          ),
          if (totalGoalsCount > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  l10n.goalTrackerCount(totalGoalsCount),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
