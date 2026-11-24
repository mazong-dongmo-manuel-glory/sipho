import 'package:flutter/material.dart';
import '../theme/sipho_colors.dart';
import '../theme/sipho_palette.dart';
import '../theme/sipho_typography.dart';

/// Bulle de dialogue joyeuse pour la mascotte Sipho (FIGMA.md §47).
class SiphoBubble extends StatelessWidget {
  final String text;
  final String? title;

  const SiphoBubble({
    super.key,
    required this.text,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SiphoPalette.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SiphoPalette.border(context), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: SiphoTypography.subtitle.copyWith(
                color: SiphoColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            text,
            style: SiphoTypography.body.copyWith(
              color: SiphoPalette.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
