import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/user_profile_provider.dart';
import '../../expenses/data/expenses_provider.dart';
import '../../fixed_expenses/data/fixed_expenses_provider.dart';

/// Provider calculant dynamiquement le Reste à vivre en centimes :
/// Reste à vivre = Revenu mensuel - Socle fixe - Dépenses variables
final remainingBudgetCentsProvider = Provider<int>((ref) {
  final user = ref.watch(userProfileProvider);
  final totalFixed = ref.watch(totalFixedExpensesCentsProvider);
  final totalVariable = ref.watch(totalVariableExpensesCentsProvider);

  return user.monthlyIncomeCents - totalFixed - totalVariable;
});
