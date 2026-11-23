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
import 'package:sipho/features/gamification/domain/streak_milestones.dart';
import 'package:sipho/features/gamification/domain/streak_week.dart';
import 'package:sipho/features/gamification/presentation/streak_repair_controller.dart';

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
    final streak = game?.streak;
    final streakDays = streak?.current ?? 0;
    final best = streak?.best ?? streakDays;
    final repairing = ref.watch(streakRepairControllerProvider);
    final offerRepair = canOfferStreakRepair(
      brokenAt: streak?.brokenAt,
      brokenCurrent: streak?.brokenCurrent ?? 0,
      freezes: streak?.freezes ?? 0,
    );
    final marks = streakWeekMarks(
      lastActiveDay: streak?.lastActiveDay,
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
              const SizedBox(height: 24),
              Text(
                l10n.streakKicker,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.terracotta,
                ),
              ),
              const SizedBox(height: 4),
              const LottieWidget(
                assetPath: SiphoLotties.streakFire,
                width: 140,
                height: 130,
              ),
              Text(
                '$streakDays',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 64,
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
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 72,
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
                              width: 26,
                              height: 26,
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
                                        fontSize: 14,
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
              if (offerRepair) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.terracotta),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.streakRepairTitle,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.streakRepairBody,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SiphoButton3D(
                        label: l10n.streakRepairCta,
                        isLoading: repairing,
                        onPressed: () async {
                          final ok = await ref
                              .read(streakRepairControllerProvider.notifier)
                              .repair();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? l10n.streakRepairDone
                                    : (streak?.freezes ?? 0) < 1
                                        ? l10n.streakRepairNoFreeze
                                        : l10n.streakRepairError,
                              ),
                            ),
                          );
                        },
                        color: AppColors.terracotta,
                        shadowColor: AppColors.primaryDark,
                        height: 44,
                        borderRadius: figmaButtonRadius,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.streakMilestonesTitle,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: kStreakMilestones.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final m = kStreakMilestones[index];
                    final reached = streakMilestoneReached(best, m);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: reached ? AppColors.mint : AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: reached ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        reached ? '$m · ${l10n.streakMilestoneReached}' : '$m',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: reached
                              ? AppColors.primaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const SiphoArt.proud(frame: 72),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.streakThanks,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SiphoButton3D(
                label: l10n.continueBtn.toUpperCase(),
                onPressed: () => context.go('/learn'),
                color: AppColors.primary,
                shadowColor: AppColors.primaryDark,
                height: 52,
                borderRadius: figmaButtonRadius,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
