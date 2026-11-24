import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_page_header.dart';

/// Frame 32 · Abonnement allégé — montant passé en `extra`.
class SubscriptionTrimmedScreen extends StatelessWidget {
  final String merchant;
  final int amountCents;
  final String currency;

  const SubscriptionTrimmedScreen({
    super.key,
    this.merchant = '',
    this.amountCents = 0,
    this.currency = 'CAD',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final money = Money(cents: amountCents, currency: currency);
    final savedLabel = amountCents > 0
        ? '−${money.format(locale)}'
        : '−${Money(cents: 0, currency: currency).format(locale)}';

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    SiphoPageHeader(
                      title: merchant.isEmpty
                          ? l10n.subTrimmedHeading
                          : merchant,
                      lead: l10n.subTrimmedLead,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      savedLabel,
                      style: SiphoTypography.amountHero.copyWith(
                        fontSize: 56,
                        color: SiphoColors.primary,
                      ),
                    ),
                    Text(
                      l10n.subTrimmedKicker,
                      style: SiphoTypography.label.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: SiphoPalette.softSurface(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        l10n.subTrimmedCard,
                        style: SiphoTypography.bodyBold.copyWith(
                          fontSize: 16,
                          color: SiphoPalette.textPrimary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SiphoButton3D(
                label: l10n.continueBtn,
                variant: SiphoButtonVariant.dark,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
