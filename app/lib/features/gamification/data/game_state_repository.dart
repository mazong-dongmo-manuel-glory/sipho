import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/gamification/domain/game_extras.dart';
import 'package:sipho/features/gamification/domain/game_state.dart';
final gameStateRepositoryProvider = Provider<GameStateRepository>((ref) {
  return GameStateRepository(ref.watch(firestoreProvider));
});

final gameStateStreamProvider = StreamProvider<GameState?>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(gameStateRepositoryProvider).watchOptionalGameState(uid);
});

/// Day-level markers (budget-day reward, "no spending today") from the same document.
final gameExtrasStreamProvider = StreamProvider<GameExtras>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const GameExtras());
  return ref
      .watch(firestoreProvider)
      .doc('users/$uid/game/state')
      .snapshots()
      .map((doc) => parseGameExtras(doc.data()))
      .distinct();
});

class GameStateRepository {
  final FirebaseFirestore _firestore;

  GameStateRepository(this._firestore);

  Stream<GameState?> watchOptionalGameState(String uid) {
    return _firestore.doc('users/$uid/game/state').snapshots().map((doc) {
      final raw = doc.data();
      if (!doc.exists || raw == null) return null;
      return _parseGameState(raw);
    });
  }

  Stream<GameState> watchGameState(String uid) {
    return watchOptionalGameState(uid).map(
      (state) => state ?? const GameState(streak: StreakInfo()),
    );
  }

  GameState _parseGameState(Map<String, dynamic> raw) {
    final rawStreak = raw['streak'];
    final streak = rawStreak is Map
        ? StreakInfo(
            current: (rawStreak['current'] as num?)?.toInt() ?? 0,
            best: (rawStreak['best'] as num?)?.toInt() ?? 0,
            lastActiveDay: rawStreak['lastActiveDay'] as String?,
            freezes: (rawStreak['freezes'] as num?)?.toInt() ?? 2,
            brokenAt: rawStreak['brokenAt'] as String?,
            brokenCurrent: (rawStreak['brokenCurrent'] as num?)?.toInt() ?? 0,
          )
        : StreakInfo(
            current: (rawStreak is num) ? rawStreak.toInt() : 0,
            best: (rawStreak is num) ? rawStreak.toInt() : 0,
          );
    return GameState(
      xp: (raw['xp'] as num?)?.toInt() ?? 0,
      level: (raw['level'] as num?)?.toInt() ?? 1,
      gems: (raw['gems'] as num?)?.toInt() ??
          (raw['seeds'] as num?)?.toInt() ??
          0,
      streak: streak,
      leagueId: (raw['leagueId'] as String?) ?? 'bronze',
      weeklyXp: (raw['weeklyXp'] as num?)?.toInt() ?? 0,
      badges: (raw['badges'] as List?)?.map((b) => b.toString()).toList() ??
          const [],
    );
  }

}
