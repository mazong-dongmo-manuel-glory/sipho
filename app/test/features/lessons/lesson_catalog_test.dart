import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';

void main() {
  final ids = [for (final lesson in kCatalogLessons) lesson.id];

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

  group('units', () {
    test('lessons are unique and listed unit by unit', () {
      expect(ids.toSet().length, ids.length);
      expect(
        ids,
        [
          for (final unit in kCatalogUnits)
            for (final lesson in unit.lessons) lesson.id,
        ],
      );
      expect(unitOfLesson(kCatalogUnits, 'savings_goal')?.id, 'unit_2');
      expect(unitOfLesson(kCatalogUnits, 'nope'), isNull);
    });

    test('only the first unit is open at the start', () {
      final progress = unitProgressList(kCatalogUnits, {});
      expect(progress[0].unlocked, isTrue);
      expect(progress[0].done, 0);
      expect(progress[1].unlocked, isFalse);
      expect(currentUnit(kCatalogUnits, {})?.unit.id, 'unit_1');
    });

    test('a partly finished unit does not open the next one', () {
      final progress = unitProgressList(
        kCatalogUnits,
        {'emergency_fund', 'needs_wants'},
      );
      expect(progress[0].done, 2);
      expect(progress[0].completed, isFalse);
      expect(progress[0].ratio, closeTo(2 / 3, 0.001));
      expect(progress[1].unlocked, isFalse);
    });

    test('finishing a unit opens the next one and the first lesson of it', () {
      final unit1 = kCatalogUnits[0].lessons.map((l) => l.id).toSet();
      final progress = unitProgressList(kCatalogUnits, unit1);
      expect(progress[0].completed, isTrue);
      expect(progress[1].unlocked, isTrue);
      expect(currentUnit(kCatalogUnits, unit1)?.unit.id, 'unit_2');
      expect(lessonUnlocked(ids, unit1, ids.indexOf('savings_goal')), isTrue);
      expect(
        lessonUnlocked(ids, unit1, ids.indexOf('pay_yourself_first')),
        isFalse,
      );
    });

    test('a finished path has no current unit', () {
      expect(currentUnit(kCatalogUnits, ids.toSet()), isNull);
    });

    test('the lesson path matches the server (functions lessonPath.ts)', () {
      final file = File('../functions/src/shared/lessonPath.ts');
      if (!file.existsSync()) {
        markTestSkipped('functions/ not found from the app directory');
        return;
      }
      final source = file.readAsStringSync();
      final block = RegExp(r'LESSON_UNITS = \[(.*?)\] as const', dotAll: true)
          .firstMatch(source)!
          .group(1)!;
      final serverUnits = [
        for (final m in RegExp(
          r'id:\s*"(\w+)",\s*lessons:\s*\[(.*?)\]',
          dotAll: true,
        ).allMatches(block))
          '${m.group(1)!}: ${RegExp(r'"(\w+)"').allMatches(m.group(2)!).map((x) => x.group(1)!).join(', ')}',
      ];
      final appUnits = [
        for (final unit in kCatalogUnits)
          '${unit.id}: ${[for (final l in unit.lessons) l.id].join(', ')}',
      ];
      expect(appUnits, serverUnits);

      final config =
          File('../functions/src/shared/xpConfig.ts').readAsStringSync();
      final xp = int.parse(
        RegExp(r'unitComplete:\s*(\d+)').firstMatch(config)!.group(1)!,
      );
      final seeds = int.parse(
        RegExp(r'unitCompleteSeeds:\s*(\d+)').firstMatch(config)!.group(1)!,
      );
      for (final unit in kCatalogUnits) {
        expect(unit.bonusXp, xp);
        expect(unit.bonusSeeds, seeds);
      }
    });
  });
}
