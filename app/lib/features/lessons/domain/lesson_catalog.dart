import 'package:sipho/features/lessons/domain/lesson_steps.dart';

export 'package:sipho/features/lessons/domain/lesson_steps.dart';

/// Most XP a lesson can pay the first time (a perfect lesson). Display only: the server decides
/// (`XP_CONFIG.lessonPerfect`, checked by a test).
const int kLessonMaxXp = 20;

/// A lesson of the path: a short, ordered sequence of [steps] (read, answer, remember).
///
/// Ids match `LESSON_UNITS` on the server (functions/src/shared/lessonPath.ts). The text is
/// educational and general: no rate, ceiling or tax rule (those come from the country pack).
class CatalogLesson {
  const CatalogLesson({
    required this.id,
    required this.emoji,
    required this.minutes,
    required this.titleFr,
    required this.titleEn,
    required this.objective,
    required this.steps,
    required this.takeaways,
  });

  final String id;
  final String emoji;

  /// Rough time to finish, shown before starting.
  final int minutes;
  final String titleFr;
  final String titleEn;

  /// One sentence: what the learner will know afterwards.
  final LText objective;
  final List<LessonStep> steps;

  /// The "to remember" page shown at the end.
  final List<LText> takeaways;

  String title(String languageCode) =>
      languageCode.toLowerCase().startsWith('fr') ? titleFr : titleEn;

  /// Steps the learner answers: they set the accuracy of the lesson.
  int get questionCount => steps.where((s) => s.isQuestion).length;

  /// The first question, for the AI tutor prompt.
  String question(String languageCode) {
    for (final step in steps) {
      if (step is QuizStep) return step.question.of(languageCode);
      if (step is TrueFalseStep) return step.statement.of(languageCode);
    }
    return title(languageCode);
  }

  /// The main idea of the lesson, for the AI tutor prompt.
  String explanation(String languageCode) => takeaways.isEmpty
      ? objective.of(languageCode)
      : takeaways.first.of(languageCode);
}

