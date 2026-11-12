import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/fixed_expense.dart';

final fixedExpenseRepositoryProvider = Provider<FixedExpenseRepository>((ref) {
  return FixedExpenseRepository(FirebaseFirestore.instance);
});

class FixedExpenseRepository {
  final FirebaseFirestore _firestore;

  FixedExpenseRepository(this._firestore);

  Stream<List<FixedExpense>> watchFixedExpenses(String uid) {
    return _firestore
        .collection('users/$uid/fixedExpenses')
        .where('active', '==', true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              return FixedExpense(
                id: d.id,
                name: data['name'] ?? '',
                category: data['category'] ?? 'other',
                icon: data['icon'] ?? '🏠',
                amountCents: data['amountCents'] ?? 0,
                dueDay: data['dueDay'] ?? 1,
                payMode: data['payMode'] ?? 'auto',
                type: data['type'] ?? 'bill',
                active: data['active'] ?? true,
                createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              );
            }).toList());
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
}

