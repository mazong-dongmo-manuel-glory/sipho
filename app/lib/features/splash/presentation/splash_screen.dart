import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_repository.dart';

/// Frame 01 · Démarrage · Épuré (Figma `2:28911`).
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  Future<void> _enter(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(authRepositoryProvider);
    final user = auth.currentUser;
    if (user != null) {
      final profile = await ref.read(userRepositoryProvider).getProfile(user.uid);
      if (!context.mounted) return;
      if (profile?.onboardingDone == true) {
        context.go('/home');
        return;
      }
      if (profile != null) {
        context.go('/onboarding');
        return;
      }
    }
    if (!context.mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.welcomeWordmark,
                style: SiphoTypography.amountHero.copyWith(
                  color: SiphoPalette.textPrimary(context),
                  fontSize: 40,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 136,
                height: 136,
                child: SvgPicture.asset(
                  'assets/images/sipho_happy.svg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.splashTagline,
                style: SiphoTypography.title.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: SiphoPalette.textPrimary(context),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.splashLead,
                style: SiphoTypography.body.copyWith(
                  color: SiphoPalette.textSecondary(context),
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.splashKicker,
                style: SiphoTypography.label.copyWith(
                  fontWeight: FontWeight.w800,
                  color: SiphoPalette.textSecondary(context),
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              SiphoButton3D(
                label: l10n.splashCta,
                variant: SiphoButtonVariant.dark,
                onPressed: () => _enter(context, ref),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
