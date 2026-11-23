import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/money/money.dart';
import '../domain/expense.dart';

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  ExpensesNotifier()
      : super([
          Expense(
            id: '1',
            title: 'Restaurant La Banquise',
            category: 'Restos',
            emoji: '🍔',
            amount: const Money(cents: 2450),
            date: DateTime.now(),
          ),
          Expense(
            id: '2',
            title: 'IGA Trois-Rivières',
            category: 'Épicerie',
            emoji: '🛒',
            amount: const Money(cents: 4849),
            date: DateTime.now(),
            hasReceipt: true,
          ),
          Expense(
            id: '3',
            title: 'Titre de transport',
            category: 'Transport',
            emoji: '🚌',
            amount: const Money(cents: 375),
            date: DateTime.now().subtract(const Duration(days: 1)),
          ),
          Expense(
            id: '4',
            title: 'Transfert famille',
            category: 'Famille',
            emoji: '💌',
            amount: const Money(cents: 15000),
            date: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ]);

  void addExpense({
    required String title,
    required String category,
    required String emoji,
    required Money amount,
  }) {
    final newExpense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      emoji: emoji,
      amount: amount,
      date: DateTime.now(),
    );
    state = [newExpense, ...state];
  }

  int get totalCents => state.fold(0, (acc, e) => acc + e.amount.cents);
}

final expensesProvider = StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) {
  return ExpensesNotifier();
});

/// Provider calculant le total des dépenses variables du mois
final totalVariableExpensesCentsProvider = Provider<int>((ref) {
  final expenses = ref.watch(expensesProvider);
  return expenses.fold(0, (acc, e) => acc + e.amount.cents);
});
