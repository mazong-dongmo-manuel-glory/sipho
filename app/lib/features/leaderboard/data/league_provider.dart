import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/cloud_functions_service.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';

class LeagueMember {
  final String uid;
  final String pseudo;
  final int level;
  final int weeklyXp;

  const LeagueMember({
    required this.uid,
    required this.pseudo,
    required this.level,
    required this.weeklyXp,
  });
}

class LeagueState {
  final String? leagueKey;
  final String tier;
  final String week;
  final List<LeagueMember> members;
  final bool loading;
  final String? error;

  const LeagueState({
    this.leagueKey,
    this.tier = 'bronze',
    this.week = '',
    this.members = const [],
    this.loading = false,
    this.error,
  });

  LeagueState copyWith({
    String? leagueKey,
    String? tier,
    String? week,
    List<LeagueMember>? members,
    bool? loading,
    String? error,
  }) {
    return LeagueState(
      leagueKey: leagueKey ?? this.leagueKey,
      tier: tier ?? this.tier,
      week: week ?? this.week,
      members: members ?? this.members,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class LeagueNotifier extends StateNotifier<LeagueState> {
  LeagueNotifier(this._ref) : super(const LeagueState(loading: true)) {
    _bind();
  }

  final Ref _ref;
  StreamSubscription? _sub;

  void _bind() {
    _ref.listen<String?>(authUidProvider, (_, uid) {
      _sub?.cancel();
      if (uid == null) {
        state = const LeagueState();
        return;
      }
      unawaited(refresh());
    }, fireImmediately: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: null);
    final result = await _ref.read(cloudFunctionsServiceProvider).joinLeague();
    if (result['status'] == 'error') {
      state = state.copyWith(
        loading: false,
        error: result['message']?.toString() ?? 'joinLeague failed',
      );
      return;
    }
    final leagueKey = result['leagueKey'] as String?;
    final tier = (result['tier'] as String?) ?? 'bronze';
    final week = (result['week'] as String?) ?? '';
    if (leagueKey == null || leagueKey.isEmpty) {
      state = state.copyWith(loading: false, error: 'no league');
      return;
    }
    state = state.copyWith(leagueKey: leagueKey, tier: tier, week: week);
    _sub?.cancel();
    _sub = _ref
        .read(firestoreProvider)
        .collection('leagues')
        .doc(leagueKey)
        .collection('members')
        .orderBy('weeklyXp', descending: true)
        .limit(30)
        .snapshots()
        .listen((snap) {
      final members = snap.docs.map((d) {
        final data = d.data();
        return LeagueMember(
          uid: d.id,
          pseudo: (data['pseudo'] as String?)?.trim().isNotEmpty == true
              ? (data['pseudo'] as String).trim()
              : 'Sipho',
          level: (data['level'] as num?)?.toInt() ?? 1,
          weeklyXp: (data['weeklyXp'] as num?)?.toInt() ?? 0,
        );
      }).toList();
      if (!mounted) return;
      state = state.copyWith(members: members, loading: false, error: null);
    }, onError: (e) {
      if (!mounted) return;
      state = state.copyWith(loading: false, error: e.toString());
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final leagueProvider =
    StateNotifierProvider<LeagueNotifier, LeagueState>((ref) {
  return LeagueNotifier(ref);
});
