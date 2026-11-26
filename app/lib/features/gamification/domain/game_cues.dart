import '../../../core/feedback/feedback_cue.dart';
import 'game_state.dart';

/// Same order as `functions/src/shared/leagues.ts`.
const kLeagueTiers = <String>[
  'bronze',
  'silver',
  'gold',
  'sapphire',
  'ruby',
  'emerald',
  'amethyst',
  'pearl',
  'obsidian',
  'diamond',
];

int leagueTierIndex(String leagueId) {
  final index = kLeagueTiers.indexOf(leagueId);
  return index < 0 ? 0 : index;
}

List<String> newBadges(List<String> previous, List<String> next) {
  final had = previous.toSet();
  return [for (final id in next) if (!had.contains(id)) id];
}

/// Celebration when server-written game state moves, or null.
///
/// A missing previous (first snapshot) never celebrates: that progress was
/// already there. When several things change at once, only the strongest
/// cue plays: level, then league, then badge, then streak.
SiphoCue? cueForGameChange(GameState? previous, GameState? next) {
  if (previous == null || next == null) return null;
  if (next.level > previous.level) return SiphoCue.levelUp;
  if (leagueTierIndex(next.leagueId) > leagueTierIndex(previous.leagueId)) {
    return SiphoCue.leagueUp;
  }
  if (newBadges(previous.badges, next.badges).isNotEmpty) {
    return SiphoCue.badgeUnlocked;
  }
  if (next.streakDays > previous.streakDays) return SiphoCue.streakExtended;
  return null;
}
