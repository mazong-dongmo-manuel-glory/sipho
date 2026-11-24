/// Miroir de `functions/src/shared/lessonPath.ts` — ids serveur uniquement.
class LessonUnit {
  final String id;
  final String titleFr;
  final String titleEn;
  final List<LessonDef> lessons;

  const LessonUnit({
    required this.id,
    required this.titleFr,
    required this.titleEn,
    required this.lessons,
  });
}

class LessonDef {
  final String id;
  final String titleFr;
  final String titleEn;

  const LessonDef({
    required this.id,
    required this.titleFr,
    required this.titleEn,
  });
}

const kLessonCatalog = <LessonUnit>[
  LessonUnit(
    id: 'unit_1',
    titleFr: 'Unité 1 · Les bases',
    titleEn: 'Unit 1 · The basics',
    lessons: [
      LessonDef(id: 'emergency_fund', titleFr: 'Un coussin pour les imprévus', titleEn: 'An emergency cushion'),
      LessonDef(id: 'needs_wants', titleFr: 'Besoins et envies', titleEn: 'Needs and wants'),
      LessonDef(id: 'track_spending', titleFr: 'Suivre ses dépenses', titleEn: 'Track your spending'),
    ],
  ),
  LessonUnit(
    id: 'unit_2',
    titleFr: 'Unité 2 · Épargner',
    titleEn: 'Unit 2 · Saving',
    lessons: [
      LessonDef(id: 'savings_goal', titleFr: 'Donner un nom à ton épargne', titleEn: 'Name your savings goal'),
      LessonDef(id: 'pay_yourself_first', titleFr: 'Te payer en premier', titleEn: 'Pay yourself first'),
      LessonDef(id: 'small_amounts', titleFr: 'Avancer régulièrement', titleEn: 'Small amounts, often'),
    ],
  ),
  LessonUnit(
    id: 'unit_3',
    titleFr: 'Unité 3 · Se protéger',
    titleEn: 'Unit 3 · Protect yourself',
    lessons: [
      LessonDef(id: 'debt_basics', titleFr: 'Crédit vs besoin', titleEn: 'Credit vs need'),
      LessonDef(id: 'inflation_101', titleFr: 'L’inflation en clair', titleEn: 'Inflation, simply'),
      LessonDef(id: 'spotting_scams', titleFr: 'Repérer les arnaques', titleEn: 'Spotting scams'),
    ],
  ),
  LessonUnit(
    id: 'unit_4',
    titleFr: 'Unité 4 · Faire fructifier',
    titleEn: 'Unit 4 · Grow your money',
    lessons: [
      LessonDef(id: 'investing_basics', titleFr: 'Investir, les bases', titleEn: 'Investing basics'),
      LessonDef(id: 'compound_interest', titleFr: 'Les intérêts composés', titleEn: 'Compound interest'),
      LessonDef(id: 'smart_budget_503020', titleFr: 'Budget 50 / 30 / 20', titleEn: '50 / 30 / 20 budget'),
    ],
  ),
];

List<String> get kAllLessonIds => [
      for (final u in kLessonCatalog) ...u.lessons.map((l) => l.id),
    ];

String? prerequisiteOf(String lessonId) {
  final all = kAllLessonIds;
  final i = all.indexOf(lessonId);
  if (i <= 0) return null;
  return all[i - 1];
}

bool isLessonUnlocked(String lessonId, Set<String> completed) {
  final prereq = prerequisiteOf(lessonId);
  if (prereq == null) return true;
  return completed.contains(prereq);
}
