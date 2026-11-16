import 'package:flutter/material.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/animations/lottie_widget.dart';
import 'package:sipho/core/animations/sipho_lotties.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/lessons/data/lesson_ai_tutor_service.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';

const _font = 'Nunito';

/// Small uppercase label above a step ("DISCOVER", "QUESTION"…).
class LessonKicker extends StatelessWidget {
  const LessonKicker(this.text, {super.key, this.color = AppColors.primary});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: _font,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
        color: color,
      ),
    );
  }
}

/// A teaching step: an emoji, a title, a short explanation and a few key points.
class LessonInfoPage extends StatelessWidget {
  const LessonInfoPage({super.key, required this.step, required this.language});

  final InfoStep step;
  final String language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LessonKicker(l10n.lessonKickerRead),
          const SizedBox(height: 14),
          Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.mint,
              shape: BoxShape.circle,
            ),
            child: Text(step.emoji, style: const TextStyle(fontSize: 38)),
          ),
          const SizedBox(height: 16),
          Text(
            step.title.of(language),
            style: const TextStyle(
              fontFamily: _font,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.2,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            step.body.of(language),
            style: const TextStyle(
              fontFamily: _font,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: AppColors.primaryDark,
            ),
          ),
          if (step.points.isNotEmpty) const SizedBox(height: 16),
          for (final point in step.points) ...[
            _PointCard(text: point.of(language)),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _PointCard extends StatelessWidget {
  const _PointCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.check_circle, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: _font,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// What a question page needs, whatever the step type (quiz or true/false).
class LessonQuestionData {
  const LessonQuestionData({
    required this.kicker,
    required this.prompt,
    required this.labels,
    required this.badges,
    required this.correctIndex,
    required this.explanation,
  });

  final String kicker;
  final String prompt;
  final List<String> labels;

  /// What the leading square of each option shows (letters for a quiz, ✓/✕ for true/false).
  final List<String> badges;
  final int correctIndex;
  final String explanation;

  /// Builds the question view for a [QuizStep] or [TrueFalseStep]; null for a teaching step.
  static LessonQuestionData? of(
    LessonStep step,
    AppLocalizations l10n,
    String language,
  ) {
    switch (step) {
      case QuizStep():
        return LessonQuestionData(
          kicker: l10n.lessonKickerQuestion,
          prompt: step.question.of(language),
          labels: [for (final c in step.choices) c.text(language)],
          badges: [
            for (var i = 0; i < step.choices.length; i++)
              String.fromCharCode(65 + i),
          ],
          correctIndex: step.correctIndex,
          explanation: step.explanation.of(language),
        );
      case TrueFalseStep():
        return LessonQuestionData(
          kicker: l10n.lessonKickerTrueFalse,
          prompt: step.statement.of(language),
          labels: [l10n.lessonTrue, l10n.lessonFalse],
          badges: const ['✓', '✕'],
          correctIndex: step.answer ? 0 : 1,
          explanation: step.explanation.of(language),
        );
      case InfoStep():
        return null;
    }
  }
}

/// A question step: prompt, Sipho's mood, options, and the AI tutor once answered.
class LessonQuestionPage extends StatelessWidget {
  const LessonQuestionPage({
    super.key,
    required this.data,
    required this.selected,
    required this.checked,
    required this.onSelect,
    required this.tutor,
  });

  final LessonQuestionData data;
  final int? selected;
  final bool checked;
  final ValueChanged<int> onSelect;

  /// Shown under the options once the learner has answered.
  final Widget? tutor;

  @override
  Widget build(BuildContext context) {
    final correct = checked && selected == data.correctIndex;
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      children: [
        LessonKicker(data.kicker),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                data.prompt,
                style: const TextStyle(
                  fontFamily: _font,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: 8),
            correct
                ? const SiphoArt.happy(frame: 84)
                : checked
                    ? const SiphoArt.worried(frame: 84)
                    : const SiphoArt.proud(frame: 84),
          ],
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < data.labels.length; i++) ...[
          LessonOption(
            badge: data.badges[i],
            label: data.labels[i],
            selected: i == selected,
            correct: correct && i == data.correctIndex,
            onTap: checked ? null : () => onSelect(i),
          ),
          const SizedBox(height: 10),
        ],
        if (tutor != null) ...[const SizedBox(height: 4), tutor!],
      ],
    );
  }
}

class LessonOption extends StatelessWidget {
  const LessonOption({
    super.key,
    required this.badge,
    required this.label,
    required this.selected,
    required this.correct,
    required this.onTap,
  });

  final String badge;
  final String label;
  final bool selected;
  final bool correct;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final highlighted = selected || correct;
    final face = correct ? AppColors.primary : AppColors.quizBlue;
    final card = correct
        ? AppColors.mint
        : (selected ? AppColors.quizBlueBg : AppColors.surface);
    final border = correct
        ? AppColors.primary
        : (selected ? AppColors.quizBlue : AppColors.border);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
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
                  badge,
                  style: TextStyle(
                    fontFamily: _font,
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
                    fontFamily: _font,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
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

/// Feedback shown after an answer, with the single action that follows.
class LessonResultBanner extends StatelessWidget {
  const LessonResultBanner({
    super.key,
    required this.title,
    required this.body,
    required this.action,
    required this.onPressed,
    this.success = true,
  });

  final String title;
  final String body;
  final String action;
  final VoidCallback onPressed;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final tone = success ? AppColors.primary : AppColors.terracotta;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.info_outline,
              color: tone,
              size: 27,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: _font,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: tone,
                ),
              ),
            ),
            if (success)
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
            fontFamily: _font,
            fontSize: 14,
            height: 1.3,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 12),
        SiphoButton3D(
          label: action,
          onPressed: onPressed,
          color: AppColors.primary,
          shadowColor: AppColors.primaryDark,
          height: 52,
          borderRadius: figmaButtonRadius,
        ),
      ],
    );
  }
}

/// The last page: what to remember from the lesson, before it is submitted.
class LessonRecapPage extends StatelessWidget {
  const LessonRecapPage({
    super.key,
    required this.lesson,
    required this.language,
  });

  final CatalogLesson lesson;
  final String language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LessonKicker(l10n.lessonRecapTitle.toUpperCase()),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${lesson.emoji}  ${lesson.title(language)}',
                  style: const TextStyle(
                    fontFamily: _font,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SiphoArt.celebrating(frame: 96),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < lesson.takeaways.length; i++) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontFamily: _font,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      lesson.takeaways[i].of(language),
                      style: const TextStyle(
                        fontFamily: _font,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

/// AI tutor entry under an answered question: a chip, then the tutor's reply.
class LessonTutorCard extends StatelessWidget {
  const LessonTutorCard({
    super.key,
    required this.reply,
    required this.asking,
    required this.onAsk,
  });

  final LessonTutorReply? reply;
  final bool asking;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reply = this.reply;
    if (reply == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: ActionChip(
          backgroundColor: AppColors.seedPill,
          side: const BorderSide(color: AppColors.accent),
          label: Text(
            asking ? l10n.quizAiTutorLoading : l10n.quizAskAiTutor,
            style: const TextStyle(
              fontFamily: _font,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          onPressed: asking ? null : onAsk,
        ),
      );
    }
    return Container(
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
              fontFamily: _font,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.warnBrown,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            reply.example,
            style: const TextStyle(
              fontFamily: _font,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.25,
              color: AppColors.primaryDark,
            ),
          ),
          if (reply.tip.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '💡 ${reply.tip}',
              style: const TextStyle(
                fontFamily: _font,
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
              fontFamily: _font,
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
