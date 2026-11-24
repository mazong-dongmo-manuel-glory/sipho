import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../auth/data/auth_repository.dart';
import '../data/league_provider.dart';

/// Frame 20 · Ligue · classement réel via `joinLeague` + members.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  String _tierLabel(AppLocalizations l10n, String tier) {
    return switch (tier) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final league = ref.watch(leagueProvider);
    final uid = ref.watch(authUidProvider);
    final myIndex = league.members.indexWhere((m) => m.uid == uid);
    final myRank = myIndex >= 0 ? myIndex + 1 : null;
    final myXp = myIndex >= 0 ? league.members[myIndex].weeklyXp : 0;
    final ahead = myIndex > 0 ? league.members[myIndex - 1].weeklyXp - myXp : 0;

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Text(
              l10n.leagueTitleThe(_tierLabel(l10n, league.tier)),
              style: SiphoTypography.title.copyWith(
                fontSize: 28,
                color: SiphoPalette.textPrimary(context),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              league.week.isEmpty ? l10n.leagueGroupWeek : l10n.leagueGroupWeek,
              style: SiphoTypography.body.copyWith(
                fontSize: 16,
                color: SiphoPalette.textSecondary(context),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: l10n.leagueTab,
                          style: SiphoTypography.bodyBold.copyWith(
                            fontSize: 16,
                            color: SiphoPalette.textPrimary(context),
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: () => context.push('/friends'),
                            child: Text(
                              '     ${l10n.leagueFriends}',
                              style: SiphoTypography.bodyBold.copyWith(
                                fontSize: 16,
                                color: SiphoPalette.textSecondary(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => ref.read(leagueProvider.notifier).refresh(),
                  icon: Icon(Icons.refresh, color: SiphoPalette.textPrimary(context)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.leagueXpOnly,
              style: SiphoTypography.label.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: SiphoPalette.textSecondary(context),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            if (league.loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (league.error != null)
              Column(
                children: [
                  Text(
                    l10n.authErrorGeneric,
                    style: SiphoTypography.body.copyWith(color: SiphoPalette.textSecondary(context)),
                  ),
                  const SizedBox(height: 12),
                  SiphoButton3D(
                    label: l10n.retryBtn,
                    variant: SiphoButtonVariant.dark,
                    onPressed: () => ref.read(leagueProvider.notifier).refresh(),
                  ),
                ],
              )
            else if (league.members.isEmpty)
              Text(
                'Ta ligue se remplit. Reviens dans un instant.',
                style: SiphoTypography.body.copyWith(color: SiphoPalette.textSecondary(context)),
              )
            else
              ...List.generate(league.members.length, (i) {
                final m = league.members[i];
                final isMe = m.uid == uid;
                final title =
                    '${i + 1}   ${m.pseudo}${isMe ? ' ${l10n.leagueYouInline}' : ''}';
                return Column(
                  children: [
                    SiphoListRow(
                      title: title,
                      trailing: l10n.leagueXpValue(m.weeklyXp),
                    ),
                    const SiphoSeparator(margin: EdgeInsets.symmetric(vertical: 14)),
                  ],
                );
              }),
            if (myRank != null && ahead > 0)
              SiphoSoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.leagueNearLevel(ahead, myRank),
                      style: SiphoTypography.bodyBold.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textPrimary(context),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.leaguePromoRules,
                      style: SiphoTypography.body.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textPrimary(context),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              l10n.leagueSeeGroup(league.members.length),
              style: SiphoTypography.label.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: SiphoPalette.textSecondary(context),
                height: 1.3,
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/podium'),
              child: Text(
                l10n.leaguePodiumSunday,
                style: SiphoTypography.label.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: SiphoPalette.textPrimary(context),
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SiphoListRow(
              title: 'Les dix ligues',
              showChevron: true,
              onTap: () => context.push('/leagues'),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: 'Coffres de progression',
              showChevron: true,
              onTap: () => context.push('/chests'),
            ),
          ],
        ),
      ),
    );
  }
}
