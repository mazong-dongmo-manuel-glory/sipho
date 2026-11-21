import 'dart:math';
import 'package:sipho/features/lessons/domain/lesson_steps.dart';

enum EconomyTipCategory {
  budget,
  saving,
  economy,
  security,
  invest,
  lifestyle,
}

class EconomyTip {
  const EconomyTip({
    required this.id,
    required this.category,
    required this.emoji,
    required this.title,
    required this.body,
    required this.actionTip,
    this.source = 'Sipho Finance',
  });

  final String id;
  final EconomyTipCategory category;
  final String emoji;
  final LText title;
  final LText body;
  final LText actionTip;
  final String source;

  String localizedCategory(String locale) {
    final isFr = locale.toLowerCase().startsWith('fr');
    switch (category) {
      case EconomyTipCategory.budget:
        return isFr ? 'Budget malin 🛒' : 'Smart Budget 🛒';
      case EconomyTipCategory.saving:
        return isFr ? 'Épargne active 🌱' : 'Active Savings 🌱';
      case EconomyTipCategory.economy:
        return isFr ? 'Info Éco 📈' : 'Economy Fact 📈';
      case EconomyTipCategory.security:
        return isFr ? 'Sécurité 🛡️' : 'Security 🛡️';
      case EconomyTipCategory.invest:
        return isFr ? 'Investissement 🪄' : 'Investing 🪄';
      case EconomyTipCategory.lifestyle:
        return isFr ? 'Quotidien 💡' : 'Daily Life 💡';
    }
  }
}

