import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../../core/widgets/sipho_status_body.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_profile_provider.dart';
import '../../budget/data/budgets_provider.dart';
import '../../expenses/data/expenses_provider.dart';
import '../../expenses/domain/expense.dart';
import '../../fixed_expenses/data/fixed_expenses_provider.dart';

/// Frame 12 · Dépenses · Épuré (Figma `2:28941`).
class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  Future<void> _editExpense(BuildContext context, WidgetRef ref, Expense e) async {
    final titleCtrl = TextEditingController(text: e.title);
    final amountCtrl = TextEditingController(
      text: (e.amount.cents / 100).toStringAsFixed(2),
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier la dépense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Marchand')),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Montant'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Enregistrer')),
        ],
      ),
    );
    if (ok != true) return;
    final dollars = double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0;
    final cents = (dollars * 100).round();
    if (cents <= 0) return;
    await ref.read(expensesProvider.notifier).updateExpense(
          id: e.id,
          title: titleCtrl.text.trim().isEmpty ? e.title : titleCtrl.text.trim(),
          amount: Money(cents: cents, currency: e.amount.currency),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final auth = ref.watch(authStateProvider);
    final user = ref.watch(userProfileProvider);
    final expenses = ref.watch(expensesProvider);
    final totalVariable = ref.watch(totalVariableExpensesCentsProvider);
    final totalFixed = ref.watch(totalFixedExpensesCentsProvider);
    final now = DateTime.now();
    final monthLabel = DateFormat.yMMMM(locale).format(now);
    final todayKey = DateFormat.yMd(locale).format(now);

    if (auth.isLoading) {
      return Scaffold(
        backgroundColor: SiphoPalette.background(context),
        body: SafeArea(
          child: SiphoStatusBody(
            title: l10n.expensesLoadingHeading,
            lead: l10n.expensesLoadingLead,
            loading: true,
          ),
        ),
      );
    }

    if (auth.hasError) {
      return Scaffold(
        backgroundColor: SiphoPalette.background(context),
        body: SafeArea(
          child: SiphoStatusBody(
            title: l10n.expensesErrorHeading,
            lead: l10n.expensesErrorLead,
            cardTitle: l10n.expensesErrorCardTitle,
            cardBody: l10n.expensesErrorCardBody,
            ctaLabel: l10n.retryBtn,
            onCta: () => ref.invalidate(authStateProvider),
          ),
        ),
      );
    }

    final grouped = <String, List<Expense>>{};
    for (final e in expenses) {
      final key = DateFormat.yMd(locale).format(e.date);
      final label = key == todayKey
          ? l10n.expensesToday
          : DateFormat('d MMMM', locale).format(e.date).toUpperCase();
      grouped.putIfAbsent(label, () => []).add(e);
    }

    if (expenses.isEmpty) {
      return Scaffold(
        backgroundColor: SiphoPalette.background(context),
        body: SafeArea(
          child: SiphoStatusBody(
            title: l10n.expensesEmptyHeading,
            lead: l10n.expensesEmptyLead,
            amountLabel: Money(cents: 0, currency: user.currency).formatWhole(),
            kicker: l10n.expensesEmptyKicker,
            cardTitle: l10n.expensesEmptyCardTitle,
            cardBody: l10n.expensesEmptyCardBody,
            ctaLabel: l10n.expensesEmptyCta,
            onCta: () => context.push('/expenses/add'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Text(
              l10n.expensesTitle,
              style: SiphoTypography.title.copyWith(
                fontSize: 28,
                color: SiphoPalette.textPrimary(context),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.expensesMonthPicker(monthLabel),
              style: SiphoTypography.body.copyWith(
                fontSize: 16,
                color: SiphoPalette.textSecondary(context),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Money(cents: totalVariable, currency: user.currency).formatWhole(),
              style: SiphoTypography.amountHero.copyWith(
                fontSize: 56,
                color: SiphoPalette.textPrimary(context),
                height: 1.3,
              ),
            ),
            Text(
              l10n.expensesSpentKicker,
              style: SiphoTypography.label.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: SiphoPalette.textSecondary(context),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            SiphoListRow(
              title: l10n.expensesFixedApart,
              subtitle: l10n.expensesSeeBills,
              trailing: Money(cents: totalFixed, currency: user.currency).formatWhole(),
              onTap: () => context.push('/fixed-expenses'),
            ),
            const SizedBox(height: 12),
            SiphoListRow(
              title: l10n.expensesCharts,
              subtitle: 'Budgets et tendances →',
              onTap: () => context.push('/budget'),
            ),
            const SizedBox(height: 12),
            SiphoListRow(
              title: l10n.scanTitle,
              subtitle: 'Photo → validation → +15 XP serveur',
              showChevron: true,
              onTap: () => context.push('/expenses/scan'),
            ),
            const SiphoSeparator(margin: EdgeInsets.symmetric(vertical: 16)),
            ...grouped.entries.expand((entry) {
                return [
                  Text(
                    entry.key,
                    style: SiphoTypography.label.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: SiphoPalette.textSecondary(context),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...entry.value.map((e) {
                    final catLabel = kBudgetLabels[e.category] ?? e.category;
                    final note = e.hasReceipt
                        ? '$catLabel · ${l10n.expenseScannedBadge}'
                        : catLabel;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          SiphoListRow(
                            title: e.title,
                            subtitle: note,
                            trailing: e.amount.format(),
                            onTap: () => _editExpense(context, ref, e),
                          ),
                          const SiphoSeparator(margin: EdgeInsets.only(top: 12)),
                        ],
                      ),
                    );
                  }),
                ];
              }),
            Text(
              l10n.expensesSeeAll,
              style: SiphoTypography.label.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: SiphoPalette.textPrimary(context),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
