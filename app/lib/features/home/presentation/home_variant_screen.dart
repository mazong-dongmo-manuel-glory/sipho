import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../../core/widgets/sipho_status_body.dart';

/// Frames 61–66 + 83 · Variantes d’Accueil.
enum HomeVariant {
  empty,
  loading,
  error,
  tight,
  underZero,
  welcomeBack,
  wellDone,
}

class HomeVariantScreen extends StatelessWidget {
  final HomeVariant variant;

  const HomeVariantScreen({super.key, required this.variant});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mascot = SizedBox(
      width: 94,
      height: 94,
      child: SvgPicture.asset('assets/images/sipho_happy.svg', fit: BoxFit.contain),
    );

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: switch (variant) {
          HomeVariant.empty => SiphoStatusBody(
              title: l10n.homeEmptyHeading,
              lead: l10n.homeEmptyLead,
              amountLabel: '—',
              kicker: l10n.homeEmptyKicker,
              cardTitle: l10n.homeEmptyCardTitle,
              cardBody: l10n.homeEmptyCardBody,
              ctaLabel: l10n.homeEmptyCta,
              onCta: () => context.push('/onboarding/nest'),
              mascot: mascot,
            ),
          HomeVariant.loading => SiphoStatusBody(
              title: l10n.homeLoadingHeading,
              lead: l10n.homeLoadingLead,
              loading: true,
            ),
          HomeVariant.error => SiphoStatusBody(
              title: l10n.homeErrorHeading,
              lead: l10n.homeErrorLead,
              cardTitle: l10n.homeErrorCardTitle,
              cardBody: l10n.homeErrorCardBody,
              ctaLabel: l10n.retryBtn,
              onCta: () => context.pop(),
            ),
          HomeVariant.tight => SiphoStatusBody(
              title: l10n.homeTightHeading,
              lead: l10n.homeTightLead,
              amountLabel: '86 \$',
              kicker: l10n.homeTightKicker,
              cardTitle: l10n.homeTightCardTitle,
              cardBody: l10n.homeTightCardBody,
              ctaLabel: l10n.homeTightCta,
              onCta: () => context.push('/expenses'),
              mascot: mascot,
            ),
          HomeVariant.underZero => SiphoStatusBody(
              title: l10n.homeUnderHeading,
              lead: l10n.homeUnderLead,
              amountLabel: '−42 \$',
              kicker: l10n.homeUnderKicker,
              cardTitle: l10n.homeUnderCardTitle,
              cardBody: l10n.homeUnderCardBody,
              ctaLabel: l10n.homeUnderCta,
              onCta: () => context.push('/budget'),
              mascot: mascot,
            ),
          HomeVariant.welcomeBack => SiphoStatusBody(
              title: l10n.homeBackHeading,
              lead: l10n.homeBackLead,
              cardTitle: l10n.homeBackCardTitle,
              cardBody: l10n.homeBackCardBody,
              ctaLabel: l10n.homeBackCta,
              onCta: () => context.go('/home'),
              mascot: mascot,
            ),
          HomeVariant.wellDone => Column(
              children: [
                Expanded(
                  child: SiphoStatusBody(
                    title: l10n.homeWellDoneHeading,
                    lead: l10n.homeWellDoneLead,
                    amountLabel: '+20 XP',
                    kicker: l10n.homeWellDoneKicker,
                    cardTitle: l10n.homeWellDoneCardTitle,
                    cardBody: l10n.homeWellDoneCardBody,
                    ctaLabel: l10n.continueBtn,
                    onCta: () => context.go('/home'),
                    mascot: mascot,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: SiphoListRow(
                    title: l10n.homeWellDoneQuests,
                    subtitle: l10n.homeWellDoneQuestsSub,
                    showChevron: true,
                    onTap: () => context.go('/home'),
                  ),
                ),
              ],
            ),
        },
      ),
    );
  }
}
