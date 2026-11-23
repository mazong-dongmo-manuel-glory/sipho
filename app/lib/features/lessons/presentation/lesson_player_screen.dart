import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/ai/sipho_ai_client.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/insights/presentation/spend_snapshot_builder.dart';
import 'package:sipho/features/lessons/data/ai_country_lessons_repository.dart';
import 'package:sipho/features/lessons/data/lesson_ai_tutor_service.dart';
import 'package:sipho/features/lessons/data/lesson_completion_repository.dart';
import 'package:sipho/features/lessons/domain/ai_country_lesson.dart';
import 'package:sipho/features/lessons/domain/country_lesson_catalog.dart';
import 'package:sipho/features/lessons/domain/country_lesson_catalog_extra.dart';
import 'package:sipho/features/lessons/domain/country_slot_player.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';
import 'package:sipho/features/lessons/domain/lesson_session.dart';
import 'package:sipho/features/lessons/presentation/lesson_player_widgets.dart';

/// Plays one lesson: short teaching steps and questions, then a "to remember" page, then the
/// score goes to the server (`completeLesson`) and the learner lands on the end-of-lesson screen.
class LessonPlayerScreen extends ConsumerStatefulWidget {
  const LessonPlayerScreen({super.key, this.lessonId});

  final String? lessonId;

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  CatalogLesson? _lesson;
  LessonSession? _session;
  late final DateTime _startedAt = DateTime.now();
  String? _boundSignature;
  bool _requestedSlotFill = false;

  int? _selected;
  bool _checked = false;
  bool _saving = false;
  LessonSaveFailureKind? _saveFailure;
  bool _askingTutor = false;
  LessonTutorReply? _tutorReply;

  CatalogLesson? _resolveLesson(
    Map<String, AiCountryLesson> ai,
    String uiLanguage,
  ) {
    final id = widget.lessonId;
    if (id == null || id.isEmpty) return null;
    // Country slots: play monolingual AI under aiLessons/{slotId}; XP via completeLesson(slotId).
    if (isCountrySlotId(id)) {
      final aiLesson = ai[id];
      if (aiLesson != null &&
          aiLesson.isPlayable &&
          appLanguagesMatch(aiLesson.locale, uiLanguage)) {
        return aiLesson.toCatalogLesson(
          fallback: kCountryCatalogLessons.cast<CatalogLesson?>().firstWhere(
                (l) => l?.id == id,
                orElse: () => null,
              ),
        );
      }
      return null;
    }
    return playableLessonById(id, ai, uiLanguage: uiLanguage) ??
        kAllPlayableLessons.cast<CatalogLesson?>().firstWhere(
              (l) => l?.id == id,
              orElse: () => null,
            );
  }

  Future<void> _ensureSlotFilled(String slotId) async {
    if (_requestedSlotFill) return;
    _requestedSlotFill = true;
    try {
      final uiLanguage = ref.read(appUiLanguageProvider);
      final existing =
          ref.read(aiCountryLessonsProvider).valueOrNull?[slotId];
      final mismatch = existing?.isPlayable == true &&
          !appLanguagesMatch(existing?.locale, uiLanguage);
      await ref.read(aiCountryLessonsRepositoryProvider).ensureGenerated(
            slotId: slotId,
            forceNew: mismatch,
            locale: uiLanguage,
          );
    } catch (_) {
      // Not-found UI stays; user can leave and retry.
    }
  }

  void _ensureBound(CatalogLesson lesson, {required bool preferAiSwap}) {
    final signature =
        '${lesson.id}:${lesson.titleFr}:${lesson.steps.length}:${lesson.objective.fr}';
    if (_boundSignature == signature && _session != null) return;
    // Don't reset mid-quiz when AI overlay arrives later.
    if (_session != null &&
        _lesson?.id == lesson.id &&
        !preferAiSwap &&
        (_checked || (_session!.index > 0))) {
      return;
    }
    _boundSignature = signature;
    _lesson = lesson;
    _session = LessonSession(lesson);
    _selected = null;
    _checked = false;
    _tutorReply = null;
    _askingTutor = false;
  }

  void _resetStepState() {
    _selected = null;
    _checked = false;
    _tutorReply = null;
    _askingTutor = false;
  }

