import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/lessons/domain/ai_country_lesson.dart';
import 'package:sipho/features/lessons/domain/country_lesson_catalog.dart';
import 'package:sipho/features/lessons/domain/country_lesson_catalog_extra.dart';

void main() {
  test('each supported country exposes $kSlotsPerCountry slots', () {
    expect(countryUnitsFor('CA').single.lessons, hasLength(kSlotsPerCountry));
    expect(countryUnitsFor('FR').single.lessons, hasLength(kSlotsPerCountry));
    expect(countryUnitsFor('CM').single.lessons, hasLength(kSlotsPerCountry));
    expect(countryUnitsFor('CI').single.lessons, hasLength(kSlotsPerCountry));
    expect(countryUnitsFor('SN').single.lessons, hasLength(kSlotsPerCountry));
    expect(countryUnitsFor('ZZ').single.lessons, hasLength(kSlotsPerCountry));
    expect(countrySlotIdsFor('CA').first, 'ca_slot_01');
    expect(countrySlotIdsFor('CA').last, 'ca_slot_10');
  });

  test('playable country slot ids match server COUNTRY_SLOTS shape', () {
    final server = File('../functions/src/shared/countryLessonTopics.ts')
        .readAsStringSync();
    expect(server, contains('SLOTS_PER_COUNTRY'));
    expect(server, contains(r'${pack.prefix}_slot_'));
    expect(server, contains('prefix: "ca"'));
    expect(server, contains('prefix: "gen"'));

    final expected = {
      for (final pack in kCountrySlotPacks)
        for (var i = 1; i <= kSlotsPerCountry; i++)
          countrySlotId(pack.prefix, i),
    };
    expect(kCountryCatalogLessons.map((l) => l.id).toSet(), expected);
    expect(expected.length, kCountrySlotPacks.length * kSlotsPerCountry);
  });

  test('isCountrySlotId accepts only awardable slot patterns', () {
    expect(isCountrySlotId('ca_slot_01'), isTrue);
    expect(isCountrySlotId('gen_slot_10'), isTrue);
    expect(isCountrySlotId('ca_tfsa_101'), isFalse);
    expect(isCountrySlotId('ca_topic_0001'), isFalse);
  });

  test('monolingual AI overlay replaces slot placeholder when playable', () {
    final slot = kCountryCatalogLessons.firstWhere((l) => l.id == 'ca_slot_01');
    final ai = AiCountryLesson.fromJson('ca_slot_01', {
      'slotId': 'ca_slot_01',
      'topicId': 'ca_topic_0001',
      'locale': 'fr',
      'personalized': true,
      'monolingual': true,
      'emoji': '✨',
      'title': 'Titre IA monolingue',
      'objective': 'Objectif clair pour le créneau',
      'steps': [
        {
          'type': 'info',
          'emoji': '📘',
          'title': 'Intro',
          'body': 'Corps assez long pour la leçon',
          'points': ['Point un'],
        },
        {
          'type': 'quiz',
          'question': 'Question ?',
          'choices': [
            {'text': 'A', 'correct': true},
            {'text': 'B', 'correct': false},
            {'text': 'C', 'correct': false},
          ],
          'explanation': 'Parce que',
        },
        {
          'type': 'trueFalse',
          'statement': 'Vrai ?',
          'answer': false,
          'explanation': 'Non',
        },
      ],
      'takeaways': ['Un', 'Deux'],
    });
    expect(ai.isPlayable, isTrue);
    expect(ai.locale, 'fr');
    expect(ai.topicId, 'ca_topic_0001');
    final merged = resolveCountryLesson(slot, ai);
    expect(merged.id, 'ca_slot_01');
    expect(merged.titleFr, 'Titre IA monolingue');
    expect(merged.titleEn, 'Titre IA monolingue');
    expect(merged.steps.length, 3);
  });

  test('AiLessonsMeta parses lastTopicId for anti-repeat', () {
    final meta = AiLessonsMeta.fromJson({
      'lastTopicId': 'ca_topic_0042',
      'lastSlotId': 'ca_slot_03',
      'recentTopicIds': ['ca_topic_0042', 'ca_topic_0001'],
    });
    expect(meta.lastTopicId, 'ca_topic_0042');
    expect(meta.lastSlotId, 'ca_slot_03');
    expect(meta.recentTopicIds, ['ca_topic_0042', 'ca_topic_0001']);
  });
}
