/// Which days of the current calendar week (Monday → Sunday) belong to the
/// user's streak.
///
/// The server only stores `streak.current` and `streak.lastActiveDay`
/// (`yyyy-MM-dd`, computed in the user's own timezone), so the streak covers the
/// `current` consecutive days ending on `lastActiveDay`. [today] must be the
/// user's local day; only its calendar date is used.
List<bool> streakWeekMarks({
  required String? lastActiveDay,
  required int current,
  required DateTime today,
}) {
  final marks = List<bool>.filled(7, false);
  final last = _parseDay(lastActiveDay);
  if (last == null || current <= 0) return marks;

  // UTC dates make day arithmetic immune to daylight-saving shifts.
  final todayDate = DateTime.utc(today.year, today.month, today.day);
  final monday = todayDate.subtract(Duration(days: todayDate.weekday - 1));
  final streakStart = last.subtract(Duration(days: current - 1));

  for (var i = 0; i < 7; i++) {
    final day = monday.add(Duration(days: i));
    marks[i] = !day.isBefore(streakStart) && !day.isAfter(last);
  }
  return marks;
}

DateTime? _parseDay(String? value) {
  if (value == null) return null;
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match == null) return null;
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final parsed = DateTime.utc(year, month, day);
  // Reject impossible dates such as 2026-02-31 (DateTime would roll them over).
  if (parsed.month != month || parsed.day != day) return null;
  return parsed;
}
