import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/ai/sipho_ai_client.dart';
import 'package:sipho/core/animations/lottie_widget.dart';
import 'package:sipho/core/animations/sipho_lotties.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/insights/presentation/spend_snapshot_builder.dart';
import 'package:sipho/features/lessons/data/lesson_ai_tutor_service.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';
import 'package:sipho/features/lessons/domain/lesson_result.dart';

class LessonQuizScreen extends ConsumerStatefulWidget {
  const LessonQuizScreen({super.key, this.lessonId});

  final String? lessonId;

  @override
  ConsumerState<LessonQuizScreen> createState() => _LessonQuizScreenState();
}

class _LessonQuizScreenState extends ConsumerState<LessonQuizScreen> {
  int _selected = 0;
  bool _checked = false;
  bool _saving = false;
  bool _askingTutor = false;
  LessonTutorReply? _tutorReply;
  // Set when this completion finished the unit (the server pays the bonus).
  int? _unitBonusXp;
  int _unitBonusSeeds = 0;
  // Wrong answers before the right one: they lower the accuracy and the score sent to the server.
  int _misses = 0;
  // What the server paid, once `completeLesson` succeeded; shown on the end-of-lesson screen.
  LessonResult? _result;
  late final DateTime _startedAt = DateTime.now();

  CatalogLesson get _lesson {
    for (final lesson in kCatalogLessons) {
      if (lesson.id == widget.lessonId) return lesson;
    }
    return kCatalogLessons.first;
  }

