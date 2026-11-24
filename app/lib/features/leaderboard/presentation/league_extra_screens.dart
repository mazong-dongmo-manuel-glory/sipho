import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../../core/widgets/sipho_page_header.dart';
import '../../../core/widgets/sipho_status_body.dart';
import '../../gamification/data/quests_provider.dart';
import '../data/league_provider.dart';

/// Frame 71 · Notifications · Exemples.
class NotificationExamplesScreen extends StatelessWidget {
  const NotificationExamplesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            SiphoPageHeader(
              title: l10n.notifExamplesHeading,
              lead: l10n.notifExamplesLead,
            ),
            const SizedBox(height: 20),
            _NotifCard(
              title: l10n.notifExamplesStreakTitle,
              body: l10n.notifExamplesStreakBody,
            ),
            const SizedBox(height: 12),
            _NotifCard(
              title: l10n.notifExamplesBudgetTitle,
              body: l10n.notifExamplesBudgetBody,
            ),
            const SizedBox(height: 12),
            _NotifCard(
              title: l10n.notifExamplesLeagueTitle,
              body: l10n.notifExamplesLeagueBody,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final String title;
  final String body;

  const _NotifCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            title,
            style: SiphoTypography.bodyBold.copyWith(
              fontSize: 16,
              color: SiphoPalette.textPrimary(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: SiphoTypography.body.copyWith(
              fontSize: 15,
              color: SiphoPalette.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Frame 72 · Les dix ligues.
class TenLeaguesScreen extends StatelessWidget {
  const TenLeaguesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final leagues = [
      (l10n.leagueBronze, '1'),
      (l10n.leagueSilver, '2'),
      (l10n.leagueGold, '3'),
      (l10n.leagueSapphire, '4'),
      (l10n.leagueRuby, '5'),
      (l10n.leagueEmerald, '6'),
      (l10n.leagueAmethyst, '7'),
      (l10n.leaguePearl, '8'),
      (l10n.leagueObsidian, '9'),
      (l10n.leagueDiamond, '10'),
    ];

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            SiphoPageHeader(
              title: l10n.tenLeaguesHeading,
              lead: l10n.tenLeaguesLead,
            ),
            const SizedBox(height: 20),
            for (final l in leagues) ...[
              SiphoListRow(title: l.$1, trailing: l.$2),
              const SiphoSeparator(),
            ],
          ],
        ),
      ),
    );
  }
}

/// Frame 73 · Podium du dimanche — top 3 de la ligue réelle.
class SundayPodiumScreen extends ConsumerWidget {
  const SundayPodiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final league = ref.watch(leagueProvider);
    final sorted = [...league.members]
      ..sort((a, b) => b.weeklyXp.compareTo(a.weeklyXp));
    final top = sorted.take(3).toList();
    final rest = sorted.skip(3).take(5).toList();

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    SiphoPageHeader(
                      title: l10n.podiumHeading,
                      lead: l10n.podiumLead,
                    ),
                    const SizedBox(height: 24),
                    if (top.isEmpty)
                      Text(
                        l10n.leagueSoon,
                        style: SiphoTypography.body.copyWith(
                          color: SiphoPalette.textSecondary(context),
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (top.length > 1)
                            _PodiumSpot(
                              name: top[1].pseudo,
                              place: '2',
                              height: 90,
                            )
                          else
                            const SizedBox(width: 72),
                          _PodiumSpot(
                            name: top.first.pseudo,
                            place: '1',
                            height: 120,
                          ),
                          if (top.length > 2)
                            _PodiumSpot(
                              name: top[2].pseudo,
                              place: '3',
                              height: 70,
                            )
                          else
                            const SizedBox(width: 72),
                        ],
                      ),
                    const SizedBox(height: 24),
                    for (var i = 0; i < rest.length; i++) ...[
                      SiphoListRow(
                        title: rest[i].pseudo,
                        trailing: '${i + 4} · ${rest[i].weeklyXp} XP',
                      ),
                      const SiphoSeparator(),
                    ],
                    Text(
                      l10n.podiumFooter,
                      style: SiphoTypography.body.copyWith(
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              SiphoButton3D(
                label: l10n.continueBtn,
                variant: SiphoButtonVariant.dark,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PodiumSpot extends StatelessWidget {
  final String name;
  final String place;
  final double height;

  const _PodiumSpot({
    required this.name,
    required this.place,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: SiphoTypography.bodyBold
                .copyWith(color: SiphoPalette.textPrimary(context)),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 72,
          height: height,
          decoration: BoxDecoration(
            color: place == '1'
                ? SiphoColors.accentGold
                : SiphoPalette.softSurface(context),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            place,
            style: SiphoTypography.title.copyWith(
              fontSize: 28,
              color: SiphoPalette.textPrimary(context),
            ),
          ),
        ),
      ],
    );
  }
}

/// Frame 74 · Coffres = quêtes réclamables.
class ProgressChestsScreen extends ConsumerWidget {
  const ProgressChestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final quests = ref.watch(questsProvider);
    final claimable = quests.where((q) => q.status == 'completed').toList();
    final active = quests.where((q) => q.status == 'active').take(2).toList();

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            SiphoPageHeader(
              title: l10n.chestsHeading,
              lead: l10n.chestsLead,
            ),
            const SizedBox(height: 20),
            if (claimable.isEmpty && active.isEmpty)
              SiphoListRow(
                title: l10n.homeQuestsEmpty,
                trailing: '—',
              )
            else ...[
              for (final q in claimable) ...[
                SiphoListRow(
                  title: q.title,
                  subtitle: l10n.questComplete,
                  trailing: '✓',
                  onTap: () => context.push('/chest'),
                ),
                const SiphoSeparator(),
              ],
              for (final q in active) ...[
                SiphoListRow(
                  title: q.title,
                  subtitle: '${q.progress}/${q.target}',
                  trailing: '🔒',
                ),
                const SiphoSeparator(),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Frame 79 · Android · Erreur.
class AndroidErrorScreen extends StatelessWidget {
  const AndroidErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: SiphoStatusBody(
          title: l10n.androidErrorHeading,
          lead: l10n.androidErrorLead,
          cardTitle: l10n.androidErrorCardTitle,
          cardBody: l10n.androidErrorCardBody,
          ctaLabel: l10n.retryBtn,
          onCta: () => context.pop(),
        ),
      ),
    );
  }
}
