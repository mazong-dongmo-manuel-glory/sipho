import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import 'friends_provider.dart';

class FriendChallenge {
  final String id;
  final String pairId;
  final String title;
  final String status;
  final int targetCount;
  final int myProgress;
  final int theirProgress;
  final bool iAmSender;
  final String friendUid;

  const FriendChallenge({
    required this.id,
    required this.pairId,
    required this.title,
    required this.status,
    required this.targetCount,
    required this.myProgress,
    required this.theirProgress,
    this.iAmSender = true,
    this.friendUid = '',
  });

  bool get canRespond => status == 'pending' && !iAmSender;
}

class ChallengesNotifier extends StateNotifier<List<FriendChallenge>> {
  ChallengesNotifier(this._ref) : super(const []) {
    _bind();
  }

  final Ref _ref;
  final _subs = <StreamSubscription>[];

  void _bind() {
    void reload(List<FriendLink> accepted, String? uid) {
      for (final s in _subs) {
        s.cancel();
      }
      _subs.clear();
      if (uid == null || accepted.isEmpty) {
        state = const [];
        return;
      }
      final db = _ref.read(firestoreProvider);
      final collected = <String, FriendChallenge>{};

      void publish() {
        final list = collected.values.toList()
          ..sort((a, b) {
            const order = {'active': 0, 'pending': 1, 'won': 2, 'lost': 3};
            return (order[a.status] ?? 9).compareTo(order[b.status] ?? 9);
          });
        state = list;
      }

      for (final link in accepted) {
        _subs.add(
          db
              .collection('friendships')
              .doc(link.pairId)
              .collection('challenges')
              .snapshots()
              .listen((snap) {
            for (final doc in snap.docs) {
              final data = doc.data();
              final sender = data['senderUid'] as String? ?? '';
              final iAmSender = sender == uid;
              final senderUid = sender;
              final receiverUid = (data['receiverUid'] as String?) ?? '';
              collected[doc.id] = FriendChallenge(
                id: doc.id,
                pairId: link.pairId,
                title: (data['title'] as String?) ?? '',
                status: (data['status'] as String?) ?? 'pending',
                targetCount: (data['targetCount'] as num?)?.toInt() ?? 0,
                myProgress: ((iAmSender
                            ? data['senderProgress']
                            : data['receiverProgress']) as num?)
                        ?.toInt() ??
                    0,
                theirProgress: ((iAmSender
                            ? data['receiverProgress']
                            : data['senderProgress']) as num?)
                        ?.toInt() ??
                    0,
                iAmSender: iAmSender,
                friendUid: iAmSender ? receiverUid : senderUid,
              );
            }
            // Drop challenges for this pair that disappeared
            collected.removeWhere(
              (id, c) =>
                  c.pairId == link.pairId &&
                  !snap.docs.any((d) => d.id == id),
            );
            publish();
          }, onError: (_) {}),
        );
      }
    }

    _ref.listen<FriendsState>(friendsProvider, (_, friends) {
      reload(friends.accepted, _ref.read(authUidProvider));
    }, fireImmediately: true);
    _ref.listen<String?>(authUidProvider, (_, uid) {
      reload(_ref.read(friendsProvider).accepted, uid);
    });
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}

final challengesProvider =
    StateNotifierProvider<ChallengesNotifier, List<FriendChallenge>>((ref) {
  return ChallengesNotifier(ref);
});
