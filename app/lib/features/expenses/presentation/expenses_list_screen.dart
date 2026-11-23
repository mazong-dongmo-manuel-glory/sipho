import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/money/money.dart';
import 'package:sipho/core/money/money_formatter.dart';
import 'package:sipho/core/time/local_day.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/expenses/data/transaction_repository.dart';
import 'package:sipho/features/expenses/domain/transaction.dart';
import 'package:sipho/features/expenses/presentation/edit_expense_sheet.dart';
import 'package:sipho/features/expenses/presentation/expense_category_label.dart';
import 'package:sipho/features/expenses/presentation/expenses_section_tabs.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/fixed_expenses/presentation/fixed_expenses_list_screen.dart';

class ExpensesListScreen extends ConsumerStatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  ConsumerState<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends ConsumerState<ExpensesListScreen> {
  void _selectSection(int index) {
    ref.read(expensesSectionTabProvider.notifier).state = index;
    if (index == 2) {
      context.go('/charts');
      return;
    }
    // Stay on /expenses for Ce mois / Mon socle.
    if (GoRouterState.of(context).matchedLocation != '/expenses') {
      context.go('/expenses');
    }
  }

  void _shiftMonth(int delta) {
    final current = ref.read(expensesMonthProvider);
    final now = DateTime.now();
    final next = DateTime(current.year, current.month + delta);
    if (next.year > now.year ||
        (next.year == now.year && next.month > now.month)) {
      return;
    }
    ref.read(expensesMonthProvider.notifier).state = next;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tab = ref.watch(expensesSectionTabProvider);
    // Coming back from /charts: keep "Ce mois" or "Mon socle", not charts.
    final section = tab == 2 ? 0 : tab;
    final month = ref.watch(expensesMonthProvider);
    final monthKey = monthKeyOf(month);
    final transactions = ref.watch(transactionsForMonthProvider(monthKey));
    final currency =
        ref.watch(userFinanceProvider).valueOrNull?.currency ?? 'CAD';
    final fixed = ref.watch(activeFixedExpensesProvider).valueOrNull ?? const [];
    final fixedTotal = fixed.fold<int>(0, (sum, item) => sum + item.amountCents);
    final now = DateTime.now();
    final isCurrent = month.year == now.year && month.month == now.month;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                8,
                AppSpacing.pagePadding,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (section == 0) ...[
                    Text(
                      l10n.expensesTitle,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ExpensesSectionTabs(
                    selectedIndex: section,
                    onSelectTab: _selectSection,
                  ),
                ],
              ),
            ),
            Expanded(
              child: section == 1
                  ? SocleView(
                      showSectionTabs: false,
                      onSelectTab: _selectSection,
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pagePadding,
                        16,
                        AppSpacing.pagePadding,
                        24,
                      ),
                      children: [
                        Row(
                          children: [
                            Semantics(
                              button: true,
                              label: _monthLabel(context, month),
                              child: GestureDetector(
                                onTap: () => _shiftMonth(-1),
                                child: Text(
                                  '${_monthLabel(context, month)}  ↓',
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 16,
                                    height: 1.3,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            if (!isCurrent) ...[
                              const SizedBox(width: 16),
                              Semantics(
                                button: true,
                                label: _monthLabel(context, month),
                                child: GestureDetector(
                                  onTap: () => _shiftMonth(1),
                                  child: const Icon(
                                    Icons.keyboard_arrow_up_rounded,
                                    size: 22,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),
                        ..._monthBody(
                          context,
                          l10n,
                          transactions,
                          currency,
                          fixedTotal,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _monthBody(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<List<SiphoTransaction>> transactions,
    String currency,
    int fixedTotal,
  ) {
    return transactions.when(
      loading: () => const [
        SizedBox(height: 48),
        Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ],
      error: (_, __) => [
        const SizedBox(height: 24),
        Text(
          l10n.expensesLoadError,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
      ],
      data: (items) {
        final spent = items.fold<int>(
          0,
          (sum, tx) => sum + tx.spendMainCents,
        );
        final groups = <String, List<SiphoTransaction>>{};
        for (final tx in items) {
          groups.putIfAbsent(tx.date, () => []).add(tx);
        }
        return [
          Text(
            _formatCents(context, spent, currency),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 56,
              fontWeight: FontWeight.w900,
              height: 1.3,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.expensesSpentKicker,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.3,
              letterSpacing: 0.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            button: true,
            label: l10n.expensesFixedApart,
            child: GestureDetector(
              onTap: () =>
                  ref.read(expensesSectionTabProvider.notifier).state = 1,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.expensesFixedApart,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        Text(
                          l10n.expensesSeeBills,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCents(context, fixedTotal, currency),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.line),
          if (items.isEmpty) ...[
            const SizedBox(height: 24),
            Text(
              l10n.expensesEmpty,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          for (final entry in groups.entries) ...[
            const SizedBox(height: 16),
            Text(_dayLabel(context, l10n, entry.key), style: _section),
            const SizedBox(height: 8),
            for (var i = 0; i < entry.value.length; i++) ...[
              const SizedBox(height: 16),
              Dismissible(
                key: ValueKey(entry.value[i].id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                confirmDismiss: (_) => _deleteExpense(entry.value[i]),
                child: _ExpenseTile(
                  transaction: entry.value[i],
                  userCurrency: currency,
                  onTap: () => showEditExpenseSheet(context, entry.value[i]),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.line),
            ],
          ],
        ];
      },
    );
  }

  Future<bool> _deleteExpense(SiphoTransaction transaction) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    final l10n = AppLocalizations.of(context);
    if (uid == null) return false;
    try {
      await ref
          .read(transactionRepositoryProvider)
          .deleteTransaction(uid, transaction.id);
      if (!mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.expenseDeleted)),
      );
      return true;
    } catch (_) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.expenseSaveError)),
      );
      return false;
    }
  }
}

String _formatCents(BuildContext context, int cents, String currency) {
  return MoneyFormatter.format(
    Money(cents: cents, currency: currency),
    locale: Localizations.localeOf(context).toString(),
  );
}

String _monthLabel(BuildContext context, DateTime month) {
  final raw = DateFormat.yMMMM(Localizations.localeOf(context).toString())
      .format(month);
  if (raw.isEmpty) return raw;
  return raw[0].toUpperCase() + raw.substring(1);
}

String _dayLabel(BuildContext context, AppLocalizations l10n, String iso) {
  if (iso == LocalDay.now().isoDate) return l10n.expensesToday;
  final parts = iso.split('-');
  if (parts.length != 3) return iso;
  final date = DateTime(
    int.tryParse(parts[0]) ?? 1,
    int.tryParse(parts[1]) ?? 1,
    int.tryParse(parts[2]) ?? 1,
  );
  return DateFormat.MMMd(Localizations.localeOf(context).toString())
      .format(date)
      .toUpperCase();
}

const _section = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 12,
  fontWeight: FontWeight.w800,
  color: AppColors.textSecondary,
);


typedef _ExpenseTile = ExpenseTile;

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    super.key,
    required this.transaction,
    this.userCurrency = 'CAD',
    this.onTap,
  });

  final SiphoTransaction transaction;
  final String userCurrency;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasMerchant = transaction.merchant?.trim().isNotEmpty == true;
    final title = hasMerchant
        ? transaction.merchant!.trim()
        : expenseCategoryLabel(l10n, transaction.category);

    final isScanned = transaction.source == 'receipt';
    final isForeign = transaction.amountMainCents != null &&
        transaction.currency.toUpperCase() != userCurrency.toUpperCase();

    final foreignConversionText = isForeign
        ? '${_formatCents(context, transaction.amountCents, transaction.currency)} → ${_formatCents(context, transaction.amountMainCents!, userCurrency)}'
        : null;

    final subtitleParts = <String>[
      if (hasMerchant) expenseCategoryLabel(l10n, transaction.category),
      if (transaction.note?.trim().isNotEmpty == true) transaction.note!.trim(),
      if (foreignConversionText != null) foreignConversionText,
    ];
    final subtitle = subtitleParts.join(' · ');

    final displayAmount = isForeign
        ? _formatCents(context, transaction.amountMainCents!, userCurrency)
        : _formatCents(context, transaction.amountCents, transaction.currency);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        if (isScanned) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.seedPill,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '📷',
                                  style: TextStyle(fontSize: 10),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  l10n.expenseScannedBadge,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.seedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                displayAmount,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
    );
  }
}
