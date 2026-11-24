import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../../core/widgets/sipho_page_header.dart';
import '../../auth/data/user_profile_provider.dart';
import '../../expenses/data/expenses_provider.dart';
import '../../expenses/domain/expense.dart';
import '../../fixed_expenses/data/fixed_expenses_provider.dart';

/// Frames 47–48 · Graphiques jours/catégories et six mois/structure.
enum ChartsView { hub, days, sixMonths }

class ChartsScreen extends StatelessWidget {
  final ChartsView view;

  const ChartsScreen({super.key, this.view = ChartsView.hub});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (view) {
      ChartsView.hub => _Hub(l10n: l10n),
      ChartsView.days => const _DaysView(),
      ChartsView.sixMonths => const _SixMonthsView(),
    };
  }
}

class _Hub extends ConsumerWidget {
  final AppLocalizations l10n;
  const _Hub({required this.l10n});

  int _monthTotal(List<Expense> expenses, DateTime month) {
    var cents = 0;
    for (final e in expenses) {
      if (e.date.year == month.year && e.date.month == month.month) {
        cents += e.amountMainCents ?? e.amount.cents;
      }
    }
    return cents;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fr = Localizations.localeOf(context).languageCode == 'fr';
    final expenses = ref.watch(expensesProvider);
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final cur = _monthTotal(expenses, thisMonth);
    final prev = _monthTotal(expenses, lastMonth);

    String insight;
    if (prev <= 0 && cur <= 0) {
      insight = fr
          ? 'Pas encore assez de dépenses pour comparer les mois.'
          : 'Not enough spending yet to compare months.';
    } else if (prev <= 0) {
      insight = fr
          ? 'Premier mois suivi — le prochain comparera automatiquement.'
          : 'First tracked month — next month will compare automatically.';
    } else {
      final deltaPct = (((cur - prev) / prev) * 100).round();
      if (deltaPct == 0) {
        insight = fr
            ? 'Même rythme que le mois dernier.'
            : 'Same pace as last month.';
      } else if (deltaPct < 0) {
        insight = fr
            ? 'Tu as dépensé ${deltaPct.abs()} % de moins que le mois dernier.'
            : 'You spent ${deltaPct.abs()}% less than last month.';
      } else {
        insight = fr
            ? 'Tu as dépensé $deltaPct % de plus que le mois dernier.'
            : 'You spent $deltaPct% more than last month.';
      }
    }

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            SiphoPageHeader(
              title: l10n.chartsHeading,
              lead: l10n.chartsLead,
            ),
            const SizedBox(height: 20),
            SiphoListRow(
              title: l10n.chartsDaysTitle,
              subtitle: l10n.chartsDaysSub,
              showChevron: true,
              onTap: () => context.push('/charts/days'),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: l10n.chartsCatsTitle,
              subtitle: l10n.chartsCatsSub,
              showChevron: true,
              onTap: () => context.push('/charts/days'),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: l10n.chartsSixTitle,
              subtitle: l10n.chartsSixSub,
              showChevron: true,
              onTap: () => context.push('/charts/six-months'),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: l10n.chartsStructureTitle,
              subtitle: l10n.chartsStructureSub,
              showChevron: true,
              onTap: () => context.push('/charts/six-months'),
            ),
            const SizedBox(height: 16),
            SiphoSoftCard(
              child: Text(
                insight,
                style: SiphoTypography.bodyBold.copyWith(
                  fontSize: 16,
                  color: SiphoPalette.textPrimary(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaysView extends ConsumerWidget {
  const _DaysView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final expenses = ref.watch(expensesProvider);
    final currency = ref.watch(userProfileProvider).currency;
    final locale = Localizations.localeOf(context);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    final dayTotals = List<int>.filled(7, 0);
    final catTotals = <String, int>{};
    for (final e in expenses) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      final diff = d.difference(start).inDays;
      if (diff < 0 || diff > 6) continue;
      dayTotals[diff] += e.amount.cents;
      catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount.cents;
    }

    final maxDay = dayTotals.fold<int>(0, (a, b) => a > b ? a : b);
    final weekdayLabels = locale.languageCode == 'fr'
        ? const ['L', 'M', 'M', 'J', 'V', 'S', 'D']
        : const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    int peakIdx = 0;
    for (var i = 1; i < 7; i++) {
      if (dayTotals[i] > dayTotals[peakIdx]) peakIdx = i;
    }
    final peakLabel = DateFormat.E(locale.toString()).format(start.add(Duration(days: peakIdx)));
    final peakMoney = Money(cents: dayTotals[peakIdx], currency: currency).format(locale.toString());

    String topCat = '—';
    var topPct = 0;
    final weekSum = dayTotals.fold<int>(0, (a, b) => a + b);
    if (catTotals.isNotEmpty && weekSum > 0) {
      final sorted = catTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topCat = sorted.first.key;
      topPct = ((sorted.first.value / weekSum) * 100).round();
    }

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            SiphoPageHeader(
              title: l10n.chartsDaysTitle,
              lead: l10n.chartsDaysDetailLead,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < 7; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: maxDay <= 0
                                      ? 0.05
                                      : (dayTotals[i] / maxDay).clamp(0.05, 1.0),
                                  widthFactor: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: SiphoColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              weekdayLabels[i],
                              style: SiphoTypography.label.copyWith(
                                fontWeight: FontWeight.w700,
                                color: SiphoPalette.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SiphoListRow(
              title: l10n.chartsDaysPeak,
              trailing: weekSum == 0 ? '—' : '$peakLabel · $peakMoney',
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: l10n.chartsDaysCats,
              trailing: weekSum == 0 ? '—' : '$topCat $topPct %',
            ),
          ],
        ),
      ),
    );
  }
}

class _SixMonthsView extends ConsumerWidget {
  const _SixMonthsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final expenses = ref.watch(expensesProvider);
    final fixed = ref.watch(fixedExpensesProvider);
    final locale = Localizations.localeOf(context);
    final now = DateTime.now();

    final months = <({String label, int cents})>[];
    for (var i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      final label = DateFormat.MMM(locale.toString()).format(m);
      var cents = 0;
      for (final e in expenses) {
        if (e.date.year == m.year && e.date.month == m.month) {
          cents += e.amount.cents;
        }
      }
      months.add((label: label, cents: cents));
    }

    final maxM = months.fold<int>(0, (a, b) => a > b.cents ? a : b.cents);
    final fixedMonthly =
        fixed.where((f) => f.active).fold<int>(0, (a, b) => a + b.amount.cents);
    final thisMonthVar = months.isEmpty ? 0 : months.last.cents;
    final structureTotal = fixedMonthly + thisMonthVar;
    final fixedPct = structureTotal <= 0
        ? 0
        : ((fixedMonthly / structureTotal) * 100).round();
    final varPct = structureTotal <= 0 ? 0 : 100 - fixedPct;

    final fr = locale.languageCode == 'fr';
    final recent = months.length >= 2 ? months.sublist(months.length - 2) : months;
    final trendDown = recent.length == 2 && recent.last.cents < recent.first.cents;
    final trendUp = recent.length == 2 && recent.last.cents > recent.first.cents;
    final sixInsight = recent.length < 2 ||
            (recent.first.cents == 0 && recent.last.cents == 0)
        ? (fr
            ? 'Pas assez d’historique pour voir la tendance.'
            : 'Not enough history to spot a trend.')
        : trendDown
            ? (fr
                ? 'La ligne descend — ton nid respire mieux.'
                : 'The line is down — your nest breathes easier.')
            : trendUp
                ? (fr
                    ? 'La ligne monte — regarde où tu peux alléger.'
                    : 'The line is up — look where you can trim.')
                : (fr
                    ? 'Dépenses stables sur les derniers mois.'
                    : 'Spending steady over recent months.');

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            SiphoPageHeader(
              title: l10n.chartsSixTitle,
              lead: l10n.chartsSixDetailLead,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final m in months)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: maxM <= 0
                                      ? 0.05
                                      : (m.cents / maxM).clamp(0.05, 1.0),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: SiphoColors.primaryLight,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: SiphoColors.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              m.label,
                              style: SiphoTypography.label.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: SiphoPalette.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SiphoSoftCard(
              child: Text(
                sixInsight,
                style: SiphoTypography.bodyBold.copyWith(
                  fontSize: 16,
                  color: SiphoPalette.textPrimary(context),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SiphoListRow(
              title: l10n.chartsStructureFixed,
              trailing: '$fixedPct %',
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: l10n.chartsStructureVar,
              trailing: '$varPct %',
            ),
          ],
        ),
      ),
    );
  }
}
