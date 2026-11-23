import 'package:sipho/features/lessons/domain/lesson_catalog.dart';

/// Awardable country **slots** (stable ids). Keep in sync with
/// `COUNTRY_SLOTS` / `SLOTS_PER_COUNTRY` in
/// `functions/src/shared/countryLessonTopics.ts`.
const int kSlotsPerCountry = 10;

const List<({String prefix, List<String> countries, String emoji})>
    kCountrySlotPacks = [
  (prefix: 'ca', countries: ['CA'], emoji: '🇨🇦'),
  (prefix: 'fr', countries: ['FR'], emoji: '🇫🇷'),
  (prefix: 'cm', countries: ['CM'], emoji: '🇨🇲'),
  (prefix: 'ci', countries: ['CI'], emoji: '🇨🇮'),
  (prefix: 'sn', countries: ['SN'], emoji: '🇸🇳'),
  (prefix: 'gen', countries: ['*'], emoji: '🌍'),
];

String countrySlotId(String prefix, int index1Based) =>
    '${prefix}_slot_${index1Based.toString().padLeft(2, '0')}';

bool isCountrySlotId(String id) =>
    RegExp(r'^(ca|fr|cm|ci|sn|gen)_slot_\d{2}$').hasMatch(id);

/// Placeholder shown on the Learn path until AI fills `aiLessons/{slotId}`.
CatalogLesson slotPlaceholder({
  required String id,
  required String emoji,
  required int index1Based,
}) {
  final n = '$index1Based';
  return CatalogLesson(
    id: id,
    emoji: emoji,
    minutes: 3,
    titleFr: 'Leçon $n',
    titleEn: 'Lesson $n',
    objective: LText(
      'Une micro-leçon adaptée à ton pays (générée pour toi).',
      'A micro-lesson tailored to your country (generated for you).',
    ),
    steps: [
      InfoStep(
        emoji: '✨',
        title: LText('En préparation', 'Getting ready'),
        body: LText(
          'Sipho prépare une leçon fraîche pour ce créneau. Rouvre-la dans un instant.',
          'Sipho is preparing a fresh lesson for this slot. Open it again in a moment.',
        ),
      ),
    ],
    takeaways: [
      LText(
        'Le contenu final arrive après génération.',
        'Final content arrives after generation.',
      ),
    ],
  );
}

List<CatalogLesson> slotsForPrefix(String prefix, String emoji) => [
      for (var i = 1; i <= kSlotsPerCountry; i++)
        slotPlaceholder(
          id: countrySlotId(prefix, i),
          emoji: emoji,
          index1Based: i,
        ),
    ];
