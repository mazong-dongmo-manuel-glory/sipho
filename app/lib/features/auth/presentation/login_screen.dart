import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';

/// Frame 02 · Bienvenue · Épuré (Figma 2:28913).
/// Fond #FCFCF9, carte surface douce #F0F4EF, boutons Apple, Google et Créer mon compte.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
              // Titre "Ton futur toi te dit merci."
              Text(
                'Ton futur toi\nte dit merci.',
                style: SiphoTypography.title.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: SiphoColors.primaryDark,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),

              // Sous-titre
              Text(
                'Deux minutes pour poser les premières bases.',
                style: SiphoTypography.body.copyWith(
                  color: SiphoColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              // Mascotte Sipho / Salue
              SizedBox(
                width: 112,
                height: 112,
                child: SvgPicture.asset(
                  'assets/images/sipho_waving.svg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),

              // Carte douce "Pas besoin d'être expert."
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4EF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pas besoin d’être expert.',
                      style: SiphoTypography.bodyBold.copyWith(
                        color: SiphoColors.primaryDark,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'On apprend à comprendre son argent, à son rythme. Sans jugement.',
                      style: SiphoTypography.body.copyWith(
                        color: SiphoColors.primaryDark,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Continuer avec Apple (secondaire / relief doux)
              SiphoButton3D(
                label: 'Continuer avec Apple',
                variant: SiphoButtonVariant.outline,
                icon: const Icon(Icons.apple, color: SiphoColors.primaryDark, size: 22),
                onPressed: () => context.go('/onboarding'),
              ),
              const SizedBox(height: 10),

              // Continuer avec Google (secondaire / relief doux)
              SiphoButton3D(
                label: 'Continuer avec Google',
                variant: SiphoButtonVariant.outline,
                icon: const Icon(Icons.g_mobiledata, color: SiphoColors.primaryDark, size: 26),
                onPressed: () => context.go('/onboarding'),
              ),
              const SizedBox(height: 14),

              // Mentions
              Text(
                'En continuant, tu acceptes nos conditions et notre politique de confidentialité.',
                style: SiphoTypography.label.copyWith(
                  fontSize: 12,
                  color: SiphoColors.textSecondary,
                  height: 1.3,
                ),
              ),

              const Spacer(),

              // Bouton Créer mon compte (primaire vert foncé)
              SiphoButton3D(
                label: 'Créer mon compte',
                variant: SiphoButtonVariant.primary,
                onPressed: () => context.go('/onboarding'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
