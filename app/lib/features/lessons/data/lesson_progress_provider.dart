import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/lesson_catalog.dart';

enum LessonUiStatus { done, current, locked }

class LessonProgressNotifier extends StateNotifier<Set<String>> {
  LessonProgressNotifier(this._ref) : super(const {}) {
    _bind();
  }

  final Ref _ref;
  StreamSubscription? _sub;

  void _bind() {
    _ref.listen<String?>(authUidProvider, (_, uid) {
      _sub?.cancel();
      if (uid == null) {
        state = const {};
        return;
      }
      _sub = _ref
          .read(firestoreProvider)
          .collection('users')
          .doc(uid)
          .collection('lessonProgress')
          .snapshots()
          .listen((snap) {
        state = snap.docs.map((d) => d.id).toSet();
      }, onError: (_) {});
    }, fireImmediately: true);
  }

  LessonUiStatus statusFor(String lessonId) {
    if (state.contains(lessonId)) return LessonUiStatus.done;
    if (isLessonUnlocked(lessonId, state)) return LessonUiStatus.current;
    return LessonUiStatus.locked;
  }

  String? get currentLessonId {
    for (final id in kAllLessonIds) {
      if (!state.contains(id) && isLessonUnlocked(id, state)) return id;
    }
    return null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final lessonProgressProvider =
    StateNotifierProvider<LessonProgressNotifier, Set<String>>((ref) {
  return LessonProgressNotifier(ref);
});
