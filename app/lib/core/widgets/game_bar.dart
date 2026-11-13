import 'package:flutter/material.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_text_styles.dart';

/// Top game bar showing streak flame, seeds (currency), and XP level.
class GameBar extends StatelessWidget implements PreferredSizeWidget {
  const GameBar({
    super.key,
    required this.streakDays,
    int? seeds,
    int? gems,
    required this.level,
  }) : seeds = seeds ?? gems ?? 0;

  final int streakDays;
  final int seeds;
  final int level;

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _GameStat(
            icon: Icons.local_fire_department,
            iconColor: AppColors.flameStart,
            value: '$streakDays',
          ),
          _GameStat(
            icon: Icons.spa_outlined,
            iconColor: AppColors.primary,
            value: '$seeds',
          ),
          _GameStat(
            icon: Icons.bolt,
            iconColor: AppColors.accent,
            value: 'Lv $level',
          ),
        ],
      ),
    );
  }
}

class _GameStat extends StatelessWidget {
  const _GameStat({
    required this.icon,
    required this.iconColor,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 4),
        Text(value, style: AppTextStyles.labelLarge),
      ],
    );
  }
}
