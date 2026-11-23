class SpendingSlice {
  const SpendingSlice({required this.category, required this.cents});

  final String category;
  final int cents;
}

class MonthChartData {
  const MonthChartData({
    required this.totalCents,
    required this.slices,
    required this.weekdayCents,
  });

  final int totalCents;
  final List<SpendingSlice> slices;

  /// Monday = 0 … Sunday = 6.
  final List<int> weekdayCents;

  static const empty = MonthChartData(
    totalCents: 0,
    slices: [],
    weekdayCents: [0, 0, 0, 0, 0, 0, 0],
  );
}

int? weekdayIndex(String isoDate) {
  final parts = isoDate.split('-');
  if (parts.length != 3) return null;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) return null;
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) return null;
  return date.weekday - 1;
}

int sharePercent(int cents, int totalCents) {
  if (totalCents <= 0 || cents <= 0) return 0;
  return ((cents * 100) / totalCents).round();
}

/// Positive when spending rose, negative when it fell. Null without a baseline.
int? spendingChangePercent(int currentCents, int previousCents) {
  if (previousCents <= 0) return null;
  return (((currentCents - previousCents) * 100) / previousCents).round();
}

/// Categories treated as fixed / "socle" when present on a transaction.
/// Keep aligned with bill templates in [kSocleTemplates] (+ common aliases).
const Set<String> kFixedExpenseCategories = {
  'rent',
  'internet',
  'energy',
  'phone',
  'insurance',
  'electricity', // alias of energy
  'water',
};

class FixedVsVariable {
  const FixedVsVariable({
    required this.fixedCents,
    required this.variableCents,
  });

  final int fixedCents;
  final int variableCents;

  int get totalCents => fixedCents + variableCents;
}

FixedVsVariable buildFixedVsVariable(
  List<({String category, int cents})> rows, {
  Set<String> fixedCategories = kFixedExpenseCategories,
}) {
  var fixed = 0;
  var variable = 0;
  for (final row in rows) {
    if (row.cents <= 0) continue;
    if (fixedCategories.contains(row.category)) {
      fixed += row.cents;
    } else {
      variable += row.cents;
    }
  }
  return FixedVsVariable(fixedCents: fixed, variableCents: variable);
}

/// One month on the 6-month trend (oldest → newest).
class MonthTrendPoint {
  const MonthTrendPoint({
    required this.monthKey,
    required this.totalCents,
  });

  final String monthKey;
  final int totalCents;
}

/// Builds up to [monthCount] points ending at [endMonth] (inclusive).
/// [totalsByMonth] maps `yyyy-MM` → total cents.
List<MonthTrendPoint> buildSixMonthTrend({
  required DateTime endMonth,
  required Map<String, int> totalsByMonth,
  int monthCount = 6,
}) {
  final points = <MonthTrendPoint>[];
  for (var i = monthCount - 1; i >= 0; i--) {
    final m = DateTime(endMonth.year, endMonth.month - i);
    final key =
        '${m.year.toString().padLeft(4, '0')}-${m.month.toString().padLeft(2, '0')}';
    points.add(
      MonthTrendPoint(monthKey: key, totalCents: totalsByMonth[key] ?? 0),
    );
  }
  return points;
}

MonthChartData buildMonthChart(
  List<({String category, int cents, String date})> rows,
) {
  final byCategory = <String, int>{};
  final weekdays = List<int>.filled(7, 0);
  var total = 0;
  for (final row in rows) {
    if (row.cents <= 0) continue;
    total += row.cents;
    byCategory[row.category] = (byCategory[row.category] ?? 0) + row.cents;
    final index = weekdayIndex(row.date);
    if (index != null) weekdays[index] += row.cents;
  }

  final ranked = byCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final slices = <SpendingSlice>[];
  var other = 0;
  for (var i = 0; i < ranked.length; i++) {
    if (i < 3) {
      slices
          .add(SpendingSlice(category: ranked[i].key, cents: ranked[i].value));
    } else {
      other += ranked[i].value;
    }
  }
  if (other > 0) {
    slices.add(SpendingSlice(category: 'other', cents: other));
  }
  return MonthChartData(
    totalCents: total,
    slices: slices,
    weekdayCents: weekdays,
  );
}
