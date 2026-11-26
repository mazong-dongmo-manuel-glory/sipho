import 'package:flutter/material.dart';
import '../theme/sipho_palette.dart';
import '../theme/sipho_typography.dart';

/// Barre de statut de jeu affichée en haut de l'écran (FIGMA.md §42).
class GameBar extends StatelessWidget {
  final int streakDays;
  final int seeds;
  final int level;
  final VoidCallback? onStreakTap;
  final VoidCallback? onSeedsTap;
  final VoidCallback? onLevelTap;

  const GameBar({
    super.key,
    this.streakDays = 0,
    this.seeds = 0,
    this.level = 1,
    this.onStreakTap,
    this.onSeedsTap,
    this.onLevelTap,
  });

  Widget _buildPill({
    required BuildContext context,
    required Widget icon,
    required String value,
    required VoidCallback? onTap,
  }) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: SiphoPalette.surface(context),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: SiphoPalette.border(context),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SiphoTypography.label.copyWith(
                    fontWeight: FontWeight.w800,
                    color: SiphoPalette.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildPill(
            context: context,
            icon: const Text('🔥', style: TextStyle(fontSize: 16)),
            value: '$streakDays',
            onTap: onStreakTap,
          ),
          const SizedBox(width: 8),
          _buildPill(
            context: context,
            icon: const Text('🌾', style: TextStyle(fontSize: 16)),
            value: '$seeds',
            onTap: onSeedsTap,
          ),
          const SizedBox(width: 8),
          _buildPill(
            context: context,
            icon: const Text('⚡', style: TextStyle(fontSize: 16)),
            value: 'Niv. $level',
            onTap: onLevelTap,
          ),
        ],
      ),
    );
  }
}
