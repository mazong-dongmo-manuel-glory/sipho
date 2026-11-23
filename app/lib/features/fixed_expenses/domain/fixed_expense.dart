import '../../../core/money/money.dart';

class FixedExpense {
  final String id;
  final String name;
  final String category;
  final String emoji;
  final Money amount;
  final String dueDay;
  final bool isPaid;

  const FixedExpense({
    required this.id,
    required this.name,
    required this.category,
    required this.emoji,
    required this.amount,
    required this.dueDay,
    this.isPaid = false,
  });

  FixedExpense copyWith({
    String? name,
    String? category,
    String? emoji,
    Money? amount,
    String? dueDay,
    bool? isPaid,
  }) {
    return FixedExpense(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      amount: amount ?? this.amount,
      dueDay: dueDay ?? this.dueDay,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
