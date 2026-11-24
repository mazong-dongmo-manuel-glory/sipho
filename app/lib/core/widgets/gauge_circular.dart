import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/sipho_colors.dart';
import '../theme/sipho_palette.dart';
import '../theme/sipho_typography.dart';

/// Jauge circulaire « reste à vivre » (Figma 08 · Accueil · Épuré).
class GaugeCircular extends StatelessWidget {
  final String amountLabel;
  final String caption;
  final double progress; // 0–1
  final double size;
  final Color? progressColor;
  final Color? trackColor;
  final Color? amountColor;
  final Color? captionColor;

  const GaugeCircular({
    super.key,
    required this.amountLabel,
    required this.caption,
    required this.progress,
    this.size = 198,
    this.progressColor,
    this.trackColor,
    this.amountColor,
    this.captionColor,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final dark = SiphoPalette.isDark(context);
    final ring = progressColor ?? SiphoColors.primary;
    final track = trackColor ??
        (dark ? SiphoColors.darkBorder : SiphoColors.primaryLight);
    final amount = amountColor ?? SiphoPalette.textPrimary(context);
    final captionCol = captionColor ?? SiphoPalette.textSecondary(context);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(
              progress: clamped,
              progressColor: ring,
              trackColor: track,
              strokeWidth: size * 0.07,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size * 0.14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    amountLabel,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                    style: SiphoTypography.amountHero.copyWith(
                      fontSize: size * 0.22,
                      color: amount,
                      height: 1.05,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: SiphoTypography.label.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: size * 0.059,
                    color: captionCol,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  _GaugePainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);

    // Départ en haut (−90°), sens horaire.
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * progress;
    canvas.drawArc(rect, start, sweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
