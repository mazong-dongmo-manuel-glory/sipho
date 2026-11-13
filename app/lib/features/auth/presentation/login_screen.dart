import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/app/theme/app_text_styles.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';

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
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final l10n = AppLocalizations.of(context);
    final isBusy = _isGoogleLoading || _isAppleLoading;

    final isApplePlatform = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo / mascot placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_nature_rounded,
                  size: 72,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('Sipho', style: AppTextStyles.displayLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.tagline,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              if (authState.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    authState.error.toString(),
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.danger),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (isApplePlatform) ...[
                SiphoButton3D(
                  label: l10n.signInWithApple,
                  onPressed: isBusy ? null : _handleAppleSignIn,
                  isLoading: _isAppleLoading,
                  color: Colors.black,
                  textColor: Colors.white,
                  icon: const Icon(Icons.apple, color: Colors.white, size: 24),
                ),
                const SizedBox(height: AppSpacing.md),
                SiphoButton3D(
                  label: l10n.signInWithGoogle,
                  onPressed: isBusy ? null : _handleGoogleSignIn,
                  isLoading: _isGoogleLoading,
                  color: AppColors.primary,
                  textColor: Colors.white,
                  icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 28),
                ),
              ] else ...[
                SiphoButton3D(
                  label: l10n.signInWithGoogle,
                  onPressed: isBusy ? null : _handleGoogleSignIn,
                  isLoading: _isGoogleLoading,
                  color: AppColors.primary,
                  textColor: Colors.white,
                  icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 28),
                ),
                const SizedBox(height: AppSpacing.md),
                SiphoButton3D(
                  label: l10n.signInWithApple,
                  onPressed: isBusy ? null : _handleAppleSignIn,
                  isLoading: _isAppleLoading,
                  color: Colors.black,
                  textColor: Colors.white,
                  icon: const Icon(Icons.apple, color: Colors.white, size: 24),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
