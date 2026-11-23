import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/features/expenses/domain/transaction.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_expense.dart';
import 'package:sipho/features/insights/domain/insight_text.dart';

/// Builds a fresh [SpendSnapshot] from the user's real profile, fixed base, and
/// current-month transactions.
SpendSnapshot buildCurrentSpendSnapshot({
  required WidgetRef ref,
  required BuildContext context,
  String focusTopic = 'general',
}) {
  final monthKey = currentMonthKey();
  final finance = ref.read(userFinanceProvider).valueOrNull;
  final summary = ref.read(monthSummaryProvider(monthKey)).valueOrNull;
  final transactions =
      ref.read(transactionsForMonthProvider(monthKey)).valueOrNull ??
          const <SiphoTransaction>[];
  final fixed = ref.read(activeFixedExpensesProvider).valueOrNull ??
      const <FixedExpense>[];

  final categories = <String, int>{};
  for (final tx in transactions) {
    final cents = tx.spendMainCents;
    if (cents > 0) {
      categories[tx.category] = (categories[tx.category] ?? 0) + cents;
    }
  }

  final fixedCents = fixed
      .where((item) => item.type != 'envelope')
      .fold<int>(0, (total, item) => total + item.amountCents);
  final incomeCents = finance?.monthlyIncomeCents ?? 0;
  final spentCents =
      categories.values.fold<int>(0, (a, b) => a + b);

  return SpendSnapshot(
    locale: Localizations.localeOf(context).languageCode,
    currency: finance?.currency ?? 'CAD',
    countryCode: finance?.countryCode ?? '',
    monthKey: monthKey,
    categoryCents: categories,
    incomeCents: incomeCents,
    fixedCents: fixedCents,
    remainingCents: summary != null && summary.hasIncome
        ? summary.remainingCents
        : (incomeCents > 0 ? incomeCents - fixedCents - spentCents : null),
    goal: finance?.goal ?? '',
    focusTopic: focusTopic,
    completedLessonIds: finance?.completedLessonIds ?? const [],
  );
}
