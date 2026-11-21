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
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/auth/data/auth_repository.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/coach/data/coach_repository.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/gamification/data/game_state_repository.dart';
import 'package:sipho/features/gamification/domain/badges.dart';
import 'package:sipho/features/goals/data/goal_repository.dart';
import 'package:sipho/features/goals/domain/goal.dart';
import 'package:sipho/features/goals/presentation/add_goal_sheet.dart';
import 'package:sipho/features/goals/presentation/deposit_goal_sheet.dart';
import 'package:sipho/features/goals/presentation/goal_card.dart';
import 'package:sipho/features/leaderboard/presentation/league_labels.dart';
import 'package:sipho/features/profile/presentation/profile_edit_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final finance = ref.watch(userFinanceProvider).valueOrNull;
    final game = ref.watch(gameStateStreamProvider).valueOrNull;
    final name = finance?.displayName.trim().isNotEmpty == true
        ? finance!.displayName.trim()
        : l10n.profileGuest;
    final lessons = finance?.completedLessonIds.length ?? 0;
    final created = finance?.createdAt;
    final member = created == null
        ? l10n.profileMember
        : l10n.profileMemberSince(
            DateFormat.yMMM(Localizations.localeOf(context).toString())
                .format(created),
          );

    final coach = ref.watch(coachProgressProvider).valueOrNull;
    final streakText = game != null ? '${game.streak.current}' : '—';
    final xpText = game != null ? '${game.xp}' : '—';
    final seedsText = game != null ? '${game.gems}' : '—';
    final levelNum = game?.level ?? 1;
    final leagueText = game != null && game.leagueId.isNotEmpty
        ? leagueTierLabel(l10n, game.leagueId)
        : '—';

    final currency = finance?.currency ?? 'CAD';
    final incomeCents = finance?.monthlyIncomeCents ?? 0;
    final incomeText = incomeCents > 0
        ? MoneyFormatter.format(
            Money(cents: incomeCents, currency: currency),
            locale: Localizations.localeOf(context).toString(),
          )
        : l10n.homeSetIncome;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            8,
            AppSpacing.pagePadding,
            16,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => showProfileEditSheet(context, ref),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    l10n.editProfileBtn,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/settings'),
                  icon: const Icon(
                    Icons.settings,
                    color: AppColors.textSecondary,
                    size: 26,
                  ),
                ),
              ],
            ),
            const Center(child: SiphoArt.happy(frame: 185)),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => context.go('/shop'),
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.seedPill,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.profileShop,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.seedText,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => showProfileEditSheet(context, ref),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            Text(
              member,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Stat('🔥', streakText, l10n.profileStreakLabel),
                const SizedBox(width: 9),
                _Stat('⭐', xpText, l10n.profileXpLabel),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _Stat(
                  '🏆',
                  leagueText,
                  l10n.profileLeagueLabel,
                  onTap: () => context.go('/leaderboard'),
                ),
                const SizedBox(width: 9),
                _Stat(
                  '📚',
                  '$lessons',
                  l10n.profileLessonsLabel,
                  onTap: () => context.go('/learn'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (coach != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.coachEducationCardTitle,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.coachEducationLevel(
                        _coachStageLabel(l10n, coach.stageId),
                        coach.educationScore,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.coachEducationCardHint,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (coach.educationScore / 100).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: AppColors.border,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
            Text(
              l10n.profileBadges,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final badge in kBadges)
                  _Badge(
                    badge.icon,
                    locked: !(game?.badges.contains(badge.id) ?? false),
                    onTap: () => _showBadge(
                      context,
                      l10n,
                      badge,
                      earned: game?.badges.contains(badge.id) ?? false,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.profileGoals,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      showAddGoalSheet(context, currency: currency),
                  icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
                  label: Text(
                    l10n.addGoalTitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _GoalsSection(currency: currency),
            const SizedBox(height: 16),
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => showProfileEditSheet(context, ref),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.editProfileTitle,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              [
                                if ((finance?.countryCode ?? '').isNotEmpty)
                                  finance!.countryCode,
                                currency,
                                incomeText,
                              ].join(' · '),
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SiphoButton3D(
              label: l10n.profileSignOut,
              height: 48,
              color: AppColors.primaryDark,
              shadowColor: AppColors.ink,
              onPressed: () async {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.emoji, this.value, this.label, {this.onTap});

  final String emoji;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
        ),
      ),
    );
  }
}

String _coachStageLabel(AppLocalizations l10n, String stageId) {
  switch (stageId) {
    case 'habits':
      return l10n.coachStageHabits;
    case 'saving':
      return l10n.coachStageSaving;
    case 'protect':
      return l10n.coachStageProtect;
    case 'grow':
      return l10n.coachStageGrow;
    case 'foundation':
    default:
      return l10n.coachStageFoundation;
  }
}

void _showBadge(
  BuildContext context,
  AppLocalizations l10n,
  BadgeDef badge, {
  required bool earned,
}) {
  final status = earned ? l10n.badgeEarnedLabel : l10n.badgeLockedLabel;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          '${badgeTitle(l10n, badge.id)} · $status\n${badgeHint(l10n, badge.id)}',
        ),
      ),
    );
}

class _Badge extends StatelessWidget {
  const _Badge(this.icon, {required this.locked, required this.onTap});

  final IconData icon;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: locked ? AppColors.border : AppColors.seedPill,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          locked ? Icons.lock : icon,
          color: locked ? AppColors.badgeLock : AppColors.badgeGold,
          size: 28,
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

class _GoalsSection extends ConsumerWidget {
  const _GoalsSection({required this.currency});

  final String currency;

  void _confirmDelete(BuildContext context, WidgetRef ref, Goal goal) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.goalDelete),
        content: Text(l10n.goalDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancelBtn),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(goalRepositoryProvider).deleteGoal(uid, goal.id);
            },
            child: Text(
              l10n.deleteBtn,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final goalsAsync = ref.watch(userGoalsProvider);

    return goalsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (goals) {
        if (goals.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.seedPill,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🎯', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.goalEmptyTitle,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.goalEmptySubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () =>
                      showAddGoalSheet(context, currency: currency),
                  icon:
                      const Icon(Icons.add, size: 16, color: AppColors.primary),
                  label: Text(
                    l10n.addGoalTitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            for (var i = 0; i < goals.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              GoalCard(
                goal: goals[i],
                currency: currency,
                onDeposit: () => showDepositGoalSheet(
                  context,
                  goal: goals[i],
                  currency: currency,
                ),
                onDelete: () => _confirmDelete(context, ref, goals[i]),
              ),
            ],
          ],
        );
      },
    );
  }
}
