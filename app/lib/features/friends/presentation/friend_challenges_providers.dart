import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/features/friends/data/friend_challenges_repository.dart';
import 'package:sipho/features/friends/domain/friend_challenge.dart';
import 'package:sipho/features/friends/presentation/friends_providers.dart';

/// All challenges for a single friend pair.
final pairChallengesProvider =
    StreamProvider.family<List<FriendChallenge>, String>((ref, pairId) {
  return ref
      .watch(friendChallengesRepositoryProvider)
      .watchChallengesForPair(pairId);
});

/// All active or pending challenges involving the current user across all accepted friends.
final activeChallengesProvider = Provider<List<FriendChallenge>>((ref) {
  final links = ref.watch(friendLinksProvider).valueOrNull;
  if (links == null || links.friends.isEmpty) return const [];

  final all = <FriendChallenge>[];
  for (final friend in links.friends) {
    final challenges =
        ref.watch(pairChallengesProvider(friend.pairId)).valueOrNull ?? const [];
    for (final c in challenges) {
      if (c.status == ChallengeStatus.active ||
          c.status == ChallengeStatus.pending) {
        all.add(c);
      }
    }
  }

  // Sort: active first, then by creation date.
  all.sort((a, b) {
    if (a.status == ChallengeStatus.active &&
        b.status != ChallengeStatus.active) {
      return -1;
    }
    if (b.status == ChallengeStatus.active &&
        a.status != ChallengeStatus.active) {
      return 1;
    }
    return b.createdAt.compareTo(a.createdAt);
  });

  return all;
});
