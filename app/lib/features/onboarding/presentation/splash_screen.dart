import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1600), _openNext);
  }

  void _openNext() {
    if (!mounted) return;
    final location = GoRouterState.of(context).matchedLocation;
    // Auth redirects may already have moved us off splash — don't force /login.
    if (!location.startsWith('/splash')) return;

    final loggedIn = ref.read(authStateProvider).valueOrNull != null;
    if (loggedIn) {
      final onboardingDone = ref.read(onboardingGateProvider);
      if (onboardingDone == true) {
        context.go('/home');
      } else if (onboardingDone == false) {
        context.go('/onboarding');
      }
      // Gate still loading: stay on splash; router refresh will navigate.
      return;
    }
    context.go('/login');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // If auth flips while we're on splash, leave immediately (avoids login loop).
    ref.listen(authStateProvider, (prev, next) {
      if (next.valueOrNull == null) return;
      if (!mounted) return;
      final location = GoRouterState.of(context).matchedLocation;
      if (!location.startsWith('/splash')) return;
      final onboardingDone = ref.read(onboardingGateProvider);
      if (onboardingDone == true) {
        context.go('/home');
      } else if (onboardingDone == false) {
        context.go('/onboarding');
      }
    });
    ref.listen(onboardingGateProvider, (prev, next) {
      if (next == null) return;
      if (!mounted) return;
      final loggedIn = ref.read(authStateProvider).valueOrNull != null;
      if (!loggedIn) return;
      final location = GoRouterState.of(context).matchedLocation;
      if (!location.startsWith('/splash') && !location.startsWith('/login')) {
        return;
      }
      context.go(next ? '/home' : '/onboarding');
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'sipho',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                height: 1.3,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const SiphoArt.happy(frame: 136),
                            const SizedBox(height: 20),
                            Text(
                              l10n.splashTagline,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                height: 1.3,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              l10n.splashLead,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 1.3,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              l10n.splashKicker,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SiphoButton3D(
                label: l10n.splashCta,
                onPressed: _openNext,
                color: AppColors.primaryDark,
                shadowColor: AppColors.primaryDark,
                textColor: Colors.white,
                height: 52,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
