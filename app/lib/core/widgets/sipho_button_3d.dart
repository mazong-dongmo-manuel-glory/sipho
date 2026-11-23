import 'package:flutter/material.dart';
import '../theme/sipho_colors.dart';
import '../theme/sipho_typography.dart';

enum SiphoButtonVariant {
  primary,
  secondary,
  accent,
  danger,
  outline,
}

/// Bouton « 3D » emblématique façon Duolingo décrit dans FIGMA.md et Specification_Sipho.pdf.
/// Bouton plein avec bordure inférieure de 4 px plus foncée donnant un effet de relief
/// et s'enfonçant de 4 px au clic.
class SiphoButton3D extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final SiphoButtonVariant variant;
  final Widget? icon;
  final bool fullWidth;
  final double height;
  final double depth;

  const SiphoButton3D({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SiphoButtonVariant.primary,
    this.icon,
    this.fullWidth = true,
    this.height = 56.0,
    this.depth = 4.0,
  });

  @override
  State<SiphoButton3D> createState() => _SiphoButton3DState();
}

class _SiphoButton3DState extends State<SiphoButton3D> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null;

  Color _getFaceColor() {
    if (!_isEnabled) return const Color(0xFFE2E8F0);
    switch (widget.variant) {
      case SiphoButtonVariant.primary:
        return SiphoColors.primary;
      case SiphoButtonVariant.secondary:
        return SiphoColors.accentGold;
      case SiphoButtonVariant.accent:
        return SiphoColors.accentTerra;
      case SiphoButtonVariant.danger:
        return SiphoColors.danger;
      case SiphoButtonVariant.outline:
        return SiphoColors.surface;
    }
  }

  Color _getEdgeColor() {
    if (!_isEnabled) return const Color(0xFFCBD5E1);
    switch (widget.variant) {
      case SiphoButtonVariant.primary:
        return SiphoColors.primaryDark;
      case SiphoButtonVariant.secondary:
        return const Color(0xFFC79200);
      case SiphoButtonVariant.accent:
        return const Color(0xFF9E3E2A);
      case SiphoButtonVariant.danger:
        return const Color(0xFFB8282D);
      case SiphoButtonVariant.outline:
        return SiphoColors.border;
    }
  }

  Color _getTextColor() {
    if (!_isEnabled) return const Color(0xFF94A3B8);
    switch (widget.variant) {
      case SiphoButtonVariant.primary:
      case SiphoButtonVariant.accent:
      case SiphoButtonVariant.danger:
        return Colors.white;
      case SiphoButtonVariant.secondary:
        return SiphoColors.textPrimary;
      case SiphoButtonVariant.outline:
        return SiphoColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final faceColor = _getFaceColor();
    final edgeColor = _getEdgeColor();
    final textColor = _getTextColor();
    final effectiveDepth = _isPressed ? 0.0 : widget.depth;
    final paddingTop = _isPressed ? widget.depth : 0.0;

    Widget content = SizedBox(
      height: widget.height + widget.depth,
      child: Stack(
        children: [
          // Ombre 3D du bas
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: widget.height,
            child: Container(
              decoration: BoxDecoration(
                color: edgeColor,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          // Face visible du bouton avec translation au tap
          Positioned(
            left: 0,
            right: 0,
            top: paddingTop,
            height: widget.height - (widget.depth - effectiveDepth),
            child: Container(
              decoration: BoxDecoration(
                color: faceColor,
                borderRadius: BorderRadius.circular(18),
                border: widget.variant == SiphoButtonVariant.outline
                    ? Border.all(color: edgeColor, width: 2)
                    : null,
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      widget.icon!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label.toUpperCase(),
                      style: SiphoTypography.button.copyWith(
                        color: textColor,
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

    if (widget.fullWidth) {
      content = SizedBox(width: double.infinity, child: content);
    }

    return GestureDetector(
      onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: _isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: _isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}
