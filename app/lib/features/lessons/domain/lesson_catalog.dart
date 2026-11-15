class LessonChoice {
  const LessonChoice({
    required this.fr,
    required this.en,
    required this.correct,
  });

  final String fr;
  final String en;
  final bool correct;

  String text(String languageCode) =>
      languageCode.toLowerCase().startsWith('fr') ? fr : en;
}

class CatalogLesson {
  const CatalogLesson({
    required this.id,
    required this.titleFr,
    required this.titleEn,
    required this.questionFr,
    required this.questionEn,
    required this.explainFr,
    required this.explainEn,
    required this.choices,
  });

  final String id;
  final String titleFr;
  final String titleEn;
  final String questionFr;
  final String questionEn;
  final String explainFr;
  final String explainEn;
  final List<LessonChoice> choices;

  String title(String languageCode) =>
      languageCode.toLowerCase().startsWith('fr') ? titleFr : titleEn;

  String question(String languageCode) =>
      languageCode.toLowerCase().startsWith('fr') ? questionFr : questionEn;

  String explanation(String languageCode) =>
      languageCode.toLowerCase().startsWith('fr') ? explainFr : explainEn;
}

const List<CatalogLesson> _unit1Lessons = [
  CatalogLesson(
    id: 'emergency_fund',
    titleFr: 'Le fonds d\'urgence',
    titleEn: 'The emergency fund',
    questionFr: 'Où garder un fonds d\'urgence ?',
    questionEn: 'Where should an emergency fund live?',
    explainFr: 'Il doit rester disponible vite, sans mauvaise surprise.',
    explainEn: 'It needs to stay available quickly, without a nasty surprise.',
    choices: [
      LessonChoice(
        fr: 'Dans un compte d\'épargne accessible',
        en: 'In an easy-to-reach savings account',
        correct: true,
      ),
      LessonChoice(
        fr: 'En actions à haut risque',
        en: 'In high-risk stocks',
        correct: false,
      ),
      LessonChoice(
        fr: 'Sous le matelas',
        en: 'Under the mattress',
        correct: false,
      ),
      LessonChoice(
        fr: 'Dans un placement bloqué dix ans',
        en: 'In a ten-year locked investment',
        correct: false,
      ),
    ],
  ),
  CatalogLesson(
    id: 'needs_wants',
    titleFr: 'Besoins et envies',
    titleEn: 'Needs and wants',
    questionFr: 'Laquelle est un besoin ?',
    questionEn: 'Which one is a need?',
    explainFr: 'Un besoin couvre le quotidien. Une envie peut attendre.',
    explainEn: 'A need covers daily life. A want can wait.',
    choices: [
      LessonChoice(
        fr: 'Le loyer du mois',
        en: 'This month\'s rent',
        correct: true,
      ),
      LessonChoice(
        fr: 'Un nouveau téléphone alors que l\'ancien marche',
        en: 'A new phone while the old one works',
        correct: false,
      ),
      LessonChoice(
        fr: 'Un dessert commandé par habitude',
        en: 'A dessert ordered out of habit',
        correct: false,
      ),
    ],
  ),
  CatalogLesson(
    id: 'track_spending',
    titleFr: 'Noter ses dépenses',
    titleEn: 'Logging spending',
    questionFr: 'Pourquoi noter une dépense ?',
    questionEn: 'Why log an expense?',
    explainFr: 'On récompense le suivi, pas le fait de dépenser.',
    explainEn: 'The reward is for tracking, not for spending.',
    choices: [
      LessonChoice(
        fr: 'Pour voir où va l\'argent',
        en: 'To see where the money goes',
        correct: true,
      ),
      LessonChoice(
        fr: 'Pour gagner plus en dépensant plus',
        en: 'To earn more by spending more',
        correct: false,
      ),
      LessonChoice(
        fr: 'Pour que les autres voient tes montants',
        en: 'So other people can see your amounts',
        correct: false,
      ),
    ],
  ),
];

