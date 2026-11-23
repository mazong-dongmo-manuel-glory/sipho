import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';

/// Frame 01 · Démarrage · Épuré (Figma 2:28911).
/// Style épuré : fond #FCFCF9, vert profond #14342B, typo Nunito Black 40, ExtraBold 32, Regular 16.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCF9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo "sipho" en haut à gauche
              Text(
                'sipho',
                style: SiphoTypography.amountHero.copyWith(
                  color: SiphoColors.primaryDark,
                  fontSize: 40,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 24),

              // Mascotte Sipho Content
              SizedBox(
                width: 136,
                height: 136,
                child: SvgPicture.asset(
                  'assets/images/sipho_happy.svg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),

              // Titre "Fais-toi un cadeau : ton avenir."
              Text(
                'Fais-toi un cadeau :\nton avenir.',
                style: SiphoTypography.title.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: SiphoColors.primaryDark,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),

              // Sous-titre
              Text(
                'L’argent qui grandit.\nUne bonne habitude à la fois.',
                style: SiphoTypography.body.copyWith(
                  color: SiphoColors.textSecondary,
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),

              // Prononciation & signification
              Text(
                'SI-PO · « CADEAU » EN ZOULOU',
                style: SiphoTypography.label.copyWith(
                  fontWeight: FontWeight.w800,
                  color: SiphoColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),

              const Spacer(),

              // Bouton 3D "Faire le premier pas"
              SiphoButton3D(
                label: 'Faire le premier pas',
                variant: SiphoButtonVariant.primary,
                onPressed: () => context.go('/login'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
