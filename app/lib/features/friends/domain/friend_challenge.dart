/// Category of a 1v1 challenge.
enum ChallengeCategory {
  learning,
  budget,
  saving,
}

extension ChallengeCategoryExtension on ChallengeCategory {
  String get key {
    switch (this) {
      case ChallengeCategory.learning:
        return 'learning';
      case ChallengeCategory.budget:
        return 'budget';
      case ChallengeCategory.saving:
        return 'saving';
    }
  }

  static ChallengeCategory fromKey(String? key) {
    switch (key) {
      case 'learning':
        return ChallengeCategory.learning;
      case 'saving':
        return ChallengeCategory.saving;
      case 'budget':
      default:
        return ChallengeCategory.budget;
    }
  }

  String get emoji {
    switch (this) {
      case ChallengeCategory.learning:
        return '📚';
      case ChallengeCategory.budget:
        return '🛡️';
      case ChallengeCategory.saving:
        return '💰';
    }
  }
}

/// Status of a 1v1 challenge.
enum ChallengeStatus {
  pending,
  active,
  completed,
  declined,
}

extension ChallengeStatusExtension on ChallengeStatus {
  String get key {
    switch (this) {
      case ChallengeStatus.pending:
        return 'pending';
      case ChallengeStatus.active:
        return 'active';
      case ChallengeStatus.completed:
        return 'completed';
      case ChallengeStatus.declined:
        return 'declined';
    }
  }

  static ChallengeStatus fromKey(String? key) {
    switch (key) {
      case 'active':
        return ChallengeStatus.active;
      case 'completed':
        return ChallengeStatus.completed;
      case 'declined':
        return ChallengeStatus.declined;
      case 'pending':
      default:
        return ChallengeStatus.pending;
    }
  }
}

/// A 1v1 challenge between two friends.
class FriendChallenge {
  const FriendChallenge({
    required this.id,
    required this.pairId,
    required this.senderUid,
    required this.receiverUid,
    required this.senderName,
    required this.receiverName,
    required this.title,
    required this.description,
    required this.category,
    required this.targetCount,
    this.senderProgress = 0,
    this.receiverProgress = 0,
    required this.rewardXp,
    required this.status,
    this.winnerUid,
    this.templateId,
    required this.createdAt,
    required this.expiresAt,
  });

  factory FriendChallenge.fromMap(String id, Map<String, dynamic> data) {
    return FriendChallenge(
      id: id,
      pairId: (data['pairId'] as String?) ?? '',
      senderUid: (data['senderUid'] as String?) ?? '',
      receiverUid: (data['receiverUid'] as String?) ?? '',
      senderName: (data['senderName'] as String?) ?? 'Ami',
      receiverName: (data['receiverName'] as String?) ?? 'Ami',
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      category: ChallengeCategoryExtension.fromKey(data['category'] as String?),
      targetCount: (data['targetCount'] as num?)?.toInt() ?? 1,
      senderProgress: (data['senderProgress'] as num?)?.toInt() ?? 0,
      receiverProgress: (data['receiverProgress'] as num?)?.toInt() ?? 0,
      rewardXp: (data['rewardXp'] as num?)?.toInt() ?? 30,
      status: ChallengeStatusExtension.fromKey(data['status'] as String?),
      winnerUid: data['winnerUid'] as String?,
      templateId: data['templateId'] as String?,
      createdAt: _readDate(data['createdAt']) ?? DateTime.now(),
      expiresAt: _readDate(data['expiresAt']) ??
          DateTime.now().add(const Duration(days: 7)),
    );
  }

  static DateTime? _readDate(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    // cloud_firestore Timestamp (duck-typed to avoid a hard Firestore import here)
    if (value != null) {
      try {
        final dynamic dyn = value;
        if (dyn.toDate is Function) {
          return dyn.toDate() as DateTime;
        }
      } catch (_) {}
    }
    return null;
  }

  final String id;
  final String pairId;
  final String senderUid;
  final String receiverUid;
  final String senderName;
  final String receiverName;
  final String title;
  final String description;
  final ChallengeCategory category;
  final int targetCount;
  final int senderProgress;
  final int receiverProgress;
  final int rewardXp;
  final ChallengeStatus status;
  final String? winnerUid;

  /// Server template id (`marathon_savoir`, …). Null on legacy client-written docs.
  final String? templateId;
  final DateTime createdAt;
  final DateTime expiresAt;

  bool isSender(String myUid) => senderUid == myUid;

  int myProgress(String myUid) =>
      isSender(myUid) ? senderProgress : receiverProgress;

  int otherProgress(String myUid) =>
      isSender(myUid) ? receiverProgress : senderProgress;

  String otherName(String myUid) =>
      isSender(myUid) ? receiverName : senderName;

  double myFraction(String myUid) =>
      targetCount <= 0 ? 0.0 : (myProgress(myUid) / targetCount).clamp(0.0, 1.0);

