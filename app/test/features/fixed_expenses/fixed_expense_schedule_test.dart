import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_expense.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_expense_schedule.dart';

void main() {
  test('envelope ratio clamps to the budget', () {
    expect(envelopeRatio(0, 40000), 0);
    expect(envelopeRatio(20000, 40000), 0.5);
    expect(envelopeRatio(50000, 40000), 1);
    expect(envelopeRatio(100, 0), 0);
  });

  test('next bill is the soonest due day still ahead', () {
    final rent = _bill('rent', 1);
    final internet = _bill('internet', 15);
    final phone = _bill('phone', 5);

    expect(nextBill([rent, internet, phone], 10)?.category, 'internet');
    expect(nextBill([rent, phone], 20)?.category, 'rent');
    expect(nextBill(const [], 10), isNull);
  });
}

FixedExpense _bill(String category, int dueDay) {
  return FixedExpense(
    id: category,
    name: category,
    category: category,
    icon: '🏠',
    amountCents: 1000,
    dueDay: dueDay,
    createdAt: DateTime(2026, 11, 1),
  );
}
