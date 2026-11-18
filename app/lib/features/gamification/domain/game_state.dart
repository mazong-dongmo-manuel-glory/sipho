class StreakInfo {
  const StreakInfo({
    this.current = 0,
    this.best = 0,
    this.lastActiveDay,
    this.freezes = 2,
    this.brokenAt,
    this.brokenCurrent = 0,
  });

  final int current;
  final int best;
  final String? lastActiveDay;
  final int freezes;
  final String? brokenAt;
  final int brokenCurrent;

  factory StreakInfo.fromJson(Map<String, dynamic> json) => StreakInfo(
        current: (json['current'] as num?)?.toInt() ?? 0,
        best: (json['best'] as num?)?.toInt() ?? 0,
        lastActiveDay: json['lastActiveDay'] as String?,
        freezes: (json['freezes'] as num?)?.toInt() ?? 2,
        brokenAt: json['brokenAt'] as String?,
        brokenCurrent: (json['brokenCurrent'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'current': current,
        'best': best,
        'lastActiveDay': lastActiveDay,
        'freezes': freezes,
        'brokenAt': brokenAt,
        'brokenCurrent': brokenCurrent,
      };
}

class GameState {
  const GameState({
    this.xp = 0,
    this.level = 1,
    this.gems = 0,
    required this.streak,
    this.leagueId = 'bronze',
    this.weeklyXp = 0,
    this.badges = const [],
  });

  final int xp;
  final int level;
  final int gems;
  final StreakInfo streak;
  final String leagueId;
  final int weeklyXp;
  final List<String> badges;

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        level: (json['level'] as num?)?.toInt() ?? 1,
        gems: (json['gems'] as num?)?.toInt() ?? 0,
        streak: json['streak'] is Map<String, dynamic>
            ? StreakInfo.fromJson(json['streak'] as Map<String, dynamic>)
            : const StreakInfo(),
        leagueId: (json['leagueId'] as String?) ?? 'bronze',
        weeklyXp: (json['weeklyXp'] as num?)?.toInt() ?? 0,
        badges: (json['badges'] as List?)?.map((b) => b.toString()).toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'xp': xp,
        'level': level,
        'gems': gems,
        'streak': streak.toJson(),
        'leagueId': leagueId,
        'weeklyXp': weeklyXp,
        'badges': badges,
      };
}
