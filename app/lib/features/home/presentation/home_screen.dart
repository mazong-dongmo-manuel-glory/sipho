import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/ai/sipho_ai_client.dart';
import 'package:sipho/core/animations/lottie_widget.dart';
import 'package:sipho/core/animations/sipho_lotties.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/core/money/money.dart';
import 'package:sipho/core/money/money_formatter.dart';
import 'package:sipho/core/widgets/game_bar.dart';
import 'package:sipho/core/widgets/gauge_circular.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/features/economy/domain/economy_tips.dart';
import 'package:sipho/features/expenses/domain/family_transfer.dart';
import 'package:sipho/features/expenses/domain/transaction.dart';
import 'package:sipho/features/expenses/presentation/expense_category_label.dart';
import 'package:sipho/features/finance/domain/month_summary.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/finance/presentation/income_sheet.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_expense_schedule.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_paid.dart';
import 'package:sipho/features/fixed_expenses/presentation/fixed_paid_button.dart';
import 'package:sipho/features/gamification/data/game_state_repository.dart';
import 'package:sipho/features/gamification/domain/game_extras.dart';
import 'package:sipho/features/gamification/presentation/no_spend_controller.dart';
import 'package:sipho/features/home/domain/home_add_expense_fab.dart';
import 'package:sipho/features/home/domain/on_track.dart';
import 'package:sipho/features/home/presentation/home_country_economy_card.dart';
import 'package:sipho/features/home/presentation/home_goal_card.dart';
import 'package:sipho/features/insights/data/insight_service.dart';
import 'package:sipho/features/insights/domain/insight_text.dart';
import 'package:sipho/features/insights/presentation/spend_snapshot_builder.dart';
import 'package:sipho/features/lessons/domain/learn_quests.dart';
import 'package:sipho/features/lessons/presentation/learn_quests_provider.dart';
import 'package:sipho/features/notifications/data/notification_service.dart';

final homeRewardProvider =
    StateProvider<({String amount, String category})?>((ref) => null);

final homeRandomEconomyTipProvider =
    StateProvider<EconomyTip>((ref) => dailyEconomyTip());

/// Plays [SiphoCue.budgetAlert] at most once per session when remaining goes negative.
final _budgetAlertPlayedProvider = StateProvider<bool>((ref) => false);

Future<void> _askInsight(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) async {
  final snapshot = buildCurrentSpendSnapshot(ref: ref, context: context);
  if (!snapshot.hasAnyFinancialData) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.homeInsightEmpty)),
    );
    return;
  }
  try {
    await ref.read(insightControllerProvider.notifier).ask(snapshot);
  } catch (error) {
    debugPrint('[SiphoAI] Home insight failed: $error');
    if (!context.mounted) return;
    await showSiphoAiErrorSnackBar(
      context,
      error,
      l10n,
      fallback: l10n.homeInsightError,
    );
  }
}

/// Opens the add-expense form and, when an expense was saved, shows the reward card on Home.
Future<void> _addExpense(BuildContext context, WidgetRef ref) async {
  ref.read(homeRewardProvider.notifier).state = null;
  final added = await context.push<({String amount, String category})>(
    '/expenses/add',
  );
  if (added != null) {
    ref.read(homeRewardProvider.notifier).state = added;
  }
}

void _openQuest(BuildContext context, WidgetRef ref, ServerQuestRecord quest) {
  final route = homeQuestRoute(quest);
  if (route == '/expenses/add') {
    _addExpense(context, ref);
  } else {
    context.go(route);
  }
}

