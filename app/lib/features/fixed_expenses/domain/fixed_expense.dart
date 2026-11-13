import 'package:freezed_annotation/freezed_annotation.dart';

part 'fixed_expense.freezed.dart';
part 'fixed_expense.g.dart';

@freezed
class FixedExpense with _$FixedExpense {
  const factory FixedExpense({
    required String id,
    required String name,
    required String category,
    required String icon,
    required int amountCents,
    required int dueDay,
    @Default('auto') String payMode, // auto | manual
    @Default('bill') String type, // bill | envelope
    @Default(true) bool active,
    required DateTime createdAt,
  }) = _FixedExpense;

  factory FixedExpense.fromJson(Map<String, dynamic> json) =>
      _$FixedExpenseFromJson(json);
}
