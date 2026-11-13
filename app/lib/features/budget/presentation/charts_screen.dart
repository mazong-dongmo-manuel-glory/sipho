import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/money/money.dart';
import 'package:sipho/core/money/money_formatter.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/features/budget/domain/month_chart.dart';
import 'package:sipho/features/expenses/domain/transaction.dart';
import 'package:sipho/features/expenses/presentation/expense_category_label.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';

const _sliceColors = [
  AppColors.primaryDark,
  AppColors.terracotta,
  AppColors.accent,
  AppColors.primary,
];

class ChartsScreen extends ConsumerWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final month = ref.watch(expensesMonthProvider);
    final monthKey = monthKeyOf(month);
    final previous = DateTime(month.year, month.month - 1);
    final transactions = ref.watch(transactionsForMonthProvider(monthKey));
    final previousTransactions =
        ref.watch(transactionsForMonthProvider(monthKeyOf(previous)));
    final currency =
        ref.watch(userFinanceProvider).valueOrNull?.currency ?? 'CAD';
    final summary = ref.watch(monthSummaryProvider(monthKey)).valueOrNull;
    final overspent =
        summary != null && summary.hasIncome && summary.remainingCents < 0;
    final now = DateTime.now();
    final isCurrent = month.year == now.year && month.month == now.month;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: transactions.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (_, __) => Center(
            child: Text(
              l10n.expensesLoadError,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          data: (items) {
            final chart = buildMonthChart(_rows(items));
            final previousItems = previousTransactions.valueOrNull;
            final previousTotal = previousItems == null
                ? null
                : buildMonthChart(_rows(previousItems)).totalCents;
            final change = previousTotal == null
                ? null
                : spendingChangePercent(chart.totalCents, previousTotal);
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
                    const Expanded(
                      child: _Pill(
                          AppColors.flamePill, AppColors.flameText, '🔥  12'),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: _Pill(
                          AppColors.seedPill, AppColors.seedText, '🌾  340'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _Pill(
                        AppColors.mint,
                        AppColors.primaryDark,
                        l10n.homeLevelPill(7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.chartsTitle,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    color: AppColors.primaryDark,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _shiftMonth(ref, -1),
                      child: const Text('‹', style: _arrow),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _monthLabel(context, month),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: isCurrent ? null : () => _shiftMonth(ref, 1),
                      child: Text(
                        '›',
                        style: _arrow.copyWith(
                          color: isCurrent
                              ? AppColors.textSecondary
                              : AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DonutCard(
                  l10n: l10n,
                  chart: chart,
                  totalLabel: _formatCents(context, chart.totalCents, currency),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.chartsByWeekday,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                _WeekBars(
                  cents: chart.weekdayCents,
                  letters: _weekdayLetters(context),
                ),
                const SizedBox(height: 16),
                if (chart.slices.isEmpty)
                  Text(
                    l10n.chartsEmpty,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: overspent ? 88 : 0),
                        child: Column(
                          children: [
                            for (var i = 0; i < chart.slices.length; i++) ...[
                              if (i > 0) const SizedBox(height: 12),
                              _ShareBar(
                                label: l10n.chartsCategoryShare(
                                  _sliceName(l10n, chart.slices[i].category),
                                  sharePercent(
                                      chart.slices[i].cents, chart.totalCents),
                                ),
                                progress: chart.totalCents == 0
                                    ? 0
                                    : chart.slices[i].cents / chart.totalCents,
                                color: _sliceColors[i % _sliceColors.length],
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (overspent) ...[
                        const Positioned(
                          right: 0,
                          bottom: 0,
                          child: SiphoArt.worried(frame: 65),
                        ),
                        Positioned(
                          right: 72,
                          bottom: 28,
                          child: Text(
                            l10n.chartsSlowDown,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.terracotta,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                if (change != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    height: 32,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _summary(l10n, change),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _shiftMonth(WidgetRef ref, int delta) {
    final current = ref.read(expensesMonthProvider);
    final now = DateTime.now();
    final next = DateTime(current.year, current.month + delta);
    if (next.year > now.year ||
        (next.year == now.year && next.month > now.month)) {
      return;
    }
    ref.read(expensesMonthProvider.notifier).state = next;
  }
}

List<({String category, int cents, String date})> _rows(
    List<SiphoTransaction> items) {
  return [
    for (final tx in items)
      (
        category: tx.category,
        cents: tx.amountMainCents ?? tx.amountCents,
        date: tx.date,
      ),
  ];
}

String _sliceName(AppLocalizations l10n, String category) {
  if (category == 'other') return l10n.chartsOtherName;
  return expenseCategoryLabel(l10n, category);
}

String _summary(AppLocalizations l10n, int change) {
  if (change < 0) return l10n.chartsSummaryLess(change.abs());
  if (change > 0) return l10n.chartsSummaryMore(change);
  return l10n.chartsSummarySame;
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

List<String> _weekdayLetters(BuildContext context) {
  final locale = Localizations.localeOf(context).toString();
  final monday = DateTime(2026, 1, 5);
  return List.generate(7, (index) {
    final raw = DateFormat.E(locale).format(monday.add(Duration(days: index)));
    if (raw.isEmpty) return '';
    return raw[0].toUpperCase();
  });
}

class _DonutCard extends StatelessWidget {
  const _DonutCard({
    required this.l10n,
    required this.chart,
    required this.totalLabel,
  });

  final AppLocalizations l10n;
  final MonthChartData chart;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    final sections = chart.totalCents == 0
        ? [
            PieChartSectionData(
              value: 1,
              color: AppColors.border,
              radius: 22,
              showTitle: false,
            ),
          ]
        : [
            for (var i = 0; i < chart.slices.length; i++)
              PieChartSectionData(
                value: chart.slices[i].cents.toDouble(),
                color: _sliceColors[i % _sliceColors.length],
                radius: 22,
                showTitle: false,
              ),
          ];
    return Container(
      height: 191,
      padding: const EdgeInsets.fromLTRB(17, 24, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 46,
                      startDegreeOffset: -90,
                      sections: sections,
                    ),
                  ),
                ),
                Text(
                  totalLabel,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (chart.slices.isEmpty)
                  Text(
                    l10n.chartsEmpty,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  for (var i = 0; i < chart.slices.length; i++)
                    _Legend(
                      _sliceColors[i % _sliceColors.length],
                      l10n.chartsSlice(
                        _sliceName(l10n, chart.slices[i].category),
                        sharePercent(chart.slices[i].cents, chart.totalCents),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekBars extends StatelessWidget {
  const _WeekBars({required this.cents, required this.letters});

  final List<int> cents;
  final List<String> letters;

  @override
  Widget build(BuildContext context) {
    final maxCents =
        cents.fold<int>(0, (max, value) => value > max ? value : max);
    return SizedBox(
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 28,
                    height: maxCents == 0 ? 4 : 8 + 75 * (cents[i] / maxCents),
                    decoration: BoxDecoration(
                      color: maxCents > 0 && cents[i] == maxCents
                          ? AppColors.accent
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    i < letters.length ? letters[i] : '',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ShareBar extends StatelessWidget {
  const _ShareBar({
    required this.label,
    required this.progress,
    required this.color,
  });

  final String label;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            width: double.infinity,
            child: Stack(
              children: [
                const ColoredBox(color: AppColors.border),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0, 1),
                  child: ColoredBox(color: color),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.color, this.label);

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
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
    return Container(
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}

const _arrow = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 18,
  fontWeight: FontWeight.w800,
  color: AppColors.primaryDark,
);
