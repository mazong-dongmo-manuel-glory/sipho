import 'package:intl/intl.dart';
import 'package:sipho/core/money/money.dart';

class MoneyFormatter {
  MoneyFormatter(this.locale);

  final String locale;

  static String format(Money money,
      {String locale = 'fr_CA', bool compact = false}) {
    final amount = money.amount;
    final formatter = compact
        ? NumberFormat.compactCurrency(
            locale: locale, symbol: _symbol(money.currency))
        : NumberFormat.currency(
            locale: locale, symbol: _symbol(money.currency));
    return formatter.format(amount);
  }

  String formatWithLocale(Money money, {bool compact = false}) =>
      format(money, locale: locale, compact: compact);

  String formatCents(int cents, String currency) =>
      format(Money(cents: cents, currency: currency), locale: locale);

  String formatDiff(Money money) {
    final sign = money.isNegative ? '-' : '+';
    return '$sign${format(money.abs(), locale: locale)}';
  }

  static String currencySymbol(String currency) => _symbol(currency);

  static String _symbol(String currency) {
    const symbols = {
      'CAD': '\$',
      'USD': '\$',
      'EUR': '€',
      'XAF': 'FCFA',
      'XOF': 'FCFA',
      'GBP': '£',
      'CHF': 'CHF ',
    };
    return symbols[currency] ?? currency;
  }
}
