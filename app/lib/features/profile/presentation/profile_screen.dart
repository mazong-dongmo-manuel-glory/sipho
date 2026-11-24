import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../../core/widgets/sipho_mascot.dart';
import '../../auth/data/user_profile_provider.dart';
import '../../coach/data/coach_repository.dart';
import '../../gamification/data/game_state_provider.dart';
import '../../lessons/data/lesson_progress_provider.dart';
import '../data/goals_provider.dart';

/// Frame 21 · Profil privé · Épuré (Figma `2:28963`).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _leagueLabel(AppLocalizations l10n, String tier) {
    return switch (tier.toLowerCase()) {
      'bronze' => l10n.leagueTierBronze,
      'silver' => l10n.leagueTierSilver,
      'gold' => l10n.leagueTierGold,
      'sapphire' => l10n.leagueTierSapphire,
      'ruby' => l10n.leagueTierRuby,
      'emerald' => l10n.leagueTierEmerald,
      'amethyst' => l10n.leagueTierAmethyst,
      'pearl' => l10n.leagueTierPearl,
      'obsidian' => l10n.leagueTierObsidian,
      'diamond' => l10n.leagueTierDiamond,
      _ => tier,
    };
  }

  String _coachStageLabel(AppLocalizations l10n, String stageId) {
    return switch (stageId) {
      'habits' => l10n.coachStageHabits,
      'saving' => l10n.coachStageSaving,
      'protect' => l10n.coachStageProtect,
      'grow' => l10n.coachStageGrow,
      _ => l10n.coachStageFoundation,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(userProfileProvider);
    final game = ref.watch(gameStateProvider);
    final lessonsDone = ref.watch(lessonProgressProvider).length;
    final coachProgress = ref.watch(coachProgressProvider).valueOrNull;
    final goals = ref.watch(goalsProvider);
    final goal = goals.isEmpty ? null : goals.first;
    final currency = user.currency;
    final locale = Localizations.localeOf(context).toString();
    String? goalSubtitle;
    if (goal != null) {
      final saved = Money(cents: goal.savedCents, currency: currency).format(locale);
      final target = Money(cents: goal.targetCents, currency: currency).format(locale);
      goalSubtitle = '${goal.title} · $saved / $target';
    }

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Text(
              user.displayName,
              style: SiphoTypography.title.copyWith(
                fontSize: 28,
                color: SiphoPalette.textPrimary(context),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.profileSpaceSince(
                user.createdAt == null
                    ? '—'
                    : DateFormat.yMMMM(
                        Localizations.localeOf(context).toString(),
                      ).format(user.createdAt!),
              ),
              style: SiphoTypography.body.copyWith(
                fontSize: 16,
                color: SiphoPalette.textSecondary(context),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: SiphoMascot(size: 110),
            ),
            const SizedBox(height: 8),
            SiphoListRow(
              title: l10n.profileShop,
              showChevron: true,
              onTap: () => context.push('/shop'),
            ),
            const SizedBox(height: 14),
            SiphoListRow(
              title: l10n.profileStreakLabel,
              trailing: l10n.profileStreakDays(game.streakDays),
            ),
            const SizedBox(height: 14),
            SiphoListRow(
              title: l10n.profileLevelLabel(game.level),
              trailing: l10n.profileXpValue('${game.xp}'),
            ),
            const SizedBox(height: 14),
            SiphoListRow(
              title: l10n.profileLeagueLabel,
              trailing: _leagueLabel(l10n, game.leagueId),
              showChevron: true,
              onTap: () => context.go('/leaderboard'),
            ),
            const SizedBox(height: 14),
            SiphoListRow(
              title: l10n.profileLessonsLabel,
              trailing: '$lessonsDone',
              showChevron: true,
              onTap: () => context.go('/learn'),
            ),
            if (coachProgress != null) ...[
              const SizedBox(height: 14),
              SiphoListRow(
                title: l10n.coachEducationCardTitle,
                subtitle: l10n.coachEducationLevel(
                  _coachStageLabel(l10n, coachProgress.stageId),
                  coachProgress.educationScore,
                ),
                showChevron: true,
                onTap: () => context.push('/insights'),
              ),
            ],
            const SiphoSeparator(),
            SiphoListRow(
              title: l10n.profileBadges,
              trailing: '${game.badges.length}',
              showChevron: true,
              onTap: () => context.push('/badges'),
            ),
            const SizedBox(height: 14),
            SiphoListRow(
              title: l10n.profileGoals,
              subtitle: goalSubtitle ?? (Localizations.localeOf(context).languageCode == 'fr'
                  ? 'Aucun objectif pour l’instant'
                  : 'No goals yet'),
              showChevron: true,
              onTap: () => context.push('/goals'),
            ),
            const SizedBox(height: 14),
            SiphoListRow(
              title: l10n.friendsListTitle,
              subtitle: l10n.friendsPrivacy,
              showChevron: true,
              onTap: () => context.push('/friends'),
            ),
            const SizedBox(height: 14),
            SiphoListRow(
              title: l10n.profilePublic,
              subtitle: l10n.profilePublicHint,
              showChevron: true,
              onTap: () => context.push('/profile/public'),
            ),
            const SizedBox(height: 14),
            SiphoListRow(
              title: l10n.profileSettingsRow,
              showChevron: true,
              onTap: () => context.push('/settings'),
            ),
            const SizedBox(height: 14),
            SiphoListRow(
              title: 'Récap du mois',
              showChevron: true,
              onTap: () => context.push('/recap'),
            ),
            const SizedBox(height: 14),
            SiphoListRow(
              title: 'Simulateurs',
              showChevron: true,
              onTap: () => context.push('/simulators'),
            ),
            const SizedBox(height: 14),
            SiphoListRow(
              title: 'Abonnements',
              showChevron: true,
              onTap: () => context.push('/subscriptions'),
            ),
            const SizedBox(height: 14),
            SiphoListRow(
              title: 'Info éco',
              showChevron: true,
              onTap: () => context.push('/economy'),
            ),
            const SizedBox(height: 14),
            SiphoListRow(
              title: 'États Accueil (maquettes)',
              subtitle: 'Vide · Chargement · Erreur · Juste · Sous zéro…',
              showChevron: true,
              onTap: () => context.push('/home/states'),
            ),
          ],
        ),
      ),
    );
  }
}