const List<CatalogLesson> _unit1Lessons = [
  CatalogLesson(
    id: 'emergency_fund',
    emoji: '🛟',
    minutes: 3,
    titleFr: 'Le fonds d\'urgence',
    titleEn: 'The emergency fund',
    objective: LText(
      'Comprendre à quoi sert un fonds d\'urgence et où le garder.',
      'Understand what an emergency fund is for and where to keep it.',
    ),
    steps: [
      InfoStep(
        emoji: '🛟',
        title: LText('Un filet de sécurité', 'A safety net'),
        body: LText(
          'Un fonds d\'urgence est une réserve d\'argent mise de côté pour les imprévus : une réparation, une perte de revenu, une facture de santé.',
          'An emergency fund is money set aside for surprises: a repair, a loss of income, a medical bill.',
        ),
        points: [
          LText('Pour les vrais imprévus, pas pour les envies',
              'For real surprises, not for wants'),
          LText('Il doit être disponible rapidement',
              'It must be available quickly'),
          LText(
              'Il se construit petit à petit', 'It is built little by little'),
        ],
      ),
      QuizStep(
        question: LText('Laquelle de ces situations est une urgence ?',
            'Which of these situations is an emergency?'),
        choices: [
          LessonChoice(
            fr: 'Des soldes sur des chaussures',
            en: 'A sale on shoes',
            correct: false,
          ),
          LessonChoice(
            fr: 'Ta voiture tombe en panne et tu en as besoin pour travailler',
            en: 'Your car breaks down and you need it for work',
            correct: true,
          ),
          LessonChoice(
            fr: 'La sortie d\'un nouveau jeu vidéo',
            en: 'A new video game comes out',
            correct: false,
          ),
        ],
        explanation: LText(
          'Une urgence est imprévue et nécessaire. Une envie, même tentante, n\'en est pas une.',
          'An emergency is unexpected and necessary. A want, however tempting, is not one.',
        ),
      ),
      InfoStep(
        emoji: '🎯',
        title: LText('Combien mettre de côté ?', 'How much to set aside?'),
        body: LText(
          'Il n\'existe pas de montant magique : l\'idée est de couvrir quelques mois de dépenses essentielles (loyer, nourriture, transport). Commence par un premier palier, comme un mois, puis continue.',
          'There is no magic number: the idea is to cover a few months of essential expenses (rent, food, transport). Start with a first step, such as one month, then keep going.',
        ),
        points: [
          LText('Compte tes dépenses essentielles, pas tout ton budget',
              'Count your essential expenses, not your whole budget'),
          LText('Vise d\'abord un petit palier', 'Aim for a small first step'),
          LText('Ajuste selon ta situation', 'Adjust to your situation'),
        ],
      ),
      TrueFalseStep(
        statement: LText(
          'Le meilleur endroit pour un fonds d\'urgence est un placement risqué qui rapporte beaucoup.',
          'The best place for an emergency fund is a risky investment that pays a lot.',
        ),
        answer: false,
        explanation: LText(
          'Un fonds d\'urgence doit rester disponible et stable. Si sa valeur baisse au moment où tu en as besoin, il ne remplit plus son rôle.',
          'An emergency fund must stay available and stable. If its value drops just when you need it, it no longer does its job.',
        ),
      ),
      QuizStep(
        question: LText('Où garder un fonds d\'urgence ?',
            'Where should an emergency fund live?'),
        choices: [
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
            fr: 'Dans un compte d\'épargne accessible',
            en: 'In an easy-to-reach savings account',
            correct: true,
          ),
          LessonChoice(
            fr: 'Dans un placement bloqué dix ans',
            en: 'In a ten-year locked investment',
            correct: false,
          ),
        ],
        explanation: LText(
          'Il doit rester disponible vite, sans mauvaise surprise.',
          'It needs to stay available quickly, without a nasty surprise.',
        ),
      ),
    ],
    takeaways: [
      LText('Un fonds d\'urgence sert aux imprévus, pas aux envies.',
          'An emergency fund is for surprises, not for wants.'),
      LText(
          'Vise d\'abord quelques mois de dépenses essentielles, par petits paliers.',
          'Aim for a few months of essential expenses, in small steps.'),
      LText('Garde-le dans un endroit stable et accessible.',
          'Keep it somewhere stable and easy to reach.'),
    ],
  ),
  CatalogLesson(
    id: 'needs_wants',
    emoji: '⚖️',
    minutes: 3,
    titleFr: 'Besoins et envies',
    titleEn: 'Needs and wants',
    objective: LText(
      'Faire la différence entre un besoin et une envie pour mieux répartir ton budget.',
      'Tell a need from a want so you can share out your budget better.',
    ),
    steps: [
      InfoStep(
        emoji: '⚖️',
        title: LText('Besoin ou envie ?', 'Need or want?'),
        body: LText(
          'Un besoin couvre ce qui est nécessaire au quotidien : se loger, se nourrir, se déplacer, se soigner. Une envie te fait plaisir mais peut attendre.',
          'A need covers what daily life requires: housing, food, getting around, health. A want makes you happy but can wait.',
        ),
        points: [
          LText('Besoin : indispensable pour vivre et travailler',
              'Need: essential to live and work'),
          LText('Envie : agréable, mais on peut la remettre',
              'Want: nice, but it can be postponed'),
          LText('Les deux ont leur place dans un budget',
              'Both have a place in a budget'),
        ],
      ),
      QuizStep(
        question: LText('Laquelle est un besoin ?', 'Which one is a need?'),
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
        explanation: LText(
          'Un besoin couvre le quotidien. Une envie peut attendre.',
          'A need covers daily life. A want can wait.',
        ),
      ),
      InfoStep(
        emoji: '🌗',
        title: LText('Il y a une zone grise', 'There is a grey area'),
        body: LText(
          'Certaines dépenses sont mixtes : se nourrir est un besoin, commander tous les soirs est une envie. Un forfait mobile est un besoin, l\'option premium est une envie.',
          'Some expenses are a mix: eating is a need, ordering in every night is a want. A phone plan is a need, the premium option is a want.',
        ),
        points: [
          LText('Demande-toi : est-ce le minimum, ou un plus ?',
              'Ask yourself: is it the minimum, or an extra?'),
          LText('Une même catégorie peut contenir les deux',
              'One category can hold both'),
          LText('Une envie prévue se vit sans culpabilité',
              'A planned want can be enjoyed guilt-free'),
        ],
      ),
      TrueFalseStep(
        statement: LText(
          'Un budget équilibré peut prévoir une petite part pour les envies.',
          'A balanced budget can include a small share for wants.',
        ),
        answer: true,
        explanation: LText(
          'Oui : un budget qui prévoit une part pour le plaisir se tient plus longtemps. Le but est de choisir, pas de tout se refuser.',
          'Yes: a budget with room for fun lasts longer. The goal is to choose, not to deny yourself everything.',
        ),
      ),
      QuizStep(
        question: LText(
            'Ton budget est serré ce mois-ci. Que regarder en premier ?',
            'Your budget is tight this month. What do you look at first?'),
        choices: [
          LessonChoice(
            fr: 'Le loyer, en le sautant ce mois-ci',
            en: 'The rent, by skipping it this month',
            correct: false,
          ),
          LessonChoice(
            fr: 'Rien : on verra à la fin du mois',
            en: 'Nothing: we will see at month end',
            correct: false,
          ),
          LessonChoice(
            fr: 'Les envies et les abonnements que tu n\'utilises plus',
            en: 'Wants and subscriptions you no longer use',
            correct: true,
          ),
        ],
        explanation: LText(
          'On ajuste d\'abord ce qui peut attendre. Les besoins, eux, doivent rester couverts.',
          'Adjust what can wait first. Needs must stay covered.',
        ),
      ),
    ],
    takeaways: [
      LText('Un besoin est nécessaire au quotidien, une envie peut attendre.',
          'A need is required day to day, a want can wait.'),
      LText(
          'Certaines dépenses mélangent les deux : demande-toi si c\'est le minimum ou un plus.',
          'Some expenses mix both: ask whether it is the minimum or an extra.'),
      LText('Garder une part pour les envies aide à tenir son budget.',
          'Keeping room for wants helps you stick to your budget.'),
    ],
  ),
  CatalogLesson(
    id: 'track_spending',
    emoji: '📝',
    minutes: 3,
    titleFr: 'Noter ses dépenses',
    titleEn: 'Logging spending',
    objective: LText(
      'Voir où va ton argent en notant tes dépenses, sans effort ni jugement.',
      'See where your money goes by logging expenses, without effort or judgement.',
    ),
    steps: [
      InfoStep(
        emoji: '📝',
        title: LText('Voir pour décider', 'See in order to decide'),
        body: LText(
          'Noter une dépense, c\'est transformer un flou en chiffres. On ne juge pas : on observe. Quand on voit où va l\'argent, on peut choisir quoi garder et quoi réduire.',
          'Logging an expense turns a blur into numbers. We do not judge: we observe. Once you see where the money goes, you can choose what to keep and what to cut.',
        ),
        points: [
          LText('Noter, c\'est observer, pas se juger',
              'Logging is observing, not judging yourself'),
          LText('Les petites dépenses fréquentes deviennent visibles',
              'Small frequent expenses become visible'),
          LText('Sipho récompense le suivi, jamais la dépense',
              'Sipho rewards tracking, never spending'),
        ],
      ),
      QuizStep(
        question: LText('Pourquoi noter une dépense ?', 'Why log an expense?'),
        choices: [
          LessonChoice(
            fr: 'Pour gagner plus en dépensant plus',
            en: 'To earn more by spending more',
            correct: false,
          ),
          LessonChoice(
            fr: 'Pour voir où va l\'argent',
            en: 'To see where the money goes',
            correct: true,
          ),
          LessonChoice(
            fr: 'Pour que les autres voient tes montants',
            en: 'So other people can see your amounts',
            correct: false,
          ),
        ],
        explanation: LText(
          'On récompense le suivi, pas le fait de dépenser. Et tes montants restent privés.',
          'The reward is for tracking, not for spending. And your amounts stay private.',
        ),
      ),
      InfoStep(
        emoji: '⚡',
        title: LText('Rapide, ou pas du tout', 'Quick, or not at all'),
        body: LText(
          'La meilleure méthode est celle que tu fais vraiment. Dans Sipho, une dépense se note en trois taps : le montant, la catégorie, valider. Note-la au moment de l\'achat, avant de l\'oublier.',
          'The best method is the one you actually do. In Sipho, an expense takes three taps: the amount, the category, confirm. Log it at the time of purchase, before you forget.',
        ),
        points: [
          LText('3 taps : montant, catégorie, valider',
              '3 taps: amount, category, confirm'),
          LText('Sur le moment, c\'est plus fiable que de mémoire',
              'In the moment is more reliable than from memory'),
          LText('Un ticket ? Le scan fait le travail',
              'A receipt? The scan does the work'),
        ],
      ),
      TrueFalseStep(
        statement: LText(
          'Pour que le suivi serve, chaque dépense doit être notée au centime près.',
          'For tracking to be useful, every expense must be logged to the cent.',
        ),
        answer: false,
        explanation: LText(
          'La régularité compte plus que la perfection. Une dépense arrondie, notée tout de suite, vaut mieux qu\'une dépense exacte oubliée.',
          'Consistency matters more than perfection. A rounded expense logged right away beats an exact one forgotten.',
        ),
      ),
      QuizStep(
        question: LText('Quel est le meilleur moment pour noter une dépense ?',
            'When is the best time to log an expense?'),
        choices: [
          LessonChoice(
            fr: 'Tout de suite, au moment de l\'achat',
            en: 'Right away, when you buy',
            correct: true,
          ),
          LessonChoice(
            fr: 'À la fin de l\'année, en une seule fois',
            en: 'At the end of the year, all at once',
            correct: false,
          ),
          LessonChoice(
            fr: 'Jamais : il suffit de regarder son solde',
            en: 'Never: just look at your balance',
            correct: false,
          ),
        ],
        explanation: LText(
          'Plus on attend, plus on oublie. Trois taps tout de suite valent mieux qu\'un grand rattrapage.',
          'The longer you wait, the more you forget. Three taps now beat a big catch-up later.',
        ),
      ),
    ],
    takeaways: [
      LText('Noter ses dépenses permet de voir où va l\'argent, sans se juger.',
          'Logging expenses shows where the money goes, without judging yourself.'),
      LText('Rapide et régulier vaut mieux que parfait.',
          'Quick and regular beats perfect.'),
      LText('Sipho récompense le suivi, pas la dépense.',
          'Sipho rewards tracking, not spending.'),
    ],
  ),
];

