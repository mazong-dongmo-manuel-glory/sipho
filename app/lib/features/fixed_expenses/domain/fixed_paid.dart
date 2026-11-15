import 'package:sipho/features/fixed_expenses/domain/fixed_expense.dart';

/// Number of days in [now]'s month.
int daysInMonth(DateTime now) => DateTime(now.year, now.month + 1, 0).day;

/// Due day actually used this month (a bill due on the 31st falls on the 30th in April).
int effectiveDueDay(FixedExpense expense, DateTime now) {
  final last = daysInMonth(now);
  return expense.dueDay > last ? last : expense.dueDay;
}

/// Whether a bill counts as paid for the month of [now].
///
///  * Envelopes are budgets, not bills: never "paid".
///  * Manual bills are paid once the server recorded it (`months/{yyyy-MM}.fixedPaid.<id>.paid`).
///  * Automatic bills are debited by the bank, so they count as paid from their due day on.
bool isFixedPaid(
  FixedExpense expense, {
  required Set<String> paidIds,
  required DateTime now,
}) {
  if (expense.type == 'envelope') return false;
  if (paidIds.contains(expense.id)) return true;
  return expense.payMode != 'manual' && effectiveDueDay(expense, now) <= now.day;
}

/// Whether the "Payé ✓" button should be offered: a manual bill not yet paid this month.
bool canMarkFixedPaid(
  FixedExpense expense, {
  required Set<String> paidIds,
}) {
  return expense.type != 'envelope' &&
      expense.active &&
      expense.payMode == 'manual' &&
      !paidIds.contains(expense.id);
}

/// Reads the paid ids out of a `months/{yyyy-MM}` document.
Set<String> paidIdsFromMonth(Map<String, dynamic>? month) {
  final raw = month?['fixedPaid'];
  if (raw is! Map) return const <String>{};
  final ids = <String>{};
  raw.forEach((key, value) {
    if (value is Map && value['paid'] == true) ids.add(key.toString());
  });
  return ids;
}
