import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/gamification/data/game_state_repository.dart';
import 'package:sipho/features/gamification/domain/game_state.dart';
import 'package:sipho/features/leaderboard/domain/league.dart';
import 'package:sipho/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:sipho/features/leaderboard/presentation/league_providers.dart';

LeagueMember _member(String uid, int xp, {String? pseudo}) => LeagueMember(
      uid: uid,
      pseudo: pseudo ?? uid,
      avatar: '',
      level: 1,
      weeklyXp: xp,
    );

class _FakeUser implements User {
  @override
  String get uid => 'me';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ranking rules (mirror the server)', () {
    test('ties are broken by uid so everybody sees the same order', () {
      final ranked = rankLeagueMembers([
        _member('b', 5),
        _member('a', 5),
        _member('c', 9),
      ]);
      expect(ranked.map((m) => m.uid), ['c', 'a', 'b']);
    });

    test('top 7 with XP are in the promotion zone, last 5 in relegation', () {
      LeagueZone zone(int rank, {int size = 30, int tier = 2, int xp = 10}) =>
          leagueZone(rank: rank, size: size, tierIndex: tier, weeklyXp: xp);
      expect(zone(1), LeagueZone.promotion);
      expect(zone(7), LeagueZone.promotion);
      expect(zone(8), LeagueZone.safe);
      expect(zone(25), LeagueZone.safe);
      expect(zone(26), LeagueZone.relegation);
      expect(zone(30), LeagueZone.relegation);
    });

    test(
        'no promotion without XP or from the top tier, no relegation from bronze or small groups',
        () {
      expect(
        leagueZone(rank: 1, size: 30, tierIndex: 2, weeklyXp: 0),
        LeagueZone.safe,
      );
      expect(
        leagueZone(rank: 1, size: 30, tierIndex: 9, weeklyXp: 50),
        LeagueZone.safe,
      );
      expect(
        leagueZone(rank: 30, size: 30, tierIndex: 0, weeklyXp: 0),
        LeagueZone.safe,
      );
      expect(
        leagueZone(rank: 10, size: 10, tierIndex: 3, weeklyXp: 0),
        LeagueZone.safe,
      );
    });

    test('zones never overlap in a group of 15', () {
      final zones = [
        for (var rank = 1; rank <= 15; rank++)
          leagueZone(rank: rank, size: 15, tierIndex: 4, weeklyXp: 10),
      ];
      expect(zones.where((z) => z == LeagueZone.promotion), hasLength(7));
      expect(zones.where((z) => z == LeagueZone.relegation), hasLength(5));
    });
  });

  group('parsing', () {
    test('membership from the callable response', () {
      final membership = LeagueMembership.fromCallable({
        'leagueKey': 'abc',
        'tier': 'gold',
        'week': '2026-11-08',
        'endsAtMs': DateTime.utc(2026, 11, 15, 20).millisecondsSinceEpoch,
      });
      expect(membership.leagueKey, 'abc');
      expect(membership.tier, 'gold');
      expect(
        membership.remaining(DateTime.utc(2026, 11, 13, 15)),
        const Duration(days: 2, hours: 5),
      );
      expect(membership.remaining(DateTime.utc(2026, 11, 16)), Duration.zero);
      expect(
        () => LeagueMembership.fromCallable({'tier': 'gold'}),
        throwsFormatException,
      );
    });

    test('unknown tiers fall back to bronze; bad member data is tolerated', () {
      expect(leagueTierIndex('platinum'), 0);
      expect(leagueTierIndex('ruby'), 4);
      final member =
          LeagueMember.fromMap('u', {'pseudo': '  ', 'weeklyXp': -3});
      expect(member.pseudo, 'Sipho');
      expect(member.weeklyXp, 0);
    });

    test('last result is only shown for the week right before the current one',
        () {
      final result = LeagueLastResult.fromMap({
        'week': '2026-11-01',
        'rank': 3,
        'result': 'promoted',
        'toTier': 'silver',
      })!;
      expect(result.outcome, LeagueOutcome.promoted);
      expect(result.isForWeekBefore('2026-11-08'), isTrue);
      expect(result.isForWeekBefore('2026-11-15'), isFalse);
      expect(LeagueLastResult.fromMap(null), isNull);
      expect(LeagueLastResult.fromMap({'week': 'x'}), isNull);
    });
  });

  group('LeaderboardScreen', () {
    final membership = LeagueMembership(
      leagueKey: 'g1',
      tier: 'gold',
      week: '2026-11-08',
      endsAt: DateTime.now().toUtc().add(const Duration(days: 2, hours: 5)),
    );

    Future<void> pump(
      WidgetTester tester, {
      Future<LeagueMembership> Function()? join,
      List<LeagueMember> members = const [],
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            leagueMembershipProvider.overrideWith(
                (ref) => join != null ? join() : Future.value(membership)),
            leagueMembersProvider('g1')
                .overrideWith((ref) => Stream.value(members)),
            lastLeagueResultProvider.overrideWith((ref) => Stream.value(null)),
            gameStateStreamProvider.overrideWith(
              (ref) => Stream.value(
                const GameState(streak: StreakInfo(current: 4), gems: 12),
              ),
            ),
            authStateProvider.overrideWith((ref) => Stream.value(_FakeUser())),
          ],
          child: const MaterialApp(
            locale: Locale('fr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: LeaderboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows the real group: tier, countdown, players and my row',
        (tester) async {
      await pump(tester, members: [
        _member('zed', 80, pseudo: 'Zed'),
        _member('me', 40, pseudo: 'Moi'),
        _member('amy', 10, pseudo: 'Amy'),
      ]);

      expect(find.text('Ligue Or'), findsOneWidget);
      expect(find.textContaining('Se termine dans 2 j'), findsOneWidget);
      expect(find.text('Zed'), findsOneWidget);
      expect(find.text('80 XP'), findsOneWidget);
      expect(find.text('Moi · Toi'), findsOneWidget);
      expect(find.text('🔥  4'), findsOneWidget);
      // No more hard-coded players.
      expect(find.text('Moussa'), findsNothing);
    });

    testWidgets('being alone in the group is explained', (tester) async {
      await pump(tester, members: [_member('me', 0, pseudo: 'Moi')]);
      expect(find.textContaining('seul'), findsOneWidget);
    });

    testWidgets('a failure to join shows a retry button instead of fake data',
        (tester) async {
      await pump(tester,
          join: () => Future.error(Exception('unauthenticated')));
      expect(find.textContaining('Impossible de charger la ligue'),
          findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
      expect(find.text('Moussa'), findsNothing);
    });
  });
}
