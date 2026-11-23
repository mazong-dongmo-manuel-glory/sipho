import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
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
    final sinceDate = created == null
        ? null
        : DateFormat.yMMMM(Localizations.localeOf(context).toString())
            .format(created);
    final spaceLead = sinceDate == null
        ? l10n.profileMember
        : l10n.profileSpaceSince(sinceDate);

    final coach = ref.watch(coachProgressProvider).valueOrNull;
    final streakValue = game == null
        ? '—'
        : l10n.profileStreakDays(game.streak.current);
    final levelLabel = l10n.profileLevelLabel(game?.level ?? 1);
    final xpValue =
        game == null ? '—' : l10n.profileXpValue('${game.xp}');
    final leagueText = game != null && game.leagueId.isNotEmpty
        ? leagueTierLabel(l10n, game.leagueId)
        : '—';

    final currency = finance?.currency ?? 'CAD';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            16,
            AppSpacing.pagePadding,
            24,
          ),
          children: [
            // Frame 21 · Profil privé · Épuré
            GestureDetector(
              onTap: () => showProfileEditSheet(context, ref),
              behavior: HitTestBehavior.opaque,
              child: Text(
                name,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              spaceLead,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.3,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: SiphoArt.happy(frame: 110),
            ),
            const SizedBox(height: 20),
            _InfoRow(
              label: l10n.profileStreakLabel,
              value: streakValue,
            ),
            const SizedBox(height: 16),
            _InfoRow(label: levelLabel, value: xpValue),
            const SizedBox(height: 16),
            _InfoRow(
              label: l10n.profileLeagueLabel,
              value: leagueText,
              onTap: () => context.go('/leaderboard'),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: l10n.profileLessonsLabel,
              value: '$lessons',
              onTap: () => context.go('/learn'),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: AppColors.line),
            const SizedBox(height: 20),
            _NavRow(
              label: l10n.profileBadges,
              onTap: null,
            ),
            const SizedBox(height: 12),
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
            _NavRow(
              label: l10n.profileGoals,
              subtitle: null,
              trailing: IconButton(
                onPressed: () =>
                    showAddGoalSheet(context, currency: currency),
                icon: const Icon(
                  Icons.add_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                tooltip: l10n.addGoalTitle,
              ),
            ),
            const SizedBox(height: 8),
            _GoalsSection(currency: currency),
            if (coach != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.soft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.coachEducationCardTitle,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
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
            ],
            const SizedBox(height: 16),
            _NavRow(
              label: l10n.profileShop,
              onTap: () => context.go('/shop'),
            ),
            const SizedBox(height: 16),
            _NavRow(
              label: l10n.profilePublic,
              subtitle: l10n.profilePublicHint,
              onTap: () => showProfileEditSheet(context, ref),
            ),
            const SizedBox(height: 16),
            _NavRow(
              label: l10n.profileSettingsRow,
              onTap: () => context.push('/settings'),
            ),
            const SizedBox(height: 24),
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

/// Ligne info style Figma 21 (libellé à gauche, valeur à droite).
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
    if (onTap == null) return row;
    return Semantics(
      button: true,
      label: '$label, $value',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: row,
      ),
    );
  }
}

/// Ligne de navigation style Figma (libellé + →).
class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.label,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: AppColors.primaryDark,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing ??
            const Text(
              '→',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: AppColors.primaryDark,
              ),
            ),
      ],
    );
    if (onTap == null) return content;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
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
