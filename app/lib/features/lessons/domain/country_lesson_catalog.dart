import 'package:sipho/features/lessons/domain/lesson_catalog.dart';
import 'package:sipho/features/lessons/domain/lesson_steps.dart';

/// Country modules referenced by packs in `content/countries/*.json`.
/// Ids must match `COUNTRY_LESSON_MODULES` in functions/src/shared/lessonPath.ts.
/// Educational only: no rates, ceilings or personalized advice.

QuizStep _quiz({
  required LText question,
  required List<(String fr, String en)> choices,
  required int correctIndex,
  required LText explanation,
}) {
  return QuizStep(
    question: question,
    choices: [
      for (var i = 0; i < choices.length; i++)
        LessonChoice(
          fr: choices[i].$1,
          en: choices[i].$2,
          correct: i == correctIndex,
        ),
    ],
    explanation: explanation,
  );
}

CatalogLesson _lesson({
  required String id,
  required String emoji,
  required String titleFr,
  required String titleEn,
  required LText objective,
  required List<LessonStep> steps,
  required List<LText> takeaways,
}) {
  return CatalogLesson(
    id: id,
    emoji: emoji,
    minutes: 3,
    titleFr: titleFr,
    titleEn: titleEn,
    objective: objective,
    steps: steps,
    takeaways: takeaways,
  );
}

final CatalogLesson kCaTfsa = _lesson(
  id: 'ca_tfsa_101',
  emoji: '🇨🇦',
  titleFr: 'Le CELI, en bref',
  titleEn: 'The TFSA, in short',
  objective: LText(
    'Savoir à quoi sert un CELI et pourquoi vérifier le plafond officiel.',
    'Know what a TFSA is for and why to check the official contribution room.',
  ),
  steps: [
    InfoStep(
      emoji: '📦',
      title: LText('Un compte, pas un produit', 'An account, not a product'),
      body: LText(
        'Le CELI (TFSA) est un type de compte enregistré au Canada. Tu y places de l’épargne ou des placements : les gains restent à l’abri de l’impôt selon les règles en vigueur.',
        'A TFSA is a registered account type in Canada. You hold savings or investments in it: growth is sheltered from tax under current rules.',
      ),
      points: [
        LText('Ce n’est pas un conseil de placement.', 'This is not investment advice.'),
        LText('Le plafond annuel change : lis la source officielle.', 'Annual room changes: read the official source.'),
      ],
    ),
    _quiz(
      question: LText(
        'Avant de cotiser à un CELI, que faire en priorité ?',
        'Before contributing to a TFSA, what should you do first?',
      ),
      choices: [
        ('Vérifier ton espace de cotisation officiel', 'Check your official contribution room'),
        ('Doubler le montant de l’année dernière', 'Double last year’s amount'),
        ('Ignorer les règles si tu es étudiant', 'Ignore the rules if you are a student'),
      ],
      correctIndex: 0,
      explanation: LText(
        'Cotiser au-delà de l’espace disponible peut entraîner une pénalité. La source officielle (Agence du revenu) prime toujours.',
        'Over-contributing can trigger a penalty. The official source (CRA) always wins.',
      ),
    ),
    TrueFalseStep(
      statement: LText(
        'Le CELI remplace un fonds d’urgence.',
        'A TFSA replaces an emergency fund.',
      ),
      answer: false,
      explanation: LText(
        'Tu peux garder une urgence dans un CELI liquide, mais le concept d’urgence reste distinct du type de compte.',
        'You can keep emergency cash in a liquid TFSA, but “emergency money” and “account type” are different ideas.',
      ),
    ),
  ],
  takeaways: [
    LText('CELI = enveloppe fiscale, pas un placement magique.', 'TFSA = tax wrapper, not a magic investment.'),
    LText('Vérifie toujours le plafond officiel avant de cotiser.', 'Always check official room before contributing.'),
    LText('Sipho t’informe : ce n’est pas un conseil personnalisé.', 'Sipho informs: this is not personalized advice.'),
  ],
);

