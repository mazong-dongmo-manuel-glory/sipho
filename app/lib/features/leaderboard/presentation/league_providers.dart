import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/leaderboard/data/league_repository.dart';
import 'package:sipho/features/leaderboard/domain/league.dart';

/// This week's group. Re-evaluated every time the ranking screen is opened, so a new week (or a
/// promotion) always lands the player in the right group.
final leagueMembershipProvider =
    FutureProvider.autoDispose<LeagueMembership>((ref) {
  return ref.watch(leagueRepositoryProvider).join();
});

final leagueMembersProvider = StreamProvider.autoDispose
    .family<List<LeagueMember>, String>((ref, leagueKey) {
  return ref.watch(leagueRepositoryProvider).watchMembers(leagueKey);
});

final lastLeagueResultProvider =
    StreamProvider.autoDispose<LeagueLastResult?>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(leagueRepositoryProvider).watchLastResult(uid);
});
