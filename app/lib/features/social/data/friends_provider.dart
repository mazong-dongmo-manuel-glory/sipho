import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/cloud_functions_service.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';

class FriendLink {
  final String pairId;
  final String otherUid;
  final String status; // pending | accepted
  final bool iAmRequester;
  final String displayName;
  final int level;
  final int streak;

  const FriendLink({
    required this.pairId,
    required this.otherUid,
    required this.status,
    required this.iAmRequester,
    this.displayName = '',
    this.level = 1,
    this.streak = 0,
  });

  FriendLink copyWithProfile({
    String? displayName,
    int? level,
    int? streak,
  }) {
    return FriendLink(
      pairId: pairId,
      otherUid: otherUid,
      status: status,
      iAmRequester: iAmRequester,
      displayName: displayName ?? this.displayName,
      level: level ?? this.level,
      streak: streak ?? this.streak,
    );
  }
}

class FriendsState {
  final String? inviteCode;
  final List<FriendLink> links;
  final bool loading;
  final String? error;

  const FriendsState({
    this.inviteCode,
    this.links = const [],
    this.loading = false,
    this.error,
  });

  List<FriendLink> get accepted =>
      links.where((l) => l.status == 'accepted').toList();
  List<FriendLink> get incoming =>
      links.where((l) => l.status == 'pending' && !l.iAmRequester).toList();
  List<FriendLink> get outgoing =>
      links.where((l) => l.status == 'pending' && l.iAmRequester).toList();

  FriendsState copyWith({
    String? inviteCode,
    List<FriendLink>? links,
    bool? loading,
    String? error,
  }) {
    return FriendsState(
      inviteCode: inviteCode ?? this.inviteCode,
      links: links ?? this.links,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class FriendsNotifier extends StateNotifier<FriendsState> {
  FriendsNotifier(this._ref) : super(const FriendsState(loading: true)) {
    _bind();
  }

  final Ref _ref;
  StreamSubscription? _sub;

  void _bind() {
    _ref.listen<String?>(authUidProvider, (_, uid) {
      _sub?.cancel();
      if (uid == null) {
        state = const FriendsState();
        return;
      }
      state = state.copyWith(loading: true);
      unawaited(loadInviteCode());
      _sub = _ref
          .read(firestoreProvider)
          .collection('friendships')
          .where('users', arrayContains: uid)
          .snapshots()
          .listen((snap) async {
        final links = <FriendLink>[];
        for (final doc in snap.docs) {
          final data = doc.data();
          final users = (data['users'] as List?)?.cast<String>() ?? const [];
          final other = users.firstWhere((u) => u != uid, orElse: () => '');
          if (other.isEmpty) continue;
          final requester = data['requesterUid'] as String? ?? '';
          links.add(FriendLink(
            pairId: doc.id,
            otherUid: other,
            status: (data['status'] as String?) ?? 'pending',
            iAmRequester: requester == uid,
          ));
        }
        final enriched = await _enrich(links);
        if (!mounted) return;
        state = state.copyWith(links: enriched, loading: false, error: null);
      }, onError: (e) {
        if (!mounted) return;
        state = state.copyWith(loading: false, error: e.toString());
      });
    }, fireImmediately: true);
  }

  Future<List<FriendLink>> _enrich(List<FriendLink> links) async {
    final db = _ref.read(firestoreProvider);
    final out = <FriendLink>[];
    for (final link in links) {
      try {
        final snap = await db.doc('publicProfiles/${link.otherUid}').get();
        final d = snap.data();
        out.add(link.copyWithProfile(
          displayName: (d?['pseudo'] as String?) ??
              (d?['displayName'] as String?) ??
              '',
          level: (d?['level'] as num?)?.toInt() ?? 1,
          streak: (d?['streak'] as num?)?.toInt() ?? 0,
        ));
      } catch (_) {
        out.add(link);
      }
    }
    return out;
  }

  Future<String?> loadInviteCode() async {
    final result = await _ref.read(cloudFunctionsServiceProvider).getInviteCode();
    final code = result['code'] as String?;
    if (code != null && mounted) {
      state = state.copyWith(inviteCode: code);
    }
    return code;
  }

  Future<Map<String, dynamic>> sendRequest(String code) async {
    final cleaned = code.trim().toUpperCase();
    final result = await _ref
        .read(cloudFunctionsServiceProvider)
        .sendFriendRequest(referralCode: cleaned);
    return result;
  }

  Future<Map<String, dynamic>> respond(String pairId, {required bool accept}) {
    return _ref
        .read(cloudFunctionsServiceProvider)
        .respondFriendRequest(pairId: pairId, accept: accept);
  }

  Future<Map<String, dynamic>> remove(String pairId) {
    return _ref.read(cloudFunctionsServiceProvider).removeFriend(pairId: pairId);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final friendsProvider =
    StateNotifierProvider<FriendsNotifier, FriendsState>((ref) {
  return FriendsNotifier(ref);
});
