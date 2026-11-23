import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';

/// Frame Figma 06 · Première victoire · Épuré (`2:28925`).
class NestReadyScreen extends StatelessWidget {
  const NestReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.nestReadyTitle,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.nestReadyLead,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              const SiphoArt.celebrating(frame: 154),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.soft,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.nestReadyXpCardTitle,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.nestReadyXpCardBody,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.nestReadyBadgeRow,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const Text(
                    '✓',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                l10n.nestReadyDisclaimer,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              SiphoButton3D(
                label: l10n.nestReadyCta,
                onPressed: () => context.go('/onboarding/notifications'),
                color: AppColors.primaryDark,
                shadowColor: AppColors.primaryDark,
                height: 52,
                borderRadius: figmaButtonRadius,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
