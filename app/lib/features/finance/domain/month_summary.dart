/// Client-side month totals until Cloud Functions write `months/{yyyy-MM}`.
class MonthSummary {
  const MonthSummary({
    required this.incomeCents,
    required this.fixedCents,
    required this.spentCents,
  });

  final int incomeCents;

  /// Recurring **bills** only (rent, phone…). Envelopes are budgets for
  /// variable spend and must not be subtracted here — their spend is already
  /// in [spentCents].
  final int fixedCents;

  /// All logged transactions this month (principal + fees), main currency.
  final int spentCents;

  /// Income − bills − logged spends (envelopes are not double-counted).
  int get remainingCents => incomeCents - fixedCents - spentCents;

  bool get hasIncome => incomeCents > 0;
}
