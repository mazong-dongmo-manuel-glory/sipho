import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/sipho_button_3d.dart';

class LessonDoneScreen extends StatelessWidget {
  const LessonDoneScreen({super.key});

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
              const Center(child: Text('🎓', style: TextStyle(fontSize: 72))),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Leçon terminée !',
                textAlign: TextAlign.center,
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statItem('XP gagnés', '+20 XP', AppColors.accent),
                  _statItem('Précision', '100 %', AppColors.success),
                  _statItem('Temps', '1:45', AppColors.info),
                ],
              ),
              const Spacer(),
              SiphoButton3D(
                text: 'CONTINUER',
                onPressed: () => context.go('/learn'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h2.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSm),
      ],
    );
  }
}

