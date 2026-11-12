import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_text_styles.dart';

/// Circular gauge showing remaining budget as a donut chart.
class GaugeCircular extends StatelessWidget {
  const GaugeCircular({
    super.key,
    required this.spentCents,
    required this.totalCents,
    required this.label,
    this.radius = 60,
  });

  final int spentCents;
  final int totalCents;
  final String label;
  final double radius;

  Color get _gaugeColor {
    if (totalCents == 0) return AppColors.budgetOk;
    final ratio = spentCents / totalCents;
    if (ratio < 0.75) return AppColors.budgetOk;
    if (ratio < 1.0) return AppColors.budgetWarn;
    return AppColors.budgetOver;
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (totalCents - spentCents).clamp(0, totalCents);
    final pct = totalCents > 0 ? remaining / totalCents : 0.0;

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
              centerSpaceRadius: radius * 0.65,
              sections: [
                PieChartSectionData(
                  value: pct,
                  color: _gaugeColor,
                  radius: radius * 0.35,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: 1 - pct,
                  color: AppColors.border,
                  radius: radius * 0.35,
                  showTitle: false,
                ),
              ],
            ),
          ),
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
