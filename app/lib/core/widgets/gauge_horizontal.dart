import 'package:flutter/material.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_radius.dart';
import 'package:sipho/app/theme/app_text_styles.dart';

/// Horizontal budget gauge bar.
class GaugeHorizontal extends StatelessWidget {
  const GaugeHorizontal({
    super.key,
    required this.spentCents,
    required this.totalCents,
    this.label,
    this.height = 12,
  });

  final int spentCents;
  final int totalCents;
  final String? label;
  final double height;

  Color get _gaugeColor {
    if (totalCents == 0) return AppColors.budgetOk;
    final ratio = spentCents / totalCents;
    if (ratio < 0.75) return AppColors.budgetOk;
    if (ratio < 1.0) return AppColors.budgetWarn;
    return AppColors.budgetOver;
  }

  @override
  Widget build(BuildContext context) {
    final pct = totalCents > 0
        ? (spentCents / totalCents).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(label!, style: AppTextStyles.labelMedium),
          ),
        ClipRRect(
          borderRadius: AppRadius.pillRadius,
          child: LinearProgressIndicator(
            value: pct,
            minHeight: height,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(_gaugeColor),
          ),
        ),
      ],
    );
  }
}
