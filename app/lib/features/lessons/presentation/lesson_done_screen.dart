import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/animations/lottie_widget.dart';
import 'package:sipho/core/animations/sipho_lotties.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/lessons/domain/lesson_result.dart';

/// Celebration shown after a lesson is validated. Every number comes from [result]: the
/// server's rewards and what the quiz measured (accuracy, time).
class LessonDoneScreen extends ConsumerWidget {
  const LessonDoneScreen({super.key, required this.result});

  final LessonResult result;

  /// Where "Continue" leads: the streak screen after a first completion, back to the path after
  /// a replay (no streak news to announce).
  static String nextRoute(LessonResult result) =>
      result.alreadyCompleted ? '/learn' : '/streak';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = ref.watch(userFinanceProvider).valueOrNull?.firstName ?? '';
    final bonusLines = <String>[
      if (result.seedsGained > 0) l10n.giftSeedsAmount(result.seedsGained),
      if (result.finishedUnit)
        l10n.lessonUnitCompleted(result.unitBonusXp, result.unitBonusSeeds),
      if (result.levelUp) l10n.lessonDoneLevelUp(result.newLevel),
      if (result.alreadyCompleted) l10n.lessonDoneReplay,
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                l10n.lessonDoneTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  color: AppColors.primaryDark,
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const LottieWidget(
                      assetPath: SiphoLotties.confetti,
                      width: 340,
                      height: 280,
                    ),
                    if (result.levelUp)
                      const LottieWidget(
                        assetPath: SiphoLotties.levelUp,
                        width: 180,
                        height: 180,
                        repeat: false,
                      )
                    else
                      const SiphoArt.celebrating(frame: 240),
                  ],
                ),
              ),
              Text(
                name.isEmpty
                    ? l10n.lessonDoneBravoAnon
                    : l10n.lessonDoneBravo(name),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Stat(l10n.lessonXp, '${result.xpGained}', AppColors.accent),
                  const SizedBox(width: 12),
                  _Stat(l10n.lessonAccuracy, '${result.accuracy} %',
                      AppColors.primary),
                  const SizedBox(width: 12),
                  _Stat(
                      l10n.lessonTime,
                      formatLessonDuration(result.durationSeconds),
                      AppColors.terracotta),
                ],
              ),
              if (bonusLines.isNotEmpty) ...[
                const SizedBox(height: 12),
                for (final line in bonusLines)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      line,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.warnBrown,
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 20),
              SiphoButton3D(
                label: l10n.continueBtn.toUpperCase(),
                onPressed: () => context.go(nextRoute(result)),
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

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.valueColor);

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: '$label $value',
        excludeSemantics: true,
        child: Container(
          height: 108,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
