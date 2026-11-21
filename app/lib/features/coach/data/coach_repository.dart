import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/coach/domain/coach_tip.dart';

final coachRepositoryProvider = Provider<CoachRepository>((ref) {
  return CoachRepository(ref.watch(firestoreProvider));
});

final coachCurrentTipProvider = StreamProvider<CoachTip?>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(coachRepositoryProvider).watchCurrentTip(uid);
});

final coachProgressProvider = StreamProvider<CoachProgress>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) {
    return Stream.value(const CoachProgress(
      stage: 0,
      stageId: 'foundation',
      educationScore: 0,
      lessonsCompleted: 0,
      tipCount: 0,
    ));
  }
  return ref.watch(coachRepositoryProvider).watchProgress(uid);
});

class CoachRepository {
  CoachRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<CoachTip?> watchCurrentTip(String uid) {
    return _firestore.doc('users/$uid/coach/current').snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      final tip = CoachTip.fromMap(data);
      return tip.isValid ? tip : null;
    });
  }

  Stream<CoachProgress> watchProgress(String uid) {
    return _firestore.doc('users/$uid/coach/progress').snapshots().map(
          (doc) => CoachProgress.fromMap(doc.data()),
        );
  }
}
