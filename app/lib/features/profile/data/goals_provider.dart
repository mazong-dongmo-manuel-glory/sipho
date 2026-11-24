import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';

class Goal {
  final String id;
  final String title;
  final int targetCents;
  final int savedCents;

  const Goal({
    required this.id,
    required this.title,
    required this.targetCents,
    required this.savedCents,
  });

  double get progress =>
      targetCents <= 0 ? 0 : (savedCents / targetCents).clamp(0.0, 1.0);
}

class GoalsNotifier extends StateNotifier<List<Goal>> {
  GoalsNotifier(this._ref) : super(const []) {
    _bind();
  }

  final Ref _ref;
  StreamSubscription? _sub;

  void _bind() {
    _ref.listen<String?>(authUidProvider, (_, uid) {
      _sub?.cancel();
      if (uid == null) {
        state = const [];
        return;
      }
      _sub = _ref
          .read(firestoreProvider)
          .collection('users')
          .doc(uid)
          .collection('goals')
          .snapshots()
          .listen((snap) {
        state = snap.docs.map((d) {
          final data = d.data();
          return Goal(
            id: d.id,
            title: (data['title'] as String?) ?? 'Objectif',
            targetCents: (data['targetCents'] as num?)?.toInt() ?? 0,
            savedCents: (data['savedCents'] as num?)?.toInt() ?? 0,
          );
        }).toList();
      }, onError: (_) {});
    }, fireImmediately: true);
  }

  Future<void> createGoal({
    required String title,
    required int targetCents,
  }) async {
    final uid = _ref.read(authUidProvider);
    if (uid == null) return;
    await _ref.read(firestoreProvider).collection('users').doc(uid).collection('goals').add({
      'title': title,
      'targetCents': targetCents,
      'savedCents': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deposit({required String goalId, required int cents}) async {
    final uid = _ref.read(authUidProvider);
    if (uid == null || cents <= 0) return;
    final ref = _ref
        .read(firestoreProvider)
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goalId);
    await _ref.read(firestoreProvider).runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = (snap.data()?['savedCents'] as num?)?.toInt() ?? 0;
      tx.set(ref, {'savedCents': current + cents}, SetOptions(merge: true));
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final goalsProvider = StateNotifierProvider<GoalsNotifier, List<Goal>>((ref) {
  return GoalsNotifier(ref);
});
