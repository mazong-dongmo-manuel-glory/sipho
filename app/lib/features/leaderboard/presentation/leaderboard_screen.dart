import 'package:flutter/material.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/widgets/sipho_art.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _tab = 0;

  static const _players = <(int, String, String, bool)>[
    (1, 'Moussa', '780 XP', true),
    (2, 'Nadia', '733 XP', false),
    (3, 'Koffi', '686 XP', false),
    (4, 'Élodie', '639 XP', true),
    (5, 'Fatou', '592 XP', false),
    (6, 'Yannick', '545 XP', false),
    (7, 'Mariama', '498 XP', true),
    (8, 'Amina', '420 XP', false),
    (9, 'Chloé', '404 XP', false),
    (10, 'Issa', '357 XP', true),
    (11, 'Samuel', '310 XP', false),
    (12, 'Mariam', '263 XP', false),
    (13, 'Léa', '216 XP', true),
    (14, 'David', '169 XP', false),
    (15, 'Aïcha', '122 XP', false),
    (16, 'Noah', '75 XP', true),
    (17, 'Sofia', '28 XP', false),
    (18, 'Malik', '25 XP', false),
    (19, 'Inès', '25 XP', true),
    (20, 'Kevin', '25 XP', false),
    (21, 'Rokia', '25 XP', false),
    (22, 'Lucas', '25 XP', true),
    (23, 'Nora', '25 XP', false),
    (24, 'Adama', '25 XP', false),
    (25, 'Sarah', '25 XP', true),
    (26, 'Émile', '25 XP', false),
    (27, 'Awa', '25 XP', false),
    (28, 'Hugo', '25 XP', true),
    (29, 'Sana', '25 XP', false),
    (30, 'Paul', '25 XP', false),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                const Expanded(
                    child: _Pill(
                        AppColors.flamePill, AppColors.flameText, '🔥  12')),
                const SizedBox(width: 16),
                const Expanded(
                    child: _Pill(
                        AppColors.seedPill, AppColors.seedText, '🌾  340')),
                const SizedBox(width: 16),
                Expanded(
                  child: _Pill(AppColors.mint, AppColors.primaryDark,
                      l10n.homeLevelPill(7)),
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
            Container(
              height: 83,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.seedPill,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events,
                      color: AppColors.badgeGold, size: 38),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.leagueTitle,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.seedText,
                        ),
                      ),
                      Text(
                        l10n.leagueEnds,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.seedText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_tab == 0) ...[
              const SizedBox(height: 12),
              _Zone(
                color: AppColors.mint,
                label: l10n.leaguePromotion,
                labelColor: AppColors.primary,
                players: _players.where((player) => player.$1 <= 7).toList(),
              ),
              for (final player in _players
                  .where((player) => player.$1 > 7 && player.$1 < 26))
                _Row(player),
              _Zone(
                color: AppColors.relegationZone,
                label: l10n.leagueRelegation,
                labelColor: AppColors.danger,
                players: _players.where((player) => player.$1 >= 26).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Zone extends StatelessWidget {
  const _Zone({
    required this.color,
    required this.label,
    required this.labelColor,
    required this.players,
  });

  final Color color;
  final String label;
  final Color labelColor;
  final List<(int, String, String, bool)> players;

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
          for (final player in players) _Row(player),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.player);

  final (int, String, String, bool) player;

  @override
  Widget build(BuildContext context) {
    final mine = player.$2 == 'Amina';
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
              '${player.$1}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: rankColor,
              ),
            ),
          ),
          player.$4
              ? const SiphoArt.proud(frame: 47)
              : const SiphoArt.happy(frame: 47),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              player.$2,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          Text(
            player.$3,
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