final CatalogLesson kCaRrsp = _lesson(
  id: 'ca_rrsp_101',
  emoji: '🏦',
  titleFr: 'Le REER, en bref',
  titleEn: 'The RRSP, in short',
  objective: LText(
    'Comprendre le rôle d’un REER sans calculer ton impôt.',
    'Understand what an RRSP is for without calculating your tax.',
  ),
  steps: [
    InfoStep(
      emoji: '🎯',
      title: LText('Épargne pour plus tard', 'Saving for later'),
      body: LText(
        'Le REER sert surtout à préparer la retraite. Les cotisations peuvent réduire le revenu imposable selon ta situation — un fiscaliste ou l’ARC tranchent, pas Sipho.',
        'An RRSP is mainly for retirement. Contributions may lower taxable income depending on your situation — a tax pro or the CRA decide, not Sipho.',
      ),
      points: [
        LText('Il existe aussi un plafond de cotisation.', 'There is also a contribution limit.'),
        LText('Retirer tôt peut avoir un coût fiscal.', 'Early withdrawals can have a tax cost.'),
      ],
    ),
    _quiz(
      question: LText(
        'À quoi sert principalement un REER ?',
        'What is an RRSP mainly for?',
      ),
      choices: [
        ('Préparer un revenu plus tard (retraite)', 'Building income for later (retirement)'),
        ('Payer les repas du mois', 'Paying this month’s groceries'),
        ('Remplacer une assurance auto', 'Replacing car insurance'),
      ],
      correctIndex: 0,
      explanation: LText(
        'Le REER est pensé pour le long terme. Les besoins du mois passent par le budget du quotidien.',
        'An RRSP is built for the long term. Day-to-day needs belong in your monthly budget.',
      ),
    ),
    TrueFalseStep(
      statement: LText(
        'Sipho peut te dire exactement combien cotiser cette année.',
        'Sipho can tell you exactly how much to contribute this year.',
      ),
      answer: false,
      explanation: LText(
        'Ton plafond dépend de ton revenu et de ton historique. Seules les sources officielles (ou un pro) le confirment.',
        'Your room depends on income and history. Only official sources (or a pro) confirm it.',
      ),
    ),
  ],
  takeaways: [
    LText('REER = horizon long, règles fiscales propres.', 'RRSP = long horizon, its own tax rules.'),
    LText('Ne confonds pas REER et fonds d’urgence.', 'Don’t confuse RRSP with an emergency fund.'),
    LText('Vérifie toujours auprès de sources officielles.', 'Always verify with official sources.'),
  ],
);

final CatalogLesson kCaFhsa = _lesson(
  id: 'ca_fhsa_101',
  emoji: '🏠',
  titleFr: 'Le CELIAPP, en bref',
  titleEn: 'The FHSA, in short',
  objective: LText(
    'Savoir que le CELIAPP aide à une première mise de fonds — sous conditions.',
    'Know that the FHSA helps with a first home down payment — under conditions.',
  ),
  steps: [
    InfoStep(
      emoji: '🔑',
      title: LText('Un objectif : le premier logement', 'One goal: a first home'),
      body: LText(
        'Le CELIAPP combine des avantages proches du CELI et du REER pour une première habitation, si tu es admissible. Les critères évoluent : lis le site officiel.',
        'The FHSA blends TFSA- and RRSP-like benefits for a first home if you qualify. Eligibility rules change: read the official site.',
      ),
      points: [
        LText('Ce n’est pas pour tout le monde.', 'It is not for everyone.'),
        LText('Pas un conseil immobilier.', 'Not real-estate advice.'),
      ],
    ),
    _quiz(
      question: LText(
        'Avant d’ouvrir un CELIAPP, que vérifier ?',
        'Before opening an FHSA, what should you check?',
      ),
      choices: [
        ('Si tu es admissible selon les règles officielles', 'Whether you qualify under official rules'),
        ('Le cours d’une crypto au hasard', 'A random crypto price'),
        ('Le solde du portefeuille d’un ami', 'A friend’s wallet balance'),
      ],
      correctIndex: 0,
      explanation: LText(
        'L’admissibilité et les plafonds sont définis par le gouvernement. Sipho ne les invente pas.',
        'Eligibility and limits are set by government. Sipho does not invent them.',
      ),
    ),
    TrueFalseStep(
      statement: LText(
        'Le CELIAPP remplace toujours un CELI.',
        'An FHSA always replaces a TFSA.',
      ),
      answer: false,
      explanation: LText(
        'Ce sont des outils différents. Le bon choix dépend de ton objectif et de ton admissibilité.',
        'They are different tools. The right mix depends on your goal and eligibility.',
      ),
    ),
  ],
  takeaways: [
    LText('CELIAPP = premier logement, sous conditions.', 'FHSA = first home, with conditions.'),
    LText('Lis toujours les critères officiels.', 'Always read official criteria.'),
    LText('Éducation, pas conseil personnalisé.', 'Education, not personalized advice.'),
  ],
);

