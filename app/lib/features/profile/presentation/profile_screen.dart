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
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/gamification/data/game_state_repository.dart';
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

    final streakText = game != null ? '${game.streak.current}' : '—';
    final xpText = game != null ? '${game.xp}' : '—';
    final seedsText = game != null ? '${game.gems}' : '—';
    final levelNum = game?.level ?? 1;
    final leagueText = game != null && game.leagueId.isNotEmpty
        ? game.leagueId[0].toUpperCase() + game.leagueId.substring(1)
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Badge(Icons.workspace_premium, locked: lessons < 1),
                _Badge(
                  Icons.local_fire_department,
                  locked: (game?.streak.best ?? 0) < 7,
                ),
                _Badge(Icons.school, locked: lessons < 3),
                const _Badge(Icons.lock, locked: true),
                const _Badge(Icons.lock, locked: true),
                const _Badge(Icons.lock, locked: true),
              ],
            ),
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

class _Badge extends StatelessWidget {
  const _Badge(this.icon, {required this.locked});

  final IconData icon;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: locked ? AppColors.border : AppColors.seedPill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: locked ? AppColors.badgeLock : AppColors.badgeGold,
        size: 28,
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
