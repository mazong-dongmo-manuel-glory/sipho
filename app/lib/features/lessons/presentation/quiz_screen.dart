import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/ai/sipho_ai_client.dart';
import '../../../core/feedback/feedback_cue.dart';
import '../../../core/feedback/feedback_service.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../auth/data/user_profile_provider.dart';
import '../../expenses/data/expenses_provider.dart';
import '../../fixed_expenses/data/fixed_expenses_provider.dart';
import '../data/lesson_ai_tutor_service.dart';
import '../domain/lesson_content.dart';
import '../domain/lesson_score.dart';

/// Frames 16a / 16b · Quiz + bonne réponse + tuteur IA.
class QuizScreen extends ConsumerStatefulWidget {
  final String lessonId;
  final String title;
  final bool startCorrect;
  final int priorMistakes;

  const QuizScreen({
    super.key,
    this.lessonId = 'emergency_fund',
    this.title = 'Un coussin pour les imprévus',
    this.startCorrect = false,
    this.priorMistakes = 0,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int? _selected;
  bool _checked = false;
  bool _tutorBusy = false;
  bool _everWrong = false;
  LessonTutorReply? _tutorReply;
  final _startedAt = DateTime.now();
  late final LessonQuizContent _content = lessonContentFor(widget.lessonId);

  @override
  void initState() {
    super.initState();
    if (widget.startCorrect) {
      _selected = _content.correctIndex;
      _checked = true;
    }
  }

  Future<void> _askTutor() async {
    if (_tutorBusy || _selected == null) return;
    setState(() => _tutorBusy = true);
    final l10n = AppLocalizations.of(context);
    final fr = Localizations.localeOf(context).languageCode == 'fr';
    final options = _content.options(fr);
    final user = ref.read(userProfileProvider);
    final fixed = ref.read(totalFixedExpensesCentsProvider);
    final expenses = ref.read(expensesProvider);
    final cats = <String, int>{};
    var variable = 0;
    for (final e in expenses) {
      cats[e.category] = (cats[e.category] ?? 0) + (e.amountMainCents ?? e.amount.cents);
      variable += e.amountMainCents ?? e.amount.cents;
    }
    try {
      final reply = await ref.read(lessonAiTutorServiceProvider).explainForUser(
            lessonTitle: widget.title,
            question: _content.question(fr),
            explanation: _content.explain(fr),
            selectedAnswer: options[_selected!],
            answeredCorrectly: _selected == _content.correctIndex,
            snapshot: TutorSpendSnapshot(
              locale: Localizations.localeOf(context).toLanguageTag(),
              currency: user.currency,
              countryCode: user.countryCode,
              incomeCents: user.monthlyIncomeCents,
              fixedCents: fixed,
              totalCents: variable,
              categoryCents: cats,
            ),
          );
      if (!mounted) return;
      setState(() {
        _tutorReply = reply;
        _tutorBusy = false;
      });
    } on SiphoAiException catch (e) {
      if (!mounted) return;
      setState(() => _tutorBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: SiphoColors.primaryDark,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _tutorBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authErrorGeneric),
          backgroundColor: SiphoColors.primaryDark,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fr = Localizations.localeOf(context).languageCode == 'fr';
    final options = _content.options(fr);
    final correct = _content.correctIndex;
    final isCorrect = _checked && _selected == correct;

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.close_rounded,
                        color: SiphoPalette.textPrimary(context)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: isCorrect ? 0.7 : 0.45,
                        minHeight: 8,
                        backgroundColor: SiphoColors.separator,
                        valueColor:
                            const AlwaysStoppedAnimation(SiphoColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  if (isCorrect) ...[
                    Text(
                      l10n.quizCorrectHeading,
                      style: SiphoTypography.title.copyWith(
                        fontSize: 28,
                        color: SiphoPalette.textPrimary(context),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.quizCorrectLead,
                      style: SiphoTypography.body.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 96,
                        height: 96,
                        child: SvgPicture.asset(
                          'assets/images/sipho_proud.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SiphoSoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            options[correct],
                            style: SiphoTypography.bodyBold.copyWith(
                              fontSize: 16,
                              color: SiphoPalette.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _content.explain(fr),
                            style: SiphoTypography.body.copyWith(
                              fontSize: 16,
                              color: SiphoPalette.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.quizCorrectXp,
                      style: SiphoTypography.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: SiphoColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _tutorBusy ? null : _askTutor,
                      child: Text(
                        _tutorBusy
                            ? l10n.quizAiTutorLoading
                            : l10n.quizAskAiTutor,
                        style: SiphoTypography.bodyBold.copyWith(
                          color: SiphoColors.primary,
                        ),
                      ),
                    ),
                    if (_tutorReply != null) ...[
                      const SizedBox(height: 8),
                      SiphoSoftCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _tutorReply!.example,
                              style: SiphoTypography.body.copyWith(
                                fontSize: 15,
                                color: SiphoPalette.textPrimary(context),
                              ),
                            ),
                            if (_tutorReply!.tip.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                _tutorReply!.tip,
                                style: SiphoTypography.bodyBold.copyWith(
                                  fontSize: 14,
                                  color: SiphoColors.primaryDark,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ] else ...[
                    Text(
                      widget.title,
                      style: SiphoTypography.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _content.question(fr),
                      style: SiphoTypography.title.copyWith(
                        fontSize: 28,
                        color: SiphoPalette.textPrimary(context),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(options.length, (i) {
                      final selected = _selected == i;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: InkWell(
                          onTap: _checked
                              ? null
                              : () => setState(() => _selected = i),
                          child: SiphoSoftCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    options[i],
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: SiphoTypography.bodyBold.copyWith(
                                      fontSize: 16,
                                      color: SiphoPalette.textPrimary(context),
                                    ),
                                  ),
                                ),
                                if (selected)
                                  Icon(
                                    _checked
                                        ? (i == correct
                                            ? Icons.check_circle
                                            : Icons.cancel)
                                        : Icons.radio_button_checked,
                                    color: _checked
                                        ? (i == correct
                                            ? SiphoColors.primary
                                            : SiphoColors.danger)
                                        : SiphoColors.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (_checked && !isCorrect)
                      SiphoSoftCard(
                        child: Text(
                          l10n.quizWrongHint,
                          style: SiphoTypography.bodyBold.copyWith(
                            fontSize: 16,
                            color: SiphoPalette.textPrimary(context),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SiphoButton3D(
                label: _checked ? l10n.continueBtn : l10n.quizCheck,
                variant: SiphoButtonVariant.dark,
                onPressed: _selected == null
                    ? null
                    : () {
                        if (!_checked) {
                          final wrong = _selected != correct;
                          setState(() {
                            _checked = true;
                            if (wrong) _everWrong = true;
                          });
                          ref.read(feedbackServiceProvider).play(
                                wrong
                                    ? SiphoCue.lessonWrong
                                    : SiphoCue.lessonCorrect,
                              );
                          return;
                        }
                        if (!isCorrect) {
                          setState(() {
                            _checked = false;
                            _selected = null;
                          });
                          return;
                        }
                        final seconds =
                            DateTime.now().difference(_startedAt).inSeconds;
                        final score = lessonCompletionScore(
                          priorMistakes: widget.priorMistakes,
                          quizEverWrong: _everWrong,
                        );
                        final perfect = score == 100;
                        context.push('/lesson-done', extra: {
                          'lessonId': widget.lessonId,
                          'xp': perfect ? 30 : 20,
                          'perfect': perfect,
                          'durationSeconds': seconds < 2 ? 2 : seconds,
                        });
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
