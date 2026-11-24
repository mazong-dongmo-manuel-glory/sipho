import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/game_state.dart';

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier(this._ref) : super(const GameState()) {
    _bind();
  }

  final Ref _ref;
  StreamSubscription? _sub;

  void _bind() {
    _ref.listen<String?>(authUidProvider, (prev, uid) {
      _sub?.cancel();
      if (uid == null) {
        state = const GameState();
        return;
      }
      _sub = _ref
          .read(firestoreProvider)
          .collection('users')
          .doc(uid)
          .collection('game')
          .doc('state')
          .snapshots()
          .listen((snap) {
        final data = snap.data();
        if (data == null) return;
        final streak = data['streak'];
        int streakDays = 0;
        int freezes = 0;
        if (streak is Map) {
          streakDays = (streak['current'] as num?)?.toInt() ?? 0;
          freezes = (streak['freezes'] as num?)?.toInt() ?? 0;
        } else if (streak is num) {
          streakDays = streak.toInt();
        }
        final gems = (data['gems'] as num?)?.toInt() ??
            (data['seeds'] as num?)?.toInt() ??
            0;
        final badges = (data['badges'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[];
        final owned = (data['ownedItems'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[];
        final equipped = (data['equippedItems'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[];
        state = GameState(
          xp: (data['xp'] as num?)?.toInt() ?? 0,
          level: (data['level'] as num?)?.toInt() ?? 1,
          seeds: gems,
          streakDays: streakDays,
          freezes: freezes,
          leagueId: (data['leagueId'] as String?) ?? 'bronze',
          badges: badges,
          ownedItems: owned,
          equippedItems: equipped,
        );
      }, onError: (_) {});
    }, fireImmediately: true);
  }

  /// Lecture seule : applique une réponse callable en attendant le snapshot.
  void applyServerState({
    int? xp,
    int? level,
    int? seeds,
    int? streakDays,
    List<String>? badges,
  }) {
    state = state.copyWith(
      xp: xp,
      level: level,
      seeds: seeds,
      streakDays: streakDays,
      badges: badges,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier(ref);
});
