import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/feedback/feedback_binder.dart';
import '../../../core/feedback/feedback_cue.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_page_header.dart';
import '../../gamification/data/quests_provider.dart';

/// XP server-side for logging a transaction (`XP_CONFIG.transactionAdd`).
const kTransactionAddXp = 2;

/// Frame 10 · Suivi récompensé — montant/catégorie réels + quête live.
class ExpenseRewardScreen extends ConsumerWidget {
  final String amountLabel;
  final String category;
  final String merchant;
  final int xp;

  const ExpenseRewardScreen({
    super.key,
    this.amountLabel = '',
    this.category = '',
    this.merchant = '',
    this.xp = kTransactionAddXp,
  });

  QuestItem? _expenseQuest(List<QuestItem> quests) {
    QuestItem? best;
    for (final q in quests) {
      if (q.status != 'active' && q.status != 'completed') continue;
      final t = q.type.toUpperCase();
      final isExpense = t == 'ADD_TRANSACTION' ||
          q.templateId.contains('log_expense') ||
          q.templateId.contains('catch') ||
          q.actionRoute == '/expenses/add';
      if (!isExpense) continue;
      if (q.status == 'active') return q;
      best ??= q;
    }
    return best;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fr = Localizations.localeOf(context).languageCode == 'fr';
    final quest = _expenseQuest(ref.watch(questsProvider));
    final xpShown = xp > 0 ? xp : kTransactionAddXp;

    String questLine;
    if (quest == null) {
      questLine = fr
          ? 'Aucune quête dépense active — continue comme ça.'
          : 'No active expense quest — keep it up.';
    } else if (quest.isDone) {
      questLine = fr
          ? 'Quête terminée : ${quest.title}'
          : 'Quest done: ${quest.title}';
    } else {
      questLine = fr
          ? '${quest.progress} / ${quest.target} — ${quest.title}'
          : '${quest.progress} of ${quest.target} — ${quest.title}';
    }

    final cat = category.isEmpty ? '—' : category;
    final merch = merchant.isEmpty ? '—' : merchant;
    final amount = amountLabel.isEmpty ? '—' : amountLabel;

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              const PlayCueOnce(cue: SiphoCue.expenseAdded),
              Expanded(
                child: ListView(
                  children: [
                    SiphoPageHeader(
                      title: l10n.rewardHeading,
                      lead: l10n.rewardLead,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 96,
                        height: 96,
                        child: SvgPicture.asset(
                          'assets/images/sipho_proud.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: SiphoPalette.softSurface(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.rewardSavedLine(amount),
                            style: SiphoTypography.bodyBold.copyWith(
                              fontSize: 16,
                              color: SiphoPalette.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$cat · $merch',
                            style: SiphoTypography.body.copyWith(
                              fontSize: 16,
                              color: SiphoPalette.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: SiphoPalette.softSurface(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.rewardXpLine(xpShown),
                            style: SiphoTypography.bodyBold.copyWith(
                              fontSize: 16,
                              color: SiphoPalette.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            questLine,
                            style: SiphoTypography.body.copyWith(
                              fontSize: 16,
                              color: SiphoPalette.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.rewardDisclaimer,
                      style: SiphoTypography.body.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              SiphoButton3D(
                label: l10n.continueBtn,
                variant: SiphoButtonVariant.dark,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
