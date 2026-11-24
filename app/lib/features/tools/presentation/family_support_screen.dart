import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../../core/widgets/sipho_page_header.dart';
import '../../auth/data/user_profile_provider.dart';
import '../../expenses/data/expenses_provider.dart';
import '../../fixed_expenses/data/fixed_expenses_provider.dart';

/// Frame 52 · Soutien à la famille — agrégats `family` du mois.
class FamilySupportScreen extends ConsumerWidget {
  const FamilySupportScreen({super.key});

  bool _isFamily(String category) {
    final c = category.toLowerCase();
    return c == 'family' ||
        c.contains('famille') ||
        c.contains('soutien') ||
        c.contains('family');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final currency = ref.watch(userProfileProvider).currency;
    final now = DateTime.now();
    final expenses = ref.watch(expensesProvider).where((e) {
      return e.date.year == now.year &&
          e.date.month == now.month &&
          _isFamily(e.category);
    }).toList();
    final fixed = ref.watch(fixedExpensesProvider).where((e) {
      return _isFamily(e.category) || _isFamily(e.name);
    }).toList();

    final variableCents = expenses.fold<int>(
      0,
      (acc, e) => acc + (e.amountMainCents ?? e.amount.cents),
    );
    final plannedCents =
        fixed.fold<int>(0, (acc, e) => acc + e.amount.cents);
    final totalCents = variableCents + plannedCents;

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            SiphoPageHeader(
              title: l10n.familySupportHeading,
              lead: l10n.familySupportLead,
            ),
            const SizedBox(height: 20),
            Text(
              Money(cents: totalCents, currency: currency).format(locale),
              style: SiphoTypography.amountHero.copyWith(
                fontSize: 56,
                color: SiphoPalette.textPrimary(context),
              ),
            ),
            Text(
              l10n.familySupportKicker,
              style: SiphoTypography.label.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: SiphoPalette.textSecondary(context),
              ),
            ),
            const SizedBox(height: 20),
            SiphoListRow(
              title: l10n.familySupportPlanned,
              trailing:
                  Money(cents: plannedCents, currency: currency).format(locale),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: l10n.familySupportExtra,
              trailing: Money(cents: variableCents, currency: currency)
                  .format(locale),
            ),
            if (expenses.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                Localizations.localeOf(context).languageCode == 'fr'
                    ? 'Ce mois'
                    : 'This month',
                style: SiphoTypography.bodyBold.copyWith(
                  color: SiphoPalette.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              for (final e in expenses.take(8)) ...[
                SiphoListRow(
                  title: e.title.isEmpty ? e.category : e.title,
                  trailing: Money(
                    cents: e.amountMainCents ?? e.amount.cents,
                    currency: currency,
                  ).format(locale),
                ),
                const SiphoSeparator(),
              ],
            ],
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: SiphoPalette.softSurface(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                l10n.familySupportTip,
                style: SiphoTypography.bodyBold.copyWith(
                  fontSize: 16,
                  color: SiphoPalette.textPrimary(context),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SiphoButton3D(
              label: l10n.expenseAmountHeading,
              variant: SiphoButtonVariant.secondary,
              onPressed: () => context.push('/expenses/add'),
            ),
          ],
        ),
      ),
    );
  }
}
