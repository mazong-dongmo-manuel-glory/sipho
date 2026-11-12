import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Apprendre')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.cardRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('UNITÉ 1', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text(
                    'Les bases du budget & Reste à Vivre',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Column(
                children: [
                  _buildNode(context, '1', 'Les bases', true, isCurrent: true),
                  _buildConnector(),
                  _buildNode(context, '2', 'Le socle', false),
                  _buildConnector(),
                  _buildNode(context, '3', 'Dépenses variables', false),
                  _buildConnector(),
                  _buildNode(context, '⭐', 'Quiz de validation', false, isMilestone: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNode(BuildContext context, String label, String title, bool unlocked,
      {bool isCurrent = false, bool isMilestone = false}) {
    return Column(
      children: [
        GestureDetector(
          onTap: unlocked ? () => context.push('/learn/quiz') : null,
          child: Container(
            width: isMilestone ? 72 : 64,
            height: isMilestone ? 72 : 64,
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.primary
                  : unlocked
                      ? AppColors.accent
                      : AppColors.border,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isCurrent ? AppColors.primaryDark : Colors.black).withAlpha(30),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: unlocked || isCurrent ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(title, style: AppTextStyles.labelSm),
      ],
    );
  }

  Widget _buildConnector() {
    return Container(
      width: 4,
      height: 28,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: AppColors.border,
    );
  }
}

