import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/finance/domain/month_summary.dart';

void main() {
  test('remaining is income minus fixed minus variable spending', () {
    const summary = MonthSummary(
      incomeCents: 280000,
      fixedCents: 169000,
      spentCents: 46800,
    );

    expect(summary.remainingCents, 64200);
    expect(summary.hasIncome, isTrue);
  });

  test('overspending yields a negative remainder', () {
    const summary = MonthSummary(
      incomeCents: 100000,
      fixedCents: 80000,
      spentCents: 30000,
    );

    expect(summary.remainingCents, -10000);
  });
}
