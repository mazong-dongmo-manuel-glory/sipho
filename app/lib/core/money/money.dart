import 'package:intl/intl.dart';

/// Règle non négociable : Montants en cents (int), jamais de double pour manipuler l'argent.
class Money {
  final int cents;
  final String currency;

  const Money({
    required this.cents,
    this.currency = 'CAD',
  });

  const Money.zero([String currency = 'CAD']) : this(cents: 0, currency: currency);

  factory Money.fromMajor(num amount, [String currency = 'CAD']) {
    return Money(
      cents: (amount * 100).round(),
      currency: currency,
    );
  }

  double toMajor() => cents / 100.0;

  Money operator +(Money other) {
    assert(currency == other.currency, 'Cannot add amounts of different currencies');
    return Money(cents: cents + other.cents, currency: currency);
  }

  Money operator -(Money other) {
    assert(currency == other.currency, 'Cannot subtract amounts of different currencies');
    return Money(cents: cents - other.cents, currency: currency);
  }

  Money operator *(num factor) {
    return Money(cents: (cents * factor).round(), currency: currency);
  }

  bool get isNegative => cents < 0;
  bool get isPositive => cents > 0;
  bool get isZero => cents == 0;

  bool get _isCfa =>
      currency.toUpperCase() == 'XAF' || currency.toUpperCase() == 'XOF';

  /// Formate le montant selon la locale (ex: "18,50 $" ou "18 500 FCFA")
  String format([String? locale]) {
    final loc = locale ?? 'fr_CA';
    if (_isCfa) {
      final major = cents / 100.0;
      final digits = cents % 100 == 0 ? 0 : 2;
      final number = NumberFormat.decimalPatternDigits(
        locale: loc,
        decimalDigits: digits,
      ).format(major);
      return '$number ${_getCurrencySymbol(currency)}';
    }
    final format = NumberFormat.currency(
      locale: loc,
      name: currency,
      symbol: _getCurrencySymbol(currency),
      decimalDigits: (cents % 100 == 0) ? 0 : 2,
    );
    return format.format(cents / 100.0);
  }

  /// Format compact sans décimales (ex: "950 $" · "100 000 FCFA")
  String formatWhole([String? locale]) {
    final loc = locale ?? 'fr_CA';
    final major = (cents / 100.0).round();
    if (_isCfa) {
      final number = NumberFormat.decimalPattern(loc).format(major);
      return '$number ${_getCurrencySymbol(currency)}';
    }
    final format = NumberFormat.currency(
      locale: loc,
      name: currency,
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 0,
    );
    return format.format(major);
  }

  static String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'CAD':
        return '\$';
      case 'USD':
        return 'US\$';
      case 'EUR':
        return '€';
      case 'XAF':
      case 'XOF':
        return 'FCFA';
      default:
        return currencyCode;
    }
  }

  @override
  String toString() => '$cents cents ($currency)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money && runtimeType == other.runtimeType && cents == other.cents && currency == other.currency;

  @override
  int get hashCode => cents.hashCode ^ currency.hashCode;
}
