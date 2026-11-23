class FamilyTransferSummary {
  const FamilyTransferSummary({
    required this.count,
    required this.sentCents,
    required this.feeCents,
  });

  final int count;
  final int sentCents;
  final int feeCents;

  int get totalCents => sentCents + feeCents;

  static const empty = FamilyTransferSummary(count: 0, sentCents: 0, feeCents: 0);
}

/// Sums family transfers for the month. Amounts are cents in the main currency
/// when [amountMainCents] is set.
FamilyTransferSummary summarizeFamilyTransfers(
  List<
      ({
        String category,
        int amountCents,
        int? amountMainCents,
        int? feeCents,
      })> rows,
) {
  var count = 0;
  var sent = 0;
  var fees = 0;
  for (final row in rows) {
    if (row.category != 'family') continue;
    final amount = row.amountMainCents ?? row.amountCents;
    if (amount <= 0) continue;
    count += 1;
    sent += amount;
    final fee = row.feeCents ?? 0;
    if (fee > 0) fees += fee;
  }
  if (count == 0) return FamilyTransferSummary.empty;
  return FamilyTransferSummary(count: count, sentCents: sent, feeCents: fees);
}