final CatalogLesson kFrLivretA = _lesson(
  id: 'fr_livreta_101',
  emoji: '🇫🇷',
  titleFr: 'Le Livret A, en bref',
  titleEn: 'Livret A, in short',
  objective: LText(
    'Comprendre le rôle d’un livret réglementé sans citer un taux inventé.',
    'Understand a regulated savings account without inventing a rate.',
  ),
  steps: [
    InfoStep(
      emoji: '🐷',
      title: LText('Épargne liquide et encadrée', 'Liquid, regulated savings'),
      body: LText(
        'Le Livret A est un produit d’épargne réglementé en France : plafond, fiscalité et taux sont fixés par les autorités. Sipho ne les affiche pas en dur : regarde ta banque ou service-public.fr.',
        'Livret A is a regulated French savings product: cap, tax treatment and rate are set by authorities. Sipho does not hard-code them: check your bank or service-public.fr.',
      ),
      points: [
        LText('Utile pour une réserve accessible.', 'Useful for accessible reserves.'),
        LText('Ce n’est pas un placement boursier.', 'It is not a stock investment.'),
      ],
    ),
    _quiz(
      question: LText(
        'Où vérifier le plafond et le taux du Livret A ?',
        'Where should you check Livret A’s cap and rate?',
      ),
      choices: [
        ('Sources officielles / ta banque', 'Official sources / your bank'),
        ('Un tweet anonyme', 'An anonymous tweet'),
        ('Une pub Instagram', 'An Instagram ad'),
      ],
      correctIndex: 0,
      explanation: LText(
        'Les paramètres réglementés changent. Seule une source officielle fait foi.',
        'Regulated parameters change. Only an official source is authoritative.',
      ),
    ),
    TrueFalseStep(
      statement: LText(
        'Le Livret A suffit toujours à « faire fructifier » tout ton patrimoine.',
        'A Livret A is always enough to grow your entire net worth.',
      ),
      answer: false,
      explanation: LText(
        'C’est un outil de sécurité / liquidité. D’autres objectifs demandent d’autres enveloppes.',
        'It is a safety / liquidity tool. Other goals need other wrappers.',
      ),
    ),
  ],
  takeaways: [
    LText('Livret A = épargne réglementée, liquide.', 'Livret A = regulated, liquid savings.'),
    LText('Plafond et taux : sources officielles seulement.', 'Cap and rate: official sources only.'),
    LText('Pas un conseil financier personnalisé.', 'Not personalized financial advice.'),
  ],
);

final CatalogLesson kFrPea = _lesson(
  id: 'fr_pea_101',
  emoji: '📈',
  titleFr: 'Le PEA, en bref',
  titleEn: 'The PEA, in short',
  objective: LText(
    'Savoir que le PEA est une enveloppe pour investir, avec des règles.',
    'Know that a PEA is an investing wrapper with rules.',
  ),
  steps: [
    InfoStep(
      emoji: '🇪🇺',
      title: LText('Investir dans une enveloppe', 'Investing inside a wrapper'),
      body: LText(
        'Le PEA permet de détenir certains titres européens avec un cadre fiscal spécifique après une durée de détention. Ce n’est pas sans risque : les cours montent et baissent.',
        'A PEA holds certain European securities with a specific tax framework after a holding period. It is not risk-free: prices go up and down.',
      ),
      points: [
        LText('Horizon long recommandé en général.', 'A long horizon is usually recommended.'),
        LText('Pas un conseil en investissement.', 'Not investment advice.'),
      ],
    ),
    TrueFalseStep(
      statement: LText(
        'Un PEA garantit un gain positif chaque année.',
        'A PEA guarantees a positive return every year.',
      ),
      answer: false,
      explanation: LText(
        'Aucun placement en actions ne garantit un gain. Tu peux perdre une partie du capital.',
        'No equity investment guarantees a gain. You can lose part of your capital.',
      ),
    ),
    _quiz(
      question: LText(
        'Avant d’ouvrir un PEA, que faire ?',
        'Before opening a PEA, what should you do?',
      ),
      choices: [
        ('Comprendre le risque et lire les conditions', 'Understand the risk and read the terms'),
        ('Tout emprunter pour « en mettre le maximum »', 'Borrow everything to “max it out”'),
        ('Suivre un influenceur sans vérifier', 'Follow an influencer without checking'),
      ],
      correctIndex: 0,
      explanation: LText(
        'Informe-toi (AMF, ta banque) et n’investis que de l’argent dont tu n’as pas besoin demain.',
        'Learn (AMF, your bank) and only invest money you do not need tomorrow.',
      ),
    ),
  ],
  takeaways: [
    LText('PEA = enveloppe d’investissement, risquée.', 'PEA = investing wrapper, with risk.'),
    LText('Informe-toi auprès de sources officielles.', 'Learn from official sources.'),
    LText('Sipho éduque, ne conseille pas.', 'Sipho educates, does not advise.'),
  ],
);

