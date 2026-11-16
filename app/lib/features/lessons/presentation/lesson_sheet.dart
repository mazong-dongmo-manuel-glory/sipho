import 'package:flutter/material.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';
import 'package:sipho/features/lessons/presentation/learn_path.dart';

/// Opens the lesson card from the path. Resolves to true when the learner chose to start (or
/// replay) the lesson, so the caller can navigate once the sheet is closed.
Future<bool?> showLessonSheet(
  BuildContext context, {
  required CatalogLesson lesson,
  required LessonNodeState state,
  required int position,
  required int total,
  required String language,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => LessonSheet(
      lesson: lesson,
      state: state,
      position: position,
      total: total,
      language: language,
    ),
  );
}

class LessonSheet extends StatelessWidget {
  const LessonSheet({
    super.key,
    required this.lesson,
    required this.state,
    required this.position,
    required this.total,
    required this.language,
  });

  final CatalogLesson lesson;
  final LessonNodeState state;

  /// 1-based rank of the lesson in its unit.
  final int position;
  final int total;
  final String language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locked = state == LessonNodeState.locked;
    final done = state == LessonNodeState.done;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: locked ? AppColors.border : AppColors.mint,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    locked ? '🔒' : lesson.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.learnLessonPosition(position, total),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        lesson.title(language),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.learnLessonObjective.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lesson.objective.of(language),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.35,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip('⏱  ${l10n.learnLessonMinutes(lesson.minutes)}'),
                _Chip('📚  ${l10n.learnLessonSteps(lesson.steps.length)}'),
                // A replay pays almost nothing: only announce the reward on a first run.
                if (!done) _Chip('⭐  ${l10n.learnLessonReward(kLessonMaxXp)}'),
              ],
            ),
            if (locked || done) ...[
              const SizedBox(height: 12),
              Text(
                locked ? l10n.learnLockedHint : l10n.learnLessonDoneHint,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 18),
            SiphoButton3D(
              label: locked
                  ? l10n.learnClose
                  : done
                      ? l10n.learnReplay
                      : l10n.learnStart,
              onPressed: () => Navigator.of(context).pop(!locked),
              color: locked ? AppColors.textSecondary : AppColors.primary,
              shadowColor: locked ? AppColors.lockIcon : AppColors.primaryDark,
              height: 52,
              borderRadius: figmaButtonRadius,
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
