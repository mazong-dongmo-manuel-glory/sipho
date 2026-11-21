class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.targetCents,
    this.savedCents = 0,
    this.deadline,
    this.emoji = '🎯',
    this.completedAt,
    required this.createdAt,
  });

  final String id;
  final String title;
  final int targetCents;
  final int savedCents;
  final String? deadline;
  final String emoji;
  final DateTime? completedAt;
  final DateTime createdAt;

  double get progress => targetCents > 0
      ? (savedCents / targetCents).clamp(0.0, 1.0)
      : 0.0;

  bool get isCompleted =>
      completedAt != null || (targetCents > 0 && savedCents >= targetCents);

  int get remainingCents {
    final diff = targetCents - savedCents;
    return diff > 0 ? diff : 0;
  }

  Goal copyWith({
    String? id,
    String? title,
    int? targetCents,
    int? savedCents,
    String? deadline,
    String? emoji,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetCents: targetCents ?? this.targetCents,
      savedCents: savedCents ?? this.savedCents,
      deadline: deadline ?? this.deadline,
      emoji: emoji ?? this.emoji,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetCents': targetCents,
        'savedCents': savedCents,
        'deadline': deadline,
        'emoji': emoji,
        'completedAt': completedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Goal.fromJson(Map<String, dynamic> json, {String? id}) => Goal(
        id: id ?? json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        targetCents: (json['targetCents'] as num?)?.toInt() ?? 0,
        savedCents: (json['savedCents'] as num?)?.toInt() ?? 0,
        deadline: json['deadline'] as String?,
        emoji: json['emoji'] as String? ?? '🎯',
        completedAt: json['completedAt'] != null
            ? DateTime.tryParse('${json['completedAt']}')
            : null,
        createdAt: json['createdAt'] != null
            ? (json['createdAt'] is DateTime
                ? json['createdAt'] as DateTime
                : DateTime.tryParse('${json['createdAt']}') ?? DateTime.now())
            : DateTime.now(),
      );
}
