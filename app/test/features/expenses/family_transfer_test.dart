import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/expenses/domain/family_transfer.dart';
import 'package:sipho/features/expenses/domain/transaction.dart';

void main() {
  test('spendMainCents includes transfer fees', () {
    final tx = SiphoTransaction(
      id: 't1',
      amountCents: 5000,
      currency: 'CAD',
      amountMainCents: 5000,
      category: 'family',
      feeCents: 200,
      date: '2026-11-01',
      createdAt: DateTime(2026, 11, 1),
    );
    expect(tx.spendMainCents, 5200);
  });

  test('sums family transfers and fees, and ignores other categories', () {
    final summary = summarizeFamilyTransfers(const [
      (
        category: 'family',
        amountCents: 5000,
        amountMainCents: 4800,
        feeCents: 200,
      ),
      (
        category: 'family',
        amountCents: 2500,
        amountMainCents: null,
        feeCents: null,
      ),
      (
        category: 'groceries',
        amountCents: 900,
        amountMainCents: 900,
        feeCents: 50,
      ),
    ]);
    expect(summary.count, 2);
    expect(summary.sentCents, 7300);
    expect(summary.feeCents, 200);
    expect(summary.totalCents, 7500);
  });

  test('no family transfer is an empty summary', () {
    expect(
      summarizeFamilyTransfers(const [
        (
          category: 'rent',
          amountCents: 100,
          amountMainCents: 100,
          feeCents: null,
        ),
      ]),
      FamilyTransferSummary.empty,
    );
  });
}
