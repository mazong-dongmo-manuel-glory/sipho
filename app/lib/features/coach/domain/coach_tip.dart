/// Server-authored coach tip (`users/{uid}/coach/current`).
class CoachTip {
  const CoachTip({
    required this.tipId,
    required this.category,
    required this.emoji,
    required this.title,
    required this.body,
    required this.stage,
    required this.stageId,
    required this.educationScore,
    required this.hourKey,
    this.createdAt,
  });

  factory CoachTip.fromMap(Map<String, dynamic> data) {
    return CoachTip(
      tipId: (data['tipId'] as String?) ?? '',
      category: (data['category'] as String?) ?? 'habit',
      emoji: (data['emoji'] as String?) ?? '💡',
      title: (data['title'] as String?) ?? '',
      body: (data['body'] as String?) ?? '',
      stage: (data['stage'] as num?)?.toInt() ?? 0,
      stageId: (data['stageId'] as String?) ?? 'foundation',
      educationScore: (data['educationScore'] as num?)?.toInt() ?? 0,
      hourKey: (data['hourKey'] as String?) ?? '',
      createdAt: data['createdAt'],
    );
  }

  final String tipId;
  final String category;
  final String emoji;
  final String title;
  final String body;
  final int stage;
  final String stageId;
  final int educationScore;
  final String hourKey;
  final Object? createdAt;

  bool get isValid => tipId.isNotEmpty && title.isNotEmpty && body.isNotEmpty;
}

/// Persistent education progress (`users/{uid}/coach/progress`).
class CoachProgress {
  const CoachProgress({
    required this.stage,
    required this.stageId,
    required this.educationScore,
    required this.lessonsCompleted,
    required this.tipCount,
    this.lastTipId,
  });

  factory CoachProgress.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return const CoachProgress(
        stage: 0,
        stageId: 'foundation',
        educationScore: 0,
        lessonsCompleted: 0,
        tipCount: 0,
      );
    }
    return CoachProgress(
      stage: (data['stage'] as num?)?.toInt() ?? 0,
      stageId: (data['stageId'] as String?) ?? 'foundation',
      educationScore: (data['educationScore'] as num?)?.toInt() ?? 0,
      lessonsCompleted: (data['lessonsCompleted'] as num?)?.toInt() ?? 0,
      tipCount: (data['tipCount'] as num?)?.toInt() ?? 0,
      lastTipId: data['lastTipId'] as String?,
    );
  }

  final int stage;
  final String stageId;
  final int educationScore;
  final int lessonsCompleted;
  final int tipCount;
  final String? lastTipId;
}
