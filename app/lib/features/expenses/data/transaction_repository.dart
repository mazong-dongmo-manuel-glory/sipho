import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/features/expenses/domain/transaction.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(firestoreProvider));
});

class TransactionRepository {
  final FirebaseFirestore _firestore;

  TransactionRepository(this._firestore);

  Stream<List<SiphoTransaction>> watchMonthTransactions(
      String uid, String yearMonth) {
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
                amountCents: (data['amountCents'] as num?)?.toInt() ?? 0,
                currency: data['currency'] as String? ?? 'CAD',
                amountMainCents: (data['amountMainCents'] as num?)?.toInt(),
                fxRate: (data['fxRate'] as num?)?.toDouble(),
                category: data['category'] as String? ?? 'other',
                merchant: data['merchant'] as String?,
                note: data['note'] as String?,
                feeCents: (data['feeCents'] as num?)?.toInt(),
                date: data['date'] as String? ?? '',
                source: data['source'] as String? ?? 'manual',
                receiptPath: data['receiptPath'] as String?,
                fixedExpenseId: data['fixedExpenseId'] as String?,
                createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
              );
            }).toList());
  }

  Future<void> addTransaction(String uid, SiphoTransaction tx) async {
    final data = <String, dynamic>{
      'amountCents': tx.amountCents,
      'currency': tx.currency,
      'amountMainCents': tx.amountMainCents ?? tx.amountCents,
      'category': tx.category,
      'date': tx.date,
      'source': tx.source,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (tx.fxRate != null) data['fxRate'] = tx.fxRate;
    if (tx.merchant != null) data['merchant'] = tx.merchant;
    if (tx.note != null) data['note'] = tx.note;
    if (tx.feeCents != null && tx.feeCents! > 0) data['feeCents'] = tx.feeCents;
    if (tx.receiptPath != null) data['receiptPath'] = tx.receiptPath;
    if (tx.fixedExpenseId != null) data['fixedExpenseId'] = tx.fixedExpenseId;
    await _firestore.collection('users/$uid/transactions').add(data);
  }

  Future<void> deleteTransaction(String uid, String id) async {
    await _firestore.collection('users/$uid/transactions').doc(id).delete();
  }

  Future<void> updateTransaction(String uid, SiphoTransaction tx) async {
    final merchant = tx.merchant?.trim() ?? '';
    final note = tx.note?.trim() ?? '';
    final data = <String, dynamic>{
      'amountCents': tx.amountCents,
      'currency': tx.currency,
      'amountMainCents': tx.amountMainCents ?? tx.amountCents,
      'category': tx.category,
      'date': tx.date,
      'source': tx.source == 'receipt' ? 'receipt' : 'manual',
      'merchant': merchant.isEmpty ? FieldValue.delete() : merchant,
      'note': note.isEmpty ? FieldValue.delete() : note,
      'feeCents': tx.feeCents == null || tx.feeCents! <= 0
          ? FieldValue.delete()
          : tx.feeCents,
      'fxRate': tx.fxRate ?? FieldValue.delete(),
    };
    await _firestore
        .collection('users/$uid/transactions')
        .doc(tx.id)
        .update(data);
  }
}
