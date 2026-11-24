import 'package:flutter/material.dart';
import '../theme/sipho_colors.dart';
import '../theme/sipho_palette.dart';
import '../theme/sipho_typography.dart';
import 'sipho_button_3d.dart';
import 'sipho_page_header.dart';

/// Corps vide / chargement / erreur style Épuré.
class SiphoStatusBody extends StatelessWidget {
  final String title;
  final String lead;
  final String? amountLabel;
  final String? kicker;
  final String? cardTitle;
  final String? cardBody;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final bool loading;
  final Widget? mascot;

  const SiphoStatusBody({
    super.key,
    required this.title,
    required this.lead,
    this.amountLabel,
    this.kicker,
    this.cardTitle,
    this.cardBody,
    this.ctaLabel,
    this.onCta,
    this.loading = false,
    this.mascot,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        SiphoPageHeader(title: title, lead: lead),
        if (mascot != null) ...[
          const SizedBox(height: 16),
          Align(alignment: Alignment.centerLeft, child: mascot!),
        ],
        if (loading) ...[
          const SizedBox(height: 32),
          const Center(
            child: CircularProgressIndicator(color: SiphoColors.primary),
          ),
        ],
        if (amountLabel != null) ...[
          const SizedBox(height: 20),
          Text(
            amountLabel!,
            style: SiphoTypography.amountHero.copyWith(
              fontSize: 56,
              color: SiphoPalette.textPrimary(context),
              height: 1.3,
            ),
          ),
        ],
        if (kicker != null) ...[
          const SizedBox(height: 4),
          Text(
            kicker!,
            style: SiphoTypography.label.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: SiphoPalette.textSecondary(context),
            ),
          ),
        ],
        if (cardTitle != null) ...[
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: SiphoPalette.softSurface(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardTitle!,
                  style: SiphoTypography.bodyBold.copyWith(
                    fontSize: 16,
                    color: SiphoPalette.textPrimary(context),
                  ),
                ),
                if (cardBody != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    cardBody!,
                    style: SiphoTypography.body.copyWith(
                      fontSize: 16,
                      color: SiphoPalette.textPrimary(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (ctaLabel != null && onCta != null) ...[
          const SizedBox(height: 24),
          SiphoButton3D(
            label: ctaLabel!,
            variant: SiphoButtonVariant.dark,
            onPressed: onCta,
          ),
        ],
      ],
    );
  }
}
