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
