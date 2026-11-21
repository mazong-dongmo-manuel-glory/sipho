import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/goals/domain/goal.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepository(ref.watch(firestoreProvider));
});

final userGoalsProvider = StreamProvider<List<Goal>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(goalRepositoryProvider).watchGoals(uid);
});

class GoalRepository {
  final FirebaseFirestore _firestore;

  GoalRepository(this._firestore);

  Stream<List<Goal>> watchGoals(String uid) {
    return _firestore
        .collection('users/$uid/goals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) {
        final data = d.data();
        return Goal(
          id: d.id,
          title: data['title'] as String? ?? '',
          targetCents: (data['targetCents'] as num?)?.toInt() ?? 0,
          savedCents: (data['savedCents'] as num?)?.toInt() ?? 0,
          deadline: data['deadline'] as String?,
          emoji: data['emoji'] as String? ?? '🎯',
          completedAt: data['completedAt'] != null
              ? (data['completedAt'] is Timestamp
                  ? (data['completedAt'] as Timestamp).toDate()
                  : DateTime.tryParse('${data['completedAt']}'))
              : null,
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] is Timestamp
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.tryParse('${data['createdAt']}') ?? DateTime.now())
              : DateTime.now(),
        );
      }).toList();
    });
  }

  Future<void> createGoal(String uid, Goal goal) async {
    final ref = goal.id.isNotEmpty
        ? _firestore.doc('users/$uid/goals/${goal.id}')
        : _firestore.collection('users/$uid/goals').doc();
    await ref.set({
      'title': goal.title,
      'targetCents': goal.targetCents,
      'savedCents': goal.savedCents,
      'deadline': goal.deadline,
      'emoji': goal.emoji,
      'completedAt': goal.completedAt?.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateGoal(String uid, Goal goal) async {
    await _firestore.doc('users/$uid/goals/${goal.id}').update({
      'title': goal.title,
      'targetCents': goal.targetCents,
      'savedCents': goal.savedCents,
      'deadline': goal.deadline,
      'emoji': goal.emoji,
      if (goal.completedAt != null)
        'completedAt': goal.completedAt!.toIso8601String(),
    });
  }

  Future<void> deposit(String uid, String goalId, int amountCents) async {
    if (amountCents <= 0) return;
    final docRef = _firestore.doc('users/$uid/goals/$goalId');
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;
      final data = snap.data() ?? {};
      final currentSaved = (data['savedCents'] as num?)?.toInt() ?? 0;
      final target = (data['targetCents'] as num?)?.toInt() ?? 0;
      final newSaved = currentSaved + amountCents;
      final completed = target > 0 && newSaved >= target;
      tx.update(docRef, {
        'savedCents': newSaved,
        if (completed && data['completedAt'] == null)
          'completedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> deleteGoal(String uid, String goalId) async {
    await _firestore.doc('users/$uid/goals/$goalId').delete();
  }
}
