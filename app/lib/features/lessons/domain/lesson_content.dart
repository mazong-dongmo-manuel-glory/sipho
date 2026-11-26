/// Contenu pédagogique embarqué (miroirs des leçons du catalogue).
///
/// Chaque id de `kLessonCatalog` a son propre texte. Une leçon inconnue
/// retombe sur le coussin d’urgence, jamais sur un mélange d’une autre leçon.
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
  final String tfStatementFr;
  final String tfStatementEn;
  final bool tfAnswer;
  final String tfCorrectFr;
  final String tfCorrectEn;
  final String tfWrongFr;
  final String tfWrongEn;
  final String simPromptFr;
  final String simPromptEn;
  final List<String> simOptionsFr;
  final List<String> simOptionsEn;
  final int simCorrectIndex;
  final String simGoodFr;
  final String simGoodEn;
  final String simOtherFr;
  final String simOtherEn;

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
    required this.tfStatementFr,
    required this.tfStatementEn,
    required this.tfAnswer,
    required this.tfCorrectFr,
    required this.tfCorrectEn,
    required this.tfWrongFr,
    required this.tfWrongEn,
    required this.simPromptFr,
    required this.simPromptEn,
    required this.simOptionsFr,
    required this.simOptionsEn,
    required this.simCorrectIndex,
    required this.simGoodFr,
    required this.simGoodEn,
    required this.simOtherFr,
    required this.simOtherEn,
  });

  String question(bool fr) => fr ? questionFr : questionEn;
  List<String> options(bool fr) => fr ? optionsFr : optionsEn;
  String explain(bool fr) => fr ? explainFr : explainEn;
  String cardBody(bool fr) => fr ? cardBodyFr : cardBodyEn;
  String tfStatement(bool fr) => fr ? tfStatementFr : tfStatementEn;
  String tfCorrect(bool fr) => fr ? tfCorrectFr : tfCorrectEn;
  String tfWrong(bool fr) => fr ? tfWrongFr : tfWrongEn;
  String simPrompt(bool fr) => fr ? simPromptFr : simPromptEn;
  List<String> simOptions(bool fr) => fr ? simOptionsFr : simOptionsEn;
  String simGood(bool fr) => fr ? simGoodFr : simGoodEn;
  String simOther(bool fr) => fr ? simOtherFr : simOtherEn;
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
    tfStatementFr: 'Un fonds d’urgence doit être accessible.',
    tfStatementEn: 'An emergency fund should be accessible.',
    tfAnswer: true,
    tfCorrectFr: 'Exact. Accessible ne veut pas dire investi en bourse.',
    tfCorrectEn: 'Right. Accessible does not mean invested in the market.',
    tfWrongFr: 'Pas tout à fait — il doit rester liquide.',
    tfWrongEn: 'Not quite — it needs to stay liquid.',
    simPromptFr: 'Tu reçois un bonus de 200 \$.',
    simPromptEn: 'You receive a \$200 bonus.',
    simOptionsFr: [
      'Tout dépenser tout de suite',
      'Mettre 150 \$ dans le coussin',
      'Attendre sans décider',
    ],
    simOptionsEn: [
      'Spend it all right away',
      'Put \$150 into the cushion',
      'Wait without deciding',
    ],
    simCorrectIndex: 1,
    simGoodFr: 'Solide. Ton coussin grandit sans tout sacrifier.',
    simGoodEn: 'Solid. Your cushion grows without giving everything up.',
    simOtherFr: 'Possible — regarde ce que ton nid préfère.',
    simOtherEn: 'Possible — see what your nest would rather you do.',
  ),
  'needs_wants': LessonQuizContent(
    questionFr: 'Quelle dépense est plutôt un besoin ?',
    questionEn: 'Which expense is more of a need?',
    optionsFr: [
      'Loyer',
      'Nouveau casque audio',
      'Abonnement streaming en plus',
      'Restaurant gastronomique',
    ],
    optionsEn: [
      'Rent',
      'A new pair of headphones',
      'An extra streaming subscription',
      'Fine dining',
    ],
    correctIndex: 0,
    explainFr: 'Le logement fait partie du socle indispensable.',
    explainEn: 'Housing is part of your essential base.',
    cardBodyFr:
        'Sépare besoins (socle) et envies (flexibles) pour décider sans culpabilité.',
    cardBodyEn:
        'Separate needs (base) from wants (flexible) to decide without guilt.',
    tfStatementFr: 'Un abonnement de streaming est toujours un besoin.',
    tfStatementEn: 'A streaming subscription is always a need.',
    tfAnswer: false,
    tfCorrectFr: 'Oui : c’est souvent une envie, même si elle fait plaisir.',
    tfCorrectEn: 'Yes: it is usually a want, even when it feels nice.',
    tfWrongFr: 'Un besoin, c’est ce qui tient le nid. Le reste est flexible.',
    tfWrongEn: 'A need is what keeps the nest standing. The rest is flexible.',
    simPromptFr: 'Il te reste 40 \$ avant la fin du mois.',
    simPromptEn: 'You have \$40 left before the month ends.',
    simOptionsFr: [
      'Un repas déjà prévu à la maison',
      'Une sortie que tu peux déplacer',
      'Les deux, sans regarder le reste',
    ],
    simOptionsEn: [
      'A meal you already planned at home',
      'An outing you can move',
      'Both, without looking at what is left',
    ],
    simCorrectIndex: 0,
    simGoodFr: 'Tu protèges le besoin et tu gardes l’envie pour plus tard.',
    simGoodEn: 'You protect the need and keep the want for later.',
    simOtherFr: 'Regarde d’abord ce qui est déjà engagé dans le socle.',
    simOtherEn: 'Look first at what the base has already committed.',
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
    tfStatementFr: 'Noter une dépense la rend plus grave.',
    tfStatementEn: 'Logging an expense makes it worse.',
    tfAnswer: false,
    tfCorrectFr: 'La note ne juge pas. Elle montre seulement le chemin.',
    tfCorrectEn: 'A log does not judge. It only shows the path.',
    tfWrongFr: 'Suivre n’est pas se punir. C’est voir clair.',
    tfWrongEn: 'Tracking is not punishment. It is clarity.',
    simPromptFr: 'Tu as payé un café et tu es pressé.',
    simPromptEn: 'You paid for a coffee and you are in a hurry.',
    simOptionsFr: [
      'Le noter en 10 secondes, même approximatif',
      'L’oublier, ce n’est qu’un café',
      'Attendre la fin du mois pour tout reconstruire',
    ],
    simOptionsEn: [
      'Log it in 10 seconds, even roughly',
      'Skip it, it is only a coffee',
      'Wait until month end to rebuild everything',
    ],
    simCorrectIndex: 0,
    simGoodFr: 'Une note rapide vaut mieux qu’un trou dans l’histoire.',
    simGoodEn: 'A quick log beats a hole in the story.',
    simOtherFr: 'Les petits oublis s’additionnent sans qu’on les voie.',
    simOtherEn: 'Small skips add up where you cannot see them.',
  ),
  'savings_goal': LessonQuizContent(
    questionFr: 'À quoi sert de nommer un objectif d’épargne ?',
    questionEn: 'Why name a savings goal?',
    optionsFr: [
      'Pour le comparer aux autres',
      'Pour savoir pourquoi tu mets de l’argent de côté',
      'Pour bloquer l’argent à vie',
      'Pour remplacer un budget',
    ],
    optionsEn: [
      'To compare it with other people',
      'To know why you are setting money aside',
      'To lock the money away forever',
      'To replace a budget',
    ],
    correctIndex: 1,
    explainFr: 'Un nom rend l’objectif concret et plus facile à suivre.',
    explainEn: 'A name makes the goal concrete and easier to follow.',
    cardBodyFr:
        'Donne un nom, un montant et une date souple. L’objectif devient un nid, pas une punition.',
    cardBodyEn:
        'Give it a name, an amount, and a flexible date. The goal becomes a nest, not a punishment.',
    tfStatementFr: 'Un objectif sans montant reste difficile à suivre.',
    tfStatementEn: 'A goal without an amount is hard to follow.',
    tfAnswer: true,
    tfCorrectFr: 'Oui. Le montant dit ce qu’il reste, pas ce que tu vaux.',
    tfCorrectEn: 'Yes. The amount says what is left, not what you are worth.',
    tfWrongFr: 'Sans chiffre, on ne sait pas si on avance.',
    tfWrongEn: 'Without a number, you cannot tell if you are moving.',
    simPromptFr: 'Tu veux un voyage dans 10 mois.',
    simPromptEn: 'You want a trip in 10 months.',
    simOptionsFr: [
      'Nommer l’objectif et verser un petit montant fixe',
      'Attendre d’avoir « assez » d’un coup',
      'Mélanger ce voyage avec le coussin d’urgence',
    ],
    simOptionsEn: [
      'Name the goal and transfer a small fixed amount',
      'Wait until you have “enough” all at once',
      'Mix this trip with the emergency cushion',
    ],
    simCorrectIndex: 0,
    simGoodFr: 'Un versement nommé avance même quand il est petit.',
    simGoodEn: 'A named transfer moves you forward even when it is small.',
    simOtherFr: 'Sépare le voyage du coussin : les deux n’ont pas le même rôle.',
    simOtherEn: 'Keep the trip separate from the cushion: they do different jobs.',
  ),
  'pay_yourself_first': LessonQuizContent(
    questionFr: 'Se payer en premier, c’est quoi ?',
    questionEn: 'What does paying yourself first mean?',
    optionsFr: [
      'Dépenser le salaire le jour où il arrive',
      'Mettre l’épargne de côté avant les envies',
      'Attendre ce qui reste en fin de mois',
      'Emprunter pour épargner',
    ],
    optionsEn: [
      'Spending payday the day it arrives',
      'Setting savings aside before wants',
      'Waiting for whatever is left at month end',
      'Borrowing in order to save',
    ],
    correctIndex: 1,
    explainFr: 'L’épargne part au début, comme une facture que tu te dois.',
    explainEn: 'Savings leave at the start, like a bill you owe yourself.',
    cardBodyFr:
        'Le jour du revenu, verse d’abord vers l’objectif. Le reste du mois s’organise avec ce qui demeure.',
    cardBodyEn:
        'On payday, transfer to the goal first. The rest of the month uses what remains.',
    tfStatementFr: 'Ce qui reste en fin de mois est le meilleur plan d’épargne.',
    tfStatementEn: 'Whatever is left at month end is the best savings plan.',
    tfAnswer: false,
    tfCorrectFr: 'Souvent il ne reste rien. D’où le versement au début.',
    tfCorrectEn: 'Often nothing is left. That is why the transfer comes first.',
    tfWrongFr: 'La fin du mois est trop tardive pour décider à ta place.',
    tfWrongEn: 'Month end is too late to decide for you.',
    simPromptFr: 'Ton revenu vient d’arriver.',
    simPromptEn: 'Your income just arrived.',
    simOptionsFr: [
      'Verser l’épargne prévue, puis payer le socle',
      'Tout laisser sur le compte courant « pour voir »',
      'Augmenter les sorties parce que le solde est haut',
    ],
    simOptionsEn: [
      'Transfer the planned savings, then pay the base',
      'Leave it all in checking “to see”',
      'Increase outings because the balance looks high',
    ],
    simCorrectIndex: 0,
    simGoodFr: 'Tu te paies avant que les envies négocient.',
    simGoodEn: 'You pay yourself before wants start negotiating.',
    simOtherFr: 'Un solde haut n’est pas de l’argent libre.',
    simOtherEn: 'A high balance is not free money.',
  ),
  'small_amounts': LessonQuizContent(
    questionFr: 'Pourquoi les petits montants comptent ?',
    questionEn: 'Why do small amounts count?',
    optionsFr: [
      'Parce qu’ils sont invisibles et donc inutiles',
      'Parce que la régularité construit l’habitude',
      'Parce qu’il faut attendre un gros montant',
      'Parce qu’ils remplacent un revenu',
    ],
    optionsEn: [
      'Because they are invisible and therefore useless',
      'Because regularity builds the habit',
      'Because you should wait for a large amount',
      'Because they replace income',
    ],
    correctIndex: 1,
    explainFr: 'Répéter un petit geste bat un effort rare et épuisant.',
    explainEn: 'Repeating a small move beats a rare, exhausting effort.',
    cardBodyFr:
        'Cinq dollars réguliers valent mieux qu’un plan parfait que tu ne tiens pas.',
    cardBodyEn:
        'Five dollars on a regular beat beats a perfect plan you do not keep.',
    tfStatementFr: 'Un petit versement régulier peut compter plus qu’un gros versement rare.',
    tfStatementEn: 'A small regular transfer can matter more than a rare large one.',
    tfAnswer: true,
    tfCorrectFr: 'Oui. C’est l’habitude qui tient, pas le montant spectaculaire.',
    tfCorrectEn: 'Yes. The habit holds, not the spectacular amount.',
    tfWrongFr: 'Attendre le « gros » montant reporte souvent tout.',
    tfWrongEn: 'Waiting for the “big” amount often postpones everything.',
    simPromptFr: 'Tu ne peux mettre que 5 \$ de côté cette semaine.',
    simPromptEn: 'You can only set aside \$5 this week.',
    simOptionsFr: [
      'Les verser quand même',
      'Ne rien faire, c’est trop petit',
      'Les dépenser pour « arrondir »',
    ],
    simOptionsEn: [
      'Transfer them anyway',
      'Do nothing, it is too small',
      'Spend them to “round things off”',
    ],
    simCorrectIndex: 0,
    simGoodFr: 'Le geste compte. La série d’épargne continue.',
    simGoodEn: 'The move counts. The saving streak continues.',
    simOtherFr: 'Sauter les petites semaines casse le rythme.',
    simOtherEn: 'Skipping the small weeks breaks the rhythm.',
  ),
  'debt_basics': LessonQuizContent(
    questionFr: 'Quelle dette coûte en général le plus cher à garder ?',
    questionEn: 'Which debt is usually the most expensive to keep?',
    optionsFr: [
      'Celle au taux le plus bas',
      'Celle au taux le plus élevé',
      'Celle dont le nom est le plus long',
      'Celle que tu ignores',
    ],
    optionsEn: [
      'The one with the lowest rate',
      'The one with the highest rate',
      'The one with the longest name',
      'The one you ignore',
    ],
    correctIndex: 1,
    explainFr:
        'Le taux dit le prix de l’attente. Ce n’est pas un conseil personnalisé.',
    explainEn:
        'The rate is the price of waiting. This is not personal advice.',
    cardBodyFr:
        'Liste tes dettes : solde, taux, mensualité. Le taux le plus haut est souvent le premier à réduire.',
    cardBodyEn:
        'List your debts: balance, rate, payment. The highest rate is often the first to shrink.',
    tfStatementFr: 'Ignorer une dette la fait disparaître.',
    tfStatementEn: 'Ignoring a debt makes it disappear.',
    tfAnswer: false,
    tfCorrectFr: 'Non. Le coût continue, même sans y penser.',
    tfCorrectEn: 'No. The cost continues even when you are not thinking about it.',
    tfWrongFr: 'Une dette non vue reste une dette.',
    tfWrongEn: 'An unseen debt is still a debt.',
    simPromptFr: 'Tu as un petit surplus ce mois-ci.',
    simPromptEn: 'You have a small surplus this month.',
    simOptionsFr: [
      'L’envoyer vers la dette au taux le plus élevé',
      'Ouvrir une nouvelle dette « pour comparer »',
      'Le dépenser sans noter le solde',
    ],
    simOptionsEn: [
      'Send it to the highest-rate debt',
      'Open a new debt “to compare”',
      'Spend it without noting the balance',
    ],
    simCorrectIndex: 0,
    simGoodFr: 'Tu réduis d’abord ce qui coûte le plus à garder.',
    simGoodEn: 'You shrink first what costs the most to keep.',
    simOtherFr: 'Ajouter une dette ne clarifie pas les anciennes.',
    simOtherEn: 'Adding a debt does not clarify the old ones.',
  ),
  'inflation_101': LessonQuizContent(
    questionFr: 'Que fait l’inflation à l’argent qui dort ?',
    questionEn: 'What does inflation do to idle money?',
    optionsFr: [
      'Elle augmente son pouvoir d’achat',
      'Elle peut réduire ce qu’il achète avec le temps',
      'Elle le transforme en salaire',
      'Elle l’efface du compte',
    ],
    optionsEn: [
      'It increases its purchasing power',
      'It can reduce what it buys over time',
      'It turns it into a salary',
      'It deletes it from the account',
    ],
    correctIndex: 1,
    explainFr: 'Les prix qui montent font acheter moins avec le même montant.',
    explainEn: 'Rising prices buy less with the same amount.',
    cardBodyFr:
        'L’inflation est une hausse générale des prix. Ton coussin liquide sert à la sécurité, pas à « battre » l’inflation.',
    cardBodyEn:
        'Inflation is a general rise in prices. Your liquid cushion is for safety, not for “beating” inflation.',
    tfStatementFr: 'Si les prix montent, le même montant achète souvent moins.',
    tfStatementEn: 'If prices rise, the same amount often buys less.',
    tfAnswer: true,
    tfCorrectFr: 'Oui. C’est ça, perdre du pouvoir d’achat.',
    tfCorrectEn: 'Yes. That is what losing purchasing power means.',
    tfWrongFr: 'Le chiffre sur le compte peut rester fixe pendant que les prix bougent.',
    tfWrongEn: 'The number in the account can stay still while prices move.',
    simPromptFr: 'Ton épicerie habituelle coûte un peu plus cher.',
    simPromptEn: 'Your usual groceries cost a bit more.',
    simOptionsFr: [
      'Le noter et ajuster l’enveloppe, sans te blâmer',
      'Conclure que tu « dépenses mal »',
      'Vider le coussin d’urgence pour compenser',
    ],
    simOptionsEn: [
      'Log it and adjust the envelope, without blaming yourself',
      'Decide you are “spending badly”',
      'Empty the emergency cushion to compensate',
    ],
    simCorrectIndex: 0,
    simGoodFr: 'Tu vois la hausse des prix à part de tes choix.',
    simGoodEn: 'You see the price rise separately from your choices.',
    simOtherFr: 'Le coussin n’est pas là pour absorber chaque hausse du quotidien.',
    simOtherEn: 'The cushion is not there to absorb every everyday price rise.',
  ),
  'spotting_scams': LessonQuizContent(
    questionFr: 'Quel message est un signal d’arnaque ?',
    questionEn: 'Which message is a scam signal?',
    optionsFr: [
      '« Envoie le code reçu par SMS »',
      'Un relevé que tu ouvres dans l’appli de ta banque',
      'Une facture que tu attendais',
      'Un rappel de ton propre calendrier',
    ],
    optionsEn: [
      '“Send the code you received by text”',
      'A statement you open in your bank’s app',
      'A bill you were expecting',
      'A reminder from your own calendar',
    ],
    correctIndex: 0,
    explainFr: 'Un code secret ne se transmet à personne, même « au service client ».',
    explainEn: 'A secret code is never shared, not even with “customer service”.',
    cardBodyFr:
        'Méfie-toi de l’urgence, des liens surprises et de toute demande de code ou de mot de passe.',
    cardBodyEn:
        'Watch for urgency, surprise links, and any request for a code or password.',
    tfStatementFr: 'Ta banque peut te demander ton mot de passe par message.',
    tfStatementEn: 'Your bank may ask for your password in a message.',
    tfAnswer: false,
    tfCorrectFr: 'Non. Tu te connectes toi-même, sans donner le secret.',
    tfCorrectEn: 'No. You sign in yourself, without handing over the secret.',
    tfWrongFr: 'Personne de légitime n’a besoin de ton mot de passe.',
    tfWrongEn: 'No legitimate person needs your password.',
    simPromptFr: 'Un SMS dit : « Compte bloqué, clique ici ».',
    simPromptEn: 'A text says: “Account locked, tap here”.',
    simOptionsFr: [
      'Ouvrir l’appli officielle toi-même, sans le lien',
      'Cliquer et entrer le code reçu',
      'Répondre avec ta date de naissance',
    ],
    simOptionsEn: [
      'Open the official app yourself, without the link',
      'Tap and enter the code you received',
      'Reply with your date of birth',
    ],
    simCorrectIndex: 0,
    simGoodFr: 'Tu vérifies à la source, pas dans le message.',
    simGoodEn: 'You check at the source, not inside the message.',
    simOtherFr: 'Le lien et le code sont le piège.',
    simOtherEn: 'The link and the code are the trap.',
  ),
  'investing_basics': LessonQuizContent(
    questionFr: 'Qu’est-ce qui est vrai pour un placement ?',
    questionEn: 'What is true of an investment?',
    optionsFr: [
      'Le gain est garanti',
      'La valeur peut monter ou baisser',
      'Ça remplace le coussin d’urgence',
      'C’est la même chose qu’un compte courant',
    ],
    optionsEn: [
      'The gain is guaranteed',
      'The value can rise or fall',
      'It replaces the emergency cushion',
      'It is the same as a checking account',
    ],
    correctIndex: 1,
    explainFr:
        'Un placement peut perdre de la valeur. Ceci est éducatif, pas un conseil d’acheter.',
    explainEn:
        'An investment can lose value. This is educational, not advice to buy.',
    cardBodyFr:
        'On n’investit que l’argent dont on n’a pas besoin tout de suite. Le coussin liquide reste à part.',
    cardBodyEn:
        'You invest only money you do not need right away. The liquid cushion stays separate.',
    tfStatementFr: 'Un placement peut perdre de la valeur.',
    tfStatementEn: 'An investment can lose value.',
    tfAnswer: true,
    tfCorrectFr: 'Oui. Le risque fait partie du placement.',
    tfCorrectEn: 'Yes. Risk is part of investing.',
    tfWrongFr: 'Aucun placement éducatif ici ne promet un gain.',
    tfWrongEn: 'No lesson here promises a gain.',
    simPromptFr: 'Tu as un coussin de 1 mois et un surplus.',
    simPromptEn: 'You have a 1-month cushion and a surplus.',
    simOptionsFr: [
      'Garder le coussin liquide, et n’envisager le surplus qu’ensuite',
      'Tout placer, y compris le coussin',
      'Emprunter pour « aller plus vite »',
    ],
    simOptionsEn: [
      'Keep the cushion liquid, and only then look at the surplus',
      'Invest everything, including the cushion',
      'Borrow to “go faster”',
    ],
    simCorrectIndex: 0,
    simGoodFr: 'La sécurité d’abord. Le placement vient après.',
    simGoodEn: 'Safety first. Investing comes after.',
    simOtherFr: 'Mélanger coussin et placement retire la sécurité.',
    simOtherEn: 'Mixing the cushion and investments removes the safety.',
  ),
  'compound_interest': LessonQuizContent(
    questionFr: 'Les intérêts composés, c’est quoi ?',
    questionEn: 'What is compound interest?',
    optionsFr: [
      'Des intérêts calculés seulement sur le départ',
      'Des intérêts qui portent eux-mêmes des intérêts avec le temps',
      'Un frais bancaire fixe',
      'Une prime versée une seule fois',
    ],
    optionsEn: [
      'Interest calculated only on the start',
      'Interest that itself earns interest over time',
      'A fixed bank fee',
      'A bonus paid only once',
    ],
    correctIndex: 1,
    explainFr: 'Le temps fait grossir la base, dans les deux sens : gain ou coût d’une dette.',
    explainEn: 'Time grows the base, both ways: a gain, or the cost of a debt.',
    cardBodyFr:
        'Commencer tôt, même petit, laisse le temps travailler. Sur une dette, le même mécanisme augmente le coût.',
    cardBodyEn:
        'Starting early, even small, lets time work. On a debt, the same mechanism raises the cost.',
    tfStatementFr: 'Les intérêts composés n’ont besoin d’aucun temps pour agir.',
    tfStatementEn: 'Compound interest needs no time to work.',
    tfAnswer: false,
    tfCorrectFr: 'Le temps est le moteur. Sans durée, il n’y a pas d’effet.',
    tfCorrectEn: 'Time is the engine. Without duration, there is no effect.',
    tfWrongFr: 'C’est la durée qui change la taille du résultat.',
    tfWrongEn: 'Duration is what changes the size of the result.',
    simPromptFr: 'Tu peux commencer cette année ou dans dix ans.',
    simPromptEn: 'You can start this year or in ten years.',
    simOptionsFr: [
      'Commencer petit maintenant',
      'Attendre dix ans pour un montant « sérieux »',
      'Arrêter dès que le premier mois est petit',
    ],
    simOptionsEn: [
      'Start small now',
      'Wait ten years for a “serious” amount',
      'Stop as soon as the first month looks small',
    ],
    simCorrectIndex: 0,
    simGoodFr: 'Le temps commence dès le premier versement.',
    simGoodEn: 'Time starts with the first transfer.',
    simOtherFr: 'Reporter le départ retire des années au mécanisme.',
    simOtherEn: 'Delaying the start takes years away from the mechanism.',
  ),
  'smart_budget_503020': LessonQuizContent(
    questionFr: 'Dans la règle 50 / 30 / 20, que représente en général le 20 ?',
    questionEn: 'In the 50 / 30 / 20 rule, what does the 20 usually stand for?',
    optionsFr: [
      'Les envies',
      'Le loyer seul',
      'L’épargne et le remboursement de dettes',
      'Les frais bancaires',
    ],
    optionsEn: [
      'Wants',
      'Rent alone',
      'Savings and debt payments',
      'Bank fees',
    ],
    correctIndex: 2,
    explainFr:
        'Repère courant : 50 besoins, 30 envies, 20 épargne ou dettes. À adapter à ta vie, pas une loi.',
    explainEn:
        'A common guide: 50 needs, 30 wants, 20 savings or debt. Adapt it to your life; it is not a law.',
    cardBodyFr:
        'La règle 50 / 30 / 20 est un repère. Si le socle dépasse 50, tu ajustes les envies avant de te juger.',
    cardBodyEn:
        'The 50 / 30 / 20 rule is a guide. If the base is over 50, you adjust wants before judging yourself.',
    tfStatementFr: 'La règle 50 / 30 / 20 est une obligation légale.',
    tfStatementEn: 'The 50 / 30 / 20 rule is a legal requirement.',
    tfAnswer: false,
    tfCorrectFr: 'Non. C’est un repère pédagogique, pas une loi.',
    tfCorrectEn: 'No. It is a teaching guide, not a law.',
    tfWrongFr: 'Aucune règle de budget ici n’est une obligation.',
    tfWrongEn: 'No budget rule here is a legal duty.',
    simPromptFr: 'Ton loyer prend déjà 55 % du revenu.',
    simPromptEn: 'Your rent already takes 55% of income.',
    simOptionsFr: [
      'Garder le logement et réduire d’abord les envies',
      'Forcer le 50 en sautant le loyer',
      'Culpabiliser et tout arrêter',
    ],
    simOptionsEn: [
      'Keep the housing and trim wants first',
      'Force the 50 by skipping rent',
      'Feel guilty and stop everything',
    ],
    simCorrectIndex: 0,
    simGoodFr: 'Le repère s’adapte. Le socle passe avant le pourcentage parfait.',
    simGoodEn: 'The guide bends. The base comes before a perfect percentage.',
    simOtherFr: 'Un pourcentage ne remplace pas un toit.',
    simOtherEn: 'A percentage does not replace a roof.',
  ),
};

LessonQuizContent lessonContentFor(String lessonId) {
  return kLessonContent[lessonId] ?? kLessonContent['emergency_fund']!;
}
