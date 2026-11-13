import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_text_styles.dart';

/// Circular gauge showing remaining budget as a donut chart.
class GaugeCircular extends StatelessWidget {
  const GaugeCircular({
    super.key,
    this.spentCents,
    this.totalCents,
    this.label = '',
    this.progress,
    this.strokeWidth,
    this.color,
    this.backgroundColor,
    this.radius = 60,
  });

  final int? spentCents;
  final int? totalCents;
  final String label;
  final double radius;
  final double? progress;
  final double? strokeWidth;
  final Color? color;
  final Color? backgroundColor;

  Color get _gaugeColor {
    final c = color;
    if (c != null) return c;
    final total = totalCents ?? 100;
    if (total == 0) return AppColors.budgetOk;
    final spent = spentCents ??
        (progress != null ? ((1.0 - progress!) * total).round() : 0);
    final ratio = spent / total;
    if (ratio < 0.75) return AppColors.budgetOk;
    if (ratio < 1.0) return AppColors.budgetWarn;
    return AppColors.budgetOver;
  }

  @override
  Widget build(BuildContext context) {
    final total = totalCents ?? 100;
    final spent = spentCents ??
        (progress != null ? ((1.0 - progress!) * total).round() : 0);
    final remaining = (total - spent).clamp(0, total);
    final pct = progress ?? (total > 0 ? remaining / total : 0.0);
    final sectionRadius = strokeWidth ?? (radius * 0.35);

    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 0,
              centerSpaceRadius: radius - sectionRadius,
              sections: [
                PieChartSectionData(
                  value: pct.clamp(0.0, 1.0),
                  color: _gaugeColor,
                  radius: sectionRadius,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: (1.0 - pct.clamp(0.0, 1.0)),
                  color: backgroundColor ?? AppColors.border,
                  radius: sectionRadius,
                  showTitle: false,
                ),
              ],
            ),
          ),
          if (label.isNotEmpty)
            Text(
              label,
              style: AppTextStyles.labelMedium,
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
