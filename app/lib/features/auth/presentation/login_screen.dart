import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_radius.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/app/theme/app_text_styles.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';

/// Gaps from the 393×852 Figma frame, below the system status bar.
const _wordmarkTopGap = 19.0;
const _wordmarkToMascot = 31.0;
const _mascotToTitle = 23.0;
const _titleToSubtitle = 18.0;
const _buttonGap = 16.0;
const _buttonsToLegal = 29.0;
const _legalBottomGap = 29.0;

const _mascotFrame = 240.0;
const _svgWidth = 218.113;
const _svgHeight = 197.495;

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
    const buttonRadius = BorderRadius.all(Radius.circular(AppRadius.md));

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pagePadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: _wordmarkTopGap),
                        Text(
                          l10n.welcomeWordmark,
                          style: AppTextStyles.welcomeWordmark,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: _wordmarkToMascot),
                        const Align(child: _WavingSipho()),
                        const SizedBox(height: _mascotToTitle),
                        Text(
                          l10n.welcomeTitle,
                          style: AppTextStyles.welcomeTitle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: _titleToSubtitle),
                        Text(
                          l10n.welcomeSubtitle,
                          style: AppTextStyles.welcomeSubtitle,
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        if (authState.hasError)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: Text(
                              authState.error.toString(),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.danger,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        SiphoButton3D(
                          label: l10n.signInWithApple,
                          onPressed: isBusy ? null : _handleAppleSignIn,
                          isLoading: _isAppleLoading,
                          color: AppColors.ink,
                          shadowColor: AppColors.primaryDark,
                          textColor: Colors.white,
                          height: 52,
                          borderRadius: buttonRadius,
                        ),
                        const SizedBox(height: _buttonGap),
                        SiphoButton3D(
                          label: l10n.signInWithGoogle,
                          onPressed: isBusy ? null : _handleGoogleSignIn,
                          isLoading: _isGoogleLoading,
                          color: AppColors.surface,
                          shadowColor: AppColors.border,
                          textColor: AppColors.primaryDark,
                          height: 52,
                          borderRadius: buttonRadius,
                        ),
                        const SizedBox(height: _buttonsToLegal),
                        Text(
                          l10n.welcomeLegal,
                          style: AppTextStyles.welcomeLegal,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: _legalBottomGap),
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

/// Mascot slot from the Figma component: a 240 frame, SVG at its root size.
class _WavingSipho extends StatelessWidget {
  const _WavingSipho();

  @override
  Widget build(BuildContext context) {
    const innerLeft = _mascotFrame * 0.05;
    const innerTop = _mascotFrame * 0.0902;
    const innerWidth = _mascotFrame * 0.90;
    const innerHeight = _mascotFrame * (1 - 0.1804);
    const left = innerLeft + innerWidth * -0.0098;
    const top = innerTop + innerHeight * -0.0039;

    return SizedBox(
      width: _mascotFrame,
      height: _mascotFrame,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: left,
            top: top,
            child: SvgPicture.asset(
              'assets/images/sipho_waving.svg',
              width: _svgWidth,
              height: _svgHeight,
              semanticsLabel: 'Sipho',
            ),
          ),
        ],
      ),
    );
  }
}
