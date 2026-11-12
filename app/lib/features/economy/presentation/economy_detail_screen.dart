import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';

class EconomyDetailScreen extends StatelessWidget {
  const EconomyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Économie & Toi')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.cardRadius,
                border: Border.all(color: AppColors.accent, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📈 Inflation alimentaire : 3,4 %', style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Ce que ça change pour toi :',
                    style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.terracotta),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pour un budget épicerie moyen de 400 \$, cela représente environ 11 \$ à 14 \$ d\'augmentation par mois. Sipho te conseille d\'optimiser tes menus de la semaine pour compenser !',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Source : Statistique Canada · Date : Nov. 2026',
                    style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

