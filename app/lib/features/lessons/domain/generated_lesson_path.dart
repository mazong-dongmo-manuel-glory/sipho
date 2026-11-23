import 'package:sipho/features/lessons/domain/ai_country_lesson.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';

/// Server-written ids: `gen_001`, `gen_002`, … in `users/{uid}/aiLessons`.
final RegExp generatedLessonIdPattern = RegExp(r'^gen_\d{3}$');

bool isGeneratedLessonId(String id) => generatedLessonIdPattern.hasMatch(id);

bool corePathCompleted(Set<String> completed) {
  return kCatalogLessons.isNotEmpty &&
      kCatalogLessons.every((lesson) => completed.contains(lesson.id));
}

/// True when the static path is done and every generated lesson is finished.
bool needsAnotherGeneratedLesson({
  required Iterable<String> generatedIds,
  required Set<String> completed,
}) {
  if (!corePathCompleted(completed)) return false;
  return generatedIds.every(completed.contains);
}

List<CatalogLesson> generatedLessonsFrom(Map<String, AiCountryLesson> ai) {
  final lessons = <CatalogLesson>[
    for (final entry in ai.entries)
      if (isGeneratedLessonId(entry.key) && entry.value.isPlayable)
        entry.value.toCatalogLesson(),
  ];
  lessons.sort((a, b) => a.id.compareTo(b.id));
  return lessons;
}

/// Groups an open-ended lesson list into units of three for the existing path UI.
List<CatalogUnit> generatedUnits(List<CatalogLesson> lessons) {
  const size = 3;
  final units = <CatalogUnit>[];
  for (var i = 0; i < lessons.length; i += size) {
    final end = i + size > lessons.length ? lessons.length : i + size;
    final number = units.length + 1;
    units.add(
      CatalogUnit(
        id: 'gen_unit_$number',
        titleFr: 'Leçons pour toi',
        titleEn: 'Lessons for you',
        subtitle: const LText(
          'La suivante est créée pour toi',
          'The next one is made for you',
        ),
        lessons: lessons.sublist(i, end),
        bonusXp: 0,
        bonusSeeds: 0,
      ),
    );
  }
  return units;
}
