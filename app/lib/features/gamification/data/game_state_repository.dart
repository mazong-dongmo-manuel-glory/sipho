import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/features/gamification/domain/game_state.dart';
import 'package:sipho/features/gamification/domain/quest.dart';

final gameStateRepositoryProvider = Provider<GameStateRepository>((ref) {
  return GameStateRepository(FirebaseFirestore.instance);
});

class GameStateRepository {
  final FirebaseFirestore _firestore;

  GameStateRepository(this._firestore);

  Stream<GameState> watchGameState(String uid) {
    return _firestore.doc('users/$uid/game/state').snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return const GameState(streak: StreakInfo());
      }
      return GameState.fromJson(doc.data()!);
    });
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
                templateId: data['templateId'] ?? '',
                type: data['type'] ?? 'daily',
                progress: data['progress'] ?? 0,
                target: data['target'] ?? 1,
                rewardXp: data['rewardXp'] ?? 20,
                rewardChest: data['rewardChest'],
                status: data['status'] ?? 'active',
              );
            }).toList());
  }
}

