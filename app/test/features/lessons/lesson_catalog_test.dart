import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';

void main() {
  const ids = ['emergency_fund', 'needs_wants', 'track_spending'];

  test('the path starts at the first lesson', () {
    expect(nextLessonId(ids, {}), 'emergency_fund');
    expect(lessonUnlocked(ids, {}, 0), isTrue);
    expect(lessonUnlocked(ids, {}, 1), isFalse);
  });

  test('finishing a lesson unlocks the next one', () {
    const done = {'emergency_fund'};
    expect(nextLessonId(ids, done), 'needs_wants');
    expect(lessonUnlocked(ids, done, 1), isTrue);
    expect(lessonUnlocked(ids, done, 2), isFalse);
  });

  test('a finished path has no next lesson', () {
    expect(nextLessonId(ids, ids.toSet()), isNull);
  });
}
