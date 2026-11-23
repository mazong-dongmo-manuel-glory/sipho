import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/money/money.dart';
import 'package:sipho/core/money/money_formatter.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/expenses/domain/transaction.dart';
import 'package:sipho/features/expenses/presentation/expense_category_label.dart';
import 'package:sipho/features/expenses/presentation/expenses_section_tabs.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_expense.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_expense_draft.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_expense_schedule.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_paid.dart';
import 'package:sipho/features/fixed_expenses/presentation/edit_fixed_expense_sheet.dart';
import 'package:sipho/features/fixed_expenses/presentation/fixed_paid_button.dart';
import 'package:sipho/features/gamification/data/game_state_repository.dart';

class FixedExpensesListScreen extends StatelessWidget {
  const FixedExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: SocleView()),
    );
  }
}

class SocleView extends ConsumerWidget {
  const SocleView({
    super.key,
    this.onSelectTab,
    this.showSectionTabs = true,
  });

  final ValueChanged<int>? onSelectTab;

  /// When false, the parent already shows [ExpensesSectionTabs].
  final bool showSectionTabs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fixed = ref.watch(activeFixedExpensesProvider);
    final currency =
        ref.watch(userFinanceProvider).valueOrNull?.currency ?? 'CAD';
    final game = ref.watch(gameStateStreamProvider).valueOrNull;
    final transactions = ref
            .watch(transactionsForMonthProvider(currentMonthKey()))
            .valueOrNull ??
        const <SiphoTransaction>[];
    final paidIds =
        ref.watch(paidFixedIdsProvider(currentMonthKey())).valueOrNull ??
            const <String>{};
    final monthLabel =
        DateFormat.yMMMM(Localizations.localeOf(context).toString())
            .format(DateTime.now())
            .toUpperCase();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        8,
        AppSpacing.pagePadding,
        24,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.homeStreakDays(game?.streak.current ?? 0),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            Text(
              l10n.homeSeedsLevel('${game?.gems ?? 0}', game?.level ?? 1),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.socleTitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    l10n.socleSubtitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SiphoArt.happy(frame: 100),
          ],
        ),
        if (showSectionTabs && onSelectTab != null) ...[
          const SizedBox(height: 12),
          ExpensesSectionTabs(
            selectedIndex: 1,
            onSelectTab: onSelectTab!,
          ),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                monthLabel,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.socleWeekdays,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              _DueDays(days: _dueDays(fixed.valueOrNull ?? const [])),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._rows(context, l10n, fixed, transactions, currency, paidIds),
        const SizedBox(height: 12),
        SiphoButton3D(
          label: l10n.socleAdd,
          height: 48,
          onPressed: () => _addBrin(context),
        ),
      ],
    );
  }

  List<Widget> _rows(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<List<FixedExpense>> fixed,
    List<SiphoTransaction> transactions,
    String currency,
    Set<String> paidIds,
  ) {
    return fixed.when(
      loading: () => const [
        SizedBox(height: 24),
        Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ],
      error: (_, __) => [
        Text(
          l10n.socleSaveError,
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
        if (items.isEmpty) {
          return [
            Text(
              l10n.socleEmpty,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ];
        }
        final total = items.fold<int>(0, (sum, item) => sum + item.amountCents);
        final now = DateTime.now();
        final today = now.day;
        return [
          for (final item in items) ...[
            _Row(
              item.icon,
              item.name.trim().isNotEmpty
                  ? item.name.trim()
                  : expenseCategoryLabel(l10n, item.category),
              isFixedPaid(item, paidIds: paidIds, now: now)
                  ? l10n.soclePaidOn('${item.dueDay}')
                  : _note(l10n, item, transactions),
              _formatCents(context, item.amountCents, currency),
              onTap: () => showEditFixedExpenseSheet(context, item),
              trailing: canMarkFixedPaid(item, paidIds: paidIds)
                  ? FixedPaidButton(fixedId: item.id)
                  : null,
              noteColor: item.type != 'envelope' &&
                      !isFixedPaid(item, paidIds: paidIds, now: now) &&
                      (item.dueDay - today).abs() <= 1
                  ? AppColors.warnBrown
                  : AppColors.textSecondary,
              progress: item.type == 'envelope'
                  ? envelopeRatio(
                      _spent(transactions, item.category), item.amountCents)
                  : null,
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 4),
          Text(
            l10n.socleTotalAmount(_formatCents(context, total, currency)),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
          ),
        ];
      },
    );
  }
}

Future<void> _addBrin(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final draft = await showModalBottomSheet<FixedExpenseDraft>(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.soclePickTitle,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              for (final template in kSocleTemplates)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(template.emoji,
                      style: const TextStyle(fontSize: 24)),
                  title: Text(
                    expenseCategoryLabel(l10n, template.categoryId),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(template),
                ),
            ],
          ),
        ),
      );
    },
  );
  if (draft == null || !context.mounted) return;
  await context.push('/fixed-expenses/amount', extra: draft);
}

List<int> _dueDays(List<FixedExpense> items) {
  final days = items
      .where((item) => item.type != 'envelope')
      .map((item) => item.dueDay)
      .toSet()
      .toList()
    ..sort();
  return days;
}

int _spent(List<SiphoTransaction> transactions, String category) {
  return transactions
      .where((tx) => tx.category == category)
      .fold<int>(0, (sum, tx) => sum + tx.spendMainCents);
}

String _note(
  AppLocalizations l10n,
  FixedExpense item,
  List<SiphoTransaction> transactions,
) {
  if (item.type == 'envelope') {
    final percent =
        (envelopeRatio(_spent(transactions, item.category), item.amountCents) *
                100)
            .round();
    return l10n.socleEnvelopePercent(percent);
  }
  return l10n.socleUpcoming('${item.dueDay}');
}

String _formatCents(BuildContext context, int cents, String currency) {
  return MoneyFormatter.format(
    Money(cents: cents, currency: currency),
    locale: Localizations.localeOf(context).toString(),
  );
}

class _DueDays extends StatelessWidget {
  const _DueDays({required this.days});

  final List<int> days;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return const SizedBox(height: 8);
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final day in days) _Day('$day', AppColors.primary),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(
    this.emoji,
    this.title,
    this.note,
    this.amount, {
    this.onTap,
    this.trailing,
    this.noteColor = AppColors.textSecondary,
    this.progress,
  });

  final String emoji;
  final String title;
  final String note;
  final String amount;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color noteColor;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: progress == null ? 48 : 58,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 19)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        note,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: noteColor,
                        ),
                      ),
                      if (progress != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: SizedBox(
                              height: 7,
                              width: 150,
                              child: Stack(
                                children: [
                                  const ColoredBox(color: AppColors.border),
                                  FractionallySizedBox(
                                    widthFactor: progress,
                                    child: const ColoredBox(
                                        color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
                if (onTap != null) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Day extends StatelessWidget {
  const _Day(this.label, this.dot);

  final String label;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: dot ?? Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}


