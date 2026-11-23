import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/i18n/app_language.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/insights/data/insight_service.dart';
import 'package:sipho/features/lessons/data/ai_country_lessons_repository.dart';
import 'package:sipho/features/lessons/domain/country_lesson_catalog_extra.dart';
import 'package:sipho/features/lessons/domain/generated_lesson_path.dart';
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
  bool _requestedAiLessons = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureNextLesson());
  }

  Future<void> _ensureNextLesson() async {
    if (!mounted || _requestedAiLessons) return;
    final finance = ref.read(userFinanceProvider).valueOrNull;
    if (finance == null) return;
    final completed = finance.completedLessonIds.toSet();
    final ai = ref.read(aiCountryLessonsProvider);
    if (!ai.hasValue) return;
    final generated = generatedLessonsFrom(ai.value ?? const {});
    if (!needsAnotherGeneratedLesson(
      generatedIds: generated.map((lesson) => lesson.id),
      completed: completed,
    )) {
      return;
    }
    _requestedAiLessons = true;
    try {
      await ref.read(aiCountryLessonsRepositoryProvider).ensureNextGenerated(
            locale: ref.read(appUiLanguageProvider),
          );
    } catch (_) {
      // The path stays on the lessons already stored. The next open retries.
    }
  }

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
    // Country slots: fill monolingual AI content before playing (reuse if present).
    if (isCountrySlotId(lesson.id)) {
      final ai = ref.read(aiCountryLessonsProvider).valueOrNull ?? {};
      final uiLanguage = ref.read(appUiLanguageProvider);
      final existing = ai[lesson.id];
      final needsFill = existing?.isPlayable != true ||
          !appLanguagesMatch(existing?.locale, uiLanguage);
      if (needsFill) {
        try {
          await ref.read(aiCountryLessonsRepositoryProvider).ensureGenerated(
                slotId: lesson.id,
                forceNew: existing?.isPlayable == true,
                locale: uiLanguage,
              );
        } catch (_) {
          // Player will show placeholder / not-found; user can retry.
        }
      }
    }
    if (!mounted) return;
    final start = await showLessonSheet(
      context,
      lesson: lesson,
      state: state,
      position: unit.unit.lessons.indexOf(lesson) + 1,
      total: unit.total,
      language: language,
    );
    if (start == true && mounted) {
      // completeLesson(slotId) awards XP for country slots.
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
    final advice = ref.watch(activeCoachAdviceProvider);
    final ids = [for (final lesson in kCatalogLessons) lesson.id];
    final nextId = nextLessonId(ids, completed);
    final units = unitProgressList(kCatalogUnits, completed);
    final coreDone = units.isNotEmpty && units.every((unit) => unit.completed);
    final generatedLessons = generatedLessonsFrom(
      ref.watch(aiCountryLessonsProvider).valueOrNull ?? const {},
    );
    final localUnits = unitProgressList(
      generatedUnits(generatedLessons),
      completed,
      startIndex: units.length,
      initiallyUnlocked: coreDone,
    );
    final localIds = [
      for (final unit in localUnits)
        for (final lesson in unit.unit.lessons) lesson.id,
    ];
    // One current lesson on the whole path. The country module waits until
    // the core units are finished, then continues with the same lock rule.
    final countryOpen = localUnits.any((unit) => unit.unlocked && !unit.completed);
    final localNextId = countryOpen ? nextLessonId(localIds, completed) : null;
    ref.listen(userFinanceProvider, (previous, next) {
      if (_requestedAiLessons) return;
      unawaited(_ensureNextLesson());
    });
    ref.listen(aiCountryLessonsProvider, (previous, next) {
      if (_requestedAiLessons || !next.hasValue) return;
      unawaited(_ensureNextLesson());
    });
    if (nextId != null || localNextId != null) _scrollToCurrentOnce();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            16,
            AppSpacing.pagePadding,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Frame 15 · Parcours · Épuré
              Text(
                l10n.learnTitle,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.learnPathLead,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                  color: AppColors.textSecondary,
                ),
              ),
              if (advice != null) ...[
                const SizedBox(height: 12),
                _CoachCard(
                  title: advice.title.isEmpty
                      ? l10n.coachTitle
                      : advice.title,
                  body: advice.body,
                  openLabel: l10n.coachOpenCard,
                  onTap: () => context.push('/insights'),
                ),
              ],
              const SizedBox(height: 14),
              const LearnQuestsSection(),
              const SizedBox(height: 16),
              for (final unit in units)
                LearnUnitSection(
                  progress: unit,
                  completed: completed,
                  nextId: nextId,
                  language: language,
                  currentKey: nextId != null ? _currentKey : null,
                  onLessonTap: (lesson, state) =>
                      _openLesson(lesson, state, unit, language),
                ),
              for (final unit in localUnits)
                LearnUnitSection(
                  progress: unit,
                  completed: completed,
                  nextId: localNextId,
                  language: language,
                  currentKey: nextId == null ? _currentKey : null,
                  onLessonTap: (lesson, state) =>
                      _openLesson(lesson, state, unit, language),
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
    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: AppColors.soft,
            borderRadius: BorderRadius.circular(20),
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
      ),
    );
  }
}

