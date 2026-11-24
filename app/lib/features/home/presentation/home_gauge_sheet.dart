import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../auth/data/user_profile_provider.dart';
import '../../expenses/data/expenses_provider.dart';
import '../../expenses/domain/expense.dart';

/// Feuille ouverte au tap sur la jauge Accueil.
Future<void> showHomeGaugeSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: SiphoPalette.surface(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _HomeGaugeSheet(),
  );
}

class _HomeGaugeSheet extends ConsumerStatefulWidget {
  const _HomeGaugeSheet();

  @override
  ConsumerState<_HomeGaugeSheet> createState() => _HomeGaugeSheetState();
}

class _HomeGaugeSheetState extends ConsumerState<_HomeGaugeSheet> {
  late final TextEditingController _incomeCtrl;
  bool _savingIncome = false;

  @override
  void initState() {
    super.initState();
    final cents = ref.read(userProfileProvider).monthlyIncomeCents;
    final major = cents / 100.0;
    _incomeCtrl = TextEditingController(
      text: cents % 100 == 0
          ? major.toStringAsFixed(0)
          : major.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _incomeCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveIncome() async {
    final l10n = AppLocalizations.of(context);
    final major = double.tryParse(
          _incomeCtrl.text.replaceAll(' ', '').replaceAll(',', '.'),
        ) ??
        0;
    final cents = (major * 100).round();
    if (cents < 0) return;
    setState(() => _savingIncome = true);
    try {
      await ref.read(userProfileProvider.notifier).saveMonthlyIncome(cents);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.homeGaugeIncomeSaved),
          backgroundColor: SiphoColors.primaryDark,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.incomeSaveError),
          backgroundColor: SiphoColors.primaryDark,
        ),
      );
    } finally {
      if (mounted) setState(() => _savingIncome = false);
    }
  }

  Future<void> _editExpense(Expense e) async {
    final l10n = AppLocalizations.of(context);
    final titleCtrl = TextEditingController(text: e.title);
    final amountCtrl = TextEditingController(
      text: (e.amount.cents / 100).toStringAsFixed(
        e.amount.cents % 100 == 0 ? 0 : 2,
      ),
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SiphoPalette.surface(ctx),
        title: Text(l10n.homeGaugeEditExpense),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(labelText: l10n.homeGaugeMerchant),
            ),
            TextField(
              controller: amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.homeGaugeAmount),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.homeGaugeCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.homeGaugeSave),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final dollars =
        double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0;
    final cents = (dollars * 100).round();
    if (cents <= 0) return;
    await ref.read(expensesProvider.notifier).updateExpense(
          id: e.id,
          title: titleCtrl.text.trim().isEmpty ? e.title : titleCtrl.text.trim(),
          amount: Money(cents: cents, currency: e.amount.currency),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final user = ref.watch(userProfileProvider);
    final expenses = ref.watch(expensesProvider);
    final now = DateTime.now();
    final monthExpenses = expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.78,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: SiphoPalette.separator(context),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.homeGaugeSheetTitle,
              style: SiphoTypography.title.copyWith(
                fontSize: 24,
                color: SiphoPalette.textPrimary(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.homeGaugeSheetLead,
              style: SiphoTypography.body.copyWith(
                color: SiphoPalette.textSecondary(context),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.homeGaugeIncomeLabel,
              style: SiphoTypography.bodyBold.copyWith(
                color: SiphoPalette.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _incomeCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: SiphoTypography.amountHero.copyWith(
                      fontSize: 28,
                      color: SiphoPalette.textPrimary(context),
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.homeGaugeIncomeHint,
                      suffixText: user.currency.toUpperCase(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 120,
                  child: SiphoButton3D(
                    label: _savingIncome ? '…' : l10n.homeGaugeSave,
                    variant: SiphoButtonVariant.dark,
                    onPressed: _savingIncome ? null : _saveIncome,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              l10n.homeGaugeHistoryHeading,
              style: SiphoTypography.bodyBold.copyWith(
                color: SiphoPalette.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: monthExpenses.isEmpty
                  ? Text(
                      l10n.homeGaugeHistoryEmpty,
                      style: SiphoTypography.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    )
                  : ListView.separated(
                      itemCount: monthExpenses.length.clamp(0, 40),
                      separatorBuilder: (_, __) => const SiphoSeparator(
                        margin: EdgeInsets.symmetric(vertical: 10),
                      ),
                      itemBuilder: (context, i) {
                        final e = monthExpenses[i];
                        final date =
                            DateFormat.MMMd(locale).format(e.date);
                        return SiphoListRow(
                          title: e.title.isEmpty ? e.category : e.title,
                          subtitle: '$date · ${e.category}',
                          trailing: e.amount.format(locale),
                          showChevron: true,
                          onTap: () => _editExpense(e),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            SiphoListRow(
              title: l10n.homeGaugeSeeAll,
              showChevron: true,
              onTap: () {
                Navigator.of(context).pop();
                context.go('/expenses');
              },
            ),
            const SiphoSeparator(margin: EdgeInsets.symmetric(vertical: 10)),
            SiphoListRow(
              title: l10n.homeGaugeBudgets,
              showChevron: true,
              onTap: () {
                Navigator.of(context).pop();
                context.push('/budget');
              },
            ),
          ],
        ),
      ),
    );
  }
}
