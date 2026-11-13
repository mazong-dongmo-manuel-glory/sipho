class FixedExpenseDraft {
  const FixedExpenseDraft({
    required this.categoryId,
    required this.emoji,
    required this.type,
  });

  final String categoryId;
  final String emoji;

  /// `bill` or `envelope`.
  final String type;
}

const List<FixedExpenseDraft> kSocleTemplates = [
  FixedExpenseDraft(categoryId: 'rent', emoji: '🏠', type: 'bill'),
  FixedExpenseDraft(categoryId: 'internet', emoji: '📶', type: 'bill'),
  FixedExpenseDraft(categoryId: 'energy', emoji: '💡', type: 'bill'),
  FixedExpenseDraft(categoryId: 'phone', emoji: '📱', type: 'bill'),
  FixedExpenseDraft(categoryId: 'groceries', emoji: '🛒', type: 'envelope'),
  FixedExpenseDraft(categoryId: 'transport', emoji: '🚌', type: 'envelope'),
];
