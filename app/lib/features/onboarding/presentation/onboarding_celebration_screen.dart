import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/app/theme/app_text_styles.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';

class OnboardingCelebrationScreen extends StatelessWidget {
  const OnboardingCelebrationScreen({super.key});

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
                child: Text('🎉', style: TextStyle(fontSize: 72)),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Ton nid est prêt !',
                textAlign: TextAlign.center,
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Tu as débloqué le badge Bâtisseur et +50 XP !',
                textAlign: TextAlign.center,
                style:
                    AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(50),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('⭐', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text('+50 XP', style: AppTextStyles.h3),
                  ],
                ),
              ),
              const Spacer(),
              SiphoButton3D(
                text: 'CONTINUER',
                onPressed: () => context.go('/onboarding/notifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
