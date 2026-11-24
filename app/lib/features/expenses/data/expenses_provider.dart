import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../../core/money/money.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_profile_provider.dart';
import '../domain/expense.dart';

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  ExpensesNotifier(this._ref) : super(const []) {
    _bind();
  }

  final Ref _ref;
  StreamSubscription? _sub;

  void _bind() {
    _ref.listen<String?>(authUidProvider, (prev, uid) {
      _sub?.cancel();
      if (uid == null) {
        state = const [];
        return;
      }
      final db = _ref.read(firestoreProvider);
      _sub = db
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .orderBy('date', descending: true)
          .limit(200)
          .snapshots()
          .listen((snap) {
        state = snap.docs
            .map((d) => Expense.fromFirestore(d.id, d.data()))
            .toList();
      }, onError: (_) {});
    }, fireImmediately: true);
  }

  Future<void> addExpense({
    required String title,
    required String category,
    required String emoji,
    required Money amount,
    String source = 'manual',
    int? amountMainCents,
    double? fxRate,
    String? entryCurrency,
  }) async {
    final uid = _ref.read(authUidProvider);
    final mainCurrency = _ref.read(userProfileProvider).currency;
    final expense = Expense(
      id: 'local',
      title: title,
      category: category,
      emoji: emoji,
      amount: Money(
        cents: amount.cents,
        currency: entryCurrency ?? amount.currency,
      ),
      date: DateTime.now(),
      hasReceipt: source == 'receipt',
      source: source,
      amountMainCents: amountMainCents ?? amount.cents,
      fxRate: fxRate,
    );

    // Optimistic
    state = [
      expense.copyWithId(DateTime.now().millisecondsSinceEpoch.toString()),
      ...state,
    ];

    if (uid == null) return;
    await _ref
        .read(firestoreProvider)
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .add(expense.toFirestore(mainCurrency: mainCurrency));
  }

  Future<void> updateExpense({
    required String id,
    String? title,
    String? category,
    Money? amount,
  }) async {
    final uid = _ref.read(authUidProvider);
    if (uid == null || id.isEmpty) return;
    final idx = state.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final current = state[idx];
    final next = Expense(
      id: current.id,
      title: title ?? current.title,
      category: category ?? current.category,
      emoji: current.emoji,
      amount: amount ?? current.amount,
      date: current.date,
      hasReceipt: current.hasReceipt,
      source: current.source,
    );
    state = [...state]..[idx] = next;
    final currency = _ref.read(userProfileProvider).currency;
    await _ref
        .read(firestoreProvider)
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(id)
        .update({
      if (title != null) 'merchant': title,
      if (category != null) 'category': category,
      if (amount != null) ...{
        'amountCents': amount.cents,
        'amountMainCents': amount.cents,
        'currency': amount.currency.isNotEmpty ? amount.currency : currency,
      },
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

extension on Expense {
  Expense copyWithId(String id) => Expense(
        id: id,
        title: title,
        category: category,
        emoji: emoji,
        amount: amount,
        date: date,
        hasReceipt: hasReceipt,
        source: source,
        amountMainCents: amountMainCents,
        fxRate: fxRate,
      );
}

final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) {
  return ExpensesNotifier(ref);
});

final totalVariableExpensesCentsProvider = Provider<int>((ref) {
  final expenses = ref.watch(expensesProvider);
  final now = DateTime.now();
  return expenses
      .where((e) => e.date.year == now.year && e.date.month == now.month)
      .fold(0, (acc, e) => acc + (e.amountMainCents ?? e.amount.cents));
});
