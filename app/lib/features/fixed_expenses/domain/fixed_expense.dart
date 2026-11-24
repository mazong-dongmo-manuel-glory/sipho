import '../../../core/money/money.dart';

class FixedExpense {
  final String id;
  final String name;
  final String category;
  final String emoji;
  final Money amount;
  final int dueDay;
  final bool isPaid;
  final String type; // bill | envelope
  final bool active;
  final String payMode; // manual | auto

  const FixedExpense({
    required this.id,
    required this.name,
    required this.category,
    required this.emoji,
    required this.amount,
    this.dueDay = 1,
    this.isPaid = false,
    this.type = 'bill',
    this.active = true,
    this.payMode = 'manual',
  });

  String get dueDayLabel {
    if (dueDay == 1) return '1er du mois';
    return '$dueDay du mois';
  }

  factory FixedExpense.fromFirestore(
    String id,
    Map<String, dynamic> data, {
    String currency = 'CAD',
  }) {
    final name = (data['name'] as String?) ?? id;
    final category = (data['category'] as String?) ?? 'Autre';
    return FixedExpense(
      id: id,
      name: name,
      category: category,
      emoji: _emojiFor(category, name),
      amount: Money(
        cents: (data['amountCents'] as num?)?.toInt() ?? 0,
        currency: (data['currency'] as String?) ?? currency,
      ),
      dueDay: (data['dueDay'] as num?)?.toInt() ?? 1,
      type: (data['type'] as String?) ?? 'bill',
      active: data['active'] != false,
      isPaid: false,
      payMode: (data['payMode'] as String?) ?? 'manual',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name.length > 80 ? name.substring(0, 80) : name,
      'category': category.length > 40 ? category.substring(0, 40) : category,
      'amountCents': amount.cents,
      'currency': amount.currency,
      'dueDay': dueDay.clamp(1, 31),
      'payMode': payMode == 'auto' ? 'auto' : 'manual',
      'type': type,
      'active': active,
    };
  }

  FixedExpense copyWith({
    String? name,
    String? category,
    String? emoji,
    Money? amount,
    int? dueDay,
    bool? isPaid,
    String? type,
    bool? active,
    String? payMode,
  }) {
    return FixedExpense(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      amount: amount ?? this.amount,
      dueDay: dueDay ?? this.dueDay,
      isPaid: isPaid ?? this.isPaid,
      type: type ?? this.type,
      active: active ?? this.active,
      payMode: payMode ?? this.payMode,
    );
  }

  static String _emojiFor(String category, String name) {
    final c = '$category $name'.toLowerCase();
    if (c.contains('loyer') || c.contains('logement')) return '🏠';
    if (c.contains('internet')) return '📶';
    if (c.contains('électri') || c.contains('electri')) return '💡';
    if (c.contains('téléphone') || c.contains('telephone')) return '📱';
    if (c.contains('épicerie') || c.contains('epicerie')) return '🛒';
    if (c.contains('transport')) return '🚌';
    if (c.contains('famille')) return '💌';
    return '📌';
  }
}
