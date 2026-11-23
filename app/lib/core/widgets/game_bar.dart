import 'package:flutter/material.dart';
import '../theme/sipho_colors.dart';
import '../theme/sipho_typography.dart';

/// Barre de statut de jeu affichée en haut de l'écran (FIGMA.md §42) :
/// - Flamme de série (🔥)
/// - Graines d'or (🌾)
/// - Niveau du joueur (⚡)
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
    required Widget icon,
    required String value,
    required VoidCallback? onTap,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor ?? SiphoColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: borderColor ?? SiphoColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 5),
            Text(
              value,
              style: SiphoTypography.label.copyWith(
                fontWeight: FontWeight.w800,
                color: SiphoColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Flamme de série
          _buildPill(
            icon: const Text('🔥', style: TextStyle(fontSize: 16)),
            value: '$streakDays',
            onTap: onStreakTap,
          ),
          // Graines d'or
          _buildPill(
            icon: const Text('🌾', style: TextStyle(fontSize: 16)),
            value: '$seeds',
            onTap: onSeedsTap,
          ),
          // Niveau
          _buildPill(
            icon: const Text('⚡', style: TextStyle(fontSize: 16)),
            value: 'Niv. $level',
            onTap: onLevelTap,
          ),
        ],
      ),
    );
  }
}
