import 'package:intl/intl.dart';
import 'money.dart';

class MoneyFormatter {
  MoneyFormatter(this.locale);

  final String locale;

  String format(Money money, {bool compact = false}) {
    final amount = money.amount;
    final format = compact
        ? NumberFormat.compactCurrency(locale: locale, symbol: _symbol(money.currency))
        : NumberFormat.currency(locale: locale, symbol: _symbol(money.currency));
    return format.format(amount);
  }

  String formatCents(int cents, String currency) =>
      format(Money(cents: cents, currency: currency));

  String formatDiff(Money money) {
    final sign = money.isNegative ? '-' : '+';
    return '$sign${format(money.abs())}';
  }

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
