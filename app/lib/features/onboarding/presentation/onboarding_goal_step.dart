import 'package:flutter/material.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/widgets/sipho_art.dart';

class OnboardingGoalStep extends StatelessWidget {
  const OnboardingGoalStep({
    super.key,
    required this.selectedGoal,
    required this.onGoalSelected,
  });

  final String selectedGoal;
  final ValueChanged<String> onGoalSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final goals = [
      ('stop_overdraft', '🛟', l10n.onboardingGoalOverdraft),
      ('save_for_project', '🌱', l10n.onboardingGoalProject),
      ('understand_money', '💡', l10n.onboardingGoalUnderstand),
      ('prepare_future', '☀️', l10n.onboardingGoalRetire),
    ];
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        for (final goal in goals) ...[
          _GoalRow(
            emoji: goal.$2,
            title: goal.$3,
            selected: goal.$1 == selectedGoal,
            onTap: () => onGoalSelected(goal.$1),
          ),
          const SizedBox(height: 18),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SiphoArt.proud(),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 70,
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.onboardingGoalCheer,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.emoji,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.mint : AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