const List<CatalogLesson> _unit2Lessons = [
  CatalogLesson(
    id: 'savings_goal',
    emoji: '🎯',
    minutes: 4,
    titleFr: 'Un objectif d\'épargne',
    titleEn: 'A savings goal',
    objective: LText(
      'Fixer un objectif d\'épargne clair, avec un montant et une date.',
      'Set a clear savings goal, with an amount and a date.',
    ),
    steps: [
      InfoStep(
        emoji: '🎯',
        title: LText('Un cap pour ton épargne', 'A direction for your savings'),
        body: LText(
          'Épargner « pour plus tard » reste flou. Un bon objectif répond à trois questions : pour quoi, combien, pour quand.',
          'Saving "for later" stays vague. A good goal answers three questions: what for, how much, by when.',
        ),
        points: [
          LText('Pour quoi : un voyage, un projet, un fonds d\'urgence',
              'What for: a trip, a project, an emergency fund'),
          LText('Combien : un montant précis', 'How much: a specific amount'),
          LText('Pour quand : une date', 'By when: a date'),
        ],
      ),
      QuizStep(
        question: LText('Quel objectif d\'épargne est le plus facile à tenir ?',
            'Which savings goal is easiest to stick to?'),
        choices: [
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
          LessonChoice(
            fr: 'Un montant précis avec une date',
            en: 'A specific amount with a date',
            correct: true,
          ),
        ],
        explanation: LText(
          'Un montant précis et une date donnent un cap à suivre.',
          'A clear amount and a date give you something to aim at.',
        ),
      ),
      InfoStep(
        emoji: '🧮',
        title: LText('Découper pour avancer', 'Break it down to move forward'),
        body: LText(
          'Un grand objectif devient simple quand on le découpe. Divise le montant par le nombre de mois : tu obtiens ce qu\'il faut mettre de côté chaque mois. Par exemple, 600 \$ en 6 mois, c\'est 100 \$ par mois.',
          'A big goal gets simple when you break it down. Divide the amount by the number of months: that is what to set aside each month. For example, \$600 in 6 months is \$100 a month.',
        ),
        points: [
          LText('Montant ÷ nombre de mois = effort mensuel',
              'Amount ÷ number of months = monthly effort'),
          LText('Trop dur ? Repousse la date plutôt que d\'abandonner',
              'Too hard? Move the date rather than give up'),
          LText('Fête chaque palier atteint', 'Celebrate every step reached'),
        ],
      ),
      QuizStep(
        question: LText(
            'Tu veux mettre 900 \$ de côté en 9 mois. Combien par mois ?',
            'You want to save \$900 in 9 months. How much per month?'),
        choices: [
          LessonChoice(fr: '90 \$', en: '\$90', correct: false),
          LessonChoice(fr: '100 \$', en: '\$100', correct: true),
          LessonChoice(fr: '300 \$', en: '\$300', correct: false),
          LessonChoice(fr: '900 \$', en: '\$900', correct: false),
        ],
        explanation: LText(
          '900 ÷ 9 = 100. Découper l\'objectif rend l\'effort concret.',
          '900 ÷ 9 = 100. Breaking the goal down makes the effort concrete.',
        ),
      ),
      TrueFalseStep(
        statement: LText(
          'Une date donne son rythme à un objectif d\'épargne.',
          'A date sets the pace of a savings goal.',
        ),
        answer: true,
        explanation: LText(
          'Oui : sans date, rien ne presse et l\'objectif glisse. La date donne le rythme.',
          'Yes: without a date nothing is urgent and the goal slips. The date sets the pace.',
        ),
      ),
    ],
    takeaways: [
      LText('Un bon objectif a un but, un montant et une date.',
          'A good goal has a purpose, an amount and a date.'),
      LText(
          'Montant ÷ nombre de mois = ce qu\'il faut mettre de côté chaque mois.',
          'Amount ÷ number of months = what to set aside each month.'),
      LText(
          'Si l\'effort est trop grand, repousse la date plutôt qu\'abandonner.',
          'If the effort is too big, move the date rather than give up.'),
    ],
  ),
  CatalogLesson(
    id: 'pay_yourself_first',
    emoji: '🏦',
    minutes: 3,
    titleFr: 'Se payer en premier',
    titleEn: 'Pay yourself first',
    objective: LText(
      'Mettre de l\'argent de côté dès que le revenu arrive.',
      'Set money aside as soon as your income arrives.',
    ),
    steps: [
      InfoStep(
        emoji: '🏦',
        title: LText('Toi d\'abord', 'You first'),
        body: LText(
          '« Se payer en premier » veut dire mettre de côté une part de ton revenu dès qu\'il arrive, avant de payer le reste. L\'argent qui reste sous les yeux finit par se dépenser.',
          '"Pay yourself first" means setting aside a share of your income as soon as it arrives, before paying the rest. Money left in sight tends to get spent.',
        ),
        points: [
          LText('Épargne le jour où le revenu arrive',
              'Save the day your income arrives'),
          LText('Ce qui reste sert au budget du mois',
              'What is left goes to the month\'s budget'),
          LText('Même un petit montant compte', 'Even a small amount counts'),
        ],
      ),
      QuizStep(
        question: LText('À quel moment mettre de l\'argent de côté ?',
            'When should you set money aside?'),
        choices: [
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
          LessonChoice(
            fr: 'Dès que le revenu arrive',
            en: 'As soon as income arrives',
            correct: true,
          ),
        ],
        explanation: LText(
          'Épargner dès que le revenu arrive évite de tout dépenser.',
          'Saving as soon as income arrives keeps you from spending it all.',
        ),
      ),
      InfoStep(
        emoji: '⚙️',
        title: LText('Automatise', 'Automate it'),
        body: LText(
          'Le plus fiable est de ne pas avoir à y penser : un virement automatique le jour de la paie. On s\'habitue vite à vivre avec le reste.',
          'The most reliable way is not having to think about it: an automatic transfer on payday. You soon get used to living on the rest.',
        ),
        points: [
          LText('Un virement automatique le jour de la paie',
              'An automatic transfer on payday'),
          LText('Un montant fixe, facile à tenir',
              'A fixed amount, easy to keep up'),
          LText('Augmente-le quand ton revenu augmente',
              'Raise it when your income rises'),
        ],
      ),
      TrueFalseStep(
        statement: LText(
          'Mettre de côté ce qui reste à la fin du mois est la méthode la plus fiable.',
          'Saving whatever is left at month end is the most reliable method.',
        ),
        answer: false,
        explanation: LText(
          'En fin de mois, il ne reste souvent rien. Épargner d\'abord garantit que ça arrive.',
          'At month end there is often nothing left. Saving first makes sure it happens.',
        ),
      ),
      QuizStep(
        question: LText('Comment rendre l\'épargne plus facile à tenir ?',
            'How can you make saving easier to keep up?'),
        choices: [
          LessonChoice(
            fr: 'Un virement automatique le jour de la paie',
            en: 'An automatic transfer on payday',
            correct: true,
          ),
          LessonChoice(
            fr: 'Compter sur sa mémoire',
            en: 'Relying on memory',
            correct: false,
          ),
          LessonChoice(
            fr: 'Attendre d\'en avoir envie',
            en: 'Waiting until you feel like it',
            correct: false,
          ),
        ],
        explanation: LText(
          'Ce qui est automatique ne dépend pas de la motivation du jour.',
          'What is automatic does not depend on today\'s motivation.',
        ),
      ),
    ],
    takeaways: [
      LText('Épargne dès que le revenu arrive, avant de dépenser.',
          'Save as soon as income arrives, before spending.'),
      LText('Un virement automatique évite d\'y penser.',
          'An automatic transfer means not having to think about it.'),
      LText('Un petit montant régulier vaut mieux qu\'un gros montant jamais.',
          'A small regular amount beats a big amount never.'),
    ],
  ),
  CatalogLesson(
    id: 'small_amounts',
    emoji: '🌱',
    minutes: 3,
    titleFr: 'Les petits montants comptent',
    titleEn: 'Small amounts add up',
    objective: LText(
      'Comprendre pourquoi les petits montants comptent, surtout pour l\'habitude.',
      'Understand why small amounts matter, above all for the habit.',
    ),
    steps: [
      InfoStep(
        emoji: '🌱',
        title: LText('Petit, mais régulier', 'Small, but regular'),
        body: LText(
          'Dix dollars par semaine paraissent peu. Mais une habitude régulière s\'accumule : le plus difficile est de commencer, pas le montant.',
          'Ten dollars a week looks like little. But a regular habit adds up: the hardest part is starting, not the amount.',
        ),
        points: [
          LText('Un petit montant est facile à garder',
              'A small amount is easy to keep up'),
          LText(
              'La régularité crée l\'habitude', 'Regularity builds the habit'),
          LText('Les gros montants viennent après l\'habitude',
              'Bigger amounts come after the habit'),
        ],
      ),
      QuizStep(
        question: LText(
            'Que donne un petit montant mis de côté chaque semaine ?',
            'What does a small amount saved each week do?'),
        choices: [
          LessonChoice(
            fr: 'Rien, c\'est trop peu pour servir',
            en: 'Nothing, it is too little to matter',
            correct: false,
          ),
          LessonChoice(
            fr: 'Il s\'accumule et crée l\'habitude',
            en: 'It adds up and builds the habit',
            correct: true,
          ),
          LessonChoice(
            fr: 'Il vaut mieux attendre de pouvoir en mettre plus',
            en: 'It is better to wait until you can save more',
            correct: false,
          ),
        ],
        explanation: LText(
          'Il s\'accumule et installe l\'habitude, bien avant les gros montants.',
          'It adds up and builds the habit, long before big amounts.',
        ),
      ),
      InfoStep(
        emoji: '📈',
        title: LText(
            'Le total se voit avec le temps', 'The total shows over time'),
        body: LText(
          'Chaque semaine, le même petit geste. Au bout de quelques mois, le total devient visible, et c\'est lui qui donne envie de continuer.',
          'The same small gesture every week. After a few months the total becomes visible, and that is what makes you want to continue.',
        ),
        points: [
          LText('Même geste, même jour', 'Same gesture, same day'),
          LText('Regarde ton total grandir', 'Watch your total grow'),
          LText('Un trou ? Reprends sans te juger',
              'Missed one? Pick up again without blaming yourself'),
        ],
      ),
      QuizStep(
        question: LText(
            'Tu mets 10 \$ de côté chaque semaine. Combien au bout d\'une année (52 semaines) ?',
            'You save \$10 every week. How much after a year (52 weeks)?'),
        choices: [
          LessonChoice(fr: '100 \$', en: '\$100', correct: false),
          LessonChoice(fr: '52 \$', en: '\$52', correct: false),
          LessonChoice(fr: '520 \$', en: '\$520', correct: true),
          LessonChoice(fr: '1 000 \$', en: '\$1,000', correct: false),
        ],
        explanation: LText(
          '10 × 52 = 520. Une petite habitude, sans rien changer d\'autre.',
          '10 × 52 = 520. One small habit, nothing else changed.',
        ),
      ),
      TrueFalseStep(
        statement: LText(
          'Un petit montant mis de côté régulièrement vaut mieux que rien.',
          'A small amount saved regularly beats saving nothing.',
        ),
        answer: true,
        explanation: LText(
          'Oui : un petit montant régulier construit l\'habitude et l\'argent. Attendre « d\'en avoir plus » repousse souvent le départ.',
          'Yes: a small regular amount builds the habit and the money. Waiting to "have more" often delays the start.',
        ),
      ),
    ],
    takeaways: [
      LText('Un petit montant régulier vaut mieux qu\'un gros montant jamais.',
          'A small regular amount beats a big amount never.'),
      LText('10 \$ par semaine, c\'est 520 \$ en un an.',
          '\$10 a week is \$520 in a year.'),
      LText('Commence petit : l\'habitude passe avant le montant.',
          'Start small: the habit comes before the amount.'),
    ],
  ),
];

