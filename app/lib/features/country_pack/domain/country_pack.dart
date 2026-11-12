import 'package:freezed_annotation/freezed_annotation.dart';

part 'country_pack.freezed.dart';
part 'country_pack.g.dart';

@freezed
class CountryPack with _$CountryPack {
  const factory CountryPack({
    required String code,
    required String name,
    required String currency,
    required String packLevel, // full | partial | generic
    @Default(1) int version,
    String? verifiedAt,
    @Default({}) Map<String, dynamic> regions,
    @Default([]) List<Map<String, dynamic>> savingsAccounts,
    @Default({}) Map<String, dynamic> retirement,
    Map<String, String>? regulatorNotice,
    @Default([]) List<String> defaultFixedExpenses,
  }) = _CountryPack;

  factory CountryPack.fromJson(Map<String, dynamic> json) =>
      _$CountryPackFromJson(json);
}

