import 'package:flutter/material.dart';
import '../theme/sipho_palette.dart';
import '../theme/sipho_typography.dart';

/// Ligne plate style Épuré : libellé(+sous-texte) à gauche, valeur à droite.
class SiphoListRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final EdgeInsetsGeometry padding;

  const SiphoListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = false,
    this.padding = const EdgeInsets.symmetric(vertical: 2),
  });

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: SiphoTypography.bodyBold.copyWith(
                    fontSize: 16,
                    color: SiphoPalette.textPrimary(context),
                    height: 1.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: SiphoTypography.label.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: SiphoPalette.textSecondary(context),
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null || showChevron)
            Flexible(
              flex: 0,
              child: Text(
                trailing ?? '→',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: SiphoTypography.label.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: SiphoPalette.textPrimary(context),
                  height: 1.3,
                ),
              ),
            ),
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: row,
    );
  }
}

/// Séparateur horizontal épuré `#E4E9E3`.
class SiphoSeparator extends StatelessWidget {
  final EdgeInsetsGeometry margin;

  const SiphoSeparator({
    super.key,
    this.margin = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: 1,
      color: SiphoPalette.separator(context),
    );
  }
}

/// Carte douce pour bulles / encouragements (clair + sombre).
class SiphoSoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const SiphoSoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: SiphoPalette.softSurface(context),
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}
