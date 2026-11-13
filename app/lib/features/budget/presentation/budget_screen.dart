import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_radius.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/app/theme/app_text_styles.dart';
import 'package:sipho/core/money/money.dart';
import 'package:sipho/core/money/money_formatter.dart';
import 'package:sipho/core/widgets/gauge_horizontal.dart';
import 'package:sipho/features/budget/domain/month_chart.dart';
import 'package:sipho/features/expenses/presentation/expense_category_label.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final monthKey = currentMonthKey();
    final transactions = ref.watch(transactionsForMonthProvider(monthKey));
    final currency =
        ref.watch(userFinanceProvider).valueOrNull?.currency ?? 'CAD';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.budgetTitle)),
      body: SafeArea(
        child: transactions.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (_, __) => Center(child: Text(l10n.expensesLoadError)),
          data: (items) {
            final chart = buildMonthChart([
              for (final tx in items)
                (
                  category: tx.category,
                  cents: tx.amountMainCents ?? tx.amountCents,
                  date: tx.date,
                ),
            ]);
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              children: [
                Text(l10n.budgetIntro, style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.md),
                if (chart.slices.isEmpty)
                  Text(
                    l10n.chartsEmpty,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  for (final slice in chart.slices)
                    _CategoryRow(
                      name: slice.category == 'other'
                          ? l10n.chartsOtherName
                          : expenseCategoryLabel(l10n, slice.category),
                      amount: MoneyFormatter.format(
                        Money(cents: slice.cents, currency: currency),
                        locale: Localizations.localeOf(context).toString(),
                      ),
                      percent: chart.totalCents == 0
                          ? 0
                          : slice.cents / chart.totalCents,
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.name,
    required this.amount,
    required this.percent,
  });

  final String name;
  final String amount;
  final double percent;

  @override
  Widget build(BuildContext context) {
    final color = percent >= 0.5
        ? AppColors.budgetOver
        : percent >= 0.3
            ? AppColors.budgetWarn
            : AppColors.budgetOk;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(name, style: AppTextStyles.bodySemiBold),
              ),
              Text(amount, style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GaugeHorizontal(
            progress: percent.clamp(0, 1),
            color: color,
            backgroundColor: AppColors.border,
          ),
        ],
      ),
    );
  }
}
