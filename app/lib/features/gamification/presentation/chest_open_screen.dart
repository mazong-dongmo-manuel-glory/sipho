import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/animations/lottie_widget.dart';
import 'package:sipho/core/animations/sipho_lotties.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/gamification/data/game_state_repository.dart';
import 'package:sipho/features/gamification/domain/quest_reward.dart';

class ChestOpenScreen extends ConsumerStatefulWidget {
  /// [reward] is what the server actually paid for the claimed quest; null when the screen is
  /// reached without a claim (then no amount is announced).
  const ChestOpenScreen({super.key, this.reward});

  final QuestReward? reward;

  @override
  ConsumerState<ChestOpenScreen> createState() => _ChestOpenScreenState();
}

class _ChestOpenScreenState extends ConsumerState<ChestOpenScreen> {
  bool _open = false;

  void _openGift() {
    if (_open) return;
    setState(() => _open = true);
    unawaited(ref.read(feedbackServiceProvider).play(SiphoCue.giftOpened));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final game = ref.watch(gameStateStreamProvider).valueOrNull;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.homeStreakDays(game?.streak.current ?? 0),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  Text(
                    l10n.homeSeedsLevel('${game?.gems ?? 0}', game?.level ?? 1),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                _open ? l10n.giftTitleOpen : l10n.giftTitleClosed,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _open ? l10n.giftEffort : l10n.giftFrom,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _openGift,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const _Rays(),
                      if (_open)
                        const LottieWidget(
                          assetPath: SiphoLotties.giftSparkles,
                          width: 300,
                          height: 300,
                          repeat: false,
                        ),
                      if (_open)
                        const LottieWidget(
                          assetPath: SiphoLotties.confetti,
                          width: 320,
                          height: 260,
                        ),
                      if (_open)
                        const LottieWidget(
                          assetPath: SiphoLotties.questComplete,
                          width: 140,
                          height: 140,
                          repeat: false,
                        ),
                      _Gift(open: _open),
                    ],
                  ),
                ),
              ),
              if (_open)
                _RewardCard(reward: widget.reward, l10n: l10n)
              else ...[
                Text(
                  l10n.giftTap,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.giftMagic,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SiphoButton3D(
                label: _open ? l10n.giftThanks : l10n.giftOpenCta,
                onPressed: () {
                  if (_open) {
                    context.go('/home');
                  } else {
                    _openGift();
                  }
                },
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

/// The amounts the server really paid. Nothing is shown for an amount that is 0.
class _RewardCard extends StatelessWidget {
  const _RewardCard({required this.reward, required this.l10n});

  final QuestReward? reward;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final reward = this.reward;
    final lines = <(String, double, Color)>[
      if (reward != null && reward.gemsGained > 0)
        (l10n.giftSeedsAmount(reward.gemsGained), 25, AppColors.warnBrown),
      if (reward != null && reward.xpGained > 0)
        (l10n.giftXpAmount(reward.xpGained), 18, AppColors.primaryDark),
      if (reward != null && reward.levelUp)
        (l10n.giftLevelUp, 16, AppColors.primary),
      if (reward != null && reward.alreadyClaimed)
        (l10n.giftNothingNew, 16, AppColors.textSecondary),
    ];
    if (lines.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Text(
              lines[i].$1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: lines[i].$2,
                fontWeight: i == 0 ? FontWeight.w900 : FontWeight.w800,
                color: lines[i].$3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Rays extends StatelessWidget {
  const _Rays();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (var i = 0; i < 8; i++)
          Transform.rotate(
            angle: i * math.pi / 4,
            child: Container(
              width: 4,
              height: 240,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
  }
}

class _Gift extends StatelessWidget {
  const _Gift({required this.open});

  final bool open;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 265,
      height: 248.437,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 59.625,
            top: 98.555,
            child: SvgPicture.asset(
              'assets/images/gift_box.svg',
              width: 147.406,
              height: 116.766,
            ),
          ),
          if (open)
            Positioned(
              left: 65.15,
              top: 96.06,
              child: SvgPicture.asset(
                'assets/images/gift_inside.svg',
                width: 132.5,
                height: 19.875,
              ),
            ),
          Positioned(
            left: 31.456,
            top: 55.476,
            child: SvgPicture.asset(
              'assets/images/gift_sparkles.svg',
              width: 204.547,
              height: 132.5,
            ),
          ),
          Positioned(
            left: 0,
            top: open ? -28 : 0,
            child: Transform.rotate(
              angle: open ? -8 * math.pi / 180 : 0,
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: 265,
                height: 248.437,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 49.608,
                      top: 73.637,
                      child: SvgPicture.asset(
                        'assets/images/gift_lid.svg',
                        width: 165.786,
                        height: 51.4818,
                      ),
                    ),
                    Positioned(
                      left: 82.813,
                      top: 65.413,
                      child: SvgPicture.asset(
                        'assets/images/gift_ribbon.svg',
                        width: 93.5781,
                        height: 38.0938,
                      ),
                    ),
                    Positioned(
                      left: 70.57,
                      top: 31.179,
                      child: SvgPicture.asset(
                        'assets/images/gift_bow.svg',
                        width: 112.696,
                        height: 52.4498,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

