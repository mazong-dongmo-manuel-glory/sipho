import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/budget/domain/month_chart.dart';

void main() {
  test('groups the top three categories and the rest as other', () {
    final chart = buildMonthChart(const [
      (category: 'groceries', cents: 4200, date: '2026-11-02'),
      (category: 'restaurants', cents: 2800, date: '2026-11-03'),
      (category: 'transport', cents: 1800, date: '2026-11-04'),
      (category: 'shopping', cents: 700, date: '2026-11-06'),
      (category: 'phone', cents: 500, date: '2026-11-08'),
    ]);

    expect(chart.totalCents, 10000);
    expect(chart.slices.map((slice) => slice.category), [
      'groceries',
      'restaurants',
      'transport',
      'other',
    ]);
    expect(chart.slices.last.cents, 1200);
    expect(sharePercent(4200, 10000), 42);
  });

  test('adds each expense to its weekday, Monday first', () {
    final chart = buildMonthChart(const [
      (category: 'groceries', cents: 1000, date: '2026-11-02'),
      (category: 'groceries', cents: 500, date: '2026-11-09'),
    ]);

    expect(weekdayIndex('2026-11-02'), 0);
    expect(chart.weekdayCents[0], 1500);
    expect(chart.weekdayCents[1], 0);
  });

  test('spending change needs a previous month', () {
    expect(spendingChangePercent(800, 1000), -20);
    expect(spendingChangePercent(1200, 1000), 20);
    expect(spendingChangePercent(500, 0), isNull);
  });
}
