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

const List<CatalogLesson> kCatalogLessons = [
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
