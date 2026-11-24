import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../budget/data/budgets_provider.dart';
import '../data/expenses_provider.dart';

/// Frame 11b · Validation du scan · données Gemini uniquement (pas de démo).
class ValidateReceiptScreen extends ConsumerWidget {
  final Map<String, dynamic> parsed;

  const ValidateReceiptScreen({super.key, this.parsed = const {}});

  bool get _hasUsableAmount {
    final cents = (parsed['amountCents'] as num?)?.toInt();
    return cents != null && cents > 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fr = Localizations.localeOf(context).languageCode == 'fr';
    final amountCents = (parsed['amountCents'] as num?)?.toInt() ?? 0;
    final currency = (parsed['currency'] as String?)?.trim();
    final categoryId = (parsed['category'] as String?)?.trim();
    final merchant = (parsed['merchant'] as String?)?.trim() ?? '';
    final date = (parsed['date'] as String?)?.trim() ?? '';
    final usable = _hasUsableAmount &&
        currency != null &&
        currency.isNotEmpty &&
        merchant.isNotEmpty;

    final money = Money(
      cents: amountCents,
      currency: currency?.isNotEmpty == true ? currency! : 'CAD',
    );
    final categoryLabel = kBudgetLabels[categoryId] ??
        (categoryId?.isNotEmpty == true ? categoryId! : '—');

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  Text(
                    l10n.validateTitle,
                    style: SiphoTypography.title.copyWith(
                      fontSize: 28,
                      color: SiphoPalette.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SiphoSoftCard(
                    child: Text(
                      usable
                          ? l10n.validateBubbleOk
                          : (fr
                              ? 'Scan incomplet — aucun montant fiable. Rescanne le ticket ou saisis à la main.'
                              : 'Incomplete scan — no reliable amount. Rescan the receipt or enter it manually.'),
                      style: SiphoTypography.body.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SiphoListRow(
                    title: l10n.validateMerchant,
                    trailing: merchant.isEmpty ? '—' : merchant,
                  ),
                  const SiphoSeparator(),
                  SiphoListRow(
                    title: l10n.validateDateLabel,
                    trailing: date.isEmpty ? '—' : date,
                  ),
                  const SiphoSeparator(),
                  SiphoListRow(
                    title: l10n.validateTotal,
                    trailing: usable ? money.format() : '—',
                  ),
                  const SiphoSeparator(),
                  SiphoListRow(
                    title: l10n.validateCategory,
                    trailing: categoryLabel,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  if (usable)
                    SiphoButton3D(
                      label: l10n.validateCta,
                      variant: SiphoButtonVariant.dark,
                      onPressed: () async {
                        await ref.read(expensesProvider.notifier).addExpense(
                              title: merchant,
                              category: categoryId?.isNotEmpty == true
                                  ? categoryId!
                                  : 'Autre',
                              emoji: '🧾',
                              amount: money,
                              source: 'receipt',
                            );
                        if (!context.mounted) return;
                        context.go('/expenses');
                      },
                    )
                  else ...[
                    SiphoButton3D(
                      label: fr ? 'Rescanner' : 'Rescan',
                      variant: SiphoButtonVariant.dark,
                      onPressed: () => context.go('/expenses/scan'),
                    ),
                    const SizedBox(height: 10),
                    SiphoButton3D(
                      label: fr ? 'Saisie manuelle' : 'Enter manually',
                      variant: SiphoButtonVariant.secondary,
                      onPressed: () => context.go('/expenses/add'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
