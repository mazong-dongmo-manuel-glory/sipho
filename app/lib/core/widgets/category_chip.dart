import 'package:flutter/material.dart';
import '../theme/sipho_colors.dart';
import '../theme/sipho_palette.dart';
import '../theme/sipho_typography.dart';

/// Pastille d'icône pour les catégories de dépenses (FIGMA.md §44).
class CategoryChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.emoji,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? SiphoPalette.selectedChip(context)
              : SiphoPalette.surface(context),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? SiphoColors.primary : SiphoPalette.border(context),
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              label,
              style: SiphoTypography.label.copyWith(
                color: isSelected
                    ? SiphoColors.primary
                    : SiphoPalette.textPrimary(context),
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