const List<CatalogLesson> _unit3Lessons = [
  CatalogLesson(
    id: 'debt_basics',
    emoji: '💳',
    minutes: 4,
    titleFr: 'Dettes et crédit',
    titleEn: 'Debt and credit',
    objective: LText(
      'Distinguer une dette utile d\'une dette dangereuse, et savoir par où commencer.',
      'Tell useful debt from dangerous debt, and know where to start.',
    ),
    steps: [
      InfoStep(
        emoji: '💳',
        title: LText('Pas toutes les dettes se valent', 'Not all debts are equal'),
        body: LText(
          'Une dette utile te rapproche d\'un objectif (études, outil de travail). Une dette dangereuse finance des envies et coûte cher en intérêts.',
          'Useful debt moves you toward a goal (studies, work tools). Dangerous debt funds wants and costs a lot in interest.',
        ),
        points: [
          LText('Utile : formation, outil qui rapporte',
              'Useful: training, a tool that earns'),
          LText('Dangereuse : envies, intérêts élevés',
              'Dangerous: wants, high interest'),
          LText('Le coût total compte plus que le paiement mensuel',
              'Total cost matters more than the monthly payment'),
        ],
      ),
      QuizStep(
        question: LText('Laquelle est plutôt une dette utile ?',
            'Which is closer to useful debt?'),
        choices: [
          LessonChoice(
            fr: 'Un crédit pour des vacances à rembourser sur 3 ans',
            en: 'A loan for a holiday repaid over 3 years',
            correct: false,
          ),
          LessonChoice(
            fr: 'Un prêt pour un outil indispensable à ton travail',
            en: 'A loan for a tool you need for work',
            correct: true,
          ),
          LessonChoice(
            fr: 'Une carte de crédit pour des sorties chaque week-end',
            en: 'A credit card for nights out every weekend',
            correct: false,
          ),
        ],
        explanation: LText(
          'Un outil de travail peut augmenter tes revenus ; les vacances et sorties ne remboursent pas leurs intérêts.',
          'A work tool can raise your income; holidays and nights out do not pay back their interest.',
        ),
      ),
      InfoStep(
        emoji: '🧭',
        title: LText('Par où commencer', 'Where to start'),
        body: LText(
          'Liste tes dettes : montant, taux, paiement minimum. Commence par la plus chère (taux le plus élevé) tout en payant le minimum sur les autres.',
          'List your debts: amount, rate, minimum payment. Start with the most expensive (highest rate) while paying the minimum on the others.',
        ),
        points: [
          LText('Écris tout : montant, taux, minimum',
              'Write it all down: amount, rate, minimum'),
          LText('Attaque d\'abord le taux le plus élevé',
              'Attack the highest rate first'),
          LText('Évite de nouveaux crédits pour des envies',
              'Avoid new credit for wants'),
        ],
      ),
      TrueFalseStep(
        statement: LText(
          'Payer seulement le minimum sur une carte de crédit coûte souvent très cher sur la durée.',
          'Paying only the minimum on a credit card often costs a lot over time.',
        ),
        answer: true,
        explanation: LText(
          'Oui : les intérêts s\'accumulent. Le minimum protège ta cote, mais allonge et renchérit la dette.',
          'Yes: interest piles up. The minimum protects your score, but stretches and raises the cost of the debt.',
        ),
      ),
      QuizStep(
        question: LText('Tu as deux dettes. Laquelle rembourser en priorité ?',
            'You have two debts. Which should you pay down first?'),
        choices: [
          LessonChoice(
            fr: 'Celle au taux le plus bas',
            en: 'The one with the lowest rate',
            correct: false,
          ),
          LessonChoice(
            fr: 'Celle au taux le plus élevé',
            en: 'The one with the highest rate',
            correct: true,
          ),
          LessonChoice(
            fr: 'Celle avec le plus petit paiement minimum',
            en: 'The one with the smallest minimum payment',
            correct: false,
          ),
        ],
        explanation: LText(
          'Le taux le plus élevé coûte le plus cher chaque jour. C\'est lui qu\'on attaque en premier.',
          'The highest rate costs the most each day. That is the one to attack first.',
        ),
      ),
    ],
    takeaways: [
      LText('Dettes utiles vs dangereuses : le but et le taux comptent.',
          'Useful vs dangerous debt: purpose and rate matter.'),
      LText('Liste tes dettes, puis attaque le taux le plus élevé.',
          'List your debts, then attack the highest rate.'),
      LText('Le minimum sur une carte de crédit n\'efface presque rien.',
          'The credit-card minimum barely clears anything.'),
    ],
  ),
  CatalogLesson(
    id: 'inflation_101',
    emoji: '📈',
    minutes: 3,
    titleFr: 'L\'inflation, simplement',
    titleEn: 'Inflation, simply',
    objective: LText(
      'Comprendre pourquoi les prix montent et ce que ça change pour ton budget.',
      'Understand why prices rise and what that means for your budget.',
    ),
    steps: [
      InfoStep(
        emoji: '📈',
        title: LText('Quand les prix montent', 'When prices rise'),
        body: LText(
          'L\'inflation, c\'est la hausse générale des prix. Avec le même montant, tu achètes un peu moins qu\'avant. Ton budget doit suivre.',
          'Inflation is the general rise in prices. With the same amount you buy a little less than before. Your budget has to keep up.',
        ),
        points: [
          LText('Même argent, un peu moins de pouvoir d\'achat',
              'Same money, a little less buying power'),
          LText('Certains postes montent plus vite (alimentation, transport)',
              'Some categories rise faster (food, transport)'),
          LText('Revoir son budget de temps en temps aide',
              'Reviewing your budget now and then helps'),
        ],
      ),
      QuizStep(
        question: LText('Que signifie l\'inflation pour ton argent ?',
            'What does inflation mean for your money?'),
        choices: [
          LessonChoice(
            fr: 'Tes billets prennent de la valeur tout seuls',
            en: 'Your cash grows in value by itself',
            correct: false,
          ),
          LessonChoice(
            fr: 'Avec le même montant, tu achètes un peu moins',
            en: 'With the same amount, you buy a little less',
            correct: true,
          ),
          LessonChoice(
            fr: 'Les prix n\'ont aucun lien avec ton budget',
            en: 'Prices have no link to your budget',
            correct: false,
          ),
        ],
        explanation: LText(
          'L\'inflation réduit le pouvoir d\'achat : même somme, moins de biens ou de services.',
          'Inflation reduces buying power: same sum, fewer goods or services.',
        ),
      ),
      InfoStep(
        emoji: '🛡️',
        title: LText('Ce que tu peux faire', 'What you can do'),
        body: LText(
          'Tu ne contrôles pas l\'inflation, mais tu peux suivre tes postes qui montent, ajuster ton budget, et garder un fonds d\'urgence pour les surprises.',
          'You cannot control inflation, but you can watch the categories that rise, adjust your budget, and keep an emergency fund for surprises.',
        ),
        points: [
          LText('Repère les postes qui ont le plus augmenté',
              'Spot the categories that rose most'),
          LText('Ajuste ton budget, pas seulement tes envies',
              'Adjust your budget, not only your wants'),
          LText('Un fonds d\'urgence amortit les chocs',
              'An emergency fund softens the shocks'),
        ],
      ),
      TrueFalseStep(
        statement: LText(
          'Si les prix montent et que ton revenu reste fixe, ton reste à vivre diminue.',
          'If prices rise and your income stays fixed, your money left to spend shrinks.',
        ),
        answer: true,
        explanation: LText(
          'Oui : mêmes revenus, dépenses plus chères → moins de marge. D\'où l\'intérêt de suivre et d\'ajuster.',
          'Yes: same income, costlier spending → less room. That is why tracking and adjusting matter.',
        ),
      ),
      QuizStep(
        question: LText('Quelle réaction est la plus utile face à l\'inflation ?',
            'Which reaction is most useful against inflation?'),
        choices: [
          LessonChoice(
            fr: 'Ignorer les hausses et espérer',
            en: 'Ignore the rises and hope',
            correct: false,
          ),
          LessonChoice(
            fr: 'Suivre ses postes et ajuster son budget',
            en: 'Track your categories and adjust your budget',
            correct: true,
          ),
          LessonChoice(
            fr: 'Tout dépenser avant que les prix montent encore',
            en: 'Spend everything before prices rise further',
            correct: false,
          ),
        ],
        explanation: LText(
          'Suivre et ajuster te laisse le contrôle. Dépenser plus vite empire la situation.',
          'Tracking and adjusting keeps you in control. Spending faster makes it worse.',
        ),
      ),
    ],
    takeaways: [
      LText('L\'inflation réduit ce que ton argent peut acheter.',
          'Inflation reduces what your money can buy.'),
      LText('Certains postes montent plus vite : suis-les.',
          'Some categories rise faster: watch them.'),
      LText('Ajuste ton budget et garde un filet de sécurité.',
          'Adjust your budget and keep a safety net.'),
    ],
  ),
  CatalogLesson(
    id: 'spotting_scams',
    emoji: '🚨',
    minutes: 3,
    titleFr: 'Repérer les arnaques',
    titleEn: 'Spotting scams',
    objective: LText(
      'Reconnaître les signes d\'une arnaque et savoir quoi faire.',
      'Recognize the signs of a scam and know what to do.',
    ),
    steps: [
      InfoStep(
        emoji: '🚨',
        title: LText('Les signes qui alertent', 'Warning signs'),
        body: LText(
          'Urgence artificielle, gain trop beau, demande d\'argent ou de codes secrets : ce sont des signaux classiques. Un vrai service ne te presse pas de « ne rien dire à personne ».',
          'Fake urgency, a deal too good to be true, asking for money or secret codes: classic signals. A real service will not push you to "tell no one".',
        ),
        points: [
          LText('Urgence + secret = méfiance', 'Urgency + secrecy = be wary'),
          LText('Personne de sérieux ne demande ton code PIN',
              'No serious person asks for your PIN'),
          LText('Vérifie par un autre canal (site officiel, appel connu)',
              'Check via another channel (official site, known number)'),
        ],
      ),
      QuizStep(
        question: LText('Quel message ressemble le plus à une arnaque ?',
            'Which message looks most like a scam?'),
        choices: [
          LessonChoice(
            fr: 'Ta banque t\'écrit sur son app pour une alerte de paiement',
            en: 'Your bank messages you in its app about a payment alert',
            correct: false,
          ),
          LessonChoice(
            fr: '« Envoie de l\'argent maintenant, sinon ton compte sera bloqué — ne le dis à personne »',
            en: '"Send money now or your account will be locked — tell no one"',
            correct: true,
          ),
          LessonChoice(
            fr: 'Un ami te rappelle un remboursement promis',
            en: 'A friend reminds you of a promised repayment',
            correct: false,
          ),
        ],
        explanation: LText(
          'Urgence + argent + secret : trio classique de l\'arnaque.',
          'Urgency + money + secrecy: the classic scam trio.',
        ),
      ),
      InfoStep(
        emoji: '🔒',
        title: LText('Que faire', 'What to do'),
        body: LText(
          'Ne clique pas, ne verse rien, ne donne aucun code. Contacte toi-même l\'organisme par un canal que tu connais. Signale si besoin.',
          'Do not click, send money, or share any code. Contact the organisation yourself through a channel you know. Report it if needed.',
        ),
        points: [
          LText('Raccroche / ignore le message',
              'Hang up / ignore the message'),
          LText('Vérifie sur le site ou le numéro officiel',
              'Check on the official site or number'),
          LText('Parle-en : les arnaques aiment le silence',
              'Tell someone: scams thrive on silence'),
        ],
      ),
      TrueFalseStep(
        statement: LText(
          'Un vrai conseiller te demandera parfois ton code secret par SMS.',
          'A real adviser will sometimes ask for your secret code by SMS.',
        ),
        answer: false,
        explanation: LText(
          'Non : codes PIN, mots de passe et OTP restent pour toi seuls. Qui les demande est suspect.',
          'No: PINs, passwords and OTPs stay yours alone. Anyone asking for them is suspect.',
        ),
      ),
      QuizStep(
        question: LText('On te demande un code reçu par SMS « pour valider ». Que faire ?',
            'Someone asks for a code you got by SMS "to validate". What do you do?'),
        choices: [
          LessonChoice(
            fr: 'L\'envoyer, c\'est pour t\'aider',
            en: 'Send it — they are helping you',
            correct: false,
          ),
          LessonChoice(
            fr: 'Ne rien envoyer et vérifier par un canal officiel',
            en: 'Send nothing and check via an official channel',
            correct: true,
          ),
          LessonChoice(
            fr: 'L\'envoyer seulement si on insiste beaucoup',
            en: 'Send it only if they insist a lot',
            correct: false,
          ),
        ],
        explanation: LText(
          'Ce code sert à prouver que c\'est toi. Le donner à quelqu\'un d\'autre, c\'est leur ouvrir la porte.',
          'That code proves it is you. Giving it to someone else opens the door for them.',
        ),
      ),
    ],
    takeaways: [
      LText('Urgence + secret + argent = signaux d\'alarme.',
          'Urgency + secrecy + money = red flags.'),
      LText('Ne partage jamais PIN, mot de passe ou code SMS.',
          'Never share a PIN, password or SMS code.'),
      LText('Vérifie toujours par un canal que tu connais.',
          'Always verify through a channel you know.'),
    ],
  ),
];

