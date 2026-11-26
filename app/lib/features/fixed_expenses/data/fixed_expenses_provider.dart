import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/feedback/feedback_cue.dart';
import '../../../core/feedback/feedback_service.dart';
import '../../../core/firebase/cloud_functions_service.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_profile_provider.dart';
import '../domain/fixed_expense.dart';

class FixedExpensesNotifier extends StateNotifier<List<FixedExpense>> {
  FixedExpensesNotifier(this._ref) : super(const []) {
    _bind();
  }

  final Ref _ref;
  StreamSubscription? _fixedSub;
  StreamSubscription? _paidSub;
  Set<String> _paidIds = {};

  void _bind() {
    _ref.listen<String?>(authUidProvider, (prev, uid) {
      _fixedSub?.cancel();
      _paidSub?.cancel();
      _paidIds = {};
      if (uid == null) {
        state = const [];
        return;
      }
      final db = _ref.read(firestoreProvider);
      final now = DateTime.now();
      final monthKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';

      _paidSub = db
          .collection('users')
          .doc(uid)
          .collection('months')
          .doc(monthKey)
          .collection('fixed')
          .snapshots()
          .listen((snap) {
        _paidIds = snap.docs
            .where((d) => d.data()['paid'] == true)
            .map((d) => d.id)
            .toSet();
        _reapplyPaid();
      }, onError: (_) {});

      _fixedSub = db
          .collection('users')
          .doc(uid)
          .collection('fixedExpenses')
          .snapshots()
          .listen((snap) {
        final currency = _ref.read(userProfileProvider).currency;
        final list = snap.docs
            .map((d) => FixedExpense.fromFirestore(d.id, d.data(), currency: currency))
            .where((e) => e.active)
            .toList();
        state = list
            .map((e) => e.copyWith(isPaid: _paidIds.contains(e.id)))
            .toList();
      }, onError: (_) {});
    }, fireImmediately: true);
  }

  void _reapplyPaid() {
    state = state
        .map((e) => e.copyWith(isPaid: _paidIds.contains(e.id)))
        .toList();
  }

  Future<void> togglePaid(String id) async {
    final item = state.cast<FixedExpense?>().firstWhere(
          (e) => e?.id == id,
          orElse: () => null,
        );
    if (item == null || item.type == 'envelope') return;

    final now = DateTime.now();
    final monthKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final wasPaid = item.isPaid;
    state = state
        .map((e) => e.id == id ? e.copyWith(isPaid: !wasPaid) : e)
        .toList();

    if (!wasPaid) {
      final result = await _ref.read(cloudFunctionsServiceProvider).markFixedPaid(
            fixedId: id,
            monthKey: monthKey,
          );
      if (result['status'] != 'error') {
        _ref.read(feedbackServiceProvider).play(SiphoCue.fixedPaid);
      }
    }
  }

  Future<void> upsertFixedExpense(FixedExpense expense) async {
    final uid = _ref.read(authUidProvider);
    state = [
      for (final e in state)
        if (e.id == expense.id) expense else e,
      if (!state.any((e) => e.id == expense.id)) expense,
    ];
    if (uid == null) return;
    await _ref
        .read(firestoreProvider)
        .collection('users')
        .doc(uid)
        .collection('fixedExpenses')
        .doc(expense.id)
        .set(expense.toFirestore(), SetOptions(merge: true));
  }

  /// Alias conservé pour l’onboarding.
  void addFixedExpense(FixedExpense expense) {
    unawaited(upsertFixedExpense(expense));
  }

  @override
  void dispose() {
    _fixedSub?.cancel();
    _paidSub?.cancel();
    super.dispose();
  }
}

final fixedExpensesProvider =
    StateNotifierProvider<FixedExpensesNotifier, List<FixedExpense>>((ref) {
  return FixedExpensesNotifier(ref);
});

final totalFixedExpensesCentsProvider = Provider<int>((ref) {
  final fixed = ref.watch(fixedExpensesProvider);
  return fixed.fold(0, (acc, e) => acc + e.amount.cents);
});