  double otherFraction(String myUid) => targetCount <= 0
      ? 0.0
      : (otherProgress(myUid) / targetCount).clamp(0.0, 1.0);

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isCompleted =>
      status == ChallengeStatus.completed ||
      senderProgress >= targetCount ||
      receiverProgress >= targetCount;

  Map<String, dynamic> toMap() => {
        'pairId': pairId,
        'senderUid': senderUid,
        'receiverUid': receiverUid,
        'senderName': senderName,
        'receiverName': receiverName,
        'title': title,
        'description': description,
        'category': category.key,
        'targetCount': targetCount,
        'senderProgress': senderProgress,
        'receiverProgress': receiverProgress,
        'rewardXp': rewardXp,
        'status': status.key,
        if (winnerUid != null) 'winnerUid': winnerUid,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      };

  FriendChallenge copyWith({
    String? id,
    String? pairId,
    String? senderUid,
    String? receiverUid,
    String? senderName,
    String? receiverName,
    String? title,
    String? description,
    ChallengeCategory? category,
    int? targetCount,
    int? senderProgress,
    int? receiverProgress,
    int? rewardXp,
    ChallengeStatus? status,
    String? winnerUid,
    String? templateId,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return FriendChallenge(
      id: id ?? this.id,
      pairId: pairId ?? this.pairId,
      senderUid: senderUid ?? this.senderUid,
      receiverUid: receiverUid ?? this.receiverUid,
      senderName: senderName ?? this.senderName,
      receiverName: receiverName ?? this.receiverName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetCount: targetCount ?? this.targetCount,
      senderProgress: senderProgress ?? this.senderProgress,
      receiverProgress: receiverProgress ?? this.receiverProgress,
      rewardXp: rewardXp ?? this.rewardXp,
      status: status ?? this.status,
      winnerUid: winnerUid ?? this.winnerUid,
      templateId: templateId ?? this.templateId,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

/// Display catalog — ids and rewards must match `FRIEND_CHALLENGE_TEMPLATES`
/// on the server. The client never invents XP or targets at create time.
class PredefinedChallengeTemplate {
  const PredefinedChallengeTemplate({
    required this.id,
    required this.titleFr,
    required this.titleEn,
    required this.descriptionFr,
    required this.descriptionEn,
    required this.category,
    required this.targetCount,
    required this.rewardXp,
    required this.durationDays,
  });

  final String id;
  final String titleFr;
  final String titleEn;
  final String descriptionFr;
  final String descriptionEn;
  final ChallengeCategory category;
  final int targetCount;
  final int rewardXp;
  final int durationDays;

  String title(String languageCode) =>
      languageCode.toLowerCase().startsWith('fr') ? titleFr : titleEn;

  String description(String languageCode) =>
      languageCode.toLowerCase().startsWith('fr')
          ? descriptionFr
          : descriptionEn;

  static const List<PredefinedChallengeTemplate> catalog = [
    PredefinedChallengeTemplate(
      id: 'marathon_savoir',
      titleFr: 'Marathon Savoir',
      titleEn: 'Knowledge Marathon',
      descriptionFr:
          'Termine 3 leçons financières cette semaine avant ton ami.',
      descriptionEn:
          'Finish 3 money lessons this week before your friend.',
      category: ChallengeCategory.learning,
      targetCount: 3,
      rewardXp: 50,
      durationDays: 7,
    ),
    PredefinedChallengeTemplate(
      id: 'zero_ecart',
      titleFr: '3 Jours Zéro Écart',
      titleEn: '3 Days On Budget',
      descriptionFr:
          '3 jours sans dépasser son budget de dépenses variables.',
      descriptionEn: 'Stay within your variable spending budget for 3 days.',
      category: ChallengeCategory.budget,
      targetCount: 3,
      rewardXp: 40,
      durationDays: 5,
    ),
    PredefinedChallengeTemplate(
      id: 'boost_epargne',
      titleFr: 'Boost Épargne',
      titleEn: 'Savings Boost',
      descriptionFr: 'Coche une dépense fixe payée (un pas vers ton nid).',
      descriptionEn: 'Mark one fixed expense as paid (a step toward your nest).',
      category: ChallengeCategory.saving,
      targetCount: 1,
      rewardXp: 30,
      durationDays: 3,
    ),
    PredefinedChallengeTemplate(
      id: 'semaine_champion',
      titleFr: 'Semaine Champion',
      titleEn: 'Champion Week',
      descriptionFr:
          'Enregistre tes dépenses ou une journée sans dépense, 5 jours.',
      descriptionEn:
          'Log spending or a no-spend day, five days in a row.',
      category: ChallengeCategory.budget,
      targetCount: 5,
      rewardXp: 75,
      durationDays: 7,
    ),
  ];
}
