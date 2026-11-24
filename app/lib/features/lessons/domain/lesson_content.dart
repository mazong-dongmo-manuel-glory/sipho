/// Contenu pédagogique embarqué (miroirs des leçons du catalogue).
class LessonQuizContent {
  final String questionFr;
  final String questionEn;
  final List<String> optionsFr;
  final List<String> optionsEn;
  final int correctIndex;
  final String explainFr;
  final String explainEn;
  final String cardBodyFr;
  final String cardBodyEn;

  const LessonQuizContent({
    required this.questionFr,
    required this.questionEn,
    required this.optionsFr,
    required this.optionsEn,
    required this.correctIndex,
    required this.explainFr,
    required this.explainEn,
    required this.cardBodyFr,
    required this.cardBodyEn,
  });

  String question(bool fr) => fr ? questionFr : questionEn;
  List<String> options(bool fr) => fr ? optionsFr : optionsEn;
  String explain(bool fr) => fr ? explainFr : explainEn;
  String cardBody(bool fr) => fr ? cardBodyFr : cardBodyEn;
}

const kLessonContent = <String, LessonQuizContent>{
  'emergency_fund': LessonQuizContent(
    questionFr: 'Où placer un coussin d’urgence ?',
    questionEn: 'Where should your emergency fund live?',
    optionsFr: [
      'Sous le matelas',
      'Compte chèques courant',
      'Compte liquide / épargne accessible',
      'Actions individuelles',
    ],
    optionsEn: [
      'Under the mattress',
      'Everyday checking account',
      'Liquid / accessible savings account',
      'Individual stocks',
    ],
    correctIndex: 2,
    explainFr:
        'Un coussin doit être accessible rapidement, sans risque de marché.',
    explainEn:
        'An emergency cushion should be quickly accessible, without market risk.',
    cardBodyFr:
        'Vise 1 à 3 mois de dépenses essentielles sur un compte séparé et liquide.',
    cardBodyEn:
        'Aim for 1–3 months of essential expenses in a separate liquid account.',
  ),
  'needs_wants': LessonQuizContent(
    questionFr: 'Quelle dépense est plutôt un besoin ?',
    questionEn: 'Which expense is more of a need?',
    optionsFr: [
      'Loyer ou logement',
      'Nouvel abonnement streaming',
      'Sneakers édition limitée',
      'Restaurant gastronomique',
    ],
    optionsEn: [
      'Rent or housing',
      'New streaming subscription',
      'Limited-edition sneakers',
      'Fine dining',
    ],
    correctIndex: 0,
    explainFr: 'Le logement fait partie du socle indispensable.',
    explainEn: 'Housing is part of your essential base.',
    cardBodyFr:
        'Sépare besoins (socle) et envies (flexibles) pour décider sans culpabilité.',
    cardBodyEn:
        'Separate needs (base) from wants (flexible) to decide without guilt.',
  ),
  'track_spending': LessonQuizContent(
    questionFr: 'Pourquoi noter ses dépenses ?',
    questionEn: 'Why track spending?',
    optionsFr: [
      'Pour se punir',
      'Pour voir où part l’argent',
      'Pour impressionner ses amis',
      'Pour éviter toute dépense plaisir',
    ],
    optionsEn: [
      'To punish yourself',
      'To see where money goes',
      'To impress friends',
      'To ban all fun spending',
    ],
    correctIndex: 1,
    explainFr: 'La trace révèle les fuites et les choix possibles.',
    explainEn: 'Tracking reveals leaks and possible choices.',
    cardBodyFr: 'Trois notes par jour suffisent pour démarrer une habitude solide.',
    cardBodyEn: 'Three logs a day are enough to start a solid habit.',
  ),
};

LessonQuizContent lessonContentFor(String lessonId) {
  return kLessonContent[lessonId] ?? kLessonContent['emergency_fund']!;
}
