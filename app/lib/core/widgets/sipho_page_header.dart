import 'package:flutter/material.dart';
import '../theme/sipho_palette.dart';
import '../theme/sipho_typography.dart';

/// En-tête Épuré : titre 28 + lead secondaire.
class SiphoPageHeader extends StatelessWidget {
  final String title;
  final String? lead;
  final Widget? leading;

  const SiphoPageHeader({
    super.key,
    required this.title,
    this.lead,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(height: 12),
        ],
        Text(
          title,
          softWrap: true,
          style: SiphoTypography.title.copyWith(
            fontSize: 28,
            color: SiphoPalette.textPrimary(context),
            height: 1.3,
          ),
        ),
        if (lead != null) ...[
          const SizedBox(height: 8),
          Text(
            lead!,
            softWrap: true,
            style: SiphoTypography.body.copyWith(
              fontSize: 16,
              color: SiphoPalette.textSecondary(context),
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }
}