const List<EconomyTip> kEconomyTips = [
  EconomyTip(
    id: 'tip_48h_rule',
    category: EconomyTipCategory.budget,
    emoji: '⏳',
    title: LText('La règle des 48 heures', 'The 48-Hour Rule'),
    body: LText(
      'Avant tout achat coup de cœur imprévu (hors courses vitales), attends 48h. L\'envie impulsive retombe souvent d\'elle-même.',
      'Before any unplanned impulse purchase, wait 48 hours. The initial emotional rush often fades away naturally.',
    ),
    actionTip: LText(
      'Mets l\'article dans tes favoris et vérifie dans 2 jours si tu en as toujours vraiment besoin.',
      'Add the item to a wishlist and check back in 2 days to see if you still truly want it.',
    ),
    source: 'Psychologie financière',
  ),
  EconomyTip(
    id: 'tip_ghost_subscriptions',
    category: EconomyTipCategory.budget,
    emoji: '👻',
    title: LText('Traque les abonnements fantômes', 'Hunt Ghost Subscriptions'),
    body: LText(
      'En moyenne, nous payons 3 services par an dont nous ne nous servons presque plus : essai gratuit oublié, double stockage cloud ou streaming.',
      'On average, people pay for 3 unused services each year: forgotten trials, redundant cloud storage, or duplicate streaming.',
    ),
    actionTip: LText(
      'Consulte ton relevé et résilie 1 abonnement non indispensable ce mois-ci.',
      'Review your statements and cancel 1 non-essential subscription this month.',
    ),
    source: 'Audit du socle',
  ),
  EconomyTip(
    id: 'tip_pay_yourself_first',
    category: EconomyTipCategory.saving,
    emoji: '🌱',
    title: LText('Paie-toi en premier dès la paie', 'Pay Yourself First on Payday'),
    body: LText(
      'Épargner ce qui reste à la fin du mois ne marche jamais. Programme un virement automatique vers ton épargne dès le lendemain de ta paie.',
      'Saving what is left at month-end rarely works. Schedule an automated transfer to savings the day right after payday.',
    ),
    actionTip: LText(
      'Même 20 \$/€ par mois automatisés bâtissent une vraie habitude sans effort.',
      'Even an automated 20 \$/€ monthly builds an effortless financial habit.',
    ),
    source: 'Règle d\'or Sipho',
  ),
  EconomyTip(
    id: 'tip_batch_cooking',
    category: EconomyTipCategory.lifestyle,
    emoji: '🍲',
    title: LText('Le réflexe des repas préparés', 'Batch Cooking Savings'),
    body: LText(
      'Les livraisons express et plats commandés en catastrophe le soir représentent jusqu\'à 25 % du budget variable d\'un foyer.',
      'Late-night food deliveries and rush takeout can swallow up to 25% of a household variable spending.',
    ),
    actionTip: LText(
      'Cuisine en double portion deux soirs par semaine pour emporter ton déjeuner le lendemain.',
      'Double your recipes two evenings a week to bring lunch to work the next day.',
    ),
    source: 'Économie domestique',
  ),
  EconomyTip(
    id: 'tip_inflation_erosion',
    category: EconomyTipCategory.economy,
    emoji: '📉',
    title: LText('Comprendre l\'inflation réelle', 'Understanding Inflation'),
    body: LText(
      'Quand l\'inflation est à 3 %, 100 \$/€ sur un compte courant ne vaudront plus que 97 \$/€ de pouvoir d\'achat l\'an prochain.',
      'When inflation runs at 3%, 100 \$/€ sitting on a checking account buys only 97 \$/€ worth of goods next year.',
    ),
    actionTip: LText(
      'Garde sur ton compte courant juste de quoi couvrir le mois en cours, et place le reste sur un compte rémunéré.',
      'Keep only enough for the current month on checking, and park the rest in high-yield savings.',
    ),
    source: 'Banque centrale & Statistique',
  ),
  EconomyTip(
    id: 'tip_interest_rates_impact',
    category: EconomyTipCategory.economy,
    emoji: '📈',
    title: LText('Taux directeurs : ami ou ennemi ?', 'Policy Rates: Friend or Foe?'),
    body: LText(
      'Des taux directeurs élevés rendent le crédit plus cher (prêts auto, cartes), mais récompensent mieux l\'épargne sans risque.',
      'Higher central bank rates make borrowing pricier (credit cards, loans), but reward guaranteed cash savings.',
    ),
    actionTip: LText(
      'Rembourse en priorité tes dettes à taux élevé (cartes de crédit à 19 %+) avant d\'épargner au-delà de ton urgence.',
      'Pay down high-rate debt (credit cards at 19%+) before saving beyond your emergency fund.',
    ),
    source: 'Indicateurs macro',
  ),
  EconomyTip(
    id: 'tip_phishing_sms',
    category: EconomyTipCategory.security,
    emoji: '🛡️',
    title: LText('Alerte colis et faux banquier', 'Delivery & Fake Banker SMS'),
    body: LText(
      'Aucune banque ni service postal ne te demandera de renseigner ton mot de passe, ton numéro de carte ou un code de sécurité par SMS.',
      'No bank or postal service will ever ask for your password, card digits, or SMS verification code via text message.',
    ),
    actionTip: LText(
      'Ne clique jamais sur un lien SMS suspect : ouvre toi-même l\'app officielle de ta banque.',
      'Never tap suspicious text links: open your bank official app directly.',
    ),
    source: 'Sécurité financière',
  ),
  EconomyTip(
    id: 'tip_grocery_unit_price',
    category: EconomyTipCategory.lifestyle,
    emoji: '🏷️',
    title: LText('Le piège du prix unitaire en rayon', 'The Unit Price Trick in Aisles'),
    body: LText(
      'Les emballages familiaux ou les promotions « 2 achetés + 1 offert » ne sont pas toujours moins chers. Le prix au kilo ou au litre ne ment jamais.',
      'Bulk packaging and promo offers are not always cheaper. The price per kilogram or liter never lies.',
    ),
    actionTip: LText(
      'Regarde la petite ligne grise en bas de l\'étiquette en rayon avant de choisir ton format.',
      'Always look at the small gray print at the bottom of the shelf tag before choosing your size.',
    ),
    source: 'Astuces pouvoir d\'achat',
  ),
  EconomyTip(
    id: 'tip_remittance_fees',
    category: EconomyTipCategory.economy,
    emoji: '🌍',
    title: LText('Envois d\'argent : compare les marges', 'Remittances: Compare Margins'),
    body: LText(
      'Envoyer de l\'argent à la famille (Cameroun, Côte d\'Ivoire, Sénégal...) cache souvent des frais invisibles dans le taux de change proposé.',
      'Sending money home often hides silent fees in wide exchange rate markups.',
    ),
    actionTip: LText(
      'Compare le montant net reçu à l\'arrivée entre opérateurs mobiles (Wave, Orange, etc.) et banques traditionnelles.',
      'Compare net cash received on arrival across mobile money operators and traditional wire services.',
    ),
    source: 'Finances de la diaspora',
  ),
  EconomyTip(
    id: 'tip_emergency_tiered',
    category: EconomyTipCategory.saving,
    emoji: '🛟',
    title: LText('Le fonds d\'urgence en 2 paliers', 'The Two-Tier Emergency Fund'),
    body: LText(
      'Palier 1 : 500 à 1 000 \$/€ tout de suite pour les pépins immédiats. Palier 2 : 3 mois de socle fixe pour une vraie sérénité d\'esprit.',
      'Tier 1: 500 to 1,000 \$/€ right away for quick repairs. Tier 2: 3 months of fixed baseline for true peace of mind.',
    ),
    actionTip: LText(
      'Célèbre chaque palier franchi dans Sipho : la sérénité n\'a pas de prix.',
      'Celebrate each milestone in Sipho: peace of mind is priceless.',
    ),
    source: 'Objectifs d\'épargne',
  ),
  EconomyTip(
    id: 'tip_index_funds',
    category: EconomyTipCategory.invest,
    emoji: '🧺',
    title: LText('Investir sans être un expert', 'Investing Without Being an Expert'),
    body: LText(
      'Chercher l\'action gagnante est risqué. Les fonds indiciels (ETF / FNB) achètent des centaines d\'entreprises en une seule fois à frais minimes.',
      'Picking winning stocks is risky. Index funds (ETFs) buy shares in hundreds of companies at once with rock-bottom fees.',
    ),
    actionTip: LText(
      'Renseigne-toi sur les comptes fiscalement avantageux de ton pays (CELI au Canada, PEA en France).',
      'Look into tax-advantaged accounts in your country (TFSA in Canada, PEA in France).',
    ),
    source: 'Bases d\'investissement',
  ),
  EconomyTip(
    id: 'tip_no_spend_day',
    category: EconomyTipCategory.budget,
    emoji: '🎯',
    title: LText('Le défi « Journée Zéro Dépense »', 'The "Zero Spend Day" Challenge'),
    body: LText(
      'Fixe-toi un jour par semaine sans aucun achat variable. Cela reconnecte à ce que tu possèdes déjà et fait gagner des XP dans Sipho !',
      'Set one day a week with zero variable spending. It reconnects you with what you own and scores XP in Sipho!',
    ),
    actionTip: LText(
      'Consulte la quête du jour sur l\'accueil de Sipho et valide ta journée sous budget.',
      'Check the daily quest on Sipho home and claim your under-budget day.',
    ),
    source: 'Gamification Sipho',
  ),
];

/// Returns a deterministic tip for a given calendar day (so every day has a fresh tip).
EconomyTip dailyEconomyTip([DateTime? date]) {
  final now = date ?? DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
  final index = dayOfYear % kEconomyTips.length;
  return kEconomyTips[index];
}

/// Returns a randomized tip, optionally excluding the current tip and/or filtered by category.
EconomyTip pickRandomEconomyTip({
  String? currentId,
  EconomyTipCategory? category,
  Random? random,
}) {
  final rng = random ?? Random();
  var candidates = category == null
      ? kEconomyTips
      : kEconomyTips.where((t) => t.category == category).toList();

  if (candidates.isEmpty) candidates = kEconomyTips;

  if (candidates.length > 1 && currentId != null) {
    final filtered = candidates.where((t) => t.id != currentId).toList();
    if (filtered.isNotEmpty) candidates = filtered;
  }

  return candidates[rng.nextInt(candidates.length)];
}
