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
import 'package:sipho/features/lessons/data/lesson_ai_tutor_service.dart';
import 'package:sipho/features/lessons/data/lesson_completion_repository.dart';
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
  late final LessonSession _session = LessonSession(_lesson);
  late final DateTime _startedAt = DateTime.now();

  int? _selected;
  bool _checked = false;
  bool _saving = false;
  bool _saveFailed = false;
  bool _askingTutor = false;
  LessonTutorReply? _tutorReply;

  CatalogLesson get _lesson {
    for (final lesson in kCatalogLessons) {
      if (lesson.id == widget.lessonId) return lesson;
    }
    return kCatalogLessons.first;
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
      if (!correct) _session.recordMiss();
    });
    unawaited(
      ref.read(feedbackServiceProvider).play(
            correct ? SiphoCue.lessonCorrect : SiphoCue.lessonWrong,
          ),
    );
  }

  void _retry() => setState(_resetStepState);

  void _next() => setState(() {
        _session.advance();
        _resetStepState();
      });

  Future<void> _finish() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _saveFailed = false;
    });
    final seconds = DateTime.now().difference(_startedAt).inSeconds;
    try {
      final result =
          await ref.read(lessonCompletionRepositoryProvider).complete(
                lessonId: _lesson.id,
                score: _session.score,
                durationSeconds: seconds,
              );
      if (!mounted) return;
      // Replace the player: "back" from the celebration returns to the path.
      context.pushReplacement('/lesson-done', extra: result);
    } catch (error) {
      // No client-side fallback: progress and XP are written by the `completeLesson` Cloud
      // Function only (Firestore rules refuse client writes to completedLessonIds).
      debugPrint('Lesson save failed: $error');
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveFailed = true;
      });
    }
  }

  Future<void> _askAiTutor(LessonQuestionData question, String language) async {
    final selected = _selected;
    if (_askingTutor || selected == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _askingTutor = true);
    try {
      final snapshot = buildCurrentSpendSnapshot(ref: ref, context: context);
      final reply = await ref.read(lessonAiTutorServiceProvider).explainForUser(
            lesson: _lesson,
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
    final started = _session.index > 0 || _selected != null;
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
    // Keep finance streams hot for the AI tutor context.
    final monthKey = currentMonthKey();
    ref.watch(userFinanceProvider);
    ref.watch(transactionsForMonthProvider(monthKey));
    ref.watch(activeFixedExpensesProvider);

    final lesson = _lesson;
    final step = _session.step;
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
                  progress: _session.progress,
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
                      key: ValueKey(_session.index),
                      child: page,
                    ),
                  ),
                ),
                _footer(l10n, language, question),
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

    if (_session.isRecap) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_saveFailed) ...[
            Text(
              l10n.lessonSaveError,
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
            _saveFailed ? l10n.quizTryAgain : l10n.lessonRecapFinish,
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