const List<CatalogLesson> _unit2Lessons = [
  CatalogLesson(
    id: 'savings_goal',
    titleFr: 'Un objectif d\'épargne',
    titleEn: 'A savings goal',
    questionFr: 'Quel objectif d\'épargne est le plus facile à tenir ?',
    questionEn: 'Which savings goal is easiest to stick to?',
    explainFr: 'Un montant précis et une date donnent un cap à suivre.',
    explainEn: 'A clear amount and a date give you something to aim at.',
    choices: [
      LessonChoice(
        fr: 'Un montant précis avec une date',
        en: 'A specific amount with a date',
        correct: true,
      ),
      LessonChoice(
        fr: 'Mettre de côté « quand je peux »',
        en: 'Saving "whenever I can"',
        correct: false,
      ),
      LessonChoice(
        fr: 'Attendre d\'avoir un gros surplus',
        en: 'Waiting for a big surplus',
        correct: false,
      ),
    ],
  ),
  CatalogLesson(
    id: 'pay_yourself_first',
    titleFr: 'Se payer en premier',
    titleEn: 'Pay yourself first',
    questionFr: 'À quel moment mettre de l\'argent de côté ?',
    questionEn: 'When should you set money aside?',
    explainFr: 'Épargner dès que le revenu arrive évite de tout dépenser.',
    explainEn:
        'Saving as soon as income arrives keeps you from spending it all.',
    choices: [
      LessonChoice(
        fr: 'Dès que le revenu arrive',
        en: 'As soon as income arrives',
        correct: true,
      ),
      LessonChoice(
        fr: 'À la fin du mois, s\'il reste quelque chose',
        en: 'At month end, if anything is left',
        correct: false,
      ),
      LessonChoice(
        fr: 'Jamais, tant que les envies passent avant',
        en: 'Never, while wants come first',
        correct: false,
      ),
    ],
  ),
  CatalogLesson(
    id: 'small_amounts',
    titleFr: 'Les petits montants comptent',
    titleEn: 'Small amounts add up',
    questionFr: 'Que donne un petit montant mis de côté chaque semaine ?',
    questionEn: 'What does a small amount saved each week do?',
    explainFr:
        'Il s\'accumule et installe l\'habitude, bien avant les gros montants.',
    explainEn: 'It adds up and builds the habit, long before big amounts.',
    choices: [
      LessonChoice(
        fr: 'Il s\'accumule et crée l\'habitude',
        en: 'It adds up and builds the habit',
        correct: true,
      ),
      LessonChoice(
        fr: 'Rien, c\'est trop peu pour servir',
        en: 'Nothing, it is too little to matter',
        correct: false,
      ),
      LessonChoice(
        fr: 'Il vaut mieux attendre de pouvoir en mettre plus',
        en: 'It is better to wait until you can save more',
        correct: false,
      ),
    ],
  ),
];

class CatalogUnit {
  const CatalogUnit({
    required this.id,
    required this.titleFr,
    required this.titleEn,
    required this.lessons,
    required this.bonusXp,
    required this.bonusSeeds,
  });

  /// Matches `LESSON_UNITS` on the server (functions/src/shared/lessonPath.ts).
  final String id;
  final String titleFr;
  final String titleEn;
  final List<CatalogLesson> lessons;

  /// One-time reward for finishing the unit. Display only: the server pays it
  /// (`XP_CONFIG.unitComplete` / `unitCompleteSeeds`).
  final int bonusXp;
  final int bonusSeeds;

  String title(String languageCode) =>
      languageCode.toLowerCase().startsWith('fr') ? titleFr : titleEn;
}

const List<CatalogUnit> kCatalogUnits = [
  CatalogUnit(
    id: 'unit_1',
    titleFr: 'Les bases du budget',
    titleEn: 'Budget basics',
    lessons: _unit1Lessons,
    bonusXp: 30,
    bonusSeeds: 10,
  ),
  CatalogUnit(
    id: 'unit_2',
    titleFr: 'Épargner, un pas après l\'autre',
    titleEn: 'Saving, one step at a time',
    lessons: _unit2Lessons,
    bonusXp: 30,
    bonusSeeds: 10,
  ),
];

/// Every lesson in path order (unit by unit).
const List<CatalogLesson> kCatalogLessons = [
  ..._unit1Lessons,
  ..._unit2Lessons,
];

/// First lesson the user has not finished, or null when the path is complete.
String? nextLessonId(List<String> lessonIds, Set<String> completed) {
  for (final id in lessonIds) {
    if (!completed.contains(id)) return id;
  }
  return null;
}

bool lessonUnlocked(List<String> lessonIds, Set<String> completed, int index) {
  if (index <= 0) return true;
  if (index >= lessonIds.length) return false;
  return completed.contains(lessonIds[index - 1]);
}

/// A unit with the user's progress in it, for the Learn tab.
class UnitProgress {
  const UnitProgress({
    required this.unit,
    required this.index,
    required this.done,
    required this.unlocked,
  });

  final CatalogUnit unit;

  /// 0-based position of the unit on the path.
  final int index;
  final int done;

  /// The first lesson of the unit can be played.
  final bool unlocked;

  int get total => unit.lessons.length;
  bool get completed => done >= total;
  double get ratio => total == 0 ? 0 : (done / total).clamp(0.0, 1.0);
}

/// Progress of each unit. A unit opens once the previous unit is finished,
/// the same rule as lessons (the server enforces it in `completeLesson`).
List<UnitProgress> unitProgressList(
  List<CatalogUnit> units,
  Set<String> completed,
) {
  final result = <UnitProgress>[];
  var previousCompleted = true;
  for (var i = 0; i < units.length; i++) {
    final done = units[i].lessons.where((l) => completed.contains(l.id)).length;
    result.add(
      UnitProgress(
        unit: units[i],
        index: i,
        done: done,
        unlocked: previousCompleted,
      ),
    );
    previousCompleted = done >= units[i].lessons.length;
  }
  return result;
}

/// The unit the user is working on: the first one not finished, or null when
/// the whole path is complete.
UnitProgress? currentUnit(List<CatalogUnit> units, Set<String> completed) {
  for (final progress in unitProgressList(units, completed)) {
    if (!progress.completed) return progress;
  }
  return null;
}

/// The unit holding [lessonId], or null for an unknown lesson.
CatalogUnit? unitOfLesson(List<CatalogUnit> units, String lessonId) {
  for (final unit in units) {
    if (unit.lessons.any((l) => l.id == lessonId)) return unit;
  }
  return null;
}
