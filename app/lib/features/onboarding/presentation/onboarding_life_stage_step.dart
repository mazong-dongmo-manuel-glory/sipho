import 'package:flutter/material.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';

/// Life-stage options written to `users/{uid}.lifeStage` (README §3.1).
const kLifeStages = <String>[
  'student',
  'first_job',
  'family',
  'pre_retirement',
  'retired',
];

class OnboardingLifeStageStep extends StatelessWidget {
  const OnboardingLifeStageStep({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = [
      ('student', '🎓', l10n.onboardingLifeStudent),
      ('first_job', '💼', l10n.onboardingLifeFirstJob),
      ('family', '🏡', l10n.onboardingLifeFamily),
      ('pre_retirement', '🌅', l10n.onboardingLifePreRetirement),
      ('retired', '☕', l10n.onboardingLifeRetired),
    ];
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        for (final row in rows) ...[
          _StageRow(
            emoji: row.$2,
            title: row.$3,
            selected: row.$1 == selected,
            onTap: () => onSelected(row.$1),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({
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
