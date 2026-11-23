import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/cloud_functions_service.dart';
import '../../../core/money/money.dart';
import '../domain/fixed_expense.dart';

class FixedExpensesNotifier extends StateNotifier<List<FixedExpense>> {
  final CloudFunctionsService? _functionsService;

  FixedExpensesNotifier([this._functionsService])
      : super([
          const FixedExpense(
            id: 'rent',
            name: 'Loyer',
            category: 'Logement',
            emoji: '🏠',
            amount: Money(cents: 95000), // 950 $ CAD
            dueDay: '1er du mois',
            isPaid: true,
          ),
          const FixedExpense(
            id: 'internet',
            name: 'Internet',
            category: 'Services',
            emoji: '📶',
            amount: Money(cents: 7500), // 75 $ CAD
            dueDay: '15 du mois',
            isPaid: false,
          ),
          const FixedExpense(
            id: 'electricity',
            name: 'Électricité',
            category: 'Services',
            emoji: '💡',
            amount: Money(cents: 6000), // 60 $ CAD
            dueDay: '20 du mois',
            isPaid: false,
          ),
          const FixedExpense(
            id: 'phone',
            name: 'Téléphone',
            category: 'Services',
            emoji: '📱',
            amount: Money(cents: 4500), // 45 $ CAD
            dueDay: '5 du mois',
            isPaid: true,
          ),
          const FixedExpense(
            id: 'groceries',
            name: 'Épicerie (enveloppe)',
            category: 'Alimentation',
            emoji: '🛒',
            amount: Money(cents: 40000), // 400 $ CAD
            dueDay: 'Mensuel',
            isPaid: false,
          ),
        ]);

  Future<void> togglePaid(String id) async {
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    // 1. Mise à jour optimiste locale instantanée
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isPaid: !item.isPaid);
      }
      return item;
    }).toList();

    // 2. Appel asynchrone vers la Cloud Function markFixedPaid
    if (_functionsService != null) {
      await _functionsService.markFixedPaid(
        fixedExpenseId: id,
        month: currentMonth,
      );
    }
  }

  void addFixedExpense(FixedExpense expense) {
    state = [...state, expense];
  }
}

final fixedExpensesProvider = StateNotifierProvider<FixedExpensesNotifier, List<FixedExpense>>((ref) {
  final functions = ref.watch(cloudFunctionsServiceProvider);
  return FixedExpensesNotifier(functions);
});

/// Total des dépenses fixes du socle
final totalFixedExpensesCentsProvider = Provider<int>((ref) {
  final fixed = ref.watch(fixedExpensesProvider);
  return fixed.fold(0, (acc, e) => acc + e.amount.cents);
});
