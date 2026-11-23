import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/animations/lottie_widget.dart';
import 'package:sipho/core/animations/sipho_lotties.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/friends/presentation/friends_panel.dart';
import 'package:sipho/features/gamification/data/game_state_repository.dart';
import 'package:sipho/features/leaderboard/domain/league.dart';
import 'package:sipho/features/leaderboard/presentation/league_labels.dart';
import 'package:sipho/features/leaderboard/presentation/league_providers.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final game = ref.watch(gameStateStreamProvider).valueOrNull;
    final membership = ref.watch(leagueMembershipProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(leagueMembershipProvider),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      '🔥  ${game?.streak.current ?? '—'}',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _Pill(
                      AppColors.seedPill,
                      AppColors.seedText,
                      '🌾  ${game?.gems ?? '—'}',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _Pill(
                      AppColors.mint,
                      AppColors.primaryDark,
                      l10n.homeLevelPill(game?.level ?? 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (final (index, label) in [
                    (0, l10n.leagueTab),
                    (1, l10n.leagueFriends),
                    (2, l10n.leagueCountry),
                  ])
                    GestureDetector(
                      onTap: () => setState(() => _tab = index),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _tab == index
                                    ? AppColors.primaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 4,
                              width: 50,
                              decoration: BoxDecoration(
                                color: _tab == index
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (_tab == 1)
                const FriendsPanel()
              else if (_tab == 2)
                _CountryLeaguePanel(
                  countryCode:
                      ref.watch(userFinanceProvider).valueOrNull?.countryCode ??
                          '',
                )
              else
                ...membership.when(
                  loading: () => const [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                  error: (error, _) => [
                    _ErrorCard(
                      message: l10n.leagueError,
                      retryLabel: l10n.retryBtn,
                      onRetry: () => ref.invalidate(leagueMembershipProvider),
                    ),
                  ],
                  data: (league) => [_LeagueBody(league: league)],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeagueBody extends ConsumerWidget {
  const _LeagueBody({required this.league});

  final LeagueMembership league;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    final members = ref.watch(leagueMembersProvider(league.leagueKey));
    final lastResult = ref.watch(lastLeagueResultProvider).valueOrNull;
    final remaining = league.remaining(DateTime.now().toUtc());
    final tierName = leagueTierLabel(l10n, league.tier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (lastResult != null && lastResult.isForWeekBefore(league.week))
          _ResultBanner(result: lastResult),
        Container(
          height: 83,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.seedPill,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const LottieWidget(
                assetPath: SiphoLotties.podium,
                width: 52,
                height: 40,
                repeat: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.leagueTitleNamed(tierName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.seedText,
                      ),
                    ),
                    Text(
                      remaining == Duration.zero
                          ? l10n.leagueEnded
                          : l10n.leagueEndsIn(
                              leagueRemainingLabel(l10n, remaining),
                            ),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.seedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ...members.when(
          loading: () => const [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
          error: (error, _) => [
            const SizedBox(height: 12),
            _ErrorCard(
              message: l10n.leagueError,
              retryLabel: l10n.retryBtn,
              onRetry: () =>
                  ref.invalidate(leagueMembersProvider(league.leagueKey)),
            ),
          ],
          data: (ranked) => _ranking(context, l10n, ranked, uid),
        ),
      ],
    );
  }

  List<Widget> _ranking(
    BuildContext context,
    AppLocalizations l10n,
    List<LeagueMember> ranked,
    String? uid,
  ) {
    final tierIndex = leagueTierIndex(league.tier);
    final rows = <_RowData>[
      for (var i = 0; i < ranked.length; i++)
        _RowData(
          rank: i + 1,
          member: ranked[i],
          mine: ranked[i].uid == uid,
          zone: leagueZone(
            rank: i + 1,
            size: ranked.length,
            tierIndex: tierIndex,
            weeklyXp: ranked[i].weeklyXp,
          ),
        ),
    ];

    // Consecutive rows of the same zone share one highlighted container.
    final widgets = <Widget>[const SizedBox(height: 12)];
    var i = 0;
    while (i < rows.length) {
      final zone = rows[i].zone;
      var j = i;
      while (j < rows.length && rows[j].zone == zone) {
        j++;
      }
      final segment = rows.sublist(i, j);
      switch (zone) {
        case LeagueZone.promotion:
          widgets.add(_Zone(
            color: AppColors.mint,
            label: l10n.leaguePromotion,
            labelColor: AppColors.primary,
            rows: segment,
          ));
        case LeagueZone.relegation:
          widgets.add(_Zone(
            color: AppColors.relegationZone,
            label: l10n.leagueRelegation,
            labelColor: AppColors.danger,
            rows: segment,
          ));
        case LeagueZone.safe:
          widgets.addAll(segment.map(_Row.new));
      }
      i = j;
    }

    if (ranked.length <= 1) {
      widgets
        ..add(const SizedBox(height: 12))
        ..add(_Message(l10n.leagueAlone));
    }
    return widgets;
  }
}

class _RowData {
  const _RowData({
    required this.rank,
    required this.member,
    required this.mine,
    required this.zone,
  });

  final int rank;
  final LeagueMember member;
  final bool mine;
  final LeagueZone zone;
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.result});

  final LeagueLastResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tier = leagueTierLabel(l10n, result.toTier);
    final text = switch (result.outcome) {
      LeagueOutcome.promoted => l10n.leagueResultPromoted(result.rank, tier),
      LeagueOutcome.relegated => l10n.leagueResultRelegated(result.rank, tier),
      LeagueOutcome.stayed => l10n.leagueResultStayed(result.rank, tier),
    };
    final promoted = result.outcome == LeagueOutcome.promoted;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: promoted ? AppColors.mint : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          if (promoted) ...[
            const LottieWidget(
              assetPath: SiphoLotties.podium,
              width: 64,
              height: 48,
              repeat: false,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color:
                    promoted ? AppColors.primaryDark : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Zone extends StatelessWidget {
  const _Zone({
    required this.color,
    required this.label,
    required this.labelColor,
    required this.rows,
  });

  final Color color;
  final String label;
  final Color labelColor;
  final List<_RowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: labelColor,
              ),
            ),
          ),
          for (final row in rows) _Row(row),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.data);

  final _RowData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mine = data.mine;
    final rankColor = mine ? AppColors.primary : AppColors.textSecondary;
    return Container(
      height: 53,
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: mine ? AppColors.mint : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '${data.rank}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: rankColor,
              ),
            ),
          ),
          data.rank <= 3
              ? const SiphoArt.proud(frame: 47)
              : const SiphoArt.happy(frame: 47),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mine
                  ? '${data.member.pseudo} · ${l10n.leagueYouSuffix}'
                  : data.member.pseudo,
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
          Text(
            l10n.leagueXpValue(data.member.weeklyXp),
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: mine ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryLeaguePanel extends StatelessWidget {
  const _CountryLeaguePanel({required this.countryCode});

  final String countryCode;

  String _flag(String code) {
    if (code.length != 2) return '🌍';
    const base = 127397;
    return String.fromCharCode(base + code.codeUnitAt(0)) +
        String.fromCharCode(base + code.codeUnitAt(1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final flag = _flag(countryCode.toUpperCase());
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.seedPill,
              shape: BoxShape.circle,
            ),
            child: Text(
              flag,
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            countryCode.isNotEmpty
                ? '${l10n.leagueCountry} · $flag'
                : l10n.leagueCountry,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              l10n.leagueSoon,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isFrench
                ? 'Rejoins bientôt les épargnants de ta région pour défendre les couleurs de ton pays dans la ligue nationale.'
                : 'Soon you will compete alongside savers from your region to represent your country in the national league.',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Message(message),
        OutlinedButton(onPressed: onRetry, child: Text(retryLabel)),
      ],
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

