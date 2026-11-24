import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../data/auth_repository.dart';
import '../data/user_profile_provider.dart';
import '../data/user_repository.dart';

/// Frame 02 · Bienvenue — Google / Apple.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _busy = false;

  Future<void> _afterAuth() async {
    final auth = ref.read(authRepositoryProvider);
    final uid = auth.currentUser?.uid;
    if (uid == null) return;
    final profile = await ref.read(userRepositoryProvider).getProfile(uid);
    if (!mounted) return;
    if (profile?.onboardingDone == true) {
      ref.read(userProfileProvider.notifier).updateProfile(
            displayName: profile!.displayName,
            countryCode: profile.countryCode,
            currency: profile.currency,
            monthlyIncomeCents: profile.monthlyIncomeCents,
            onboardingDone: true,
          );
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  String _messageFor(FirebaseAuthException e, AppLocalizations l10n) {
    return switch (e.code) {
      'operation-not-allowed' || 'admin-restricted-operation' =>
        l10n.authErrorAppleDisabled,
      'invalid-credential' || 'invalid-app-credential' =>
        l10n.authErrorInvalidCredential,
      'network-request-failed' => l10n.authErrorNetwork,
      'canceled' || 'aborted' || 'web-context-canceled' =>
        l10n.authErrorGeneric,
      _ => l10n.authErrorGeneric,
    };
  }

  Future<void> _run(Future<UserCredential> Function() signIn) async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    try {
      await signIn();
      await _afterAuth();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      debugPrint('Auth failed [${e.code}]: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_messageFor(e, l10n)),
          backgroundColor: SiphoColors.primaryDark,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('Auth failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authErrorGeneric),
          backgroundColor: SiphoColors.primaryDark,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.read(authRepositoryProvider);

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.welcomeTitle,
                style: SiphoTypography.title.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: SiphoPalette.textPrimary(context),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.welcomeSubtitle,
                style: SiphoTypography.body.copyWith(
                  color: SiphoPalette.textSecondary(context),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 112,
                height: 112,
                child: SvgPicture.asset(
                  'assets/images/sipho_waving.svg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              SiphoSoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.loginExpertTitle,
                      style: SiphoTypography.bodyBold.copyWith(
                        color: SiphoPalette.textPrimary(context),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.loginExpertBody,
                      style: SiphoTypography.body.copyWith(
                        color: SiphoPalette.textPrimary(context),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SiphoButton3D(
                label: l10n.signInWithApple,
                variant: SiphoButtonVariant.outline,
                icon: Icon(Icons.apple, color: SiphoPalette.textPrimary(context), size: 22),
                onPressed: _busy ? null : () => _run(auth.signInWithApple),
              ),
              const SizedBox(height: 10),
              SiphoButton3D(
                label: l10n.signInWithGoogle,
                variant: SiphoButtonVariant.outline,
                icon: Icon(Icons.g_mobiledata, color: SiphoPalette.textPrimary(context), size: 26),
                onPressed: _busy ? null : () => _run(auth.signInWithGoogle),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.welcomeLegal,
                style: SiphoTypography.label.copyWith(
                  fontSize: 12,
                  color: SiphoPalette.textSecondary(context),
                  height: 1.3,
                ),
              ),
              const Spacer(),
              SiphoButton3D(
                label: _busy ? '…' : l10n.loginCreateAccount,
                variant: SiphoButtonVariant.dark,
                onPressed: _busy ? null : () => _run(auth.signInWithGoogle),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => _run(auth.signInAnonymously),
                  child: Text(
                    'Continuer sans compte (debug)',
                    style: SiphoTypography.bodyBold.copyWith(
                      color: SiphoPalette.textSecondary(context),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
