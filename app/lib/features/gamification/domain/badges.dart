import 'package:flutter/material.dart';
import 'package:sipho/app/l10n/app_localizations.dart';

/// A badge the server can award (see `functions/src/shared/badges.ts`).
///
/// Whether a badge is earned is decided by the server only and arrives in
/// `GameState.badges`; this describes how to show it.
class BadgeDef {
  const BadgeDef(this.id, this.icon);

  final String id;
  final IconData icon;
}

/// In display order. Ids match the server's `BADGE_RULES` (a test checks it).
const List<BadgeDef> kBadges = [
  BadgeDef('first_lesson', Icons.workspace_premium),
  BadgeDef('unit_1', Icons.school),
  BadgeDef('unit_2', Icons.savings),
  BadgeDef('streak_7', Icons.local_fire_department),
  BadgeDef('streak_30', Icons.whatshot),
  BadgeDef('level_5', Icons.trending_up),
  BadgeDef('level_10', Icons.military_tech),
  BadgeDef('league_silver', Icons.emoji_events),
];

/// Name of a badge. An id this app does not know (a newer server) is shown as is.
String badgeTitle(AppLocalizations l10n, String id) {
  switch (id) {
    case 'first_lesson':
      return l10n.badgeFirstLesson;
    case 'unit_1':
      return l10n.badgeUnit1;
    case 'unit_2':
      return l10n.badgeUnit2;
    case 'streak_7':
      return l10n.badgeStreak7;
    case 'streak_30':
      return l10n.badgeStreak30;
    case 'level_5':
      return l10n.badgeLevel5;
    case 'level_10':
      return l10n.badgeLevel10;
    case 'league_silver':
      return l10n.badgeLeagueSilver;
    default:
      return id;
  }
}

/// How to earn a badge.
String badgeHint(AppLocalizations l10n, String id) {
  switch (id) {
    case 'first_lesson':
      return l10n.badgeFirstLessonHint;
    case 'unit_1':
      return l10n.badgeUnit1Hint;
    case 'unit_2':
      return l10n.badgeUnit2Hint;
    case 'streak_7':
      return l10n.badgeStreak7Hint;
    case 'streak_30':
      return l10n.badgeStreak30Hint;
    case 'level_5':
      return l10n.badgeLevel5Hint;
    case 'level_10':
      return l10n.badgeLevel10Hint;
    case 'league_silver':
      return l10n.badgeLeagueSilverHint;
    default:
      return '';
  }
}

/// Badges in [next] that were not in [previous].
List<String> newBadges(Iterable<String> previous, Iterable<String> next) {
  final had = previous.toSet();
  return [
    for (final id in next)
      if (!had.contains(id)) id,
  ];
}