const List<CatalogLesson> _unit4Lessons = [
  CatalogLesson(
    id: 'investing_basics',
    emoji: '🌱',
    minutes: 4,
    titleFr: 'Bases de l\'investissement',
    titleEn: 'Investing basics',
    objective: LText(
      'Comprendre la différence entre épargner et investir, et le rôle du risque.',
      'Understand the difference between saving and investing, and how risk works.',
    ),
    steps: [
      InfoStep(
        emoji: '🌱',
        title: LText('Épargner vs Investir', 'Saving vs Investing'),
        body: LText(
          'Épargner, c\'est mettre de l\'argent de côté en sécurité. Investir, c\'est faire travailler cet argent pour qu\'il prenne de la valeur sur le moyen et long terme.',
          'Saving is putting money aside safely. Investing is putting that money to work so it gains value over the medium and long term.',
        ),
        points: [
          LText('L\'épargne reste disponible pour les urgences',
              'Savings stay liquid for emergencies'),
          LText('L\'investissement vise le moyen et long terme (3 à 5 ans et plus)',
              'Investing targets the medium and long term (3 to 5 years+)'),
          LText('Tout investissement comporte un risque, rémunéré par le rendement',
              'Every investment carries risk, rewarded by expected returns'),
        ],
      ),
      QuizStep(
        question: LText('Quel argent est adapté pour commencer à investir ?',
            'Which money is suitable to start investing?'),
        choices: [
          LessonChoice(
            fr: 'L\'argent de ton loyer ou des courses du mois',
            en: 'Your rent or groceries money for the month',
            correct: false,
          ),
          LessonChoice(
            fr: 'Un surplus dont tu n\'as pas besoin à court terme, après avoir ton fonds d\'urgence',
            en: 'Surplus cash you do not need short term, after your emergency fund',
            correct: true,
          ),
          LessonChoice(
            fr: 'Un prêt contracté pour spéculer rapidement',
            en: 'A loan taken to speculate quickly',
            correct: false,
          ),
        ],
        explanation: LText(
          'On n\'investit jamais l\'argent du quotidien ou des urgences. On commence avec des surplus après s\'être protégé.',
          'Never invest money needed for daily life or emergencies. Start with surpluses after securing a safety net.',
        ),
      ),
      TrueFalseStep(
        statement: LText(
          'Investir garantit de doubler son argent en quelques semaines sans risque.',
          'Investing guarantees doubling your money in weeks with no risk.',
        ),
        answer: false,
        explanation: LText(
          'Les gains rapides et sans risque n\'existent pas : c\'est le piège classique des arnaques. Les vrais investissements prennent du temps.',
          'Fast risk-free gains do not exist: that is a classic scam red flag. Real investments take time to compound.',
        ),
      ),
      InfoStep(
        emoji: '🧺',
        title: LText('La diversification', 'Diversification'),
        body: LText(
          'Diversifier signifie répartir ton argent sur plusieurs actifs (entreprises, secteurs, pays) plutôt que tout miser sur un seul.',
          'Diversifying means spreading your money across multiple assets (companies, sectors, countries) rather than betting on one.',
        ),
        points: [
          LText('Si une entreprise chute, les autres amortissent le choc',
              'If one company drops, the others cushion the fall'),
          LText('Les fonds indiciels permettent de diversifier à moindre coût',
              'Index funds make broad diversification simple and low cost'),
        ],
      ),
    ],
    takeaways: [
      LText('Construis ton fonds d\'urgence avant de commencer à investir.',
          'Build your emergency fund before you start investing.'),
      LText('Investis pour le long terme : le temps absorbe les soubresauts du marché.',
          'Invest for the long run: time smooths market fluctuations.'),
      LText('Diversifie toujours pour ne jamais dépendre d\'un seul actif.',
          'Always diversify so you never depend on a single asset.'),
    ],
  ),
  CatalogLesson(
    id: 'compound_interest',
    emoji: '🪄',
    minutes: 3,
    titleFr: 'La magie des intérêts composés',
    titleEn: 'The magic of compound interest',
    objective: LText(
      'Découvrir comment les gains créent de nouveaux gains au fil du temps.',
      'Discover how returns generate new returns over time.',
    ),
    steps: [
      InfoStep(
        emoji: '🪄',
        title: LText('L\'effet boule de neige', 'The snowball effect'),
        body: LText(
          'Les intérêts composés, c\'est quand tes intérêts génèrent eux-mêmes des intérêts. Plus tu laisses passer de temps, plus la croissance s\'accélère.',
          'Compound interest happens when your interest earns interest of its own. The more time passes, the faster it grows.',
        ),
        points: [
          LText('Année 1 : tu gagnes des intérêts sur ton versement initial',
              'Year 1: you earn interest on your initial deposit'),
          LText('Année 2 : tu gagnes des intérêts sur ton capital ET sur les intérêts passés',
              'Year 2: you earn interest on your principal AND past earnings'),
          LText('Sur 10 à 20 ans, la courbe grimpe de façon impressionnante',
              'Over 10 to 20 years, the growth curve turns exponential'),
        ],
      ),
      QuizStep(
        question: LText('Qui tirera le plus profit des intérêts composés ?',
            'Who will benefit most from compound interest?'),
        choices: [
          LessonChoice(
            fr: 'Une personne qui commence à 20 ans avec 30 \$/€ par mois',
            en: 'Someone starting at 20 with 30 \$/€ per month',
            correct: true,
          ),
          LessonChoice(
            fr: 'Une personne qui attend 45 ans pour mettre 100 \$/€ par mois',
            en: 'Someone waiting until 45 to put 100 \$/€ per month',
            correct: false,
          ),
        ],
        explanation: LText(
          'Commencer 25 ans plus tôt donne beaucoup plus d\'années aux intérêts pour décupler le capital, même avec de petits montants.',
          'Starting 25 years earlier gives compound interest decades to multiply your capital, even on modest contributions.',
        ),
      ),
      TrueFalseStep(
        statement: LText(
          'Plus on commence tôt à épargner ou investir, plus l\'effet des intérêts composés est puissant.',
          'The earlier you start saving or investing, the more powerful compound interest becomes.',
        ),
        answer: true,
        explanation: LText(
          'Exact ! Le temps est le facteur le plus décisif dans l\'effet boule de neige financier.',
          'Exactly! Time is the most decisive factor in the financial snowball effect.',
        ),
      ),
      InfoStep(
        emoji: '⏳',
        title: LText('La régularité avant tout', 'Consistency above all'),
        body: LText(
          'Pas besoin d\'une fortune pour commencer. Mettre même 15 ou 25 \$/€ de côté chaque mois de façon automatique enclenche la machine.',
          'You don\'t need a fortune to start. Putting even 15 or 25 \$/€ aside automatically every month gets the flywheel spinning.',
        ),
        points: [
          LText('Automatise tes virements pour ne jamais hésiter',
              'Automate your transfers so you never hesitate'),
          LText('La patience et la discipline battent les coups de chance',
              'Patience and discipline outperform lucky gambles'),
        ],
      ),
    ],
    takeaways: [
      LText('Les intérêts composés font faire des petits à ton argent.',
          'Compound interest lets your returns make returns of their own.'),
      LText('Commencer tôt a plus d\'impact que commencer gros.',
          'Starting early has more impact than waiting to start big.'),
      LText('La régularité automatique transforme les petits pas en grand nid.',
          'Automated consistency turns small steps into a solid nest egg.'),
    ],
  ),
  CatalogLesson(
    id: 'smart_budget_503020',
    emoji: '⚖️',
    minutes: 4,
    titleFr: 'La règle du 50 / 30 / 20',
    titleEn: 'The 50 / 30 / 20 rule',
    objective: LText(
      'Apprendre une méthode simple et universelle pour équilibrer ses revenus chaque mois.',
      'Learn a simple, universal framework to balance your monthly income.',
    ),
    steps: [
      InfoStep(
        emoji: '⚖️',
        title: LText('Trois parts pour ton revenu', 'Three slices for your income'),
        body: LText(
          'La règle 50/30/20 est une boussole pour répartir ton salaire net chaque mois sans prise de tête et garder l\'esprit serein.',
          'The 50/30/20 rule is a practical compass to divide your take-home pay each month without stress.',
        ),
        points: [
          LText('50 % pour tes besoins essentiels (loyer, factures, courses)',
              '50% for essential needs (rent, bills, groceries)'),
          LText('30 % pour tes envies et loisirs (sorties, restos, plaisirs)',
              '30% for wants and leisure (outings, dining, treats)'),
          LText('20 % pour ton épargne et tes objectifs d\'avenir',
              '20% for your savings and future goals'),
        ],
      ),
      QuizStep(
        question: LText('Dans quelle tranche classe-t-on une sortie resto entre amis ?',
            'In which bucket does dining out with friends belong?'),
        choices: [
          LessonChoice(
            fr: 'Les 50 % de besoins vitaux',
            en: 'The 50% essential needs',
            correct: false,
          ),
          LessonChoice(
            fr: 'Les 30 % d\'envies et loisirs',
            en: 'The 30% wants and leisure',
            correct: true,
          ),
          LessonChoice(
            fr: 'Les 20 % d\'épargne',
            en: 'The 20% savings',
            correct: false,
          ),
        ],
        explanation: LText(
          'Se nourrir est un besoin, mais aller au resto est un plaisir agréable qui relève de tes envies.',
          'Eating is a need, but dining at a restaurant is an enjoyable treat that belongs in wants.',
        ),
      ),
      TrueFalseStep(
        statement: LText(
          'Si tes besoins dépassent 50 %, cette règle t\'interdit de faire des ajustements.',
          'If your essentials exceed 50%, the rule forbids making adjustments.',
        ),
        answer: false,
        explanation: LText(
          'La règle est un guide souple, pas une prison. Adapte-la à ta réalité (ex: 60/25/15) puis améliore tes ratios progressivement.',
          'The rule is a flexible guide, not a rigid constraint. Adapt it to your reality (e.g. 60/25/15) and improve over time.',
        ),
      ),
      InfoStep(
        emoji: '🧘',
        title: LText('Dépenser sans culpabilité', 'Guilt-free spending'),
        body: LText(
          'Le grand avantage : dès que tes 20 % d\'épargne et ton socle de 50 % sont sécurisés, tes 30 % d\'envies se dépensent en toute tranquillité.',
          'The biggest perk: once your 20% savings and 50% baseline are locked in, your 30% wants can be enjoyed guilt-free.',
        ),
        points: [
          LText('Tu profites de la vie sans craindre pour la fin de mois',
              'You enjoy life without fearing month-end surprises'),
          LText('Ton nid grandit chaque mois automatiquement',
              'Your nest grows automatically each and every month'),
        ],
      ),
    ],
    takeaways: [
      LText('50 % pour tes besoins vitaux, 30 % pour tes envies, 20 % pour ton épargne.',
          '50% for vital needs, 30% for wants, 20% for savings.'),
      LText('Cette règle est une boussole flexible, adaptable à ton coût de la vie.',
          'This framework is a flexible compass, adaptable to your reality.'),
      LText('Prévoir un budget plaisir permet de tenir ses finances sans frustration.',
          'Budgeting for fun lets you maintain healthy finances without burnout.'),
    ],
  ),
];

