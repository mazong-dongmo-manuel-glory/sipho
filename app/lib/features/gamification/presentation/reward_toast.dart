import 'package:flutter/material.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_text_styles.dart';

class RewardToast {
  static void show(BuildContext context, {required String message, int xp = 5}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const Text('⭐', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text('+$xp XP', style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.accent)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.body.copyWith(color: AppColors.cream),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

