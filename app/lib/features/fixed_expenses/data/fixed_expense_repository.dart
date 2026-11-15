import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_expense.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_paid.dart';

final fixedExpenseRepositoryProvider = Provider<FixedExpenseRepository>((ref) {
  return FixedExpenseRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseFunctionsProvider),
  );
});

class FixedExpenseRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  FixedExpenseRepository(this._firestore, this._functions);

  /// Ids of the bills already paid in [monthKey] (`yyyy-MM`). The month document is written by
  /// the `markFixedPaid` Cloud Function only; clients just read it.
  Stream<Set<String>> watchPaidFixedIds(String uid, String monthKey) {
    return _firestore
        .doc('users/$uid/months/$monthKey')
        .snapshots()
        .map((doc) => paidIdsFromMonth(doc.data()));
  }

  /// Marks a bill as paid for [monthKey] through the `markFixedPaid` callable (XP is awarded
  /// server-side; only the current month is accepted).
  Future<void> markPaid(String fixedId, String monthKey) async {
    await _functions.httpsCallable('markFixedPaid').call<Map<String, dynamic>>({
      'fixedId': fixedId,
      'monthKey': monthKey,
    });
  }

  Stream<List<FixedExpense>> watchFixedExpenses(String uid) {
    return _firestore
        .collection('users/$uid/fixedExpenses')
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final items = snap.docs.map((d) {
        final data = d.data();
        return FixedExpense(
          id: d.id,
          name: data['name'] as String? ?? '',
          category: data['category'] as String? ?? 'other',
          icon: data['icon'] as String? ?? '🏠',
          amountCents: (data['amountCents'] as num?)?.toInt() ?? 0,
          dueDay: (data['dueDay'] as num?)?.toInt() ?? 1,
          payMode: data['payMode'] as String? ?? 'auto',
          type: data['type'] as String? ?? 'bill',
          active: data['active'] as bool? ?? true,
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
      items.sort((a, b) => a.dueDay.compareTo(b.dueDay));
      return items;
    });
  }

  Future<void> addFixedExpense(String uid, FixedExpense expense) async {
    await _firestore.collection('users/$uid/fixedExpenses').add({
      'name': expense.name,
      'category': expense.category,
      'icon': expense.icon,
      'amountCents': expense.amountCents,
      'dueDay': expense.dueDay,
      'payMode': expense.payMode,
      'type': expense.type,
      'active': expense.active,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateFixedExpense(String uid, FixedExpense expense) async {
    await _firestore
        .collection('users/$uid/fixedExpenses')
        .doc(expense.id)
        .update({
      'name': expense.name.trim(),
      'category': expense.category,
      'icon': expense.icon,
      'amountCents': expense.amountCents,
      'dueDay': expense.dueDay.clamp(1, 31),
      'payMode': expense.payMode == 'manual' ? 'manual' : 'auto',
      'type': expense.type,
      'active': expense.active,
    });
  }

  Future<void> deleteFixedExpense(String uid, String id) async {
    await _firestore.collection('users/$uid/fixedExpenses').doc(id).delete();
  }
}
