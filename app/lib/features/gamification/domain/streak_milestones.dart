/// Streak milestones (README §5.3). Keep in sync with `STREAK_MILESTONES` on the server.
const List<int> kStreakMilestones = [3, 7, 14, 30, 50, 100, 200, 365];

bool streakMilestoneReached(int bestOrCurrent, int milestone) =>
    bestOrCurrent >= milestone;

/// True when a repair is still possible client-side (server re-checks).
bool canOfferStreakRepair({
  required String? brokenAt,
  required int brokenCurrent,
  required int freezes,
  DateTime? now,
}) {
  if (brokenAt == null || brokenCurrent <= 0 || freezes < 1) return false;
  final broken = DateTime.tryParse(brokenAt);
  if (broken == null) return false;
  final elapsed = (now ?? DateTime.now()).difference(broken);
  return elapsed <= const Duration(hours: 24) && !elapsed.isNegative;
}
