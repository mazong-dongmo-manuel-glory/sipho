import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';
import 'package:sipho/features/lessons/domain/lesson_session.dart';

bool _filled(LText text) =>
    text.fr.trim().isNotEmpty && text.en.trim().isNotEmpty;

void main() {
  group('lesson content', () {
    test('every lesson has teaching, questions and exactly 3 takeaways', () {
      for (final lesson in kCatalogLessons) {
        expect(lesson.steps.whereType<InfoStep>(), isNotEmpty,
            reason: '${lesson.id} must teach before it asks');
        expect(lesson.questionCount, greaterThanOrEqualTo(2),
            reason: '${lesson.id} needs a few questions');
        expect(lesson.takeaways, hasLength(3), reason: lesson.id);
        expect(lesson.minutes, greaterThan(0), reason: lesson.id);
      }
    });

    test('a lesson opens by teaching, never with a question', () {
      for (final lesson in kCatalogLessons) {
        expect(lesson.steps.first, isA<InfoStep>(), reason: lesson.id);
      }
    });

    test('every quiz has one right answer among at least two choices', () {
      for (final lesson in kCatalogLessons) {
        for (final step in lesson.steps.whereType<QuizStep>()) {
          expect(step.choices.length, inInclusiveRange(2, 4),
              reason: lesson.id);
          expect(step.choices.where((c) => c.correct), hasLength(1),
              reason: '${lesson.id}: ${step.question.en}');
          expect(step.correctIndex, greaterThanOrEqualTo(0));
        }
      }
    });

    test('the right answer is not always the first choice', () {
      final positions = {
        for (final lesson in kCatalogLessons)
          for (final step in lesson.steps.whereType<QuizStep>())
            step.correctIndex,
      };
      expect(positions.length, greaterThan(1));
    });

    test('true/false answers are not always the same', () {
      final answers = {
        for (final lesson in kCatalogLessons)
          for (final step in lesson.steps.whereType<TrueFalseStep>())
            step.answer,
      };
      expect(answers, {true, false});
    });

    test('everything is written in French and in English', () {
      for (final lesson in kCatalogLessons) {
        expect(lesson.titleFr.trim(), isNotEmpty);
        expect(lesson.titleEn.trim(), isNotEmpty);
        expect(_filled(lesson.objective), isTrue, reason: lesson.id);
        for (final text in lesson.takeaways) {
          expect(_filled(text), isTrue, reason: lesson.id);
        }
        for (final step in lesson.steps) {
          switch (step) {
            case InfoStep():
              expect(_filled(step.title), isTrue, reason: lesson.id);
              expect(_filled(step.body), isTrue, reason: lesson.id);
              expect(step.points.every(_filled), isTrue, reason: lesson.id);
            case QuizStep():
              expect(_filled(step.question), isTrue, reason: lesson.id);
              expect(_filled(step.explanation), isTrue, reason: lesson.id);
              for (final choice in step.choices) {
                expect(choice.fr.trim(), isNotEmpty, reason: lesson.id);
                expect(choice.en.trim(), isNotEmpty, reason: lesson.id);
              }
            case TrueFalseStep():
              expect(_filled(step.statement), isTrue, reason: lesson.id);
              expect(_filled(step.explanation), isTrue, reason: lesson.id);
          }
        }
      }
    });

    test('every unit has a subtitle', () {
      for (final unit in kCatalogUnits) {
        expect(_filled(unit.subtitle), isTrue, reason: unit.id);
      }
    });

    test('text picks the language, English being the fallback', () {
      const text = LText('Bonjour', 'Hello');
      expect(text.of('fr'), 'Bonjour');
      expect(text.of('fr-CA'), 'Bonjour');
      expect(text.of('en'), 'Hello');
      expect(text.of('es'), 'Hello');
    });

    test('the max XP shown matches the perfect-lesson XP of the server', () {
      final file = File('../functions/src/shared/xpConfig.ts');
      if (!file.existsSync()) {
        markTestSkipped('functions/ not found from the app directory');
        return;
      }
      final perfect = int.parse(
        RegExp(r'lessonPerfect:\s*(\d+)')
            .firstMatch(file.readAsStringSync())!
            .group(1)!,
      );
      expect(kLessonMaxXp, perfect);
    });
  });

  group('LessonSession', () {
    final lesson = kCatalogLessons.first;

    test('starts on the first step with no miss and an empty bar', () {
      final session = LessonSession(lesson);
      expect(session.index, 0);
      expect(session.step, same(lesson.steps.first));
      expect(session.isRecap, isFalse);
      expect(session.misses, 0);
      expect(session.progress, 0);
      expect(session.pageCount, lesson.steps.length + 1);
    });

    test('ends on the recap page and does not go past it', () {
      final session = LessonSession(lesson);
      for (var i = 0; i < lesson.steps.length; i++) {
        expect(session.isRecap, isFalse);
        session.advance();
      }
      expect(session.isRecap, isTrue);
      expect(session.step, isNull);
      expect(session.progress, 1);
      session.advance();
      expect(session.index, lesson.steps.length);
    });

    test('progress rises with each page', () {
      final session = LessonSession(lesson);
      var previous = session.progress;
      while (!session.isRecap) {
        session.advance();
        expect(session.progress, greaterThan(previous));
        previous = session.progress;
      }
    });

    test('no miss is a perfect score, misses lower it', () {
      final clean = LessonSession(lesson);
      expect(clean.score, 100);

      final missed = LessonSession(lesson)..recordMiss();
      expect(missed.misses, 1);
      expect(missed.score, lessThan(100));
      final worse = LessonSession(lesson)
        ..recordMiss()
        ..recordMiss();
      expect(worse.score, lessThan(missed.score));
    });
  });
}
