class GameState {
  final int xp;
  final int level;
  final int seeds;
  final int streakDays;
  final List<String> badges;

  const GameState({
    this.xp = 0,
    this.level = 1,
    this.seeds = 50,
    this.streakDays = 1,
    this.badges = const [],
  });

  GameState copyWith({
    int? xp,
    int? level,
    int? seeds,
    int? streakDays,
    List<String>? badges,
  }) {
    return GameState(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      seeds: seeds ?? this.seeds,
      streakDays: streakDays ?? this.streakDays,
      badges: badges ?? this.badges,
    );
  }
}
