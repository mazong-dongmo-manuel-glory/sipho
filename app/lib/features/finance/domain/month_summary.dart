/// Client-side month totals until Cloud Functions write `months/{yyyy-MM}`.
class MonthSummary {
  const MonthSummary({
    required this.incomeCents,
    required this.fixedCents,
    required this.spentCents,
  });

  final int incomeCents;
  final int fixedCents;
  final int spentCents;

  /// Revenu − dépenses fixes − dépenses variables du mois.
  int get remainingCents => incomeCents - fixedCents - spentCents;

  bool get hasIncome => incomeCents > 0;
}
