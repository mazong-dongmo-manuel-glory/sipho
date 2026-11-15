import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/core/time/local_day.dart';
import 'package:sipho/features/auth/data/auth_repository.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/expenses/data/transaction_repository.dart';
import 'package:sipho/features/expenses/domain/transaction.dart';
import 'package:sipho/features/finance/domain/month_summary.dart';
import 'package:sipho/features/finance/domain/user_finance.dart';
import 'package:sipho/features/fixed_expenses/data/fixed_expense_repository.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_expense.dart';

/// Creates the Firestore profile for a session that already exists.
final ensureUserProfileProvider = FutureProvider<void>((ref) async {
  final user = await ref.watch(authStateProvider.future);
  if (user == null) return;
  await ref.read(authRepositoryProvider).ensureProfile(user);
});

final userFinanceProvider = StreamProvider<UserFinance>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(UserFinance.empty);

  return ref.watch(firestoreProvider).doc('users/${user.uid}').snapshots().map(
    (doc) {
      final data = doc.data();
      final storedName = (data?['displayName'] as String?)?.trim() ?? '';
      final authName = user.displayName?.trim() ?? '';
      return UserFinance(
        uid: user.uid,
        displayName: storedName.isNotEmpty ? storedName : authName,
        currency: (data?['currency'] as String?)?.trim().isNotEmpty == true
            ? (data!['currency'] as String).trim()
            : 'CAD',
        monthlyIncomeCents: (data?['monthlyIncomeCents'] as num?)?.toInt() ?? 0,
        countryCode: (data?['countryCode'] as String?)?.trim() ?? '',
        region: (data?['region'] as String?)?.trim() ?? '',
        goal: (data?['goal'] as String?)?.trim() ?? '',
        completedLessonIds: (data?['completedLessonIds'] as List?)
                ?.map((id) => id.toString())
                .toList() ??
            const [],
        createdAt: (data?['createdAt'] as Timestamp?)?.toDate(),
        onboardingDone: data?['onboardingDone'] == true,
      );
    },
  );
});

/// Null while the profile is still loading. Only changes when the flag flips,
/// so the router is not recreated on every profile write.
final onboardingGateProvider = Provider<bool?>((ref) {
  final profile = ref.watch(userFinanceProvider);
  if (!profile.hasValue && !profile.hasError) return null;
  return profile.valueOrNull?.onboardingDone ?? false;
});

/// Month shown on the expenses screen. Home always uses the current month.
final expensesMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

final transactionsForMonthProvider =
    StreamProvider.family<List<SiphoTransaction>, String>((ref, monthKey) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const []);
  return ref
      .watch(transactionRepositoryProvider)
      .watchMonthTransactions(uid, monthKey);
});

final activeFixedExpensesProvider = StreamProvider<List<FixedExpense>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(fixedExpenseRepositoryProvider).watchFixedExpenses(uid);
});

/// Ids of the fixed expenses already paid in the given month (`yyyy-MM`).
final paidFixedIdsProvider =
    StreamProvider.family<Set<String>, String>((ref, monthKey) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const <String>{});
  return ref
      .watch(fixedExpenseRepositoryProvider)
      .watchPaidFixedIds(uid, monthKey);
});

/// Marks bills as paid and tracks the ones in flight (to disable their button).
class FixedPaidController extends Notifier<Set<String>> {
  @override
  Set<String> build() => const <String>{};

  /// Returns true on success. The paid state itself comes back through [paidFixedIdsProvider].
  Future<bool> markPaid(String fixedId) async {
    if (state.contains(fixedId)) return false;
    state = {...state, fixedId};
    try {
      await ref
          .read(fixedExpenseRepositoryProvider)
          .markPaid(fixedId, currentMonthKey());
      return true;
    } catch (_) {
      return false;
    } finally {
      state = {...state}..remove(fixedId);
    }
  }
}

final fixedPaidControllerProvider =
    NotifierProvider<FixedPaidController, Set<String>>(FixedPaidController.new);

final monthSummaryProvider =
    Provider.family<AsyncValue<MonthSummary>, String>((ref, monthKey) {
  final finance = ref.watch(userFinanceProvider);
  final transactions = ref.watch(transactionsForMonthProvider(monthKey));
  final fixed = ref.watch(activeFixedExpensesProvider);

  if (finance.isLoading || transactions.isLoading || fixed.isLoading) {
    return const AsyncValue.loading();
  }
  if (finance.hasError) {
    return AsyncValue.error(finance.error!, finance.stackTrace!);
  }
  if (transactions.hasError) {
    return AsyncValue.error(transactions.error!, transactions.stackTrace!);
  }
  if (fixed.hasError) {
    return AsyncValue.error(fixed.error!, fixed.stackTrace!);
  }

  final spent = transactions.value!.fold<int>(
    0,
    (total, tx) => total + (tx.amountMainCents ?? tx.amountCents),
  );
  final fixedCents = fixed.value!
      .fold<int>(0, (total, expense) => total + expense.amountCents);

  return AsyncValue.data(
    MonthSummary(
      incomeCents: finance.value!.monthlyIncomeCents,
      fixedCents: fixedCents,
      spentCents: spent,
    ),
  );
});

String currentMonthKey() => LocalDay.now().isoMonth;

String monthKeyOf(DateTime month) =>
    '${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}';