class CatalogUnit {
  const CatalogUnit({
    required this.id,
    required this.titleFr,
    required this.titleEn,
    required this.subtitle,
    required this.lessons,
    required this.bonusXp,
    required this.bonusSeeds,
  });

  /// Matches `LESSON_UNITS` on the server (functions/src/shared/lessonPath.ts).
  final String id;
  final String titleFr;
  final String titleEn;

  /// What the unit is about, in one line.
  final LText subtitle;
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
    subtitle: LText(
        'Comprendre où va ton argent', 'Understand where your money goes'),
    lessons: _unit1Lessons,
    bonusXp: 30,
    bonusSeeds: 10,
  ),
  CatalogUnit(
    id: 'unit_2',
    titleFr: 'Épargner, un pas après l\'autre',
    titleEn: 'Saving, one step at a time',
    subtitle:
        LText('Mettre de côté, simplement', 'Setting money aside, simply'),
    lessons: _unit2Lessons,
    bonusXp: 30,
    bonusSeeds: 10,
  ),
  CatalogUnit(
    id: 'unit_3',
    titleFr: 'Protéger ton argent',
    titleEn: 'Protect your money',
    subtitle: LText(
        'Dettes, inflation et arnaques', 'Debt, inflation and scams'),
    lessons: _unit3Lessons,
    bonusXp: 30,
    bonusSeeds: 10,
  ),
  CatalogUnit(
    id: 'unit_4',
    titleFr: 'Faire grandir son argent',
    titleEn: 'Grow your money',
    subtitle: LText(
        'Investir et faire fructifier son épargne', 'Invest and make your savings grow'),
    lessons: _unit4Lessons,
    bonusXp: 30,
    bonusSeeds: 10,
  ),
];

/// Every lesson in path order (unit by unit).
const List<CatalogLesson> kCatalogLessons = [
  ..._unit1Lessons,
  ..._unit2Lessons,
  ..._unit3Lessons,
  ..._unit4Lessons,
];

/// Path + country modules (player lookup). Country list is appended in
/// `country_lesson_catalog.dart` via [kAllPlayableLessons].

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
