import 'package:sipho/features/lessons/domain/lesson_catalog.dart';
import 'package:sipho/features/lessons/domain/lesson_result.dart';

/// Where the learner is in a lesson: which page, how many wrong answers so far.
///
/// The pages are the lesson's steps followed by a final "to remember" page ([isRecap]). Pure
/// state, no UI: the player screen drives it and reads the score from it.
class LessonSession {
  LessonSession(this.lesson);

  final CatalogLesson lesson;
  int _index = 0;
  int _misses = 0;

  /// Steps plus the final recap page.
  int get pageCount => lesson.steps.length + 1;

  /// 0-based page being shown.
  int get index => _index;

  bool get isRecap => _index >= lesson.steps.length;

  /// The step being shown, or null on the recap page.
  LessonStep? get step => isRecap ? null : lesson.steps[_index];

  int get misses => _misses;

  /// Wrong answers lower the accuracy; the learner stays on the step until it is right.
  void recordMiss() => _misses++;

  /// Moves to the next page. Does nothing past the recap page.
  void advance() {
    if (_index < pageCount - 1) _index++;
  }

  /// Share of the lesson already behind the learner, 0 → 1. Reaches 1 on the recap page.
  double get progress => pageCount == 0 ? 1 : _index / (pageCount - 1);

  /// Score to send to the server once the lesson is finished.
  int get score =>
      lessonScore(questions: lesson.questionCount, misses: _misses);
}
