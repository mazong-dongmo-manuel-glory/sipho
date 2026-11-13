import 'package:sipho/features/fixed_expenses/domain/fixed_expense.dart';

/// Share of an envelope already spent this month, clamped to 0–1.
double envelopeRatio(int spentCents, int budgetCents) {
  if (budgetCents <= 0 || spentCents <= 0) return 0;
  final ratio = spentCents / budgetCents;
  if (ratio > 1) return 1;
  return ratio;
}

/// Next bill on or after [today], otherwise the earliest bill next month.
FixedExpense? nextBill(List<FixedExpense> items, int today) {
  final bills = items.where((expense) => expense.type != 'envelope').toList()
    ..sort((a, b) => a.dueDay.compareTo(b.dueDay));
  if (bills.isEmpty) return null;
  for (final bill in bills) {
    if (bill.dueDay >= today) return bill;
  }
  return bills.first;
}
