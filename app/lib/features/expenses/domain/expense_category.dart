class ExpenseCategory {
  const ExpenseCategory({required this.id, required this.emoji});

  final String id;
  final String emoji;
}

/// Quick-add categories shown on the express keypad.
const List<ExpenseCategory> kQuickExpenseCategories = [
  ExpenseCategory(id: 'rent', emoji: '🏠'),
  ExpenseCategory(id: 'internet', emoji: '📶'),
  ExpenseCategory(id: 'energy', emoji: '💡'),
  ExpenseCategory(id: 'phone', emoji: '📱'),
  ExpenseCategory(id: 'groceries', emoji: '🛒'),
  ExpenseCategory(id: 'transport', emoji: '🚌'),
  ExpenseCategory(id: 'restaurants', emoji: '🍔'),
  ExpenseCategory(id: 'shopping', emoji: '🛍'),
];
