import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/core/money/money.dart';
import 'package:sipho/core/money/money_formatter.dart';

String _plain(String s) => s.replaceAll(RegExp(r'[\u00A0\u202F]'), ' ');

void main() {
  group('Money', () {
    test('arithmetic is exact on integer cents (no 0.1 + 0.2 drift)', () {
      const a = Money(cents: 10, currency: 'CAD');
      const b = Money(cents: 20, currency: 'CAD');
      expect((a + b).cents, 30);
      expect((b - a).cents, 10);
      expect((a - b).cents, -10);
      expect((a - b).isNegative, isTrue);
    });

    test('keeps its currency through operations', () {
      const a = Money(cents: 500, currency: 'XAF');
      expect((a + a).currency, 'XAF');
      expect(a.abs().currency, 'XAF');
      expect(a.clamp(0, 100).currency, 'XAF');
    });

    test('zero, abs and clamp', () {
      expect(Money.zero.isZero, isTrue);
      expect(const Money(cents: -4849, currency: 'EUR').abs().cents, 4849);
      const m = Money(cents: 99999, currency: 'USD');
      expect(m.clamp(0, 5000).cents, 5000);
      expect(const Money(cents: -5, currency: 'USD').clamp(0, 5000).cents, 0);
    });

    test('is a value object', () {
      expect(const Money(cents: 1, currency: 'CAD'),
          const Money(cents: 1, currency: 'CAD'));
      expect(const Money(cents: 1, currency: 'CAD'),
          isNot(const Money(cents: 1, currency: 'USD')));
    });

    test('mixing currencies is rejected', () {
      const cad = Money(cents: 1, currency: 'CAD');
      const usd = Money(cents: 1, currency: 'USD');
      expect(() => cad + usd, throwsA(isA<AssertionError>()));
      expect(() => cad - usd, throwsA(isA<AssertionError>()));
    });
  });

  group('MoneyFormatter', () {
    test('formats cents in French (Canada) with the currency symbol', () {
      final out = _plain(MoneyFormatter.format(
          const Money(cents: 4849, currency: 'CAD'),
          locale: 'fr_CA'));
      expect(out, '48,49 \$');
    });

    test('formats cents in English (US) with the symbol first', () {
      final out = MoneyFormatter.format(
          const Money(cents: 4849, currency: 'USD'),
          locale: 'en_US');
      expect(out, '\$48.49');
    });

    test('keeps the sign for negative amounts', () {
      final out = _plain(MoneyFormatter.format(
          const Money(cents: -1250, currency: 'EUR'),
          locale: 'fr_FR'));
      expect(out, contains('12,50'));
      expect(out, contains('-'));
      expect(out, contains('€'));
    });

    test('uses FCFA for both CFA franc currencies', () {
      expect(MoneyFormatter.currencySymbol('XAF'), 'FCFA');
      expect(MoneyFormatter.currencySymbol('XOF'), 'FCFA');
    });

    test('unknown currencies fall back to their ISO code', () {
      expect(MoneyFormatter.currencySymbol('JPY'), 'JPY');
    });

    test('formatDiff adds an explicit sign', () {
      final f = MoneyFormatter('en_US');
      expect(f.formatDiff(const Money(cents: 500, currency: 'USD')), '+\$5.00');
      expect(
          f.formatDiff(const Money(cents: -500, currency: 'USD')), '-\$5.00');
    });
  });
}
