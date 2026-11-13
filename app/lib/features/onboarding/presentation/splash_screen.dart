import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/widgets/sipho_art.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1600), _openWelcome);
  }

  void _openWelcome() {
    if (!mounted) return;
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
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: GestureDetector(
        onTap: _openWelcome,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            const _Weave(),
            const Positioned(
              top: 205,
              left: 0,
              right: 0,
              child: Center(child: SiphoArt.happy()),
            ),
            Positioned(
              top: 468,
              left: 20,
              right: 20,
              child: Text(
                l10n.appName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 68,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  color: AppColors.accent,
                ),
              ),
            ),
            Positioned(
              top: 530,
              left: 246,
              child: SvgPicture.asset(
                'assets/images/sipho_nest.svg',
                width: 45,
                height: 13.2955,
              ),
            ),
            Positioned(
              top: 575,
              left: 40,
              right: 40,
              child: Text(
                l10n.splashTagline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              top: 768,
              left: 20,
              right: 20,
              child: Text(
                l10n.splashFooter,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: AppColors.mist,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Weave extends StatelessWidget {
  const _Weave();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        _Thread(left: 20),
        _Thread(left: 68),
        _Thread(left: 116),
        _Thread(left: 164),
        _Thread(left: 212),
        _Thread(left: 260),
        _Thread(left: 308),
        _Thread(left: 356),
      ],
    );
  }
}

class _Thread extends StatelessWidget {
  const _Thread({required this.left});

  final double left;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: 110,
      child: Container(
        width: 2,
        height: 580,
        decoration: BoxDecoration(
          color: AppColors.weave,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
