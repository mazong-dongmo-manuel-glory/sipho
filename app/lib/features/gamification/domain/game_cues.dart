import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/features/gamification/domain/badges.dart';
import 'package:sipho/features/gamification/domain/game_state.dart';
import 'package:sipho/features/leaderboard/domain/league.dart';

/// The celebration to play when the server-written game state moves from
/// [previous] to [next], or `null` when nothing worth celebrating happened.
///
/// XP, levels, streaks and leagues are written by Cloud Functions only, so the
/// client learns about them by watching `users/{uid}/game/state`. A missing
/// [previous] (first load, or just after a sign-in) never celebrates: the user
/// did not just earn what was already there.
///
/// When several things happen at once only the most important one is played:
/// level up > league promotion > new badge > streak.
SiphoCue? cueForGameChange(GameState? previous, GameState? next) {
  if (previous == null || next == null) return null;
  if (next.level > previous.level) return SiphoCue.levelUp;
  if (leagueTierIndex(next.leagueId) > leagueTierIndex(previous.leagueId)) {
    return SiphoCue.leagueUp;
  }
  if (newBadges(previous.badges, next.badges).isNotEmpty) {
    return SiphoCue.badgeUnlocked;
  }
  if (next.streak.current > previous.streak.current) {
    return SiphoCue.streakExtended;
  }
  return null;
}
