import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/lessons/domain/ai_country_lesson.dart';

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

    test('keeps monolingual strings as-is', () {
      expect(
        resolveLocalizedField('Plain', preferredLocale: 'en'),
        'Plain',
      );
    });
  });

  test('AiCountryLesson.fromJson picks bilingual title by preferredLocale', () {
    final json = <String, dynamic>{
      'title': {'fr': 'Titre FR', 'en': 'Title EN'},
      'objective': {'fr': 'Obj FR', 'en': 'Obj EN'},
      'emoji': '🇨🇦',
      'steps': [
        {
          'type': 'info',
          'emoji': '📘',
          'title': {'fr': 'Info FR', 'en': 'Info EN'},
          'body': {'fr': 'Corps FR', 'en': 'Body EN'},
          'points': [
            {'fr': 'P1 FR', 'en': 'P1 EN'},
          ],
        },
        {
          'type': 'quiz',
          'question': {'fr': 'Q FR?', 'en': 'Q EN?'},
          'choices': [
            {'fr': 'A FR', 'en': 'A EN', 'correct': true},
            {'fr': 'B FR', 'en': 'B EN', 'correct': false},
          ],
          'explanation': {'fr': 'Ex FR', 'en': 'Ex EN'},
        },
      ],
      'takeaways': [
        {'fr': 'T FR', 'en': 'T EN'},
      ],
    };

    final en = AiCountryLesson.fromJson(
      'ca_slot_01',
      json,
      preferredLocale: 'en',
    );
    expect(en.title, 'Title EN');
    expect(en.objective, 'Obj EN');
    expect(en.locale, 'en');

    final fr = AiCountryLesson.fromJson(
      'ca_slot_01',
      json,
      preferredLocale: 'fr',
    );
    expect(fr.title, 'Titre FR');
    expect(fr.locale, 'fr');
  });
}
