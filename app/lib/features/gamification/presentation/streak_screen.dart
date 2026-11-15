import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/animations/lottie_widget.dart';
import 'package:sipho/core/animations/sipho_lotties.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/gamification/data/game_state_repository.dart';
import 'package:sipho/features/gamification/domain/streak_week.dart';

class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  /// One-letter weekday labels, Monday first, in the app locale.
  static List<String> weekdayInitials(String locale) {
    final format = DateFormat('EEEEE', locale);
    // 2024-01-01 is a Monday.
    return [
      for (var i = 0; i < 7; i++) format.format(DateTime(2024, 1, 1 + i))
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final game = ref.watch(gameStateStreamProvider).valueOrNull;
    final streakDays = game?.streak.current ?? 0;
    final marks = streakWeekMarks(
      lastActiveDay: game?.streak.lastActiveDay,
      current: streakDays,
      today: DateTime.now(),
    );
    final days = weekdayInitials(Localizations.localeOf(context).toString());
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            children: [
              const SizedBox(height: 36),
              Text(
                l10n.streakKicker,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.terracotta,
                ),
              ),
              const SizedBox(height: 8),
              const LottieWidget(
                assetPath: SiphoLotties.streakFire,
                width: 190,
                height: 180,
              ),
              Text(
                '$streakDays',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 76,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  color: AppColors.terracotta,
                ),
              ),
              Text(
                l10n.streakDays,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 82,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < days.length; i++)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              days[i],
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 29,
                              height: 29,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: marks[i]
                                    ? AppColors.flamePill
                                    : AppColors.dayOff,
                                shape: BoxShape.circle,
                              ),
                              child: marks[i]
                                  ? const Text(
                                      '✓',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.flameCheck,
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const SiphoArt.proud(frame: 87),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.streakThanks,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SiphoButton3D(
                label: l10n.continueBtn.toUpperCase(),
                onPressed: () => context.go('/learn'),
                color: AppColors.primary,
                shadowColor: AppColors.primaryDark,
                height: 52,
                borderRadius: figmaButtonRadius,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