  Future<void> _check(CatalogLesson lesson) async {
    final correct = lesson.choices[_selected].correct;
    if (!correct) {
      setState(() {
        _checked = true;
        _misses++;
      });
      unawaited(ref.read(feedbackServiceProvider).play(SiphoCue.lessonWrong));
      return;
    }
    setState(() {
      _checked = true;
      _saving = true;
    });
    unawaited(ref.read(feedbackServiceProvider).play(SiphoCue.lessonCorrect));
    final elapsedSeconds =
        DateTime.now().difference(_startedAt).inSeconds.clamp(2, 3600);
    final score = lessonScoreForMisses(_misses);
    try {
      final result = await ref
          .read(firebaseFunctionsProvider)
          .httpsCallable('completeLesson')
          .call<Map<String, dynamic>>({
        'lessonId': lesson.id,
        'score': score,
        'durationSeconds': elapsedSeconds,
      });
      final data = result.data;
      final lessonResult = LessonResult.fromCallable(
        data,
        accuracy: score,
        durationSeconds: elapsedSeconds,
      );
      if (mounted) {
        setState(() {
          _result = lessonResult;
          if (lessonResult.finishedUnit) {
            _unitBonusXp = lessonResult.unitBonusXp;
            _unitBonusSeeds = lessonResult.unitBonusSeeds;
          }
        });
      }
    } catch (error) {
      // No client-side fallback: lesson progress and XP are written by the `completeLesson`
      // Cloud Function only (Firestore rules refuse client writes to completedLessonIds).
      debugPrint('Lesson save failed: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).lessonSaveError)),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _askAiTutor(CatalogLesson lesson, String language) async {
    if (_askingTutor) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _askingTutor = true);
    try {
      final snapshot = buildCurrentSpendSnapshot(ref: ref, context: context);
      final reply = await ref.read(lessonAiTutorServiceProvider).explainForUser(
            lesson: lesson,
            selectedAnswer: lesson.choices[_selected].text(language),
            answeredCorrectly: lesson.choices[_selected].correct,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    // Keep finance streams hot for AI tutor context.
    final monthKey = currentMonthKey();
    ref.watch(userFinanceProvider);
    ref.watch(transactionsForMonthProvider(monthKey));
    ref.watch(activeFixedExpensesProvider);

    final lesson = _lesson;
    final correct = _checked && lesson.choices[_selected].correct;
    // Progress inside the lesson's own unit.
    final unitLessons =
        unitOfLesson(kCatalogUnits, lesson.id)?.lessons ?? kCatalogLessons;
    final progress =
        (unitLessons.indexWhere((item) => item.id == lesson.id) + 1) /
            unitLessons.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: SizedBox(
                        height: 12,
                        child: Stack(
                          children: [
                            const ColoredBox(color: AppColors.border),
                            FractionallySizedBox(
                              widthFactor: progress.clamp(0.05, 1),
                              child: const ColoredBox(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                lesson.title(language).toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lesson.question(language),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  color: AppColors.primaryDark,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.quizHint,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  correct
                      ? const SiphoArt.happy(frame: 96)
                      : _checked
                          ? const SiphoArt.worried(frame: 96)
                          : const SiphoArt.proud(frame: 96),
                ],
              ),
              Expanded(
                child: ListView(
                  children: [
                    for (var i = 0; i < lesson.choices.length; i++) ...[
                      _Option(
                        letter: String.fromCharCode(65 + i),
                        label: lesson.choices[i].text(language),
                        selected: i == _selected,
                        correct: correct && lesson.choices[i].correct,
                        onTap: _checked
                            ? null
                            : () => setState(() => _selected = i),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (_checked) ...[
                      const SizedBox(height: 4),
                      if (_tutorReply == null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ActionChip(
                            backgroundColor: AppColors.seedPill,
                            side: const BorderSide(color: AppColors.accent),
                            label: Text(
                              _askingTutor
                                  ? l10n.quizAiTutorLoading
                                  : l10n.quizAskAiTutor,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            onPressed: _askingTutor
                                ? null
                                : () => _askAiTutor(lesson, language),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.seedPill,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.accent),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '✨  ${l10n.quizAiTutorTitle}',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.warnBrown,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _tutorReply!.example,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              if (_tutorReply!.tip.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  '💡 ${_tutorReply!.tip}',
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Text(
                                l10n.adviceDisclaimer,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              if (_checked && correct)
                _ResultBanner(
                  title: l10n.quizExcellent,
                  body: _unitBonusXp == null
                      ? lesson.explanation(language)
                      : '${lesson.explanation(language)}\n\n'
                          '🎓 ${l10n.lessonUnitCompleted(_unitBonusXp!, _unitBonusSeeds)}',
                  action: l10n.continueBtn.toUpperCase(),
                  loading: _saving,
                  onPressed: () {
                    final result = _result;
                    if (result == null) {
                      context.pop();
                    } else {
                      // Replace the quiz: "back" from the celebration returns to the path.
                      context.pushReplacement('/lesson-done', extra: result);
                    }
                  },
                )
              else if (_checked)
                _ResultBanner(
                  title: l10n.quizWrong,
                  body: lesson.explanation(language),
                  action: l10n.quizTryAgain,
                  tone: AppColors.terracotta,
                  onPressed: () => setState(() {
                    _checked = false;
                    _tutorReply = null;
                  }),
                )
              else
                SiphoButton3D(
                  label: l10n.quizCheck,
                  onPressed: () => _check(lesson),
                  color: AppColors.primary,
                  shadowColor: AppColors.primaryDark,
                  height: 52,
                  borderRadius: figmaButtonRadius,
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({
    required this.title,
    required this.body,
    required this.action,
    required this.onPressed,
    this.loading = false,
    this.tone = AppColors.primary,
  });

  final String title;
  final String body;
  final String action;
  final VoidCallback onPressed;
  final bool loading;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                tone == AppColors.primary
                    ? Icons.check_circle
                    : Icons.info_outline,
                color: tone,
                size: 27,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: tone,
                  ),
                ),
              ),
              if (tone == AppColors.primary)
                const LottieWidget(
                  assetPath: SiphoLotties.xpCoins,
                  width: 48,
                  height: 36,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          SiphoButton3D(
            label: action,
            isLoading: loading,
            onPressed: onPressed,
            color: AppColors.primary,
            shadowColor: AppColors.primaryDark,
            height: 52,
            borderRadius: figmaButtonRadius,
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.letter,
    required this.label,
    required this.selected,
    required this.correct,
    required this.onTap,
  });

  final String letter;
  final String label;
  final bool selected;
  final bool correct;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final highlighted = selected || correct;
    final face = correct
        ? AppColors.primary
        : (selected ? AppColors.quizBlue : AppColors.background);
    final card = correct
        ? AppColors.mint
        : (selected ? AppColors.quizBlueBg : AppColors.surface);
    final border = correct
        ? AppColors.primary
        : (selected ? AppColors.quizBlue : AppColors.border);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: highlighted ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: highlighted ? face : AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                letter,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: highlighted ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
