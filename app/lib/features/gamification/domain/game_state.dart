import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_state.freezed.dart';
part 'game_state.g.dart';

@freezed
class StreakInfo with _$StreakInfo {
  const factory StreakInfo({
    @Default(0) int current,
    @Default(0) int best,
    String? lastActiveDay,
    @Default(2) int freezes,
  }) = _StreakInfo;

  factory StreakInfo.fromJson(Map<String, dynamic> json) =>
      _$StreakInfoFromJson(json);
}

@freezed
class GameState with _$GameState {
  const factory GameState({
    @Default(0) int xp,
    @Default(1) int level,
    @Default(0) int gems,
    required StreakInfo streak,
    @Default('bronze') String leagueId,
    @Default(0) int weeklyXp,
    @Default([]) List<String> badges,
  }) = _GameState;

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);
}
