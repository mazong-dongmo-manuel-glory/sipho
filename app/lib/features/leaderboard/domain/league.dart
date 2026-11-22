/// Weekly leagues (client side). The server owns membership, XP and promotions
/// (`joinLeague`, `onGameXpChange`, `leagueWeekly` Cloud Functions); the client only reads.
/// The thresholds below mirror `functions/src/shared/leagues.ts`.
library;

const kLeagueTiers = <String>[
  'bronze',
  'silver',
  'gold',
  'sapphire',
  'ruby',
  'emerald',
  'amethyst',
  'pearl',
  'obsidian',
  'diamond',
];

const kLeaguePromoteCount = 7;
const kLeagueRelegateCount = 5;
const kLeagueMinGroupForRelegation = 15;

/// Unknown ids fall back to the lowest tier, like the server.
int leagueTierIndex(String? id) {
  final index = kLeagueTiers.indexOf(id ?? '');
  return index < 0 ? 0 : index;
}

class LeagueMembership {
  const LeagueMembership({
    required this.leagueKey,
    required this.tier,
    required this.week,
    required this.endsAt,
  });

  final String leagueKey;
  final String tier;

  /// `yyyy-MM-dd` (UTC) of the week's start.
  final String week;
  final DateTime endsAt;

  factory LeagueMembership.fromCallable(Map<String, dynamic> raw) {
    final key = raw['leagueKey'];
    if (key is! String || key.isEmpty) {
      throw const FormatException('joinLeague returned no leagueKey');
    }
    final endsAtMs = raw['endsAtMs'];
    return LeagueMembership(
      leagueKey: key,
      tier: (raw['tier'] as String?) ?? kLeagueTiers.first,
      week: (raw['week'] as String?) ?? '',
      endsAt: DateTime.fromMillisecondsSinceEpoch(
        endsAtMs is num ? endsAtMs.toInt() : 0,
        isUtc: true,
      ),
    );
  }

  /// Time left in the week (never negative).
  Duration remaining(DateTime now) {
    final left = endsAt.difference(now);
    return left.isNegative ? Duration.zero : left;
  }
}

class LeagueMember {
  const LeagueMember({
    required this.uid,
    required this.pseudo,
    required this.avatar,
    required this.level,
    required this.weeklyXp,
  });

  final String uid;
  final String pseudo;
  final String avatar;
  final int level;
  final int weeklyXp;

  factory LeagueMember.fromMap(String uid, Map<String, dynamic> raw) {
    final pseudo = raw['pseudo'];
    return LeagueMember(
      uid: uid,
      pseudo: pseudo is String && pseudo.trim().isNotEmpty
          ? pseudo.trim()
          : 'Sipho',
      avatar: (raw['avatar'] as String?) ?? '',
      level: (raw['level'] as num?)?.toInt() ?? 1,
      weeklyXp: ((raw['weeklyXp'] as num?)?.toInt() ?? 0).clamp(0, 1 << 31),
    );
  }
}

/// Weekly XP descending; ties broken by uid so everybody sees the same order (and the same one
/// the server uses to decide promotions).
List<LeagueMember> rankLeagueMembers(Iterable<LeagueMember> members) {
  final sorted = members.toList()
    ..sort((a, b) {
      final byXp = b.weeklyXp.compareTo(a.weeklyXp);
      return byXp != 0 ? byXp : a.uid.compareTo(b.uid);
    });
  return sorted;
}

enum LeagueZone { promotion, safe, relegation }

/// Zone of a player at [rank] (1-based) in a group of [size]. Mirrors the server rules:
/// top 7 move up (with XP, and below the top tier); the last 5 move down (groups of 15+, below
/// the bottom tier), never overlapping with the promotion zone.
LeagueZone leagueZone({
  required int rank,
  required int size,
  required int tierIndex,
  required int weeklyXp,
}) {
  if (rank <= kLeaguePromoteCount &&
      weeklyXp > 0 &&
      tierIndex < kLeagueTiers.length - 1) {
    return LeagueZone.promotion;
  }
  if (size >= kLeagueMinGroupForRelegation &&
      rank > kLeaguePromoteCount &&
      rank > size - kLeagueRelegateCount &&
      tierIndex > 0) {
    return LeagueZone.relegation;
  }
  return LeagueZone.safe;
}

enum LeagueOutcome { promoted, relegated, stayed }

/// What happened to the player when the previous week closed
/// (`users/{uid}/league/lastResult`, written by the server).
class LeagueLastResult {
  const LeagueLastResult({
    required this.week,
    required this.rank,
    required this.outcome,
    required this.toTier,
  });

  final String week;
  final int rank;
  final LeagueOutcome outcome;
  final String toTier;

  static LeagueLastResult? fromMap(Map<String, dynamic>? raw) {
    if (raw == null) return null;
    final week = raw['week'];
    final rank = raw['rank'];
    if (week is! String || rank is! num) return null;
    return LeagueLastResult(
      week: week,
      rank: rank.toInt(),
      outcome: switch (raw['result']) {
        'promoted' => LeagueOutcome.promoted,
        'relegated' => LeagueOutcome.relegated,
        _ => LeagueOutcome.stayed,
      },
      toTier: (raw['toTier'] as String?) ?? kLeagueTiers.first,
    );
  }

  /// True when this result is the one for the week right before [currentWeek]; older results
  /// are not worth a banner.
  bool isForWeekBefore(String currentWeek) {
    final previous = DateTime.tryParse(week);
    final current = DateTime.tryParse(currentWeek);
    if (previous == null || current == null) return false;
    return current.difference(previous).inDays == 7;
  }
}
