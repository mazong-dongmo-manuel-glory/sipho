import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/expenses/domain/parsed_receipt.dart';

void main() {
  test('keeps a visible total and drops an unknown category', () {
    final parsed = ParsedReceipt.fromModelJson({
      'isReceipt': true,
      'merchant': 'IGA',
      'date': '2026-11-10',
      'currency': 'cad',
      'totalCents': 4849,
      'suggestedCategory': 'groceries',
      'confidence': 0.91,
    });

    expect(parsed.isReceipt, isTrue);
    expect(parsed.totalCents, 4849);
    expect(parsed.currency, 'CAD');
    expect(parsed.category, 'groceries');
    expect(parsed.needsReview, isFalse);
  });

  test('drops an impossible amount and a category outside the list', () {
    final parsed = ParsedReceipt.fromModelJson({
      'isReceipt': true,
      'totalCents': 0,
      'suggestedCategory': 'food',
      'date': '10/11/2026',
      'confidence': 0.2,
    });

    expect(parsed.totalCents, isNull);
    expect(parsed.category, isNull);
    expect(parsed.date, isNull);
    expect(parsed.needsReview, isTrue);
  });

  test('categories stay aligned with the keypad', () {
    expect(receiptCategoriesMatchQuickAdd(), isTrue);
  });
}
