import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                    ),
                    child: const Center(
                      child: Text('🐤', style: TextStyle(fontSize: 48)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Amina', style: AppTextStyles.h2),
                  Text(
                    'Membre depuis nov. 2026',
                    style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                _statCard('Série', '12 🔥'),
                const SizedBox(width: AppSpacing.sm),
                _statCard('Total XP', '1 450 ⭐'),
                const SizedBox(width: AppSpacing.sm),
                _statCard('Ligue', 'Or 🏆'),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Text('🛍️', style: TextStyle(fontSize: 24)),
              title: const Text('Boutique de Sipho', style: AppTextStyles.bodySemiBold),
              subtitle: const Text('Accessoires, thèmes et gels de série'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              tileColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.cardRadius,
                side: const BorderSide(color: AppColors.border),
              ),
              onTap: () => context.push('/profile/shop'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.bodySemiBold),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.labelSm),
          ],
        ),
      ),
    );
  }
}

