class GameState {
  final int xp;
  final int level;
  final int seeds;
  final int streakDays;
  final int freezes;
  final String leagueId;
  final List<String> badges;
  final List<String> ownedItems;
  final List<String> equippedItems;

  const GameState({
    this.xp = 0,
    this.level = 1,
    this.seeds = 50,
    this.streakDays = 1,
    this.freezes = 0,
    this.leagueId = 'bronze',
    this.badges = const [],
    this.ownedItems = const [],
    this.equippedItems = const [],
  });

  GameState copyWith({
    int? xp,
    int? level,
    int? seeds,
    int? streakDays,
    int? freezes,
    String? leagueId,
    List<String>? badges,
    List<String>? ownedItems,
    List<String>? equippedItems,
  }) {
    return GameState(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      seeds: seeds ?? this.seeds,
      streakDays: streakDays ?? this.streakDays,
      freezes: freezes ?? this.freezes,
      leagueId: leagueId ?? this.leagueId,
      badges: badges ?? this.badges,
      ownedItems: ownedItems ?? this.ownedItems,
      equippedItems: equippedItems ?? this.equippedItems,
    );
  }
}
