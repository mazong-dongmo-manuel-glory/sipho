/// Miroir de `functions/src/shared/badges.ts`.
class BadgeDef {
  final String id;
  final String emoji;
  final String titleFr;
  final String titleEn;
  final String subtitleFr;
  final String subtitleEn;

  const BadgeDef({
    required this.id,
    required this.emoji,
    required this.titleFr,
    required this.titleEn,
    required this.subtitleFr,
    required this.subtitleEn,
  });
}

const kBadges = <BadgeDef>[
  BadgeDef(
    id: 'builder',
    emoji: '🏡',
    titleFr: 'Nid construit',
    titleEn: 'Nest built',
    subtitleFr: 'Socle configuré',
    subtitleEn: 'Foundation set up',
  ),
  BadgeDef(
    id: 'first_lesson',
    emoji: '🎯',
    titleFr: 'Première leçon',
    titleEn: 'First lesson',
    subtitleFr: 'Finis ta première leçon',
    subtitleEn: 'Finish your first lesson',
  ),
  BadgeDef(
    id: 'unit_1',
    emoji: '📚',
    titleFr: 'Unité 1',
    titleEn: 'Unit 1',
    subtitleFr: 'Les bases terminées',
    subtitleEn: 'Basics completed',
  ),
  BadgeDef(
    id: 'unit_2',
    emoji: '🌱',
    titleFr: 'Unité 2',
    titleEn: 'Unit 2',
    subtitleFr: 'Épargne maîtrisée',
    subtitleEn: 'Saving mastered',
  ),
  BadgeDef(
    id: 'unit_3',
    emoji: '🛡️',
    titleFr: 'Unité 3',
    titleEn: 'Unit 3',
    subtitleFr: 'Se protéger',
    subtitleEn: 'Protect yourself',
  ),
  BadgeDef(
    id: 'unit_4',
    emoji: '📈',
    titleFr: 'Unité 4',
    titleEn: 'Unit 4',
    subtitleFr: 'Faire fructifier',
    subtitleEn: 'Grow your money',
  ),
  BadgeDef(
    id: 'streak_7',
    emoji: '🔥',
    titleFr: 'Flamme 7j',
    titleEn: '7-day flame',
    subtitleFr: '1 semaine active',
    subtitleEn: 'One active week',
  ),
  BadgeDef(
    id: 'streak_30',
    emoji: '🔥',
    titleFr: 'Flamme 30j',
    titleEn: '30-day flame',
    subtitleFr: 'Un mois de constance',
    subtitleEn: 'A month of consistency',
  ),
  BadgeDef(
    id: 'level_5',
    emoji: '⭐',
    titleFr: 'Niveau 5',
    titleEn: 'Level 5',
    subtitleFr: 'Atteins le niveau 5',
    subtitleEn: 'Reach level 5',
  ),
  BadgeDef(
    id: 'level_10',
    emoji: '🌟',
    titleFr: 'Niveau 10',
    titleEn: 'Level 10',
    subtitleFr: 'Atteins le niveau 10',
    subtitleEn: 'Reach level 10',
  ),
  BadgeDef(
    id: 'league_silver',
    emoji: '🥈',
    titleFr: 'Ligue Argent',
    titleEn: 'Silver league',
    subtitleFr: 'Atteins la ligue Argent',
    subtitleEn: 'Reach the Silver league',
  ),
];
