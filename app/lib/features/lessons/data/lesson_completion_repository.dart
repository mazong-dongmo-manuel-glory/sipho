import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/features/lessons/domain/lesson_result.dart';

/// Why a lesson could not be saved. The player screen picks the matching message.
enum LessonSaveFailureKind { signedOut, refused, network, unknown }

class LessonSaveException implements Exception {
  const LessonSaveException(this.kind, {this.cause});

  final LessonSaveFailureKind kind;
  final Object? cause;

  @override
  String toString() => 'LessonSaveException($kind, cause: $cause)';
}

/// Tells the server a lesson was finished. XP, seeds, streak and the unit bonus are decided and
/// written by the `completeLesson` Cloud Function only: the app just reports and displays.
abstract class LessonCompletionRepository {
  /// Throws [LessonSaveException] when the server refuses or the device cannot reach it: the
  /// caller keeps the learner on the lesson so nothing is lost.
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
    ref.watch(firebaseAuthProvider),
  );
});

class CallableLessonCompletionRepository implements LessonCompletionRepository {
  CallableLessonCompletionRepository(this._functions, this._auth);

  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  @override
  Future<LessonResult> complete({
    required String lessonId,
    required int score,
    required int durationSeconds,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const LessonSaveException(LessonSaveFailureKind.signedOut);
    }
    // Force a fresh ID token so the callable is never called with an expired one (Cloud Run
    // then answers UNAUTHENTICATED before our function even runs).
    try {
      await user.getIdToken(true);
    } catch (error) {
      throw LessonSaveException(LessonSaveFailureKind.signedOut, cause: error);
    }

    try {
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
    } on FirebaseFunctionsException catch (error) {
      throw LessonSaveException(_kindOf(error), cause: error);
    } catch (error) {
      throw LessonSaveException(LessonSaveFailureKind.unknown, cause: error);
    }
  }

  static LessonSaveFailureKind _kindOf(FirebaseFunctionsException error) {
    switch (error.code) {
      case 'unauthenticated':
        // Also returned when Cloud Run refuses the call (IAM) before Auth is checked.
        return LessonSaveFailureKind.signedOut;
      case 'unavailable':
      case 'deadline-exceeded':
      case 'resource-exhausted':
        return LessonSaveFailureKind.network;
      case 'failed-precondition':
      case 'invalid-argument':
      case 'permission-denied':
        return LessonSaveFailureKind.refused;
      default:
        return LessonSaveFailureKind.unknown;
    }
  }
}
