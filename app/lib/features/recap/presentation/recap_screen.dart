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
import '../../gamification/data/game_state_provider.dart';
import '../../lessons/data/lesson_progress_provider.dart';
import '../../profile/data/goals_provider.dart';

/// Frames 24a–24c + 44–46 · Récap mensuel branché sur données réelles.
class RecapScreen extends ConsumerStatefulWidget {
  final int initialPage;

  const RecapScreen({super.key, this.initialPage = 0});

  @override
  ConsumerState<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends ConsumerState<RecapScreen> {
  late int _page;

  @override
  void initState() {
    super.initState();
    _page = widget.initialPage.clamp(0, 5);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fr = Localizations.localeOf(context).languageCode == 'fr';
    final locale = Localizations.localeOf(context).toString();
    final user = ref.watch(userProfileProvider);
    final game = ref.watch(gameStateProvider);
    final expenses = ref.watch(expensesProvider);
    final goals = ref.watch(goalsProvider);
    final lessonsDone = ref.watch(lessonProgressProvider).length;
    final now = DateTime.now();
    final monthExpenses = expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();
    final spentCents = monthExpenses.fold<int>(
      0,
      (acc, e) => acc + (e.amountMainCents ?? e.amount.cents),
    );
    final cats = <String, int>{};
    for (final e in monthExpenses) {
      cats[e.category] = (cats[e.category] ?? 0) + (e.amountMainCents ?? e.amount.cents);
    }
    String topCat = '—';
    var topCents = 0;
    cats.forEach((k, v) {
      if (v > topCents) {
        topCents = v;
        topCat = k;
      }
    });
    final goal = goals.isEmpty ? null : goals.first;
    final monthLabel =
        DateFormat.MMMM(locale).format(now);
    final spentMoney = Money(cents: spentCents, currency: user.currency).format(locale);

    final pages = <(String, String, String, String)>[
      (
        fr ? 'HABITUDES' : 'HABITS',
        fr ? 'Ce mois-ci tu as noté' : 'This month you logged',
        '${monthExpenses.length}',
        fr
            ? 'Chaque note nourrit ta série et tes quêtes. Continue comme ça.'
            : 'Every log feeds your streak and quests. Keep it up.',
      ),
      (
        fr ? 'DÉPENSES' : 'SPENDING',
        fr ? 'Variables en $monthLabel' : 'Variable spend in $monthLabel',
        spentMoney,
        topCents > 0
            ? (fr
                ? 'Catégorie dominante : $topCat (${Money(cents: topCents, currency: user.currency).format(locale)}).'
                : 'Top category: $topCat (${Money(cents: topCents, currency: user.currency).format(locale)}).')
            : (fr
                ? 'Pas encore de dépenses variables ce mois-ci.'
                : 'No variable spending logged this month yet.'),
      ),
      (
        fr ? 'OBJECTIF' : 'GOAL',
        goal?.title ?? l10n.goalEmptyTitle,
        goal == null
            ? '—'
            : '${(goal.progress * 100).round()} %',
        goal == null
            ? l10n.goalEmptySubtitle
            : '${Money(cents: goal.savedCents, currency: user.currency).format(locale)} / ${Money(cents: goal.targetCents, currency: user.currency).format(locale)}',
      ),
      (
        fr ? 'SÉRIE' : 'STREAK',
        fr ? 'Ta flamme actuelle' : 'Your current streak',
        '${game.streakDays}',
        fr
            ? 'Niveau ${game.level} · ${game.xp} XP · ${game.seeds} graines'
            : 'Level ${game.level} · ${game.xp} XP · ${game.seeds} seeds',
      ),
      (
        fr ? 'BADGES' : 'BADGES',
        fr ? 'Badges débloqués' : 'Badges unlocked',
        '${game.badges.length}',
        fr
            ? 'Leçons terminées : $lessonsDone'
            : 'Lessons completed: $lessonsDone',
      ),
      (
        monthLabel.toUpperCase(),
        fr ? 'Vue d’ensemble' : 'Overview',
        spentMoney,
        fr
            ? '${monthExpenses.length} dépenses · série ${game.streakDays} j · ${goals.length} objectif(s)'
            : '${monthExpenses.length} expenses · streak ${game.streakDays}d · ${goals.length} goal(s)',
      ),
    ];
    final page = pages[_page];

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                page.$1,
                style: SiphoTypography.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: SiphoPalette.textSecondary(context),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      page.$2,
                      style: SiphoTypography.body.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      page.$3,
                      style: SiphoTypography.amountHero.copyWith(
                        fontSize: 48,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SiphoSoftCard(
                      child: Text(
                        page.$4,
                        style: SiphoTypography.body.copyWith(
                          fontSize: 16,
                          color: SiphoPalette.textPrimary(context),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: List.generate(
                        pages.length,
                        (i) => Container(
                          width: i == _page ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: i == _page
                                ? SiphoColors.primary
                                : SiphoColors.separator,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SiphoButton3D(
                label: _page < pages.length - 1
                    ? l10n.continueBtn
                    : l10n.homeWellDoneQuests,
                variant: SiphoButtonVariant.dark,
                onPressed: () {
                  if (_page < pages.length - 1) {
                    setState(() => _page++);
                  } else {
                    context.pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
