class MonthRecapFacts {
  const MonthRecapFacts({
    required this.expenseCount,
    required this.spentCents,
    required this.savedCents,
    required this.changePercent,
    required this.focusCategory,
    required this.focusPercent,
    required this.focusImproved,
  });

  final int expenseCount;
  final int spentCents;

  /// How much less was spent than last month. Zero when spending rose or
  /// there is no earlier month.
  final int savedCents;

  /// Whole-month change versus the previous month. Null without a baseline.
  final int? changePercent;

  /// Category to highlight: the one that fell the most, or the largest share.
  final String? focusCategory;

  /// Drop (positive) or share of the month (positive) for [focusCategory].
  final int focusPercent;

  /// True when [focusPercent] is a drop versus last month.
  final bool focusImproved;

  static const empty = MonthRecapFacts(
    expenseCount: 0,
    spentCents: 0,
    savedCents: 0,
    changePercent: null,
    focusCategory: null,
    focusPercent: 0,
    focusImproved: false,
  );
}

int _centsOf({
  required int amountCents,
  int? amountMainCents,
  int? feeCents,
}) {
  final amount = amountMainCents ?? amountCents;
  final fee = feeCents ?? 0;
  return amount + (fee > 0 ? fee : 0);
}

/// Real month-versus-month figures for the recap. Amounts stay in cents.
MonthRecapFacts buildMonthRecap({
  required List<
          ({
            String category,
            int amountCents,
            int? amountMainCents,
            int? feeCents,
          })>
      current,
  required List<
          ({
            String category,
            int amountCents,
            int? amountMainCents,
            int? feeCents,
          })>
      previous,
}) {
  if (current.isEmpty) return MonthRecapFacts.empty;

  final currentTotals = <String, int>{};
  var spent = 0;
  for (final row in current) {
    final cents = _centsOf(
      amountCents: row.amountCents,
      amountMainCents: row.amountMainCents,
      feeCents: row.feeCents,
    );
    if (cents <= 0) continue;
    spent += cents;
    currentTotals[row.category] = (currentTotals[row.category] ?? 0) + cents;
  }
  if (spent <= 0) return MonthRecapFacts.empty;

  final previousTotals = <String, int>{};
  var previousSpent = 0;
  for (final row in previous) {
    final cents = _centsOf(
      amountCents: row.amountCents,
      amountMainCents: row.amountMainCents,
      feeCents: row.feeCents,
    );
    if (cents <= 0) continue;
    previousSpent += cents;
    previousTotals[row.category] =
        (previousTotals[row.category] ?? 0) + cents;
  }

  final saved = previousSpent > spent ? previousSpent - spent : 0;
  final change = previousSpent <= 0
      ? null
      : (((spent - previousSpent) * 100) / previousSpent).round();

  String? bestCategory;
  var bestDrop = 0;
  for (final entry in currentTotals.entries) {
    final before = previousTotals[entry.key] ?? 0;
    if (before <= 0 || entry.value >= before) continue;
    final drop = (((before - entry.value) * 100) / before).round();
    if (drop > bestDrop) {
      bestDrop = drop;
      bestCategory = entry.key;
    }
  }

  if (bestCategory != null) {
    return MonthRecapFacts(
      expenseCount: current.length,
      spentCents: spent,
      savedCents: saved,
      changePercent: change,
      focusCategory: bestCategory,
      focusPercent: bestDrop,
      focusImproved: true,
    );
  }

  var topCategory = currentTotals.keys.first;
  var topCents = 0;
  for (final entry in currentTotals.entries) {
    if (entry.value > topCents) {
      topCents = entry.value;
      topCategory = entry.key;
    }
  }
  final share = ((topCents * 100) / spent).round();
  return MonthRecapFacts(
    expenseCount: current.length,
    spentCents: spent,
    savedCents: saved,
    changePercent: change,
    focusCategory: topCategory,
    focusPercent: share,
    focusImproved: false,
  );
}
