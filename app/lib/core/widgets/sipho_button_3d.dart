import 'package:flutter/material.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_radius.dart';
import 'package:sipho/app/theme/app_text_styles.dart';

/// A Duolingo-style 3D button with a bottom shadow that presses in on tap.
class SiphoButton3D extends StatefulWidget {
  const SiphoButton3D({
    super.key,
    String? label,
    String? text,
    required this.onPressed,
    this.color = AppColors.primary,
    this.textColor = Colors.white,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
    this.height = 56,
    this.shadowOffset = 4.0,
  }) : label = label ?? text ?? '';

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final Widget? icon;
  final bool isLoading;
  final bool enabled;
  final double height;
  final double shadowOffset;

  @override
  State<SiphoButton3D> createState() => _SiphoButton3DState();
}

class _SiphoButton3DState extends State<SiphoButton3D> {
  bool _pressed = false;

  Color get _shadowColor => HSLColor.fromColor(widget.color)
      .withLightness(
        (HSLColor.fromColor(widget.color).lightness - 0.15).clamp(0, 1),
      )
      .toColor();

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed =
        (widget.enabled && !widget.isLoading) ? widget.onPressed : null;

    return GestureDetector(
      onTapDown: effectiveOnPressed != null
          ? (_) => setState(() => _pressed = true)
          : null,
      onTapUp: effectiveOnPressed != null
          ? (_) {
              setState(() => _pressed = false);
              effectiveOnPressed();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: widget.height + widget.shadowOffset,
        decoration: BoxDecoration(
          color: _shadowColor,
          borderRadius: AppRadius.buttonRadius,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          margin: EdgeInsets.only(bottom: _pressed ? 0 : widget.shadowOffset),
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.enabled ? widget.color : AppColors.border,
            borderRadius: AppRadius.buttonRadius,
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: widget.textColor,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      widget.icon!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: widget.enabled
                            ? widget.textColor
                            : AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
