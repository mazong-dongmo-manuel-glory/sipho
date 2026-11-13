import 'package:flutter/material.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_radius.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/app/theme/app_text_styles.dart';
import 'package:sipho/core/widgets/sipho_bubble.dart';

class OnboardingGoalStep extends StatelessWidget {
  final String selectedGoal;
  final ValueChanged<String> onGoalSelected;

  const OnboardingGoalStep({
    super.key,
    required this.selectedGoal,
    required this.onGoalSelected,
  });

  static const _goals = [
    {
      'id': 'stop_overdraft',
      'emoji': '🛑',
      'title': 'Arrêter d\'être à découvert',
    },
    {
      'id': 'save_for_project',
      'emoji': '🎯',
      'title': 'Épargner pour un projet',
    },
    {
      'id': 'understand_money',
      'emoji': '💡',
      'title': 'Comprendre mon argent',
    },
    {
      'id': 'prepare_future',
      'emoji': '🌱',
      'title': 'Préparer mon avenir & retraite',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const SiphoBubble(
          text: 'Quel est ton objectif prioritaire pour commencer ?',
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: ListView.separated(
            itemCount: _goals.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final g = _goals[index];
              final isSelected = g['id'] == selectedGoal;
              return InkWell(
                onTap: () => onGoalSelected(g['id']!),
                borderRadius: AppRadius.cardRadius,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withAlpha(25) : AppColors.surface,
                    borderRadius: AppRadius.cardRadius,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(g['emoji']!, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(g['title']!, style: AppTextStyles.bodySemiBold),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: AppColors.primary),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

