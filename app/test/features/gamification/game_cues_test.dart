import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/features/gamification/domain/game_cues.dart';
import 'package:sipho/features/gamification/domain/game_state.dart';

GameState _state({
  int level = 3,
  int streak = 4,
  String league = 'bronze',
  int xp = 100,
  int gems = 10,
  List<String> badges = const [],
}) =>
    GameState(
      xp: xp,
      level: level,
      gems: gems,
      leagueId: league,
      badges: badges,
      streak: StreakInfo(current: streak),
    );

void main() {
  group('cueForGameChange', () {
    test('the first load never celebrates', () {
      expect(cueForGameChange(null, _state()), isNull);
      expect(cueForGameChange(_state(), null), isNull);
      expect(cueForGameChange(null, null), isNull);
    });

    test('no change, or only XP / seeds changing, stays quiet', () {
      expect(cueForGameChange(_state(), _state()), isNull);
      expect(cueForGameChange(_state(), _state(xp: 150, gems: 15)), isNull);
    });

    test('a higher level is a level up', () {
      expect(cueForGameChange(_state(), _state(level: 4)), SiphoCue.levelUp);
    });

    test('a higher league tier is a promotion', () {
      expect(cueForGameChange(_state(), _state(league: 'silver')),
          SiphoCue.leagueUp);
    });

    test('a relegation is not celebrated', () {
      expect(cueForGameChange(_state(league: 'silver'), _state()), isNull);
    });

    test('a longer streak is celebrated', () {
      expect(cueForGameChange(_state(), _state(streak: 5)),
          SiphoCue.streakExtended);
    });

    test('a streak that resets is not celebrated', () {
      expect(cueForGameChange(_state(streak: 9), _state(streak: 0)), isNull);
    });

    test('level up wins over promotion, which wins over the streak', () {
      expect(
        cueForGameChange(
            _state(), _state(level: 4, league: 'silver', streak: 5)),
        SiphoCue.levelUp,
      );
      expect(
        cueForGameChange(_state(), _state(league: 'silver', streak: 5)),
        SiphoCue.leagueUp,
      );
    });

    test('a new badge is celebrated', () {
      expect(
        cueForGameChange(_state(), _state(badges: ['first_lesson'])),
        SiphoCue.badgeUnlocked,
      );
      expect(
        cueForGameChange(
          _state(badges: ['first_lesson']),
          _state(badges: ['first_lesson', 'unit_1']),
        ),
        SiphoCue.badgeUnlocked,
      );
    });

    test('badges already owned stay quiet', () {
      expect(
        cueForGameChange(
          _state(badges: ['first_lesson']),
          _state(badges: ['first_lesson']),
        ),
        isNull,
      );
    });

    test('a badge ranks below level up and promotion, above the streak', () {
      expect(
        cueForGameChange(_state(), _state(level: 4, badges: ['level_5'])),
        SiphoCue.levelUp,
      );
      expect(
        cueForGameChange(_state(), _state(league: 'silver', badges: ['x'])),
        SiphoCue.leagueUp,
      );
      expect(
        cueForGameChange(_state(), _state(streak: 7, badges: ['streak_7'])),
        SiphoCue.badgeUnlocked,
      );
    });

    test('a lower level (data correction) is not celebrated', () {
      expect(cueForGameChange(_state(level: 5), _state(level: 4)), isNull);
    });
  });
}
