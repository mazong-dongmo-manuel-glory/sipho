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
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/fixed_expenses/presentation/fixed_expenses_list_screen.dart';
import 'package:sipho/features/gamification/data/game_state_repository.dart';

class ExpensesListScreen extends ConsumerStatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  ConsumerState<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends ConsumerState<ExpensesListScreen> {
  int _tab = 0;

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
    final month = ref.watch(expensesMonthProvider);
    final monthKey = monthKeyOf(month);
    final transactions = ref.watch(transactionsForMonthProvider(monthKey));
    final currency =
        ref.watch(userFinanceProvider).valueOrNull?.currency ?? 'CAD';
    final game = ref.watch(gameStateStreamProvider).valueOrNull;
    final now = DateTime.now();
    final isCurrent = month.year == now.year && month.month == now.month;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: _tab == 1
            ? SocleView(
                onSelectTab: (index) {
                  if (index == 2) {
                    context.push('/charts');
                    return;
                  }
                  setState(() => _tab = index);
                },
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  8,
                  AppSpacing.pagePadding,
                  24,
                ),
                children: [
                  _Pills(
                    streak: game?.streak.current,
                    seeds: game?.gems,
                    level: l10n.homeLevelPill(game?.level ?? 1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.expensesTitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Tabs(
                    labels: [
                      l10n.expensesThisMonth,
                      l10n.expensesBase,
                      l10n.expensesCharts,
                    ],
                    selected: _tab,
                    onTap: (index) {
                      if (index == 2) {
                        context.push('/charts');
                        return;
                      }
                      setState(() => _tab = index);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _shiftMonth(-1),
                        child: const Text('‹', style: _monthArrow),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        _monthLabel(context, month),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 24),
                      GestureDetector(
                        onTap: isCurrent ? null : () => _shiftMonth(1),
                        child: Text(
                          '›',
                          style: _monthArrow.copyWith(
                            color: isCurrent
                                ? AppColors.textSecondary
                                : AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._monthBody(context, l10n, transactions, currency),
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
          (sum, tx) => sum + (tx.amountMainCents ?? tx.amountCents),
        );
        final groups = <String, List<SiphoTransaction>>{};
        for (final tx in items) {
          groups.putIfAbsent(tx.date, () => []).add(tx);
        }
        return [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.expensesSpentKicker,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.spentMuted,
                  ),
                ),
                Text(
                  _formatCents(context, spent, currency),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
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
              if (i > 0) const SizedBox(height: 8),
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

const _monthArrow = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 18,
  fontWeight: FontWeight.w800,
  color: AppColors.primaryDark,
);

class _Pills extends StatelessWidget {
  const _Pills({
    required this.level,
    this.streak,
    this.seeds,
  });

  final String level;
  final int? streak;
  final int? seeds;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Pill(AppColors.flamePill, AppColors.flameText, '🔥  ${streak ?? '—'}'),
        const SizedBox(width: 16),
        _Pill(AppColors.seedPill, AppColors.seedText, '🌾  ${seeds ?? '—'}'),
        const SizedBox(width: 16),
        _Pill(AppColors.mint, AppColors.primaryDark, level),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.background, this.foreground, this.label);

  final Color background;
  final Color foreground;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: foreground,
          ),
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.labels,
    required this.selected,
    required this.onTap,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.72,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: i == selected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

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
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 65),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.seedPill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  expenseCategoryIcon(transaction.category),
                  color: AppColors.categoryGold,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
