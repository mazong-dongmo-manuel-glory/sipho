import '../../../core/money/money.dart';

class Expense {
  final String id;
  final String title;
  final String category;
  final String emoji;
  final Money amount;
  final DateTime date;
  final bool hasReceipt;
  final String source;
  final int? amountMainCents;
  final double? fxRate;

  const Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.emoji,
    required this.amount,
    required this.date,
    this.hasReceipt = false,
    this.source = 'manual',
    this.amountMainCents,
    this.fxRate,
  });

  factory Expense.fromFirestore(String id, Map<String, dynamic> data) {
    final dateStr = data['date'] as String? ?? '2000-01-01';
    final parts = dateStr.split('-');
    final date = DateTime(
      int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 2000,
      int.tryParse(parts.length > 1 ? parts[1] : '') ?? 1,
      int.tryParse(parts.length > 2 ? parts[2] : '') ?? 1,
    );
    final currency = (data['currency'] as String?) ?? 'CAD';
    final cents = (data['amountCents'] as num?)?.toInt() ?? 0;
    final mainCents = (data['amountMainCents'] as num?)?.toInt();
    final merchant = (data['merchant'] as String?) ?? '';
    final category = (data['category'] as String?) ?? 'Autre';
    final source = (data['source'] as String?) ?? 'manual';
    final entryCurrency = (data['currency'] as String?) ?? currency;
    return Expense(
      id: id,
      title: merchant.isNotEmpty ? merchant : category,
      category: category,
      emoji: _emojiFor(category),
      amount: Money(cents: cents, currency: entryCurrency),
      date: date,
      hasReceipt: source == 'receipt',
      source: source,
      amountMainCents: mainCents,
      fxRate: (data['fxRate'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore({required String mainCurrency}) {
    final d =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final main = amountMainCents ?? amount.cents;
    return {
      'amountCents': amount.cents,
      'amountMainCents': main,
      'currency': amount.currency.isNotEmpty ? amount.currency : mainCurrency,
      if (fxRate != null) 'fxRate': fxRate,
      'date': d,
      'category': category.length > 40 ? category.substring(0, 40) : category,
      'source': source,
      if (title.isNotEmpty) 'merchant': title.length > 80 ? title.substring(0, 80) : title,
    };
  }

  static String _emojiFor(String cat) {
    final c = cat.toLowerCase();
    if (c == 'groceries' || c.contains('épicerie') || c.contains('epicerie')) {
      return '🛒';
    }
    if (c == 'restaurants' || c.contains('resto')) return '🍔';
    if (c == 'transport' || c.contains('transport')) return '🚌';
    if (c == 'shopping' || c.contains('shop') || c.contains('loisir')) return '🛍️';
    if (c == 'family' || c.contains('famille') || c.contains('soutien')) return '💌';
    if (c == 'phone') return '📱';
    if (c == 'internet') return '🌐';
    if (c == 'energy') return '⚡';
    if (c == 'rent') return '🏠';
    return '✨';
  }
}
