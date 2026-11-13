import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/animations/lottie_widget.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';

class ChestOpenScreen extends StatefulWidget {
  const ChestOpenScreen({super.key});

  @override
  State<ChestOpenScreen> createState() => _ChestOpenScreenState();
}

class _ChestOpenScreenState extends State<ChestOpenScreen> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: _open ? AppColors.seedPill : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(
                      child: _Pill(
                          AppColors.flamePill, AppColors.flameText, '🔥  12')),
                  const SizedBox(width: 16),
                  const Expanded(
                      child: _Pill(
                          AppColors.seedPill, AppColors.seedText, '🌾  340')),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _Pill(AppColors.mint, AppColors.primaryDark,
                        l10n.homeLevelPill(7)),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                _open ? l10n.giftTitleOpen : l10n.giftTitleClosed,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
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
                  onTap: () => setState(() => _open = true),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const _Rays(),
                      if (_open)
                        const LottieWidget(
                          assetPath:
                              'assets/animations/confetti_celebration.json',
                          width: 320,
                          height: 260,
                        ),
                      _Gift(open: _open),
                    ],
                  ),
                ),
              ),
              if (_open)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.giftSeeds,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          color: AppColors.warnBrown,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '❄  ${l10n.giftFreeze}',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                )
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
                    setState(() => _open = true);
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

class _Pill extends StatelessWidget {
  const _Pill(this.background, this.foreground, this.label);

  final Color background;
  final Color foreground;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}
