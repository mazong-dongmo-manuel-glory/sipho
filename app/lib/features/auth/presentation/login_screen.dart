import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_text_styles.dart';
import 'package:sipho/core/legal/sipho_legal.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:url_launcher/url_launcher.dart';

/// User-facing auth error (avoids dumping full exception stacks on login).
String authErrorMessage(Object? error, AppLocalizations l10n) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'operation-not-allowed':
        return l10n.authErrorAppleDisabled;
      case 'invalid-credential':
      case 'invalid-id-token':
        return l10n.authErrorInvalidCredential;
      case 'network-request-failed':
        return l10n.authErrorNetwork;
      default:
        return l10n.authErrorGeneric;
    }
  }
  return l10n.authErrorGeneric;
}

/// Apple Sign-In on iOS/macOS (native) and Android (Firebase OAuth / Custom Tabs).
/// Android needs Firebase Auth Apple **OAuth code flow** — see ENVIRONMENTS.md.
bool get kShowAppleSignInButton =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.android);

const _buttonRadius = BorderRadius.all(Radius.circular(16));

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading || _isAppleLoading) return;
    setState(() => _isGoogleLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    if (_isGoogleLoading || _isAppleLoading) return;
    setState(() => _isAppleLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).signInWithApple();
      if (!mounted) return;
      // Router redirect normally takes over; nudge if we're still on /login.
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) return;
      final done = ref.read(onboardingGateProvider);
      if (done == true) {
        context.go('/home');
      } else if (done == false) {
        context.go('/onboarding');
      }
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final l10n = AppLocalizations.of(context);
    final isBusy = _isGoogleLoading || _isAppleLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre — maquette 02 · Bienvenue
                        Text(
                          l10n.welcomeTitle,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Accroche
                        Text(
                          l10n.welcomeSubtitle,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Sipho qui salue
                        const SiphoArt.waving(frame: 112),
                        const SizedBox(height: 20),
                        // Carte info douce — "Pas besoin d'être expert."
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
                                l10n.loginExpertTitle,
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
                                l10n.loginExpertBody,
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
                        // Erreur éventuelle
                        if (authState.hasError)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              authErrorMessage(authState.error, l10n),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.danger,
                              ),
                            ),
                          ),
                        // Bouton secondaire Apple (blanc/bordure)
                        if (kShowAppleSignInButton) ...[
                          SiphoButton3D(
                            label: l10n.signInWithApple,
                            onPressed: isBusy ? null : _handleAppleSignIn,
                            isLoading: _isAppleLoading,
                            color: AppColors.surface,
                            shadowColor: AppColors.border,
                            textColor: AppColors.primaryDark,
                            height: 52,
                            borderRadius: _buttonRadius,
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Bouton secondaire Google (blanc/bordure)
                        SiphoButton3D(
                          label: l10n.signInWithGoogle,
                          onPressed: isBusy ? null : _handleGoogleSignIn,
                          isLoading: _isGoogleLoading,
                          color: AppColors.surface,
                          shadowColor: AppColors.border,
                          textColor: AppColors.primaryDark,
                          height: 52,
                          borderRadius: _buttonRadius,
                        ),
                        const SizedBox(height: 20),
                        // Mention légale
                        GestureDetector(
                          onTap: () {
                            launchUrl(
                              Uri.parse(kSiphoPrivacyPolicyUrl),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          child: Text(
                            l10n.welcomeLegal,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Bouton primaire principal — "Créer mon compte"
                        SiphoButton3D(
                          label: l10n.loginCreateAccount,
                          onPressed: isBusy ? null : _handleGoogleSignIn,
                          isLoading: _isGoogleLoading,
                          color: AppColors.primaryDark,
                          shadowColor: AppColors.primaryDark,
                          textColor: Colors.white,
                          height: 52,
                          borderRadius: _buttonRadius,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

