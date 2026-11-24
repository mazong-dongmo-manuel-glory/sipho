import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/firebase/cloud_functions_service.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../gamification/data/game_state_provider.dart';

/// Frame 18 · Palier de série · Épuré (+ réparation via `repairStreak`).
class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(gameStateProvider).streakDays;

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      'La constance, ça se cultive',
                      style: SiphoTypography.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$days',
                      textAlign: TextAlign.center,
                      style: SiphoTypography.amountHero.copyWith(
                        fontSize: 72,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                    Text(
                      'jours de série !',
                      textAlign: TextAlign.center,
                      style: SiphoTypography.title.copyWith(
                        fontSize: 28,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: SvgPicture.asset(
                          'assets/images/sipho_proud.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Ton futur toi te remercie.',
                      textAlign: TextAlign.center,
                      style: SiphoTypography.body.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SiphoButton3D(
                      label: 'Coup de main',
                      variant: SiphoButtonVariant.outline,
                      onPressed: () => context.push('/streak/help'),
                    ),
                    const SizedBox(height: 12),
                    SiphoButton3D(
                      label: 'Réparer ma série',
                      variant: SiphoButtonVariant.outline,
                      onPressed: () async {
                        await ref.read(cloudFunctionsServiceProvider).repairStreak();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Demande de réparation envoyée'),
                            backgroundColor: SiphoColors.primaryDark,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SiphoButton3D(
                label: 'Continuer',
                variant: SiphoButtonVariant.dark,
                onPressed: () => context.go('/chest'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
