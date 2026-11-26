import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/feedback/feedback_cue.dart';
import '../../../core/feedback/feedback_service.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_page_header.dart';
import '../domain/lesson_content.dart';
import '../domain/lesson_score.dart';

enum LessonStepKind { card, trueFalse, simulation }

/// Frames 37 / 38 / 39 · Étapes de leçon (carte, vrai/faux, mini-simulation).
class LessonStepsScreen extends ConsumerStatefulWidget {
  final LessonStepKind kind;
  final String lessonId;
  final String title;
  final int priorMistakes;

  const LessonStepsScreen({
    super.key,
    required this.kind,
    this.lessonId = 'emergency_fund',
    this.title = 'Un coussin pour les imprévus',
    this.priorMistakes = 0,
  });

  @override
  ConsumerState<LessonStepsScreen> createState() => _LessonStepsScreenState();
}

class _LessonStepsScreenState extends ConsumerState<LessonStepsScreen> {
  bool? _trueFalseAnswer;
  bool _checked = false;
  int? _simChoice;

  void _answerTrueFalse(bool answer, bool expected) {
    setState(() {
      _trueFalseAnswer = answer;
      _checked = true;
    });
    ref.read(feedbackServiceProvider).play(
          answer == expected ? SiphoCue.lessonCorrect : SiphoCue.lessonWrong,
        );
  }

  void _answerSim(int index, int expected) {
    final first = _simChoice == null;
    setState(() => _simChoice = index);
    if (!first) return;
    ref.read(feedbackServiceProvider).play(
          index == expected ? SiphoCue.lessonCorrect : SiphoCue.lessonWrong,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fr = Localizations.localeOf(context).languageCode == 'fr';
    final content = lessonContentFor(widget.lessonId);

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
                        value: switch (widget.kind) {
                          LessonStepKind.card => 0.25,
                          LessonStepKind.trueFalse => 0.75,
                          LessonStepKind.simulation => 0.9,
                        },
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
                  if (widget.kind == LessonStepKind.card) ...[
                    SiphoPageHeader(
                      title: widget.title,
                      lead: '1 / 4',
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 92,
                        height: 92,
                        child: SvgPicture.asset(
                          'assets/images/sipho_happy.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      content.cardBody(fr),
                      style: SiphoTypography.body.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textPrimary(context),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.lessonCardSource,
                      style: SiphoTypography.label.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                  ] else if (widget.kind == LessonStepKind.trueFalse) ...[
                    SiphoPageHeader(
                      title: content.tfStatement(fr),
                      lead: '3 / 4',
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 92,
                        height: 92,
                        child: SvgPicture.asset(
                          'assets/images/sipho_happy.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SiphoButton3D(
                      label: l10n.lessonTfTrue,
                      variant: SiphoButtonVariant.dark,
                      onPressed: _checked
                          ? null
                          : () => _answerTrueFalse(true, content.tfAnswer),
                    ),
                    const SizedBox(height: 12),
                    SiphoButton3D(
                      label: l10n.lessonTfFalse,
                      variant: SiphoButtonVariant.outline,
                      onPressed: _checked
                          ? null
                          : () => _answerTrueFalse(false, content.tfAnswer),
                    ),
                    if (_checked) ...[
                      const SizedBox(height: 16),
                      Text(
                        _trueFalseAnswer == content.tfAnswer
                            ? content.tfCorrect(fr)
                            : content.tfWrong(fr),
                        style: SiphoTypography.bodyBold.copyWith(
                          color: _trueFalseAnswer == content.tfAnswer
                              ? SiphoColors.primary
                              : SiphoColors.accentTerra,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      l10n.lessonTfHint,
                      style: SiphoTypography.body.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.lessonCardSource,
                      style: SiphoTypography.label.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                  ] else ...[
                    SiphoPageHeader(
                      title: content.simPrompt(fr),
                      lead: '4 / 4',
                    ),
                    const SizedBox(height: 20),
                    for (var i = 0; i < content.simOptions(fr).length; i++) ...[
                      _SimOption(
                        label: content.simOptions(fr)[i],
                        selected: _simChoice == i,
                        onTap: () => _answerSim(i, content.simCorrectIndex),
                      ),
                      if (i < content.simOptions(fr).length - 1)
                        const SizedBox(height: 10),
                    ],
                    if (_simChoice != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _simChoice == content.simCorrectIndex
                            ? content.simGood(fr)
                            : content.simOther(fr),
                        style: SiphoTypography.bodyBold.copyWith(
                          color: SiphoPalette.textPrimary(context),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SiphoButton3D(
                label: l10n.continueBtn,
                variant: SiphoButtonVariant.dark,
                onPressed: () {
                  final mistakes = lessonMistakesAfterAnswer(
                    priorMistakes: widget.priorMistakes,
                    answered: widget.kind == LessonStepKind.trueFalse
                        ? _checked
                        : widget.kind == LessonStepKind.simulation &&
                            _simChoice != null,
                    correct: widget.kind == LessonStepKind.trueFalse
                        ? _trueFalseAnswer == content.tfAnswer
                        : _simChoice == content.simCorrectIndex,
                  );
                  final extra = {
                    'id': widget.lessonId,
                    'title': widget.title,
                    'priorMistakes': mistakes,
                  };
                  if (widget.kind == LessonStepKind.card) {
                    context.pushReplacement('/lesson/true-false', extra: extra);
                  } else if (widget.kind == LessonStepKind.trueFalse) {
                    context.pushReplacement('/lesson/simulation', extra: extra);
                  } else {
                    context.pushReplacement('/quiz', extra: extra);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SimOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? SiphoPalette.selectedChip(context)
              : SiphoPalette.softSurface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? SiphoColors.primary : SiphoPalette.separator(context),
          ),
        ),
        child: Text(
          label,
          style: SiphoTypography.bodyBold.copyWith(
            fontSize: 16,
            color: SiphoPalette.textPrimary(context),
          ),
        ),
      ),
    );
  }
}
