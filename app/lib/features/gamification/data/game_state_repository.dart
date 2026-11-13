import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/gamification/domain/game_state.dart';
import 'package:sipho/features/gamification/domain/quest.dart';

final gameStateRepositoryProvider = Provider<GameStateRepository>((ref) {
  return GameStateRepository(ref.watch(firestoreProvider));
});

final gameStateStreamProvider = StreamProvider<GameState?>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(gameStateRepositoryProvider).watchOptionalGameState(uid);
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

  Stream<List<Quest>> watchActiveQuests(String uid) {
    return _firestore
        .collection('users/$uid/quests')
        .where('status', isNotEqualTo: 'claimed')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              return Quest(
                id: d.id,
                templateId: data['templateId'] as String? ?? '',
                type: data['type'] as String? ?? 'daily',
                progress: (data['progress'] as num?)?.toInt() ?? 0,
                target: (data['target'] as num?)?.toInt() ?? 1,
                rewardXp: (data['rewardXp'] as num?)?.toInt() ?? 20,
                rewardChest: data['rewardChest'] as String?,
                status: data['status'] as String? ?? 'active',
              );
            }).toList());
  }
}