  void _check(LessonQuestionData question) {
    final correct = _selected == question.correctIndex;
    setState(() {
      _checked = true;
      if (!correct) _session?.recordMiss();
    });
    unawaited(
      ref.read(feedbackServiceProvider).play(
            correct ? SiphoCue.lessonCorrect : SiphoCue.lessonWrong,
          ),
    );
  }

  void _retry() => setState(_resetStepState);

  void _next() => setState(() {
        _session?.advance();
        _resetStepState();
      });

  Future<void> _finish() async {
    final lesson = _lesson;
    final session = _session;
    if (_saving || lesson == null || session == null) return;
    setState(() {
      _saving = true;
      _saveFailure = null;
    });
    final seconds = DateTime.now().difference(_startedAt).inSeconds;
    try {
      final result =
          await ref.read(lessonCompletionRepositoryProvider).complete(
                lessonId: lesson.id,
                score: session.score,
                durationSeconds: seconds,
              );
      if (!mounted) return;
      // Replace the player: "back" from the celebration returns to the path.
      context.pushReplacement('/lesson-done', extra: result);
    } on LessonSaveException catch (error) {
      // No client-side fallback: progress and XP are written by the `completeLesson` Cloud
      // Function only (Firestore rules refuse client writes to completedLessonIds).
      debugPrint('Lesson save failed: $error');
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveFailure = error.kind;
      });
    } catch (error) {
      debugPrint('Lesson save failed: $error');
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveFailure = LessonSaveFailureKind.unknown;
      });
    }
  }

  Future<void> _askAiTutor(LessonQuestionData question, String language) async {
    final selected = _selected;
    final lesson = _lesson;
    if (_askingTutor || selected == null || lesson == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _askingTutor = true);
    try {
      final snapshot = buildCurrentSpendSnapshot(ref: ref, context: context);
      final reply = await ref.read(lessonAiTutorServiceProvider).explainForUser(
            lesson: lesson,
            question: question.prompt,
            selectedAnswer: question.labels[selected],
            answeredCorrectly: selected == question.correctIndex,
            snapshot: snapshot,
          );
      if (!mounted) return;
      setState(() {
        _tutorReply = reply;
        _askingTutor = false;
      });
    } catch (error) {
      debugPrint('[SiphoAI] Lesson AI tutor failed: $error');
      if (!mounted) return;
      setState(() => _askingTutor = false);
      await showSiphoAiErrorSnackBar(
        context,
        error,
        l10n,
        fallback: l10n.quizAiTutorError,
      );
    }
  }

  /// Leaving mid-lesson loses the progress, so ask first once the learner has started.
  Future<void> _requestLeave() async {
    final session = _session;
    if (session == null) {
      context.go('/learn');
      return;
    }
    final started = session.index > 0 || _selected != null;
    if (!started) {
      context.pop();
      return;
    }
    final l10n = AppLocalizations.of(context);
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.lessonLeaveTitle),
        content: Text(l10n.lessonLeaveBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.lessonLeaveStay),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.lessonLeaveQuit,
              style: const TextStyle(color: AppColors.terracotta),
            ),
          ),
        ],
      ),
    );
    if (leave == true && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final uiLanguage = normalizeAppLanguage(language);
    final ai = ref.watch(aiCountryLessonsProvider).valueOrNull ?? const {};
    final slotId = widget.lessonId;
    final slotAi = slotId == null ? null : ai[slotId];
    final slotNeedsFill = slotId != null &&
        isCountrySlotId(slotId) &&
        (slotAi?.isPlayable != true ||
            !appLanguagesMatch(slotAi?.locale, uiLanguage));
    if (slotNeedsFill) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_ensureSlotFilled(slotId));
      });
    }
    final resolved = _resolveLesson(ai, uiLanguage);
    if (resolved != null) {
      final signature =
          '${resolved.id}:${resolved.title(uiLanguage)}:${resolved.steps.length}:${resolved.objective.of(uiLanguage)}';
      if (_boundSignature != signature) {
        final preferAi = ai.containsKey(resolved.id) &&
            appLanguagesMatch(ai[resolved.id]?.locale, uiLanguage);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _ensureBound(
              resolved,
              preferAiSwap: preferAi && (_session?.index ?? 0) == 0,
            );
          });
        });
      }
    }
    final lesson = _lesson;
    final session = _session;
    if (lesson == null || session == null) {
      final waitingForSlot = shouldShowCountrySlotSpinner(
        isCountrySlot: slotId != null && isCountrySlotId(slotId),
        isPlayable: slotAi?.isPlayable == true &&
            appLanguagesMatch(slotAi?.locale, uiLanguage),
        slotFillFailed: false,
      );
      if (waitingForSlot) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    l10n.learnTitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.lessonNotFoundTitle,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.lessonNotFoundBody,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                SiphoButton3D(
                  label: l10n.lessonNotFoundCta,
                  onPressed: () => context.go('/learn'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Keep finance streams hot for the AI tutor context.
    final monthKey = currentMonthKey();
    ref.watch(userFinanceProvider);
    ref.watch(transactionsForMonthProvider(monthKey));
    ref.watch(activeFixedExpensesProvider);

    final step = session.step;
    final question =
        step == null ? null : LessonQuestionData.of(step, l10n, language);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final Widget page;
    if (step == null) {
      page = LessonRecapPage(lesson: lesson, language: language);
    } else if (question != null) {
      page = LessonQuestionPage(
        data: question,
        selected: _selected,
        checked: _checked,
        onSelect: (index) => setState(() => _selected = index),
        tutor: _checked
            ? LessonTutorCard(
                reply: _tutorReply,
                asking: _askingTutor,
                onAsk: () => _askAiTutor(question, language),
              )
            : null,
      );
    } else {
      page = LessonInfoPage(step: step as InfoStep, language: language);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_requestLeave());
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _TopBar(
                  progress: session.progress,
                  closeLabel: l10n.lessonLeaveTitle,
                  onClose: _requestLeave,
                  animate: !reduceMotion,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    child: KeyedSubtree(
                      key: ValueKey(session.index),
                      child: page,
                    ),
                  ),
                ),
                _footer(l10n, language, question, session),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _footer(
    AppLocalizations l10n,
    String language,
    LessonQuestionData? question,
    LessonSession session,
  ) {
    SiphoButton3D button(
      String label,
      VoidCallback onPressed, {
      bool enabled = true,
      bool loading = false,
    }) {
      return SiphoButton3D(
        label: label,
        onPressed: onPressed,
        enabled: enabled,
        isLoading: loading,
        color: AppColors.primary,
        shadowColor: AppColors.primaryDark,
        height: 52,
        borderRadius: figmaButtonRadius,
      );
    }

    if (session.isRecap) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_saveFailure != null) ...[
            Text(
              switch (_saveFailure!) {
                LessonSaveFailureKind.signedOut => l10n.lessonSaveErrorAuth,
                LessonSaveFailureKind.refused => l10n.lessonSaveErrorRefused,
                LessonSaveFailureKind.network ||
                LessonSaveFailureKind.unknown =>
                  l10n.lessonSaveError,
              },
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.terracotta,
              ),
            ),
            const SizedBox(height: 8),
          ],
          button(
            _saveFailure != null ? l10n.quizTryAgain : l10n.lessonRecapFinish,
            _finish,
            loading: _saving,
          ),
        ],
      );
    }
    if (question == null) {
      return button(l10n.continueBtn.toUpperCase(), _next);
    }
    if (!_checked) {
      return button(
        l10n.quizCheck,
        () => _check(question),
        enabled: _selected != null,
      );
    }
    final correct = _selected == question.correctIndex;
    return LessonResultBanner(
      title: correct ? l10n.quizExcellent : l10n.quizWrong,
      body: question.explanation,
      action: correct ? l10n.continueBtn.toUpperCase() : l10n.quizTryAgain,
      success: correct,
      onPressed: correct ? _next : _retry,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.progress,
    required this.closeLabel,
    required this.onClose,
    required this.animate,
  });

  final double progress;
  final String closeLabel;
  final VoidCallback onClose;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: closeLabel,
          onPressed: onClose,
          icon: const Icon(
            Icons.close,
            color: AppColors.textSecondary,
            size: 26,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: SizedBox(
              height: 12,
              child: Stack(
                children: [
                  const ColoredBox(color: AppColors.border),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: progress.clamp(0.05, 1)),
                    duration: animate
                        ? const Duration(milliseconds: 300)
                        : Duration.zero,
                    builder: (context, value, _) => FractionallySizedBox(
                      widthFactor: value,
                      child: const ColoredBox(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
