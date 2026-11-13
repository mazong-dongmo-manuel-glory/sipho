import 'package:flutter/material.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_radius.dart';
import 'package:sipho/app/theme/app_text_styles.dart';

/// Duolingo-style speech bubble with Sipho's avatar.
class SiphoBubble extends StatelessWidget {
  const SiphoBubble({
    super.key,
    String? message,
    String? text,
    this.avatarAsset = 'assets/images/sipho_avatar.png',
    this.animated = false,
  }) : message = message ?? text ?? '';

  final String message;
  final String avatarAsset;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Avatar
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Image.asset(
            avatarAsset,
            width: 40,
            height: 40,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.emoji_nature_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Bubble
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.md),
                topRight: Radius.circular(AppRadius.md),
                bottomRight: Radius.circular(AppRadius.md),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(message, style: AppTextStyles.bodyMedium),
          ),
        ),
      ],
    );
  }
}