final CatalogLesson kFrPer = _lesson(
  id: 'fr_per_101',
  emoji: '🧓',
  titleFr: 'Le PER, en bref',
  titleEn: 'The PER, in short',
  objective: LText(
    'Comprendre que le PER vise la retraite, avec des sorties encadrées.',
    'Understand that a PER targets retirement, with framed withdrawals.',
  ),
  steps: [
    InfoStep(
      emoji: '📅',
      title: LText('Un horizon retraite', 'A retirement horizon'),
      body: LText(
        'Le Plan d’Épargne Retraite regroupe plusieurs formes d’épargne retraite. Les règles de sortie et d’avantage fiscal dépendent de ta situation : un conseiller réglementé ou service-public.fr font foi.',
        'The PER groups several retirement savings forms. Exit and tax rules depend on your situation: a regulated adviser or service-public.fr are authoritative.',
      ),
      points: [
        LText('Souvent illiquide avant la retraite.', 'Often illiquid before retirement.'),
        LText('Pas un compte courant.', 'Not a checking account.'),
      ],
    ),
    TrueFalseStep(
      statement: LText(
        'Tu peux traiter un PER comme une épargne de précaution du mois.',
        'You can treat a PER like this month’s emergency cash.',
      ),
      answer: false,
      explanation: LText(
        'L’épargne de précaution doit rester accessible. Le PER est pensé pour plus tard.',
        'Emergency savings must stay accessible. A PER is built for later.',
      ),
    ),
    _quiz(
      question: LText(
        'Qui peut te donner un conseil fiscal personnalisé sur un PER ?',
        'Who can give personalized tax advice on a PER?',
      ),
      choices: [
        ('Un professionnel réglementé', 'A regulated professional'),
        ('Sipho (cette app)', 'Sipho (this app)'),
        ('Un forum anonyme', 'An anonymous forum'),
      ],
      correctIndex: 0,
      explanation: LText(
        'Sipho reste éducatif. Un conseil individualisé relève d’un pro.',
        'Sipho stays educational. Individual advice belongs to a professional.',
      ),
    ),
  ],
  takeaways: [
    LText('PER = retraite, règles de sortie à vérifier.', 'PER = retirement; check exit rules.'),
    LText('Garde une épargne liquide à part.', 'Keep liquid savings separately.'),
    LText('Éducation ≠ conseil personnalisé.', 'Education ≠ personalized advice.'),
  ],
);