Future<void> _confirmNoSpend(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) async {
  final ok = await ref.read(noSpendControllerProvider.notifier).confirm();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(ok ? l10n.homeNoSpendDone : l10n.homeNoSpendError)),
  );
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final palette = _HomePalette(dark);
    final reward = ref.watch(homeRewardProvider);
    ref.listen(homeRewardProvider, (previous, next) {
      if (next == null) return;
      Future<void>.delayed(kHomeRewardDisplayDuration, () {
        if (ref.read(homeRewardProvider) == next) {
          ref.read(homeRewardProvider.notifier).state = null;
        }
      });
    });
    ref.watch(ensureUserProfileProvider);
    ref.watch(dailyQuestsRefreshProvider);
    final monthKey = currentMonthKey();
    final summary = ref.watch(monthSummaryProvider(monthKey));
    final transactions =
        ref.watch(transactionsForMonthProvider(monthKey)).valueOrNull ??
            const <SiphoTransaction>[];
    final finance = ref.watch(userFinanceProvider).valueOrNull;
    final currency = finance?.currency ?? 'CAD';
    final game = ref.watch(gameStateStreamProvider).valueOrNull;
    final extras = ref.watch(gameExtrasStreamProvider).valueOrNull;
    final dailyQuests = dailyQuestsForHome(
      ref.watch(serverQuestsStreamProvider).valueOrNull ?? const [],
    );
    final insightState = ref.watch(insightControllerProvider);
    final activeAdvice = ref.watch(activeCoachAdviceProvider);
    ref.listen(monthSummaryProvider(monthKey), (previous, next) {
      final data = next.valueOrNull;
      if (data == null || !data.hasIncome || data.remainingCents >= 0) return;
      final wasOk = previous?.valueOrNull == null ||
          !(previous!.valueOrNull!.hasIncome) ||
          previous.valueOrNull!.remainingCents >= 0;
      if (!wasOk) return;
      if (ref.read(_budgetAlertPlayedProvider)) return;
      ref.read(_budgetAlertPlayedProvider.notifier).state = true;
      ref.read(feedbackServiceProvider).play(SiphoCue.budgetAlert);
    });
    ref.listen(pendingNotificationRouteProvider, (previous, next) {
      if (next == null) return;
      ref.read(pendingNotificationRouteProvider.notifier).state = null;
      context.push(next);
    });
    final firstName = finance?.firstName ?? '';
    final greeting = firstName.isEmpty ? l10n.homeGuestName : firstName;
    final latest = transactions.isEmpty ? null : transactions.first;
    final nextFixed = nextBill(
      ref.watch(activeFixedExpensesProvider).valueOrNull ?? const [],
      DateTime.now().day,
    );
    final paidIds = ref.watch(paidFixedIdsProvider(monthKey)).valueOrNull ??
        const <String>{};
    final nextFixedPaid = nextFixed != null &&
        isFixedPaid(nextFixed, paidIds: paidIds, now: DateTime.now());
    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                8,
                AppSpacing.pagePadding,
                24,
              ),
              children: [
                GameBar(
                  streakDays: game?.streak.current ?? 0,
                  seeds: game?.seeds ?? 0,
                  level: game?.level ?? 1,
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
                            l10n.homeHello(greeting),
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                              color: palette.title,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.homeEveryStep,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              color: palette.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (reward != null)
                      const LottieWidget(
                        assetPath: SiphoLotties.xpCoins,
                        width: 48,
                        height: 48,
                      ),
                    reward == null
                        ? const SiphoArt.proud(frame: 48)
                        : const SiphoArt.happy(frame: 48),
                  ],
                ),
                const SizedBox(height: 12),
                _RemainingCard(
                  l10n: l10n,
                  palette: palette,
                  summary: summary,
                  currency: currency,
                  onSetIncome: () => showMonthlyIncomeSheet(context, ref),
                ),
                if (reward == null)
                  _NextExpense(
                    palette: palette,
                    title: nextFixed != null
                        ? '${expenseCategoryLabel(l10n, nextFixed.category)} · ${_formatCents(context, nextFixed.amountCents, currency)}'
                        : latest == null
                            ? l10n.homeNoExpenseYet
                            : '${expenseCategoryLabel(l10n, latest.category)} · ${_formatCents(context, latest.spendMainCents, currency)}',
                    subtitle: nextFixed != null
                        ? (nextFixedPaid
                            ? l10n.soclePaidOn('${nextFixed.dueDay}')
                            : l10n.homeNextFixed(nextFixed.dueDay))
                        : latest == null
                            ? l10n.homeAddFirstExpense
                            : l10n.homeLatestExpense,
                    icon: nextFixed != null
                        ? expenseCategoryIcon(nextFixed.category)
                        : latest == null
                            ? Icons.add_rounded
                            : expenseCategoryIcon(latest.category),
                    trailing: nextFixed != null &&
                            canMarkFixedPaid(nextFixed, paidIds: paidIds)
                        ? FixedPaidButton(fixedId: nextFixed.id)
                        : null,
                  )
                else
                  _RewardCard(l10n: l10n, reward: reward),
                if (isBudgetDayBannerVisible(extras?.budgetDay, DateTime.now()))
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _BudgetDayCard(
                      l10n: l10n,
                      xp: extras!.budgetDay!.xp,
                    ),
                  ),
                if (reward == null &&
                    canConfirmNoSpend(
                      extras: extras,
                      today: DateTime.now(),
                      expenseDates: [for (final tx in transactions) tx.date],
                    ))
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _NoSpendButton(
                      label: l10n.homeNoSpendCta,
                      color: palette.read,
                      onTap: () => _confirmNoSpend(context, ref, l10n),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.homeQuests,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: palette.title,
                        ),
                      ),
                    ),
                    Text(
                      l10n.homeQuestsProgress(
                        dailyQuests
                            .where(
                              (q) =>
                                  q.status == 'completed' ||
                                  q.progress >= q.target,
                            )
                            .length,
                        dailyQuests.isEmpty ? 3 : dailyQuests.length,
                      ),
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: palette.title,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _QuestCard(
                  l10n: l10n,
                  palette: palette,
                  quests: dailyQuests,
                  onOpen: (quest) => _openQuest(context, ref, quest),
                ),
                const SizedBox(height: 12),
                _OnTrackCard(
                  l10n: l10n,
                  tone: buildOnTrack(
                    streak: game?.streak.current ?? 0,
                    hasIncome: summary.valueOrNull?.hasIncome ?? false,
                    remainingCents: summary.valueOrNull?.remainingCents ?? 0,
                    expensesThisMonth: transactions.length,
                  ).tone,
                  streak: game?.streak.current ?? 0,
                ),
                const SizedBox(height: 12),
                const Divider(height: 32, color: AppColors.line),
                _FamilyMonthSlot(
                  l10n: l10n,
                  currency: currency,
                  transactions: transactions,
                ),
                const HomeGoalTrackerSection(),
                const SizedBox(height: 12),
                const HomeCountryEconomyCard(),
                const SizedBox(height: 12),
                if (reward == null)
                  _EconomyCard(
                    l10n: l10n,
                    palette: palette,
                    insight: activeAdvice,
                    loading: insightState.loading,
                    onAsk: () => _askInsight(context, ref, l10n),
                    onOpenDetail: () => context.push('/insights'),
                  )
                else
                  const _RewardToast(),
              ],
            ),
            if (shouldShowHomeAddExpenseFab(hasPendingReward: reward != null))
              Positioned(
                right: 20,
                bottom: 16,
                child: _AddButton(
                  onTap: () => _addExpense(context, ref),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HomePalette {
  const _HomePalette(this.dark);

  final bool dark;

  Color get background =>
      dark ? AppColors.backgroundDark : AppColors.background;
  Color get card => dark ? AppColors.surfaceDark : AppColors.surface;
  Color get title => dark ? AppColors.textPrimaryDark : AppColors.primaryDark;
  Color get muted =>
      dark ? AppColors.textSecondaryDark : AppColors.textSecondary;
  Color get kicker => dark ? AppColors.nightKicker : AppColors.primary;
  Color get paidBackground => dark ? AppColors.nightPaid : AppColors.mint;
  Color get paidForeground => dark ? AppColors.nightMint : AppColors.primary;
  Color get economyBackground =>
      dark ? AppColors.nightEconomy : AppColors.economyCard;
  Color get read => dark ? AppColors.nightMint : AppColors.primary;
}

String _formatCents(BuildContext context, int cents, String currency) {
  return MoneyFormatter.format(
    Money(cents: cents, currency: currency),
    locale: Localizations.localeOf(context).toString(),
  );
}

String _monthName(BuildContext context, DateTime month) {
  final raw =
      DateFormat.MMMM(Localizations.localeOf(context).toString()).format(month);
  if (raw.isEmpty) return raw;
  return raw[0].toUpperCase() + raw.substring(1);
}

class _RemainingCard extends StatelessWidget {
  const _RemainingCard({
    required this.l10n,
    required this.palette,
    required this.summary,
    required this.currency,
    required this.onSetIncome,
  });

  final AppLocalizations l10n;
  final _HomePalette palette;
  final AsyncValue<MonthSummary> summary;
  final String currency;
  final VoidCallback onSetIncome;

  @override
  Widget build(BuildContext context) {
    final data = summary.valueOrNull;
    final loading = summary.isLoading && data == null;
    final hasIncome = data?.hasIncome ?? false;
    final amount = loading
        ? '…'
        : data == null
            ? l10n.expensesLoadError
            : hasIncome
                ? _formatCents(context, data.remainingCents, currency)
                : '—';
    final now = DateTime.now();
    final caption = data != null && hasIncome
        ? l10n.homeRemainingCaptionMonth(_monthName(context, now))
        : l10n.homeSetIncome;
    final kicker = data != null && hasIncome
        ? '${_monthName(context, now).toUpperCase()} ${now.year} · ${l10n.homeRemainingKicker}'
        : l10n.homeRemainingKicker;
    final status = data == null || !hasIncome
        ? null
        : data.remainingCents < 0
            ? l10n.homeUnderZero
            : data.remainingCents * 5 < data.incomeCents
                ? l10n.homeTight
                : l10n.homeComfortable;
    final breakdown = data == null
        ? ''
        : l10n.homeRemainingBreakdownValues(
            _formatCents(context, data.incomeCents, currency),
            _formatCents(context, data.fixedCents, currency),
            _formatCents(context, data.spentCents, currency),
          );
    final amountColor = data != null && hasIncome && data.remainingCents < 0
        ? AppColors.terracotta
        : palette.title;

    return GestureDetector(
      onTap: onSetIncome,
      child: Container(
        height: 268,
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Stack(
          children: [
            Positioned(
              top: 13,
              left: 16,
              right: 16,
              child: Text(
                kicker,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: palette.kicker,
                ),
              ),
            ),
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 170,
                  height: 170,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GaugeCircular(
                        radius: 80,
                        strokeWidth: 14,
                        totalCents: hasIncome ? data!.incomeCents : 100,
                        spentCents: hasIncome
                            ? (data!.incomeCents - data.remainingCents)
                                .clamp(0, data.incomeCents)
                            : 0,
                        color: amountColor == AppColors.terracotta
                            ? AppColors.budgetOver
                            : null,
                        backgroundColor: AppColors.border,
                      ),
                      Text(
                        amount,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: amount.length > 10 ? 22 : 32,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          color: amountColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 178,
              left: 16,
              right: 16,
              child: Text(
                caption,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  height: 1.2,
                  color: palette.muted,
                ),
              ),
            ),
            if (status != null)
              Positioned(
                top: 198,
                left: 8,
                right: 8,
                child: Text(
                  '✓  $status',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: data!.remainingCents < 0
                        ? AppColors.terracotta
                        : palette.title,
                  ),
                ),
              ),
            Positioned(
              top: 222,
              left: 8,
              right: 8,
              child: Text(
                breakdown,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: palette.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextExpense extends StatelessWidget {
  const _NextExpense({
    required this.palette,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
  });

  final _HomePalette palette;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 25),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: palette.title,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    height: 1.2,
                    color: palette.muted,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Today's quests, straight from the server (`users/{uid}/quests`, `period == daily`).
/// Progress is computed server-side, so the client never invents a quest state.
class _QuestCard extends StatelessWidget {
  const _QuestCard({
    required this.l10n,
    required this.palette,
    required this.quests,
    required this.onOpen,
  });

  final AppLocalizations l10n;
  final _HomePalette palette;
  final List<ServerQuestRecord> quests;
  final ValueChanged<ServerQuestRecord> onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: quests.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.homeQuestsEmpty,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  height: 1.2,
                  color: palette.muted,
                ),
              ),
            )
          : Column(
              children: [
                for (final quest in quests) _questRow(quest),
              ],
            ),
    );
  }

  Widget _questRow(ServerQuestRecord quest) {
    final target = quest.target <= 0 ? 1 : quest.target;
    final progress = quest.progress.clamp(0, target);
    final done = quest.status == 'completed' || progress >= target;
    final isLesson = quest.type == 'COMPLETE_LESSON';
    return _QuestRow(
      icon: isLesson ? Icons.school_rounded : Icons.edit_note_rounded,
      color: isLesson ? AppColors.terracotta : AppColors.primary,
      titleColor: palette.title,
      muted: palette.muted,
      title: quest.title,
      progress: progress / target,
      trailing: done ? '✓' : '$progress/$target',
      onTap: () => onOpen(quest),
    );
  }
}

class _QuestRow extends StatelessWidget {
  const _QuestRow({
    required this.icon,
    required this.color,
    required this.titleColor,
    required this.muted,
    required this.title,
    required this.progress,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color titleColor;
  final Color muted;
  final String title;
  final double progress;
  final String trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _content(),
        ),
      ),
    );
  }

  Widget _content() {
    return Row(
      children: [
        Icon(icon, color: color, size: 21),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: SizedBox(
                  height: 7,
                  child: Stack(
                    children: [
                      const ColoredBox(color: AppColors.border),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: const ColoredBox(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          trailing,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: muted,
          ),
        ),
        const Icon(Icons.card_giftcard, size: 16, color: AppColors.gift),
      ],
    );
  }
}

class _EconomyCard extends ConsumerWidget {
  const _EconomyCard({
    required this.l10n,
    required this.palette,
    required this.onAsk,
    required this.onOpenDetail,
    required this.loading,
    this.insight,
  });

  final AppLocalizations l10n;
  final _HomePalette palette;
  final VoidCallback onAsk;
  final VoidCallback onOpenDetail;
  final bool loading;
  final InsightText? insight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).languageCode;
    final tip = ref.watch(homeRandomEconomyTipProvider);

    final title = insight != null && insight!.title.isNotEmpty
        ? '💡  ${insight!.title}'
        : '${tip.emoji}  ${tip.title.of(locale)}';

    final body = insight?.body ?? tip.body.of(locale);

    return GestureDetector(
      onTap: onOpenDetail,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: palette.economyBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: palette.title,
                    ),
                  ),
                ),
                if (insight == null) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final current = ref.read(homeRandomEconomyTipProvider);
                      ref.read(homeRandomEconomyTipProvider.notifier).state =
                          pickRandomEconomyTip(currentId: current.id);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('🎲', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                height: 1.3,
                color: palette.muted,
              ),
            ),
            if (insight != null) ...[
              const SizedBox(height: 6),
              Text(
                l10n.adviceDisclaimer,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  height: 1.2,
                  color: palette.muted,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap:
                      loading ? null : (insight == null ? onOpenDetail : onOpenDetail),
                  child: Text(
                    loading
                        ? l10n.homeInsightWorking
                        : l10n.coachOpenCard,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: palette.read,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 11,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({required this.l10n, required this.reward});

  final AppLocalizations l10n;
  final ({String amount, String category}) reward;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 63,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.rewardAdded(reward.amount, reward.category),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  l10n.rewardHabit,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    height: 1.2,
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

/// Shown the day after a day under budget: the server evaluated it at midnight and paid the XP.
class _BudgetDayCard extends StatelessWidget {
  const _BudgetDayCard({required this.l10n, required this.xp});

  final AppLocalizations l10n;
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.mint,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.savings_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeBudgetDayTitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    l10n.homeBudgetDayBody(xp),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      height: 1.2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSpendButton extends StatelessWidget {
  const _NoSpendButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(Icons.check_circle_outline_rounded, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _RewardToast extends StatelessWidget {
  const _RewardToast();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        AppLocalizations.of(context).rewardToast,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          fontWeight: FontWeight.w800,
          height: 1.2,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _OnTrackCard extends StatelessWidget {
  const _OnTrackCard({
    required this.l10n,
    required this.tone,
    required this.streak,
  });

  final AppLocalizations l10n;
  final OnTrackTone tone;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final title = switch (tone) {
      OnTrackTone.onTrack => l10n.onTrackTitle,
      OnTrackTone.catchUp => l10n.onTrackCatchUpTitle,
      OnTrackTone.start => l10n.onTrackStartTitle,
    };
    final body = switch (tone) {
      OnTrackTone.onTrack =>
        streak >= 3 ? l10n.onTrackBody(streak) : l10n.onTrackLogging,
      OnTrackTone.catchUp => l10n.onTrackCatchUpBody,
      OnTrackTone.start => l10n.onTrackStartBody,
    };
    final line = tone == OnTrackTone.onTrack && streak >= 3
        ? l10n.homeOnTrackLine
        : '$title. $body';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        line,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1.25,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}

class _FamilyMonthSlot extends StatelessWidget {
  const _FamilyMonthSlot({
    required this.l10n,
    required this.currency,
    required this.transactions,
  });

  final AppLocalizations l10n;
  final String currency;
  final List<SiphoTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final summary = summarizeFamilyTransfers([
      for (final tx in transactions)
        (
          category: tx.category,
          amountCents: tx.amountCents,
          amountMainCents: tx.amountMainCents,
          feeCents: tx.feeCents,
        ),
    ]);
    if (summary.count == 0) return const SizedBox.shrink();
    final locale = Localizations.localeOf(context).toString();
    final fees = MoneyFormatter(locale).formatCents(summary.feeCents, currency);
    final sent = MoneyFormatter(locale).formatCents(summary.sentCents, currency);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.familyMonthTitle,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sent,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
              ),
            ),
            Text(
              l10n.familyMonthBody(summary.count, fees),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).addExpenseCta,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 64,
          height: 68,
          child: Stack(
            children: [
              Positioned(
                top: 4,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '+',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
