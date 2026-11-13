import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/app/theme/app_text_styles.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';

class StreakScreen extends StatelessWidget {
  final int streakDays;

  const StreakScreen({super.key, this.streakDays = 13});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(
                child: Text('🔥', style: TextStyle(fontSize: 80)),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '$streakDays',
                textAlign: TextAlign.center,
                style: AppTextStyles.displayXl.copyWith(color: AppColors.flameEnd),
              ),
              const Text(
                'jours de série !',
                textAlign: TextAlign.center,
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Chaque jour compte pour ton avenir.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              SiphoButton3D(
                text: 'CONTINUER',
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

