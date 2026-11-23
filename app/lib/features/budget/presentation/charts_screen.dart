import 'package:fl_chart/fl_chart.dart';
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
import 'package:sipho/features/budget/domain/month_chart.dart';
import 'package:sipho/features/expenses/domain/transaction.dart';
import 'package:sipho/features/expenses/presentation/expense_category_label.dart';
import 'package:sipho/features/expenses/presentation/expenses_section_tabs.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/gamification/data/game_state_repository.dart';

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
    final game = ref.watch(gameStateStreamProvider).valueOrNull;
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
                Text(
                  l10n.chartsTitle,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                ExpensesSectionTabs(
                  selectedIndex: 2,
                  onSelectTab: (index) {
                    ref.read(expensesSectionTabProvider.notifier).state = index;
                    if (index == 2) return;
                    context.go('/expenses');
                  },
                ),
                const SizedBox(height: 12),
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
                      l10n.homeSeedsLevel(
                        '${game?.gems ?? 0}',
                        game?.level ?? 1,
                      ),
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
                _FixedVariableCard(
                  l10n: l10n,
                  split: buildFixedVsVariable([
                    for (final row in _rows(items))
                      (category: row.category, cents: row.cents),
                  ]),
                  format: (cents) =>
                      _formatCents(context, cents, currency),
                ),
                const SizedBox(height: 16),
                _SixMonthTrendCard(
                  l10n: l10n,
                  points: _sixMonthPoints(ref, month),
                  format: (cents) =>
                      _formatCents(context, cents, currency),
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
        cents: tx.spendMainCents,
        date: tx.date,
      ),
  ];
}

List<MonthTrendPoint> _sixMonthPoints(WidgetRef ref, DateTime endMonth) {
  final totals = <String, int>{};
  for (var i = 0; i < 6; i++) {
    final m = DateTime(endMonth.year, endMonth.month - i);
    final key = monthKeyOf(m);
    final summary = ref.watch(monthSummaryProvider(key)).valueOrNull;
    totals[key] = summary?.spentCents ?? 0;
  }
  return buildSixMonthTrend(endMonth: endMonth, totalsByMonth: totals);
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

class _FixedVariableCard extends StatelessWidget {
  const _FixedVariableCard({
    required this.l10n,
    required this.split,
    required this.format,
  });

  final AppLocalizations l10n;
  final FixedVsVariable split;
  final String Function(int cents) format;

  @override
  Widget build(BuildContext context) {
    final total = split.totalCents;
    final fixedFrac = total == 0 ? 0.0 : split.fixedCents / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.chartsFixedVsVariable,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 14,
                  child: Row(
                    children: [
                      Expanded(
                        flex: (fixedFrac * 1000).round().clamp(0, 1000),
                        child: const ColoredBox(color: AppColors.primaryDark),
                      ),
                      Expanded(
                        flex: ((1 - fixedFrac) * 1000).round().clamp(0, 1000),
                        child: const ColoredBox(color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.chartsFixedLabel}\n${format(split.fixedCents)}',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                        height: 1.3,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${l10n.chartsVariableLabel}\n${format(split.variableCents)}',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SixMonthTrendCard extends StatelessWidget {
  const _SixMonthTrendCard({
    required this.l10n,
    required this.points,
    required this.format,
  });

  final AppLocalizations l10n;
  final List<MonthTrendPoint> points;
  final String Function(int cents) format;

  @override
  Widget build(BuildContext context) {
    final maxCents = points.fold<int>(
      0,
      (m, p) => p.totalCents > m ? p.totalCents : m,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.chartsSixMonths,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 160,
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: maxCents <= 0
              ? Center(
                  child: Text(
                    l10n.chartsEmpty,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: maxCents * 1.15,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          getTitlesWidget: (value, meta) {
                            final i = value.round();
                            if (i < 0 || i >= points.length) {
                              return const SizedBox.shrink();
                            }
                            final label = points[i].monthKey.substring(5);
                            return Text(
                              label,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (spots) => [
                          for (final spot in spots)
                            LineTooltipItem(
                              format(spot.y.round()),
                              const TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < points.length; i++)
                            FlSpot(i.toDouble(), points[i].totalCents.toDouble()),
                        ],
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withValues(alpha: 0.12),
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

const _arrow = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 18,
  fontWeight: FontWeight.w800,
  color: AppColors.primaryDark,
);
