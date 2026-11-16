/// A text in both launch languages. Anything that is not French is shown in English.
class LText {
  const LText(this.fr, this.en);

  final String fr;
  final String en;

  String of(String languageCode) =>
      languageCode.toLowerCase().startsWith('fr') ? fr : en;
}

/// One answer of a multiple-choice step.
class LessonChoice {
  const LessonChoice({
    required this.fr,
    required this.en,
    required this.correct,
  });

  final String fr;
  final String en;
  final bool correct;

  String text(String languageCode) =>
      languageCode.toLowerCase().startsWith('fr') ? fr : en;
}

/// A page of a lesson. A lesson is a short sequence of steps: something to read, then
/// something to answer, so that every idea is explained before it is checked.
sealed class LessonStep {
  const LessonStep();

  /// True for steps the learner answers (they count toward the accuracy).
  bool get isQuestion;
}

/// A page to read: a title, a short explanation and a few key points.
class InfoStep extends LessonStep {
  const InfoStep({
    required this.emoji,
    required this.title,
    required this.body,
    this.points = const [],
  });

  final String emoji;
  final LText title;
  final LText body;

  /// Three or fewer short bullet points that sum the page up.
  final List<LText> points;

  @override
  bool get isQuestion => false;
}

/// A multiple-choice question with exactly one right answer.
class QuizStep extends LessonStep {
  const QuizStep({
    required this.question,
    required this.choices,
    required this.explanation,
  });

  final LText question;
  final List<LessonChoice> choices;

  /// Shown after the answer, right or wrong: it teaches the idea again.
  final LText explanation;

  @override
  bool get isQuestion => true;

  int get correctIndex => choices.indexWhere((c) => c.correct);
}

/// A statement to judge true or false.
class TrueFalseStep extends LessonStep {
  const TrueFalseStep({
    required this.statement,
    required this.answer,
    required this.explanation,
  });

  final LText statement;

  /// Whether the statement is true.
  final bool answer;
  final LText explanation;

  @override
  bool get isQuestion => true;
}
