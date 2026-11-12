import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/sipho_bubble.dart';
import '../../../core/widgets/sipho_button_3d.dart';

class NotificationPrimingScreen extends StatelessWidget {
  const NotificationPrimingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            children: [
              const Spacer(),
              const Center(
                child: Text('🔔', style: TextStyle(fontSize: 64)),
              ),
              const SizedBox(height: AppSpacing.md),
              const SiphoBubble(
                text: 'Je peux te rappeler de garder ta flamme ? 🔥\nPromis : maximum 2 rappels par jour, et jamais la nuit !',
              ),
              const Spacer(),
              SiphoButton3D(
                text: 'OUI, RAPPELLE-MOI',
                onPressed: () {
                  // Request system permission, then go to home
                  context.go('/home');
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text(
                  'Plus tard',
                  style: AppTextStyles.bodySemiBold.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