final CatalogLesson kFrAv = _lesson(
  id: 'fr_av_101',
  emoji: '📜',
  titleFr: 'L’assurance-vie, en bref',
  titleEn: 'Life insurance contracts, in short',
  objective: LText(
    'Savoir que « assurance-vie » désigne surtout une enveloppe d’épargne en France.',
    'Know that “assurance-vie” often means a savings wrapper in France.',
  ),
  steps: [
    InfoStep(
      emoji: '🧩',
      title: LText('Beaucoup de formes', 'Many forms'),
      body: LText(
        'En France, l’assurance-vie est souvent utilisée comme enveloppe d’épargne / transmission. Les supports (fonds euros, unités de compte) n’ont pas le même risque. Lis le document d’information clé.',
        'In France, life-insurance contracts are often used as a savings / inheritance wrapper. Vehicles (euro funds, unit-linked) do not share the same risk. Read the key information document.',
      ),
      points: [
        LText('Compare frais et risques.', 'Compare fees and risks.'),
        LText('Pas un dépôt garanti comme un livret réglementé.', 'Not the same guarantee as a regulated savings book.'),
      ],
    ),
    _quiz(
      question: LText(
        'Avant de signer un contrat, que lire ?',
        'Before signing a contract, what should you read?',
      ),
      choices: [
        ('Le document d’information et les frais', 'The information document and fees'),
        ('Uniquement le slogan publicitaire', 'Only the marketing slogan'),
        ('Rien : « ça ira »', 'Nothing: “it’ll be fine”'),
      ],
      correctIndex: 0,
      explanation: LText(
        'Les frais et le risque des supports comptent autant que le packaging.',
        'Fees and underlying risk matter as much as the packaging.',
      ),
    ),
    TrueFalseStep(
      statement: LText(
        'Toutes les assurances-vie sont sans risque.',
        'All life-insurance savings contracts are risk-free.',
      ),
      answer: false,
      explanation: LText(
        'Les unités de compte peuvent perdre de la valeur. Informe-toi avant de choisir.',
        'Unit-linked funds can lose value. Learn before you choose.',
      ),
    ),
  ],
  takeaways: [
    LText('Assurance-vie = enveloppe, pas un seul produit.', 'Assurance-vie = wrapper, not one product.'),
    LText('Lis frais, risques et durée.', 'Read fees, risks and horizon.'),
    LText('Sipho informe, ne vend rien.', 'Sipho informs, sells nothing.'),
  ],
);

CatalogLesson _tontine(String id, String countryLabel) => _lesson(
      id: id,
      emoji: '🤝',
      titleFr: 'La tontine, en bref',
      titleEn: 'Tontines, in short',
      objective: LText(
        'Comprendre la logique d’une tontine / épargne tournante et ses risques.',
        'Understand rotating savings and their risks.',
      ),
      steps: [
        InfoStep(
          emoji: '🔁',
          title: LText('Épargne à tour de rôle', 'Savings in turns'),
          body: LText(
            'Dans beaucoup de communautés ($countryLabel et ailleurs), une tontine réunit des personnes qui cotisent à tour de rôle. C’est de la solidarité — et de la confiance.',
            'In many communities ($countryLabel and beyond), a tontine pools people who contribute in turns. It is solidarity — and trust.',
          ),
          points: [
            LText('Pas un produit bancaire réglementé partout.', 'Not a regulated bank product everywhere.'),
            LText('Le risque principal : un membre qui ne paie plus.', 'Main risk: a member who stops paying.'),
          ],
        ),
        _quiz(
          question: LText(
            'Quel est le risque le plus courant d’une tontine informelle ?',
            'What is the most common risk of an informal tontine?',
          ),
          choices: [
            ('Un membre ne respecte pas sa cotisation', 'A member misses their contribution'),
            ('Le taux directeur de la BCE', 'The ECB policy rate'),
            ('Le cours de l’or à Londres', 'The London gold price'),
          ],
          correctIndex: 0,
          explanation: LText(
            'La tontine repose sur la confiance. Des règles claires et des membres connus réduisent le risque.',
            'Tontines rest on trust. Clear rules and known members reduce risk.',
          ),
        ),
        TrueFalseStep(
          statement: LText(
            'Une tontine remplace toujours un compte d’épargne personnel.',
            'A tontine always replaces a personal savings account.',
          ),
          answer: false,
          explanation: LText(
            'Elle peut compléter ton épargne, mais garder une réserve à toi reste prudent.',
            'It can complement your savings, but keeping your own reserve is still wise.',
          ),
        ),
      ],
      takeaways: [
        LText('Tontine = solidarité + confiance.', 'Tontine = solidarity + trust.'),
        LText('Connais les règles et les membres.', 'Know the rules and the members.'),
        LText('Garde aussi une épargne personnelle.', 'Also keep personal savings.'),
      ],
    );

