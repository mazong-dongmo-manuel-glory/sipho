class MonthBudget {
  const MonthBudget({
    required this.monthKey,
    required this.categoryLimitsCents,
    this.rule = '50_30_20',
  });

  final String monthKey; // YYYY-MM
  final Map<String, int> categoryLimitsCents;
  final String rule;

  factory MonthBudget.fromJson(Map<String, dynamic> json) {
    final raw = json['categoryLimitsCents'];
    final limits = <String, int>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is num) limits[key.toString()] = value.toInt();
      });
    }
    return MonthBudget(
      monthKey: json['monthKey'] as String? ?? '',
      categoryLimitsCents: limits,
      rule: json['rule'] as String? ?? '50_30_20',
    );
  }

  Map<String, dynamic> toJson() => {
        'monthKey': monthKey,
        'categoryLimitsCents': categoryLimitsCents,
        'rule': rule,
      };
}
