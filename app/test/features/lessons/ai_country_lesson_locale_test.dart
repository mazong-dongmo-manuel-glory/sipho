import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/lessons/domain/ai_country_lesson.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';

void main() {
  group('resolveLocalizedField', () {
    test('prefers user locale for legacy bilingual maps', () {
      const bilingual = {'fr': 'Bonjour', 'en': 'Hello'};
      expect(
        resolveLocalizedField(bilingual, preferredLocale: 'en'),
        'Hello',
      );
      expect(
        resolveLocalizedField(bilingual, preferredLocale: 'fr'),
        'Bonjour',
      );
    });

    test('falls back to the other language when preferred is missing', () {
      expect(
        resolveLocalizedField({'fr': 'Seul'}, preferredLocale: 'en'),
        'Seul',
      );
      expect(
        resolveLocalizedField({'en': 'Only'}, preferredLocale: 'fr'),
        'Only',
      );
    });
  });

  group('sanitizeMonolingualTitle', () {
    test('drops English half after & for French UI', () {
      expect(
        sanitizeMonolingualTitle('Mutuelle & Health Buffers', 'fr'),
        'Mutuelle',
      );
    });

    test('keeps clean monolingual titles', () {
      expect(
        sanitizeMonolingualTitle('Mutuelle et reste à charge', 'fr'),
        'Mutuelle et reste à charge',
      );
    });
  });

  test('resolveCountryLesson ignores AI in the wrong UI language', () {
    const placeholder = CatalogLesson(
      id: 'fr_slot_01',
      emoji: '🇫🇷',
      minutes: 3,
      titleFr: 'Créneau',
      titleEn: 'Slot',
      objective: LText('Obj FR', 'Obj EN'),
      steps: [],
      takeaways: [],
    );
    const ai = AiCountryLesson(
      slotId: 'fr_slot_01',
      emoji: '🏥',
      title: 'Health buffers',
      objective: 'Learn buffers',
      steps: [
        InfoStep(
          emoji: '📘',
          title: LText('A', 'A'),
          body: LText('B', 'B'),
          points: [],
        ),
        QuizStep(
          question: LText('Q?', 'Q?'),
          choices: [
            LessonChoice(fr: 'A', en: 'A', correct: true),
            LessonChoice(fr: 'B', en: 'B', correct: false),
          ],
          explanation: LText('E', 'E'),
        ),
      ],
      takeaways: [LText('T', 'T')],
      locale: 'en',
    );
    expect(
      resolveCountryLesson(placeholder, ai, uiLanguage: 'fr').titleFr,
      'Créneau',
    );
    expect(
      resolveCountryLesson(placeholder, ai, uiLanguage: 'en').titleEn,
      'Health buffers',
    );
  });
}
