import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/finance/data/fx_rates_repository.dart';

void main() {
  const fx = FxRates(
    base: 'USD',
    rates: {'CAD': 1.40, 'EUR': 0.90, 'XOF': 600},
  );

  test('same currency keeps cents and rate 1', () {
    expect(fx.convertCents(amountCents: 1234, from: 'CAD', to: 'cad'), 1234);
    expect(fx.rateTo(from: 'EUR', to: 'EUR'), 1);
  });

  test('converts via base', () {
    // 100 USD → CAD at 1.40
    expect(fx.convertCents(amountCents: 10000, from: 'USD', to: 'CAD'), 14000);
    // 140 CAD → USD
    expect(fx.convertCents(amountCents: 14000, from: 'CAD', to: 'USD'), 10000);
    // 90 EUR → CAD: (90/0.9)*1.4 = 140
    expect(fx.convertCents(amountCents: 9000, from: 'EUR', to: 'CAD'), 14000);
  });

  test('missing rate returns null', () {
    expect(fx.convertCents(amountCents: 100, from: 'GBP', to: 'CAD'), isNull);
    expect(fx.rateTo(from: 'GBP', to: 'USD'), isNull);
  });
}
