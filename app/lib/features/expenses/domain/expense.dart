import '../../../core/money/money.dart';

class Expense {
  final String id;
  final String title;
  final String category;
  final String emoji;
  final Money amount;
  final DateTime date;
  final bool hasReceipt;

  const Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.emoji,
    required this.amount,
    required this.date,
    this.hasReceipt = false,
  });
}
