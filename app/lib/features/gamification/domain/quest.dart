class Quest {
  const Quest({
    required this.id,
    required this.templateId,
    required this.type,
    required this.progress,
    required this.target,
    required this.rewardXp,
    this.rewardChest,
    this.expiresAt,
    this.status = 'active',
  });

  final String id;
  final String templateId;
  final String type; // daily | weekly | monthly
  final int progress;
  final int target;
  final int rewardXp;
  final String? rewardChest;
  final DateTime? expiresAt;
  final String status; // active | completed | claimed

  factory Quest.fromJson(Map<String, dynamic> json) => Quest(
        id: json['id'] as String? ?? '',
        templateId: json['templateId'] as String? ?? '',
        type: json['type'] as String? ?? 'daily',
        progress: (json['progress'] as num?)?.toInt() ?? 0,
        target: (json['target'] as num?)?.toInt() ?? 1,
        rewardXp: (json['rewardXp'] as num?)?.toInt() ?? 0,
        rewardChest: json['rewardChest'] as String?,
        status: json['status'] as String? ?? 'active',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'templateId': templateId,
        'type': type,
        'progress': progress,
        'target': target,
        'rewardXp': rewardXp,
        'rewardChest': rewardChest,
        'status': status,
      };
}
