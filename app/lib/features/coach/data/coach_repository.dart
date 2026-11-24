import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/coach_tip.dart';

final coachRepositoryProvider = Provider<CoachRepository>((ref) {
  return CoachRepository(ref.watch(firestoreProvider));
});

final coachCurrentTipProvider = StreamProvider<CoachTip?>((ref) {
  final uid = ref.watch(authUidProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(coachRepositoryProvider).watchCurrentTip(uid);
});

final coachProgressProvider = StreamProvider<CoachProgress>((ref) {
  final uid = ref.watch(authUidProvider);
  if (uid == null) {
    return Stream.value(
      const CoachProgress(
        stage: 0,
        stageId: 'foundation',
        educationScore: 0,
        lessonsCompleted: 0,
        tipCount: 0,
      ),
    );
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
