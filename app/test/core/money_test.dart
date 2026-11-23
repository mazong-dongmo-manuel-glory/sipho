import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/core/money/money.dart';

void main() {
  group('Money domain tests', () {
    test('creates Money from cents and formats properly', () {
      const m = Money(cents: 1850, currency: 'CAD');
      expect(m.cents, 1850);
      expect(m.toMajor(), 18.5);
      expect(m.format('fr_CA'), contains('18,50'));
    });

    test('creates Money from whole major amount', () {
      final m = Money.fromMajor(950, 'CAD');
      expect(m.cents, 95000);
      expect(m.formatWhole('fr_CA'), contains('950'));
    });

    test('supports arithmetic operations in cents', () {
      const a = Money(cents: 1000);
      const b = Money(cents: 2500);
      final sum = a + b;
      final diff = b - a;
      final multiplied = a * 2;

      expect(sum.cents, 3500);
      expect(diff.cents, 1500);
      expect(multiplied.cents, 2000);
    });

    test('preserves immutability and equality', () {
      const a = Money(cents: 500);
      const b = Money(cents: 500);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
