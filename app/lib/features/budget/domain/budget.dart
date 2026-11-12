import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

@freezed
class MonthBudget with _$MonthBudget {
  const factory MonthBudget({
    required String monthKey, // YYYY-MM
    required Map<String, int> categoryLimitsCents,
    @Default('50_30_20') String rule,
  }) = _MonthBudget;

  factory MonthBudget.fromJson(Map<String, dynamic> json) =>
      _$MonthBudgetFromJson(json);
}

