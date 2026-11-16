import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/ai/sipho_ai_client.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/features/insights/data/insight_service.dart';
import 'package:sipho/features/insights/presentation/spend_snapshot_builder.dart';
import 'package:sipho/features/lessons/domain/learn_quests.dart';
import 'package:sipho/features/lessons/presentation/learn_quests_provider.dart';

/// Quests under the Learn path. Folded by default so the path stays the star of the screen,
/// unless a reward is waiting to be claimed.
class LearnQuestsSection extends ConsumerStatefulWidget {
  const LearnQuestsSection({super.key});

  @override
  ConsumerState<LearnQuestsSection> createState() => _LearnQuestsSectionState();
}

class _LearnQuestsSectionState extends ConsumerState<LearnQuestsSection> {
  // Null until the learner toggles: then the default (open only when a reward is claimable).
  bool? _expanded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final insightState = ref.watch(insightControllerProvider);
    final quests = ref.watch(learnQuestsProvider(language));
    final claimingId = ref.watch(questClaimControllerProvider);
    final doneQuestsCount = quests.where((q) => q.isCompleted).length;
    final hasClaimable =
        quests.any((q) => q.claimableOnServer && q.serverQuestId != null);
    final expanded = _expanded ?? hasClaimable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: true,
          expanded: expanded,
          label: l10n.learnQuestsTitle,
          excludeSemantics: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '🎯  ${l10n.learnQuestsTitle}',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.learnQuestsSummary(doneQuestsCount, quests.length),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: ActionChip(
              backgroundColor: AppColors.seedPill,
              side: const BorderSide(color: AppColors.accent),
              label: Text(
                insightState.loading
                    ? l10n.learnGeneratingAiQuest
                    : l10n.learnGenerateAiQuest,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              onPressed: insightState.loading
                  ? null
                  : () async {
                      final snapshot = buildCurrentSpendSnapshot(
                        ref: ref,
                        context: context,
                        focusTopic: 'goal',
                      );
                      if (!snapshot.hasAnyFinancialData) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.homeInsightEmpty)),
                        );
                        return;
                      }
                      try {
                        await ref
                            .read(insightControllerProvider.notifier)
                            .ask(snapshot, acceptQuest: true);
                      } catch (error) {
                        debugPrint('[SiphoAI] Learn AI quest failed: $error');
                        if (!context.mounted) return;
                        await showSiphoAiErrorSnackBar(
                          context,
                          error,
                          l10n,
                          fallback: l10n.homeInsightError,
                        );
                      }
                    },
            ),
          ),
          const SizedBox(height: 10),
          for (final quest in quests) ...[
            _QuestTile(
              quest: quest,
              l10n: l10n,
              claiming: claimingId == quest.serverQuestId &&
                  quest.serverQuestId != null,
              onAction: () async {
                if (quest.claimableOnServer && quest.serverQuestId != null) {
                  final reward = await ref
                      .read(questClaimControllerProvider.notifier)
                      .claim(quest.serverQuestId!);
                  if (!context.mounted) return;
                  if (reward != null) {
                    unawaited(ref
                        .read(feedbackServiceProvider)
                        .play(SiphoCue.questClaimed));
                    await context.push('/chest', extra: reward);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.learnQuestClaimError)),
                    );
                  }
                  return;
                }
                if (!quest.isCompleted) {
                  if (quest.actionRoute == '/profile') {
                    context.go('/profile');
                  } else {
                    await context.push(quest.actionRoute);
                  }
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

class _QuestTile extends StatelessWidget {
  const _QuestTile({
    required this.quest,
    required this.l10n,
    required this.claiming,
    required this.onAction,
  });

  final LearnQuestItem quest;
  final AppLocalizations l10n;
  final bool claiming;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final completed = quest.isCompleted;
    final canClaim = quest.claimableOnServer && quest.serverQuestId != null;
    final interactive = canClaim || !completed;

    return Material(
      color: completed && !canClaim ? AppColors.mint : AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: interactive && !claiming ? onAction : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: canClaim
                  ? AppColors.accent
                  : (completed ? AppColors.primary : AppColors.border),
              width: canClaim ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: completed ? AppColors.primary : AppColors.seedPill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: completed && !canClaim
                    ? const Icon(Icons.check_rounded, color: Colors.white)
                    : Text(quest.emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (quest.isAiCoach) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.seedPill,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n.learnQuestAiTag,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.warnBrown,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            quest.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      quest.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: SizedBox(
                              height: 8,
                              child: Stack(
                                children: [
                                  const ColoredBox(color: AppColors.border),
                                  FractionallySizedBox(
                                    widthFactor: quest.ratio,
                                    child: ColoredBox(
                                      color: completed
                                          ? AppColors.primary
                                          : AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${quest.clampedProgress}/${quest.safeTarget}',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (canClaim)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: claiming
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.card_giftcard,
                              size: 15,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.learnQuestClaim,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                )
              else if (completed)
                Text(
                  l10n.learnQuestDoneBadge,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (quest.rewardXp != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.seedPill,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '+${quest.rewardXp} XP',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.warnBrown,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      l10n.learnQuestGo,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
