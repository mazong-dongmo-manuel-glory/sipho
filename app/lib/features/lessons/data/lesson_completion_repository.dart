import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/features/lessons/domain/lesson_result.dart';

/// Tells the server a lesson was finished. XP, seeds, streak and the unit bonus are decided and
/// written by the `completeLesson` Cloud Function only: the app just reports and displays.
abstract class LessonCompletionRepository {
  /// Throws when the server refuses (locked lesson, network error…): the caller keeps the
  /// learner on the lesson so nothing is lost.
  Future<LessonResult> complete({
    required String lessonId,
    required int score,
    required int durationSeconds,
  });
}

final lessonCompletionRepositoryProvider =
    Provider<LessonCompletionRepository>((ref) {
  return CallableLessonCompletionRepository(
    ref.watch(firebaseFunctionsProvider),
  );
});

class CallableLessonCompletionRepository implements LessonCompletionRepository {
  CallableLessonCompletionRepository(this._functions);

  final FirebaseFunctions _functions;

  @override
  Future<LessonResult> complete({
    required String lessonId,
    required int score,
    required int durationSeconds,
  }) async {
    final response = await _functions
        .httpsCallable('completeLesson')
        .call<Map<String, dynamic>>({
      'lessonId': lessonId,
      'score': score,
      // The server refuses durations under 2 s or over an hour.
      'durationSeconds': durationSeconds.clamp(2, 3600),
    });
    return LessonResult.fromCallable(
      response.data,
      accuracy: score,
      durationSeconds: durationSeconds,
    );
  }
}
