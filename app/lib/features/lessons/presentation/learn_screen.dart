import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/ai/sipho_ai_client.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/gamification/data/game_state_repository.dart';
import 'package:sipho/features/insights/data/insight_service.dart';
import 'package:sipho/features/insights/presentation/spend_snapshot_builder.dart';
import 'package:sipho/features/lessons/domain/learn_quests.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';
import 'package:sipho/features/lessons/presentation/learn_quests_provider.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final completed = ref
            .watch(userFinanceProvider)
            .valueOrNull
            ?.completedLessonIds
            .toSet() ??
        {};
    final game = ref.watch(gameStateStreamProvider).valueOrNull;
    final advice = ref.watch(activeCoachAdviceProvider);
    final insightState = ref.watch(insightControllerProvider);
    final quests = ref.watch(learnQuestsProvider(language));
    final claimingId = ref.watch(questClaimControllerProvider);
    final ids = [for (final lesson in kCatalogLessons) lesson.id];
    final units = unitProgressList(kCatalogUnits, completed);

    final streakText = game != null ? '${game.streak.current}' : '—';
    final seedsText = game != null ? '${game.gems}' : '—';
    final levelNum = game?.level ?? 1;
    final doneQuestsCount = quests.where((q) => q.isCompleted).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
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
                  child: _Pill(
                    AppColors.flamePill,
                    AppColors.flameText,
                    '🔥  $streakText',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _Pill(
                    AppColors.seedPill,
                    AppColors.seedText,
                    '🌾  $seedsText',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _Pill(
                    AppColors.mint,
                    AppColors.primaryDark,
                    l10n.homeLevelPill(levelNum),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.learnTitle,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 27,
                fontWeight: FontWeight.w900,
                height: 1.2,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.push('/economy'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      advice == null || advice.title.isEmpty
                          ? '💡  ${l10n.coachTitle}'
                          : '💡  ${advice.title}',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      advice?.body ?? l10n.coachSubtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.coachOpenCard,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            // ─── Quests section on Learn ────────────────────────────────────
            Row(
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
              ],
            ),
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
              _LearnQuestTile(
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
            const SizedBox(height: 10),
            // ─── Lesson units & path ────────────────────────────────────────
            for (final progress in units) ...[
              _UnitHeader(
                progress: progress,
                language: language,
                l10n: l10n,
              ),
              const SizedBox(height: 16),
              for (final lesson in progress.unit.lessons) ...[
                _LessonRow(
                  title: lesson.title(language),
                  done: completed.contains(lesson.id),
                  unlocked: lessonUnlocked(
                    ids,
                    completed,
                    ids.indexOf(lesson.id),
                  ),
                  doneLabel: l10n.learnDone,
                  lockedLabel: l10n.learnLocked,
                  onTap: () => context.push('/lesson/${lesson.id}'),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
            ],
            const Center(child: SiphoArt.happy(frame: 107)),
            Container(
              height: 53,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '🔒  ${l10n.learnUnit3}',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnQuestTile extends StatelessWidget {
  const _LearnQuestTile({
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

class _UnitHeader extends StatelessWidget {
  const _UnitHeader({
    required this.progress,
    required this.language,
    required this.l10n,
  });

  final UnitProgress progress;
  final String language;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final unit = progress.unit;
    final locked = !progress.unlocked;
    final background = locked ? AppColors.border : AppColors.primary;
    final titleColor = locked ? AppColors.textSecondary : Colors.white;
    final subColor = locked ? AppColors.textSecondary : AppColors.mint;
    final status = progress.completed
        ? l10n.learnUnitDone
        : locked
            ? '🔒  ${l10n.learnUnitLocked}'
            : l10n.learnUnitBonus(unit.bonusXp, unit.bonusSeeds);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.learnUnitLabel(progress.index + 1),
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: subColor,
                  ),
                ),
              ),
              Text(
                l10n.learnUnitProgress(progress.done, progress.total),
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: subColor,
                ),
              ),
            ],
          ),
          Text(
            unit.title(language),
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  ColoredBox(
                    color: locked ? AppColors.surface : AppColors.primaryDark,
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.ratio,
                    child: const ColoredBox(color: AppColors.accent),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            status,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: subColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.title,
    required this.done,
    required this.unlocked,
    required this.doneLabel,
    required this.lockedLabel,
    required this.onTap,
  });

  final String title;
  final bool done;
  final bool unlocked;
  final String doneLabel;
  final String lockedLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final face = done
        ? AppColors.accent
        : unlocked
            ? AppColors.primary
            : AppColors.border;
    return GestureDetector(
      onTap: unlocked ? onTap : null,
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: face, shape: BoxShape.circle),
              child: Icon(
                done
                    ? Icons.star_rounded
                    : unlocked
                        ? Icons.play_arrow_rounded
                        : Icons.lock_rounded,
                color: unlocked ? Colors.white : AppColors.lockIcon,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    done
                        ? doneLabel
                        : unlocked
                            ? ''
                            : lockedLabel,
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
          ],
        ),
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