CatalogLesson _momo(String id, String label) => _lesson(
      id: id,
      emoji: '📱',
      titleFr: 'Mobile money et épargne',
      titleEn: 'Mobile money and saving',
      objective: LText(
        'Utiliser le mobile money avec prudence (frais, arnaques, réserve).',
        'Use mobile money carefully (fees, scams, a reserve).',
      ),
      steps: [
        InfoStep(
          emoji: '💸',
          title: LText('Pratique, mais pas gratuit', 'Handy, but not free'),
          body: LText(
            'Le mobile money ($label) facilite paiements et transferts. Les frais et les plafonds dépendent de l’opérateur : lis la grille officielle, Sipho ne l’invente pas.',
            'Mobile money ($label) makes payments and transfers easy. Fees and limits depend on the operator: read the official grid; Sipho does not invent it.',
          ),
          points: [
            LText('Active le code PIN / biométrie.', 'Turn on PIN / biometrics.'),
            LText('Méfie-toi des messages « urgence, envoie ».', 'Beware of “urgent, send now” messages.'),
          ],
        ),
        _quiz(
          question: LText(
            'Que faire face à un SMS qui demande ton code secret ?',
            'What to do if an SMS asks for your secret code?',
          ),
          choices: [
            ('Ne jamais le donner — c’est une arnaque', 'Never share it — it is a scam'),
            ('Le renvoyer « pour vérifier »', 'Send it back “to verify”'),
            ('Le publier pour « aider un ami »', 'Post it to “help a friend”'),
          ],
          correctIndex: 0,
          explanation: LText(
            'Ton code = tes fonds. Aucun opérateur sérieux ne te le demande par SMS.',
            'Your code = your money. No serious operator asks for it by SMS.',
          ),
        ),
        TrueFalseStep(
          statement: LText(
            'Il est utile de garder une petite réserve hors des transferts du jour.',
            'It helps to keep a small reserve aside from day-to-day transfers.',
          ),
          answer: true,
          explanation: LText(
            'Séparer « dépenser » et « garder » évite de tout envoyer sans le vouloir.',
            'Separating “spend” and “keep” avoids sending everything by mistake.',
          ),
        ),
      ],
      takeaways: [
        LText('Mobile money : vérifie les frais officiels.', 'Mobile money: check official fees.'),
        LText('Ne partage jamais ton code.', 'Never share your code.'),
        LText('Garde une réserve à part.', 'Keep a reserve aside.'),
      ],
    );

final CatalogLesson kCmTontine = _tontine('cm_tontine_101', 'au Cameroun');
final CatalogLesson kCmMomo = _momo('cm_momo_101', 'Orange Money / MTN MoMo');
final CatalogLesson kCiTontine = _tontine('ci_tontine_101', 'en Côte d’Ivoire');
final CatalogLesson kCiMomo = _momo('ci_momo_101', 'Wave / Orange / MTN');
final CatalogLesson kSnTontine = _tontine('sn_tontine_101', 'au Sénégal');
final CatalogLesson kSnMomo = _momo('sn_momo_101', 'Wave / Orange');

final CatalogLesson kGenSavings = _lesson(
  id: 'gen_savings_101',
  emoji: '🌍',
  titleFr: 'Épargne rémunérée, en bref',
  titleEn: 'Interest-bearing savings, in short',
  objective: LText(
    'Comparer un compte d’épargne sans croire un taux inventé.',
    'Compare a savings account without inventing a rate.',
  ),
  steps: [
    InfoStep(
      emoji: '🔍',
      title: LText('Lis le contrat', 'Read the contract'),
      body: LText(
        'Un compte « rémunéré » verse des intérêts selon des conditions (solde minimum, durée, fiscalité). Le taux n’est jamais écrit en dur dans Sipho : regarde ta banque.',
        'An interest-bearing account pays interest under conditions (minimum balance, term, tax). Sipho never hard-codes the rate: check your bank.',
      ),
      points: [
        LText('Compare frais et accessibilité.', 'Compare fees and access.'),
        LText('Garde une urgence liquide.', 'Keep a liquid emergency buffer.'),
      ],
    ),
    TrueFalseStep(
      statement: LText(
        'Le taux le plus élevé est toujours le meilleur choix.',
        'The highest rate is always the best choice.',
      ),
      answer: false,
      explanation: LText(
        'Frais, liquidité, garantie des dépôts et risques comptent aussi.',
        'Fees, liquidity, deposit protection and risk matter too.',
      ),
    ),
    _quiz(
      question: LText(
        'Où trouver le taux réel d’un compte ?',
        'Where do you find a real account rate?',
      ),
      choices: [
        ('Chez ta banque / le contrat', 'Your bank / the contract'),
        ('Dans le code de Sipho', 'Inside Sipho’s code'),
        ('Sur un sticker de bus', 'On a bus sticker'),
      ],
      correctIndex: 0,
      explanation: LText(
        'Sipho refuse d’inventer des taux. Les vrais chiffres viennent de ta banque.',
        'Sipho refuses to invent rates. Real numbers come from your bank.',
      ),
    ),
  ],
  takeaways: [
    LText('Les taux changent : source officielle seulement.', 'Rates change: official source only.'),
    LText('Regarde frais + liquidité, pas seulement le taux.', 'Look at fees + liquidity, not only the rate.'),
    LText('Éducation, pas conseil personnalisé.', 'Education, not personalized advice.'),
  ],
);

