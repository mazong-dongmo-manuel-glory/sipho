import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
class SiphoTransaction with _$SiphoTransaction {
  const factory SiphoTransaction({
    required String id,
    required int amountCents,
    required String currency,
    int? amountMainCents,
    double? fxRate,
    required String category,
    String? merchant,
    String? note,
    required String date, // ISO string YYYY-MM-DD
    @Default('manual') String source, // manual | receipt | bank
    String? receiptPath,
    String? fixedExpenseId,
    required DateTime createdAt,
  }) = _SiphoTransaction;

  factory SiphoTransaction.fromJson(Map<String, dynamic> json) =>
      _$SiphoTransactionFromJson(json);
}
