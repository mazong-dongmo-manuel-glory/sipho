import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/animations/lottie_widget.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';

class NestReadyScreen extends StatelessWidget {
  const NestReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const LottieWidget(
                assetPath: 'assets/animations/confetti_celebration.json',
                width: 220,
                height: 72,
              ),
              Text(
                l10n.nestReadyKicker,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 270,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: -12 * math.pi / 180,
                      child: SvgPicture.asset(
                        'assets/images/sipho_dancing.svg',
                        width: 209.739,
                        height: 182.02,
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      child: SvgPicture.asset(
                        'assets/images/sipho_nest_wide.svg',
                        width: 247,
                        height: 72.9773,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                l10n.nestReadyTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                l10n.nestReadyXp,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  color: AppColors.seedPill,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏅', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      l10n.nestReadyBadge,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.seedText,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SiphoButton3D(
                label: l10n.continueBtn.toUpperCase(),
                onPressed: () => context.go('/onboarding/notifications'),
                color: AppColors.primary,
                shadowColor: AppColors.primaryDark,
                height: 52,
                borderRadius: figmaButtonRadius,
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
