import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/gamification/data/game_state_repository.dart';
import 'package:sipho/features/insights/data/insight_service.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';
import 'package:sipho/features/lessons/presentation/learn_path.dart';
import 'package:sipho/features/lessons/presentation/learn_quests_section.dart';
import 'package:sipho/features/lessons/presentation/lesson_sheet.dart';

/// The Learn tab: stats, today's quests, and the lesson path unit by unit.
class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  final _currentKey = GlobalKey();
  bool _scrolledToCurrent = false;

  void _scrollToCurrentOnce() {
    if (_scrolledToCurrent) return;
    _scrolledToCurrent = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _currentKey.currentContext;
      if (!mounted || target == null) return;
      Scrollable.ensureVisible(target, alignment: 0.4, duration: Duration.zero);
    });
  }

  Future<void> _openLesson(
    CatalogLesson lesson,
    LessonNodeState state,
    UnitProgress unit,
    String language,
  ) async {
    final start = await showLessonSheet(
      context,
      lesson: lesson,
      state: state,
      position: unit.unit.lessons.indexOf(lesson) + 1,
      total: unit.total,
      language: language,
    );
    if (start == true && mounted) {
      unawaited(context.push('/lesson/${lesson.id}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final completed = ref
            .watch(userFinanceProvider)
            .valueOrNull
            ?.completedLessonIds
            .toSet() ??
        {};
    final game = ref.watch(gameStateStreamProvider).valueOrNull;
    final advice = ref.watch(activeCoachAdviceProvider);
    final ids = [for (final lesson in kCatalogLessons) lesson.id];
    final nextId = nextLessonId(ids, completed);
    final units = unitProgressList(kCatalogUnits, completed);
    if (nextId != null) _scrollToCurrentOnce();

    final streakText = game != null ? '${game.streak.current}' : '—';
    final seedsText = game != null ? '${game.gems}' : '—';
    final levelNum = game?.level ?? 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            8,
            AppSpacing.pagePadding,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _Pill(
                      AppColors.flamePill,
                      AppColors.flameText,
                      '🔥  $streakText',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _Pill(
                      AppColors.seedPill,
                      AppColors.seedText,
                      '🌾  $seedsText',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _Pill(
                      AppColors.mint,
                      AppColors.primaryDark,
                      l10n.homeLevelPill(levelNum),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.learnTitle,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              _CoachCard(
                title: advice == null || advice.title.isEmpty
                    ? '💡  ${l10n.coachTitle}'
                    : '💡  ${advice.title}',
                body: advice?.body ?? l10n.coachSubtitle,
                openLabel: l10n.coachOpenCard,
                onTap: () => context.push('/economy'),
              ),
              const SizedBox(height: 14),
              const LearnQuestsSection(),
              const SizedBox(height: 16),
              for (final unit in units)
                LearnUnitSection(
                  progress: unit,
                  completed: completed,
                  nextId: nextId,
                  language: language,
                  currentKey: _currentKey,
                  onLessonTap: (lesson, state) =>
                      _openLesson(lesson, state, unit, language),
                ),
              Container(
                height: 53,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '🔒  ${l10n.learnUnit3}',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
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

class _CoachCard extends StatelessWidget {
  const _CoachCard({
    required this.title,
    required this.body,
    required this.openLabel,
    required this.onTap,
  });

  final String title;
  final String body;
  final String openLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              openLabel,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.background, this.foreground, this.label);

  final Color background;
  final Color foreground;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}
