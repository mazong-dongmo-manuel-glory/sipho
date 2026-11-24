import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/widgets/sipho_status_body.dart';

/// Frames 67–69 · Variantes Dépenses.
enum ExpensesVariant { empty, error, loading }

class ExpensesVariantScreen extends StatelessWidget {
  final ExpensesVariant variant;

  const ExpensesVariantScreen({super.key, required this.variant});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: switch (variant) {
          ExpensesVariant.empty => SiphoStatusBody(
              title: l10n.expensesEmptyHeading,
              lead: l10n.expensesEmptyLead,
              amountLabel: '0 \$',
              kicker: l10n.expensesEmptyKicker,
              cardTitle: l10n.expensesEmptyCardTitle,
              cardBody: l10n.expensesEmptyCardBody,
              ctaLabel: l10n.expensesEmptyCta,
              onCta: () => context.push('/expenses/add'),
            ),
          ExpensesVariant.error => SiphoStatusBody(
              title: l10n.expensesErrorHeading,
              lead: l10n.expensesErrorLead,
              cardTitle: l10n.expensesErrorCardTitle,
              cardBody: l10n.expensesErrorCardBody,
              ctaLabel: l10n.retryBtn,
              onCta: () => context.pop(),
            ),
          ExpensesVariant.loading => SiphoStatusBody(
              title: l10n.expensesLoadingHeading,
              lead: l10n.expensesLoadingLead,
              loading: true,
            ),
        },
      ),
    );
  }
}
