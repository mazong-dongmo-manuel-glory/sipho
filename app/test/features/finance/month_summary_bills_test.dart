import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/finance/domain/month_summary.dart';

void main() {
  test('remaining uses bills only — envelopes are not double-counted', () {
    // Income 3000, rent bill 1000, grocery envelope 500 (ignored here),
    // grocery spends 200 → remaining 1800 (not 1300).
    const summary = MonthSummary(
      incomeCents: 300000,
      fixedCents: 100000, // bills only
      spentCents: 20000,
    );
    expect(summary.remainingCents, 180000);
  });
}
