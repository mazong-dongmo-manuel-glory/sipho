import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../../expenses/data/expenses_provider.dart';

class BudgetCategory {
  final String id;
  final String label;
  final int limitCents;
  final int spentCents;

  const BudgetCategory({
    required this.id,
    required this.label,
    required this.limitCents,
    required this.spentCents,
  });

  double get progress =>
      limitCents <= 0 ? 0 : (spentCents / limitCents).clamp(0.0, 1.5);
}

const kBudgetLabels = <String, String>{
  'restaurants': 'Restos',
  'groceries': 'Épicerie',
  'transport': 'Transport',
  'shopping': 'Shopping',
  'family': 'Famille',
  'phone': 'Téléphone',
  'internet': 'Internet',
  'energy': 'Énergie',
  'rent': 'Loyer',
};

class BudgetsNotifier extends StateNotifier<List<BudgetCategory>> {
  BudgetsNotifier(this._ref) : super(const []) {
    _bind();
  }

  final Ref _ref;
  StreamSubscription? _sub;
  Map<String, int> _limits = {};

  void _bind() {
    _ref.listen<String?>(authUidProvider, (_, uid) {
      _sub?.cancel();
      if (uid == null) {
        state = const [];
        return;
      }
      _sub = _ref
          .read(firestoreProvider)
          .collection('users')
          .doc(uid)
          .collection('budgets')
          .snapshots()
          .listen((snap) {
        _limits = {
          for (final d in snap.docs)
            d.id: (d.data()['limitCents'] as num?)?.toInt() ?? 0,
        };
        _recompute();
      }, onError: (_) {});
    }, fireImmediately: true);

    _ref.listen(expensesProvider, (_, __) => _recompute());
  }

  void _recompute() {
    final expenses = _ref.read(expensesProvider);
    final now = DateTime.now();
    final spent = <String, int>{};
    for (final e in expenses) {
      if (e.date.year != now.year || e.date.month != now.month) continue;
      final key = normalizeCategory(e.category);
      spent[key] = (spent[key] ?? 0) + e.amount.cents;
    }

    final keys = {..._limits.keys, ...spent.keys};
    state = keys.map((id) {
      return BudgetCategory(
        id: id,
        label: kBudgetLabels[id] ?? id,
        limitCents: _limits[id] ?? 0,
        spentCents: spent[id] ?? 0,
      );
    }).toList()
      ..sort((a, b) => b.progress.compareTo(a.progress));
  }

  Future<void> setLimit({required String categoryId, required int limitCents}) async {
    final uid = _ref.read(authUidProvider);
    if (uid == null || limitCents <= 0) return;
    await _ref
        .read(firestoreProvider)
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .doc(categoryId)
        .set({'limitCents': limitCents}, SetOptions(merge: true));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

String normalizeCategory(String raw) {
  final c = raw.toLowerCase();
  if (c.contains('resto')) return 'restaurants';
  if (c.contains('épicerie') || c.contains('epicerie') || c.contains('grocer')) {
    return 'groceries';
  }
  if (c.contains('transport')) return 'transport';
  if (c.contains('shop') || c.contains('shopping')) return 'shopping';
  if (c.contains('famille') || c.contains('soutien') || c.contains('family')) {
    return 'family';
  }
  if (c.contains('phone') || c.contains('téléphone') || c.contains('telephone')) {
    return 'phone';
  }
  if (c.contains('internet')) return 'internet';
  if (c.contains('électri') || c.contains('electri') || c.contains('energy')) {
    return 'energy';
  }
  if (c.contains('loyer') || c.contains('rent')) return 'rent';
  // Already an id?
  if (kBudgetLabels.containsKey(raw)) return raw;
  return raw.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();
}

final budgetsProvider =
    StateNotifierProvider<BudgetsNotifier, List<BudgetCategory>>((ref) {
  return BudgetsNotifier(ref);
});