/// Units shown on the Learn tab when the user's country matches.
class CountryCatalogUnit {
  const CountryCatalogUnit({
    required this.countries,
    required this.unit,
  });

  /// ISO codes, or `*` for the generic pack.
  final List<String> countries;
  final CatalogUnit unit;

  bool matches(String? countryCode) {
    if (countries.contains('*')) return true;
    final code = (countryCode ?? '').toUpperCase();
    return code.length == 2 && countries.contains(code);
  }
}

final List<CountryCatalogUnit> kCountryCatalogUnits = [
  CountryCatalogUnit(
    countries: const ['CA'],
    unit: CatalogUnit(
      id: 'ca_accounts',
      titleFr: 'Comptes canadiens',
      titleEn: 'Canadian accounts',
      subtitle: LText(
          'CELI, REER, CELIAPP — le mode d’emploi', 'TFSA, RRSP, FHSA — the basics'),
      lessons: [kCaTfsa, kCaRrsp, kCaFhsa],
      bonusXp: 0,
      bonusSeeds: 0,
    ),
  ),
  CountryCatalogUnit(
    countries: const ['FR'],
    unit: CatalogUnit(
      id: 'fr_accounts',
      titleFr: 'Enveloppes françaises',
      titleEn: 'French wrappers',
      subtitle:
          LText('Livret A, PEA, PER, assurance-vie', 'Livret A, PEA, PER, life insurance'),
      lessons: [kFrLivretA, kFrPea, kFrPer, kFrAv],
      bonusXp: 0,
      bonusSeeds: 0,
    ),
  ),
  CountryCatalogUnit(
    countries: const ['CM'],
    unit: CatalogUnit(
      id: 'cm_local',
      titleFr: 'Épargne au Cameroun',
      titleEn: 'Saving in Cameroon',
      subtitle: LText('Tontine et mobile money', 'Tontines and mobile money'),
      lessons: [kCmTontine, kCmMomo],
      bonusXp: 0,
      bonusSeeds: 0,
    ),
  ),
  CountryCatalogUnit(
    countries: const ['CI'],
    unit: CatalogUnit(
      id: 'ci_local',
      titleFr: 'Épargne en Côte d’Ivoire',
      titleEn: 'Saving in Côte d’Ivoire',
      subtitle: LText('Tontine et mobile money', 'Tontines and mobile money'),
      lessons: [kCiTontine, kCiMomo],
      bonusXp: 0,
      bonusSeeds: 0,
    ),
  ),
  CountryCatalogUnit(
    countries: const ['SN'],
    unit: CatalogUnit(
      id: 'sn_local',
      titleFr: 'Épargne au Sénégal',
      titleEn: 'Saving in Senegal',
      subtitle: LText('Tontine et mobile money', 'Tontines and mobile money'),
      lessons: [kSnTontine, kSnMomo],
      bonusXp: 0,
      bonusSeeds: 0,
    ),
  ),
  CountryCatalogUnit(
    countries: const ['*'],
    unit: CatalogUnit(
      id: 'gen_local',
      titleFr: 'Épargne partout',
      titleEn: 'Saving anywhere',
      subtitle: LText('Comparer un compte rémunéré', 'Comparing an interest account'),
      lessons: [kGenSavings],
      bonusXp: 0,
      bonusSeeds: 0,
    ),
  ),
];

/// Every country lesson (for the player lookup).
final List<CatalogLesson> kCountryCatalogLessons = [
  for (final cu in kCountryCatalogUnits) ...cu.unit.lessons,
];

/// Path lessons + country modules — use this for the lesson player lookup.
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
  // Unknown country → generic pack module only.
  return [
    for (final cu in kCountryCatalogUnits)
      if (cu.countries.contains('*')) cu.unit,
  ];
}
