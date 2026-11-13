import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/features/lessons/domain/lesson.dart';

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return LessonRepository(FirebaseFirestore.instance);
});

class LessonRepository {
  final FirebaseFirestore _firestore;

  LessonRepository(this._firestore);

  Stream<List<Lesson>> watchUnitLessons(int unit) {
    return _firestore
        .collection('lessons')
        .where('unit', isEqualTo: unit)
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Lesson.fromJson(d.data())).toList());
  }

  Future<Lesson?> getLesson(String id) async {
    final doc = await _firestore.doc('lessons/$id').get();
    if (!doc.exists || doc.data() == null) return null;
    return Lesson.fromJson(doc.data()!);
  }
}

