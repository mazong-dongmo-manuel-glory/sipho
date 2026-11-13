import 'package:flutter/material.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_radius.dart';
import 'package:sipho/app/theme/app_text_styles.dart';

/// Horizontal budget gauge bar.
class GaugeHorizontal extends StatelessWidget {
  const GaugeHorizontal({
    super.key,
    this.spentCents,
    this.totalCents,
    this.progress,
    this.label,
    this.height = 12,
    this.color,
    this.backgroundColor,
  });

  final int? spentCents;
  final int? totalCents;
  final double? progress;
  final Color? color;
  final Color? backgroundColor;
  final String? label;
  final double height;

  Color get _gaugeColor {
    if (color != null) return color!;
    final total = totalCents ?? 100;
    if (total == 0) return AppColors.budgetOk;
    final spent = spentCents ?? ((progress ?? 0.0) * total).round();
    final ratio = spent / total;
    if (ratio < 0.75) return AppColors.budgetOk;
    if (ratio < 1.0) return AppColors.budgetWarn;
    return AppColors.budgetOver;
  }

  @override
  Widget build(BuildContext context) {
    final total = totalCents ?? 100;
    final pct = progress ??
        (total > 0 ? ((spentCents ?? 0) / total).clamp(0.0, 1.0) : 0.0);

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
            backgroundColor: backgroundColor ?? AppColors.border,
            valueColor: AlwaysStoppedAnimation(_gaugeColor),
          ),
        ),
      ],
    );
  }
}
