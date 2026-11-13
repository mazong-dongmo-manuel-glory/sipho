import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/features/expenses/domain/transaction.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(FirebaseFirestore.instance);
});

class TransactionRepository {
  final FirebaseFirestore _firestore;

  TransactionRepository(this._firestore);

  Stream<List<SiphoTransaction>> watchMonthTransactions(String uid, String yearMonth) {
    return _firestore
        .collection('users/$uid/transactions')
        .where('date', isGreaterThanOrEqualTo: '$yearMonth-01')
        .where('date', isLessThanOrEqualTo: '$yearMonth-31')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              return SiphoTransaction(
                id: d.id,
                amountCents: data['amountCents'] ?? 0,
                currency: data['currency'] ?? 'CAD',
                amountMainCents: data['amountMainCents'],
                fxRate: (data['fxRate'] as num?)?.toDouble(),
                category: data['category'] ?? 'other',
                merchant: data['merchant'],
                note: data['note'],
                date: data['date'] ?? '',
                source: data['source'] ?? 'manual',
                receiptPath: data['receiptPath'],
                fixedExpenseId: data['fixedExpenseId'],
                createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              );
            }).toList());
  }

  Future<void> addTransaction(String uid, SiphoTransaction tx) async {
    await _firestore.collection('users/$uid/transactions').add({
      'amountCents': tx.amountCents,
      'currency': tx.currency,
      'amountMainCents': tx.amountMainCents ?? tx.amountCents,
      'category': tx.category,
      'merchant': tx.merchant,
      'note': tx.note,
      'date': tx.date,
      'source': tx.source,
      'receiptPath': tx.receiptPath,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

