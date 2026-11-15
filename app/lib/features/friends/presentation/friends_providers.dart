import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/friends/data/friends_repository.dart';
import 'package:sipho/features/friends/domain/friends.dart';

/// The signed-in user's friends, incoming requests and sent requests, live.
final friendLinksProvider = StreamProvider.autoDispose<FriendLinks>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const FriendLinks());
  return ref
      .watch(friendsRepositoryProvider)
      .watchFriendships(uid)
      .map((records) => splitFriendships(records, uid));
});

/// Public profile of another user (pseudo, level, streak, league: never amounts).
final publicProfileProvider =
    StreamProvider.autoDispose.family<PublicProfile?, String>((ref, uid) {
  return ref.watch(friendsRepositoryProvider).watchPublicProfile(uid);
});

/// The user's own invite code, requested once while the screen is open.
final inviteCodeProvider = FutureProvider.autoDispose<String>((ref) {
  return ref.watch(friendsRepositoryProvider).inviteCode();
});
