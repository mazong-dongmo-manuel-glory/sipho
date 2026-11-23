import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/game_state.dart';

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier()
      : super(
          const GameState(
            xp: 750,
            level: 7,
            seeds: 340,
            streakDays: 12,
            badges: ['Bâtisseur', 'Flamme 7j', 'Savant'],
          ),
        );

  void addXp(int amount) {
    final newXp = state.xp + amount;
    // Niveau calculé (chaque niveau nécessite 150 XP supplémentaires)
    final newLevel = (newXp / 150).floor() + 1;
    state = state.copyWith(xp: newXp, level: newLevel);
  }

  void addSeeds(int amount) {
    state = state.copyWith(seeds: state.seeds + amount);
  }

  void addBadge(String badge) {
    if (!state.badges.contains(badge)) {
      state = state.copyWith(badges: [...state.badges, badge]);
    }
  }
}

final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});
