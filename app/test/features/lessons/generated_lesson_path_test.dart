import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/lessons/domain/generated_lesson_path.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';

void main() {
  test('generated ids are gen_ plus three digits', () {
    expect(isGeneratedLessonId('gen_001'), isTrue);
    expect(isGeneratedLessonId('gen_12'), isFalse);
    expect(isGeneratedLessonId('ca_slot_01'), isFalse);
  });

  test('the next lesson is requested only after the static path', () {
    final first = kCatalogLessons.first.id;
    expect(
      needsAnotherGeneratedLesson(generatedIds: const [], completed: {first}),
      isFalse,
    );
    final all = {for (final lesson in kCatalogLessons) lesson.id};
    expect(
      needsAnotherGeneratedLesson(generatedIds: const [], completed: all),
      isTrue,
    );
    expect(
      needsAnotherGeneratedLesson(
        generatedIds: const ['gen_001'],
        completed: all,
      ),
      isFalse,
    );
    expect(
      needsAnotherGeneratedLesson(
        generatedIds: const ['gen_001'],
        completed: {...all, 'gen_001'},
      ),
      isTrue,
    );
  });

  test('generated lessons are grouped by three and the count is not fixed', () {
    final seed = kCatalogLessons.first;
    final lessons = [
      for (var i = 1; i <= 4; i++)
        CatalogLesson(
          id: 'gen_00$i',
          emoji: seed.emoji,
          minutes: seed.minutes,
          titleFr: seed.titleFr,
          titleEn: seed.titleEn,
          objective: seed.objective,
          steps: seed.steps,
          takeaways: seed.takeaways,
        ),
    ];
    final units = generatedUnits(lessons);
    expect(units, hasLength(2));
    expect(units.first.lessons, hasLength(3));
    expect(units.last.lessons.single.id, 'gen_004');
  });
}
