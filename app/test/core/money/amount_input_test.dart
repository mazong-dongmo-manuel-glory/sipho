import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/core/money/amount_input.dart';

void main() {
  test('parses comma and dot decimals into cents', () {
    expect(AmountInput.parseCents('18,50'), 1850);
    expect(AmountInput.parseCents('18.5'), 1850);
    expect(AmountInput.parseCents('18'), 1800);
    expect(AmountInput.parseCents(',5'), 50);
    expect(AmountInput.parseCents(''), 0);
  });

  test('rejects a second decimal separator and a third decimal digit', () {
    expect(AmountInput.canAppend('18,50', '1'), isFalse);
    expect(AmountInput.canAppend('18,5', ','), isFalse);
    expect(AmountInput.canAppend('18', '5'), isTrue);
  });
}
