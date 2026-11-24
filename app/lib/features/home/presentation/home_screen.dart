import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/gauge_circular.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../../core/widgets/sipho_status_body.dart';
import '../../../core/firebase/cloud_functions_service.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_mascot.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_profile_provider.dart';
import '../../budget/data/remaining_budget_provider.dart';
import '../../economy/data/economy_provider.dart';
import '../../expenses/data/expenses_provider.dart';
import '../../fixed_expenses/data/fixed_expenses_provider.dart';
import '../../gamification/data/game_state_provider.dart';
import '../../gamification/data/quests_provider.dart';
import '../../insights/data/insights_provider.dart';
import 'home_gauge_sheet.dart';
import 'home_goal_tracker.dart';

Future<void> _confirmNoSpend(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) async {
  final result = await ref.read(cloudFunctionsServiceProvider).confirmNoSpend();
  if (!context.mounted) return;
  final ok = result['status'] != 'error';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(ok ? l10n.homeNoSpendDone : l10n.homeNoSpendError),
      backgroundColor: SiphoColors.primaryDark,
    ),
  );
}

/// Frame 08 · Accueil · Épuré (Figma `2:28929`).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authStateProvider);
    final user = ref.watch(userProfileProvider);
    final game = ref.watch(gameStateProvider);
    final remainingCents = ref.watch(remainingBudgetCentsProvider);
    final totalFixedCents = ref.watch(totalFixedExpensesCentsProvider);
    final totalVariableCents = ref.watch(totalVariableExpensesCentsProvider);
    final fixedExpenses = ref.watch(fixedExpensesProvider);
    final quests = ref.watch(questsProvider);
    final activeQuests = quests
        .where((q) => q.status == 'active' || q.status == 'completed')
        .take(3)
        .toList();
    final doneQuests = activeQuests.where((q) => q.isDone).length;

    if (auth.isLoading) {
      return Scaffold(
        backgroundColor: SiphoPalette.background(context),
        body: SafeArea(
          child: SiphoStatusBody(
            title: l10n.homeLoadingHeading,
            lead: l10n.homeLoadingLead,
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
            title: l10n.homeErrorHeading,
            lead: l10n.homeErrorLead,
            cardTitle: l10n.homeErrorCardTitle,
            cardBody: l10n.homeErrorCardBody,
            ctaLabel: l10n.retryBtn,
            onCta: () => ref.invalidate(authStateProvider),
          ),
        ),
      );
    }

    // Pas encore de nid : revenu à 0 → état vide Accueil.
    if (user.monthlyIncomeCents <= 0 && fixedExpenses.isEmpty) {
      return Scaffold(
        backgroundColor: SiphoPalette.background(context),
        body: SafeArea(
          child: SiphoStatusBody(
            title: l10n.homeHello(user.displayName.isEmpty ? 'Sipho' : user.displayName),
            lead: l10n.homeEmptyLead,
            amountLabel: '—',
            kicker: l10n.homeEmptyKicker,
            cardTitle: l10n.homeEmptyCardTitle,
            cardBody: l10n.homeEmptyCardBody,
            ctaLabel: l10n.homeEmptyCta,
            onCta: () => context.push('/onboarding'),
          ),
        ),
      );
    }

    final currency = user.currency;
    final remaining = Money(cents: remainingCents, currency: currency);
    final income = Money(cents: user.monthlyIncomeCents, currency: currency);
    final fixed = Money(cents: totalFixedCents, currency: currency);
    final spent = Money(cents: totalVariableCents, currency: currency);

    final nextFixed = fixedExpenses.where((e) => !e.isPaid).isEmpty
        ? null
        : fixedExpenses.firstWhere((e) => !e.isPaid);

    final now = DateTime.now();
    final monthName = DateFormat.MMMM(Localizations.localeOf(context).toString())
        .format(now)
        .toUpperCase();
    final year = now.year;

    final budgetRatio = user.monthlyIncomeCents <= 0
        ? 0.0
        : (remainingCents / user.monthlyIncomeCents).clamp(0.0, 1.0);

    final underZero = remainingCents < 0;
    final tight = !underZero && budgetRatio < 0.2;
    final statusLabel = underZero
        ? l10n.homeUnderZeroCheck
        : tight
            ? l10n.homeTightCheck
            : l10n.homeComfortableCheck;
    final gaugeProgress = underZero ? 1.0 : budgetRatio;
    final gaugeColor = underZero
        ? SiphoColors.danger
        : tight
            ? SiphoColors.warning
            : SiphoColors.primary;
    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.homeStreakDays(game.streakDays),
                    style: SiphoTypography.bodyBold.copyWith(
                      fontSize: 16,
                      color: SiphoPalette.textPrimary(context),
                      height: 1.25,
                    ),
                  ),
                ),
                Text(
                  l10n.homeSeedsLevel(
                    NumberFormat.decimalPattern().format(game.seeds),
                    game.level,
                  ),
                  style: SiphoTypography.label.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: SiphoPalette.textPrimary(context),
                    height: 1.25,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeHello(user.displayName),
                        style: SiphoTypography.title.copyWith(
                          fontSize: 28,
                          color: SiphoPalette.textPrimary(context),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.homeEveryStep,
                        style: SiphoTypography.label.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: SiphoPalette.textSecondary(context),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SiphoMascot(
                  size: 48,
                  moodAsset: 'assets/images/sipho_proud.svg',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                Text(
                  l10n.homeMonthRemainingKicker('$monthName $year'),
                  textAlign: TextAlign.center,
                  style: SiphoTypography.label.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: SiphoPalette.textSecondary(context),
                    height: 1.25,
                  ),
                ),
                GestureDetector(
                  onTap: () => showHomeGaugeSheet(context),
                  behavior: HitTestBehavior.opaque,
                  child: GaugeCircular(
                    amountLabel: remaining.formatWhole(),
                    caption: l10n.homeRemainingCaptionMonth(
                      DateFormat.MMMM(Localizations.localeOf(context).toString()).format(now),
                    ),
                    progress: gaugeProgress,
                    progressColor: gaugeColor,
                    amountColor: underZero
                        ? SiphoColors.danger
                        : SiphoPalette.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.homeSetIncome,
                  textAlign: TextAlign.center,
                  style: SiphoTypography.label.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: SiphoPalette.textSecondary(context),
                  ),
                ),
                Text(
                  statusLabel,
                  style: SiphoTypography.label.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: underZero
                        ? SiphoColors.danger
                        : SiphoPalette.textPrimary(context),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.homeBreakdownEpure(
                    income.formatWhole(),
                    fixed.formatWhole(),
                    spent.formatWhole(),
                  ),
                  textAlign: TextAlign.center,
                  style: SiphoTypography.label.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: SiphoPalette.textSecondary(context),
                    height: 1.25,
                  ),
                ),
              ],
            ),
            const SiphoSeparator(),
            if (nextFixed != null)
              SiphoListRow(
                title: nextFixed.name,
                subtitle: l10n.homeCheckOncePaid,
                trailing:
                    '${Money(cents: nextFixed.amount.cents, currency: currency).formatWhole()}   ✓',
                onTap: () => ref.read(fixedExpensesProvider.notifier).togglePaid(nextFixed.id),
              ),
            if (nextFixed != null) const SiphoSeparator(),
            if (underZero) ...[
              SiphoSoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeUnderZero,
                      style: SiphoTypography.bodyBold.copyWith(
                        fontSize: 16,
                        color: SiphoColors.danger,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Localizations.localeOf(context).languageCode == 'fr'
                          ? 'Ton reste à vivre est négatif. Note ou ajuste une dépense, ou coche une charge fixe déjà payée.'
                          : 'Your living money is negative. Log or adjust an expense, or tick a fixed bill already paid.',
                      style: SiphoTypography.body.copyWith(
                        fontSize: 14,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SiphoButton3D(
                      label: l10n.navExpenses,
                      variant: SiphoButtonVariant.outline,
                      height: 48,
                      onPressed: () => context.go('/expenses'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Builder(builder: (context) {
              final now = DateTime.now();
              final spentToday = ref.watch(expensesProvider).any(
                    (e) =>
                        e.date.year == now.year &&
                        e.date.month == now.month &&
                        e.date.day == now.day,
                  );
              if (spentToday) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SiphoButton3D(
                  label: l10n.homeNoSpendCta,
                  variant: SiphoButtonVariant.secondary,
                  height: 48,
                  onPressed: () => _confirmNoSpend(context, ref, l10n),
                ),
              );
            }),
            const HomeGoalTrackerSection(),
            const SizedBox(height: 12),
            _HomeDigestSection(currency: currency),
            const SiphoSeparator(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.homeQuests,
                    style: SiphoTypography.bodyBold.copyWith(
                      fontSize: 16,
                      color: SiphoPalette.textPrimary(context),
                      height: 1.25,
                    ),
                  ),
                ),
                Text(
                  l10n.homeQuestCount(doneQuests, activeQuests.length),
                  style: SiphoTypography.label.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: SiphoPalette.textPrimary(context),
                    height: 1.25,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (activeQuests.isEmpty)
              _QuestProgressRow(
                title: l10n.homeQuestNote3,
                progressLabel: '—',
                progress: 0,
              )
            else
              ...activeQuests.map(
                    (q) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () {
                          if (q.status == 'completed') {
                            context.push('/chest');
                            return;
                          }
                          final route = q.actionRoute;
                          if (route != null) {
                            if (route == '/learn') {
                              context.go('/learn');
                            } else {
                              context.push(route);
                            }
                          }
                        },
                        child: _QuestProgressRow(
                          title: q.title,
                          progressLabel: q.status == 'completed'
                              ? '✓'
                              : '${q.progress}/${q.target}',
                          progress: q.target <= 0
                              ? 0
                              : (q.progress / q.target).clamp(0.0, 1.0),
                        ),
                      ),
                    ),
                  ),
            if (activeQuests.any((q) => !q.isDone))
              Text(
                l10n.homeQuestOneMore,
                style: SiphoTypography.label.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: SiphoPalette.textSecondary(context),
                  height: 1.25,
                ),
              ),
            const SizedBox(height: 16),
            SiphoListRow(
              title: l10n.homeTakeLesson,
              trailing: '→',
              onTap: () => context.go('/learn'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Graphique 7j + taux du jour + petit conseil (insight / fallback).
class _HomeDigestSection extends ConsumerWidget {
  final String currency;

  const _HomeDigestSection({required this.currency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final expenses = ref.watch(expensesProvider);
    final eco = ref.watch(economyProvider);
    final insight = ref.watch(insightsProvider).valueOrNull;

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final dayTotals = List<int>.filled(7, 0);
    for (final e in expenses) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      final diff = d.difference(start).inDays;
      if (diff < 0 || diff > 6) continue;
      dayTotals[diff] += e.amount.cents;
    }
    final maxDay = dayTotals.fold<int>(0, (a, b) => a > b ? a : b);
    final weekSum = dayTotals.fold<int>(0, (a, b) => a + b);
    final weekdayLabels = locale.languageCode == 'fr'
        ? const ['L', 'M', 'M', 'J', 'V', 'S', 'D']
        : const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final fxRate = eco.fxRates[currency.toUpperCase()];
    final tip = (insight?.body.isNotEmpty == true)
        ? insight!.body
        : (insight?.title.isNotEmpty == true)
            ? insight!.title
            : l10n.homeTipFallback;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.homeSpendWeekHeading,
                style: SiphoTypography.bodyBold.copyWith(
                  fontSize: 16,
                  color: SiphoPalette.textPrimary(context),
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.push('/charts/days'),
              child: Text(
                '→',
                style: SiphoTypography.bodyBold.copyWith(
                  color: SiphoPalette.textPrimary(context),
                ),
              ),
            ),
          ],
        ),
        if (weekSum == 0)
          Text(
            l10n.homeSpendWeekEmpty,
            style: SiphoTypography.label.copyWith(
              fontWeight: FontWeight.w700,
              color: SiphoPalette.textSecondary(context),
            ),
          )
        else
          SizedBox(
            height: 96,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: maxDay <= 0
                                    ? 0.08
                                    : (dayTotals[i] / maxDay).clamp(0.08, 1.0),
                                widthFactor: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: SiphoColors.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            weekdayLabels[i],
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
        const SizedBox(height: 16),
        Text(
          l10n.homeFxHeading,
          style: SiphoTypography.bodyBold.copyWith(
            fontSize: 16,
            color: SiphoPalette.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        SiphoSoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fxRate == null
                    ? l10n.homeFxUnavailable
                    : l10n.homeFxLine(
                        eco.fxBase,
                        fxRate.toStringAsFixed(fxRate >= 100 ? 0 : 2),
                        currency.toUpperCase(),
                      ),
                style: SiphoTypography.bodyBold.copyWith(
                  fontSize: 15,
                  color: SiphoPalette.textPrimary(context),
                ),
              ),
              if (eco.summary.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  eco.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: SiphoTypography.label.copyWith(
                    fontWeight: FontWeight.w700,
                    color: SiphoPalette.textSecondary(context),
                    height: 1.3,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => context.push('/economy'),
                child: Text(
                  l10n.homeReadEco,
                  style: SiphoTypography.label.copyWith(
                    fontWeight: FontWeight.w800,
                    color: SiphoColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.homeTipHeading,
          style: SiphoTypography.bodyBold.copyWith(
            fontSize: 16,
            color: SiphoPalette.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        SiphoSoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tip,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: SiphoTypography.label.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: SiphoPalette.textPrimary(context),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => context.push('/insights'),
                child: Text(
                  '→',
                  style: SiphoTypography.bodyBold.copyWith(
                    color: SiphoColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuestProgressRow extends StatelessWidget {
  final String title;
  final String progressLabel;
  final double progress;

  const _QuestProgressRow({
    required this.title,
    required this.progressLabel,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: SiphoPalette.chipSurface(context),
            shape: BoxShape.circle,
          ),
          child: Text(
            '✎',
            style: TextStyle(
              fontSize: 18,
              color: SiphoPalette.textPrimary(context),
            ),
          ),
        ),
        const SizedBox(height: 0, width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: SiphoTypography.bodyBold.copyWith(
                        fontSize: 14,
                        color: SiphoPalette.textPrimary(context),
                        height: 1.2,
                      ),
                    ),
                  ),
                  Text(
                    progressLabel,
                    style: SiphoTypography.label.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: SiphoPalette.textSecondary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: SiphoPalette.separator(context),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          SiphoColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('🎁', style: TextStyle(fontSize: 20)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
