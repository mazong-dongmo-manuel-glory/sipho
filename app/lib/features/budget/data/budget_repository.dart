import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/budget.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(FirebaseFirestore.instance);
});

class BudgetRepository {
  final FirebaseFirestore _firestore;

  BudgetRepository(this._firestore);

  Stream<MonthBudget?> watchBudget(String uid, String yearMonth) {
    return _firestore.doc('users/$uid/budgets/$yearMonth').snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;
      final rawLimits = data['categories'] as Map<String, dynamic>? ?? {};
      final limits = rawLimits.map((k, v) => MapEntry(k, (v as num).toInt()));
      return MonthBudget(
        monthKey: yearMonth,
        categoryLimitsCents: limits,
        rule: data['rule'] ?? '50_30_20',
      );
    });
  }

  Future<void> setBudget(String uid, MonthBudget budget) async {
    await _firestore.doc('users/$uid/budgets/${budget.monthKey}').set({
      'categories': budget.categoryLimitsCents,
      'rule': budget.rule,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

