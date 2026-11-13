import 'package:flutter/material.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_radius.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/app/theme/app_text_styles.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Classement — Ligue Or 🏆'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.cardRadius,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Text('⏱️', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'La ligue se termine dans 2j 5h',
                    style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.primaryDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildRow('1', 'Koffi_225', '620 XP', '🥇', false),
            _buildRow('2', 'Marc_MTL', '580 XP', '🥈', false),
            _buildRow('3', 'Chloe_PAR', '510 XP', '🥉', false),
            _buildRow('8', 'Amina (Toi)', '420 XP', '🐤', true),
            _buildRow('29', 'Sam_97', '110 XP', '🔻', false, isRelegation: true),
            _buildRow('30', 'Alex_01', '80 XP', '🔻', false, isRelegation: true),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String rank, String pseudo, String xp, String icon, bool isSelf,
      {bool isRelegation = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
      decoration: BoxDecoration(
        color: isSelf
            ? AppColors.primary.withAlpha(25)
            : isRelegation
                ? AppColors.danger.withAlpha(15)
                : AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: isSelf ? AppColors.primary : AppColors.border,
          width: isSelf ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              rank,
              style: AppTextStyles.bodySemiBold.copyWith(
                color: isSelf ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              pseudo,
              style: AppTextStyles.bodySemiBold.copyWith(
                fontWeight: isSelf ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          Text(
            xp,
            style: AppTextStyles.bodySemiBold.copyWith(
              color: isSelf ? AppColors.primaryDark : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

