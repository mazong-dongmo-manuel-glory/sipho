import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_expense.dart';

final fixedExpenseRepositoryProvider = Provider<FixedExpenseRepository>((ref) {
  return FixedExpenseRepository(ref.watch(firestoreProvider));
});

class FixedExpenseRepository {
  final FirebaseFirestore _firestore;

  FixedExpenseRepository(this._firestore);

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
