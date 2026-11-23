import 'package:sipho/features/lessons/domain/country_lesson_catalog_extra.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';

/// Country **slots** (awardable ids). Content is AI-generated into
/// `users/{uid}/aiLessons/{slotId}` — keep ids in sync with
/// `COUNTRY_SLOTS` in `functions/src/shared/countryLessonTopics.ts`.

class CountryCatalogUnit {
  const CountryCatalogUnit({
    required this.countries,
    required this.unit,
  });

  final List<String> countries;
  final CatalogUnit unit;

  bool matches(String? countryCode) {
    if (countries.contains('*')) return true;
    final code = (countryCode ?? '').toUpperCase();
    return code.length == 2 && countries.contains(code);
  }
}

CatalogUnit _slotUnit({
  required String id,
  required String titleFr,
  required String titleEn,
  required LText subtitle,
  required String prefix,
  required String emoji,
}) {
  return CatalogUnit(
    id: id,
    titleFr: titleFr,
    titleEn: titleEn,
    subtitle: subtitle,
    lessons: slotsForPrefix(prefix, emoji),
    bonusXp: 0,
    bonusSeeds: 0,
  );
}

final List<CountryCatalogUnit> kCountryCatalogUnits = [
  CountryCatalogUnit(
    countries: const ['CA'],
    unit: _slotUnit(
      id: 'ca_slots',
      titleFr: 'Leçons Canada',
      titleEn: 'Canada lessons',
      subtitle: LText(
        'Ce qui change pour toi au Canada',
        'What changes for you in Canada',
      ),
      prefix: 'ca',
      emoji: '🇨🇦',
    ),
  ),
  CountryCatalogUnit(
    countries: const ['FR'],
    unit: _slotUnit(
      id: 'fr_slots',
      titleFr: 'Leçons France',
      titleEn: 'France lessons',
      subtitle: LText(
        'Ce qui change pour toi en France',
        'What changes for you in France',
      ),
      prefix: 'fr',
      emoji: '🇫🇷',
    ),
  ),
  CountryCatalogUnit(
    countries: const ['CM'],
    unit: _slotUnit(
      id: 'cm_slots',
      titleFr: 'Leçons Cameroun',
      titleEn: 'Cameroon lessons',
      subtitle: LText(
        'Ce qui change pour toi au Cameroun',
        'What changes for you in Cameroon',
      ),
      prefix: 'cm',
      emoji: '🇨🇲',
    ),
  ),
  CountryCatalogUnit(
    countries: const ['CI'],
    unit: _slotUnit(
      id: 'ci_slots',
      titleFr: 'Leçons Côte d’Ivoire',
      titleEn: 'Côte d’Ivoire lessons',
      subtitle: LText(
        'Ce qui change pour toi en Côte d’Ivoire',
        'What changes for you in Côte d’Ivoire',
      ),
      prefix: 'ci',
      emoji: '🇨🇮',
    ),
  ),
  CountryCatalogUnit(
    countries: const ['SN'],
    unit: _slotUnit(
      id: 'sn_slots',
      titleFr: 'Leçons Sénégal',
      titleEn: 'Senegal lessons',
      subtitle: LText(
        'Ce qui change pour toi au Sénégal',
        'What changes for you in Senegal',
      ),
      prefix: 'sn',
      emoji: '🇸🇳',
    ),
  ),
  CountryCatalogUnit(
    countries: const ['*'],
    unit: _slotUnit(
      id: 'gen_slots',
      titleFr: 'Leçons partout',
      titleEn: 'Lessons anywhere',
      subtitle: LText(
        'Ce qui change pour toi, où que tu vives',
        'What changes for you, wherever you live',
      ),
      prefix: 'gen',
      emoji: '🌍',
    ),
  ),
];

/// Every country slot placeholder (for player / id lookup).
final List<CatalogLesson> kCountryCatalogLessons = [
  for (final cu in kCountryCatalogUnits) ...cu.unit.lessons,
];

/// Path lessons + country slots — use this for the lesson player lookup.
final List<CatalogLesson> kAllPlayableLessons = [
  ...kCatalogLessons,
  ...kCountryCatalogLessons,
];

List<CatalogUnit> countryUnitsFor(String? countryCode) {
  final code = (countryCode ?? '').toUpperCase();
  if (code.isEmpty) return const [];
  final specific = [
    for (final cu in kCountryCatalogUnits)
      if (!cu.countries.contains('*') && cu.matches(code)) cu.unit,
  ];
  if (specific.isNotEmpty) return specific;
  return [
    for (final cu in kCountryCatalogUnits)
      if (cu.countries.contains('*')) cu.unit,
  ];
}

/// Slot ids available for [countryCode] (or generic `*` pack).
List<String> countrySlotIdsFor(String? countryCode) => [
      for (final unit in countryUnitsFor(countryCode))
        for (final lesson in unit.lessons) lesson.id,
    ];
