/// What the server paid for a finished lesson (`completeLesson` response), plus what the app
/// measured itself (accuracy, duration). Shown on the end-of-lesson screen: nothing here is
/// invented by the client, the rewards are exactly the server's numbers.
class LessonResult {
  const LessonResult({
    required this.xpGained,
    required this.seedsGained,
    required this.newStreak,
    required this.levelUp,
    required this.newLevel,
    required this.alreadyCompleted,
    required this.accuracy,
    required this.durationSeconds,
    this.unitCompleted,
    this.unitBonusXp = 0,
    this.unitBonusSeeds = 0,
  });

  /// Builds a result from the `completeLesson` callable response.
  ///
  /// Missing or malformed numbers count as 0 rather than throwing: a server a version ahead of
  /// the app must not break the celebration screen.
  factory LessonResult.fromCallable(
    Map<String, dynamic> data, {
    required int accuracy,
    required int durationSeconds,
  }) {
    int number(String key) {
      final value = data[key];
      return value is num ? value.toInt() : 0;
    }

    return LessonResult(
      xpGained: number('xpGained'),
      seedsGained: number('seedsGained'),
      newStreak: number('newStreak'),
      levelUp: data['levelUp'] == true,
      newLevel: number('newLevel'),
      alreadyCompleted: data['alreadyCompleted'] == true,
      accuracy: accuracy.clamp(0, 100),
      durationSeconds: durationSeconds < 0 ? 0 : durationSeconds,
      unitCompleted: data['unitCompleted'] is String
          ? data['unitCompleted'] as String
          : null,
      unitBonusXp: number('unitBonusXp'),
      unitBonusSeeds: number('unitBonusSeeds'),
    );
  }

  /// Total XP of this completion (it already includes the unit bonus).
  final int xpGained;

  /// Total seeds of this completion (it already includes the unit bonus).
  final int seedsGained;
  final int newStreak;
  final bool levelUp;
  final int newLevel;

  /// True when the server had already paid this lesson (replay or repeated call).
  final bool alreadyCompleted;

  /// 0–100, see [lessonScoreForMisses].
  final int accuracy;
  final int durationSeconds;

  /// Id of the unit finished by this completion, if any.
  final String? unitCompleted;
  final int unitBonusXp;
  final int unitBonusSeeds;

  bool get finishedUnit => unitCompleted != null;
}

/// Score sent to the server for a lesson answered correctly after [misses] wrong answers.
///
/// Accuracy is correct answers over answers given: a first-try success is a perfect 100 (the
/// server pays the "perfect" XP), every miss lowers it. Retrying until right therefore no
/// longer earns the perfect-lesson reward.
int lessonScoreForMisses(int misses) {
  if (misses <= 0) return 100;
  return (100 / (misses + 1)).round();
}

/// `m:ss`, e.g. 134 seconds → `2:14`.
String formatLessonDuration(int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final minutes = safe ~/ 60;
  final rest = (safe % 60).toString().padLeft(2, '0');
  return '$minutes:$rest';
}
