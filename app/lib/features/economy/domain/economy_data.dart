import 'package:freezed_annotation/freezed_annotation.dart';

part 'economy_data.freezed.dart';
part 'economy_data.g.dart';

@freezed
class IndicatorItem with _$IndicatorItem {
  const factory IndicatorItem({
    required double value,
    required String unit,
    required String source,
    required String date,
  }) = _IndicatorItem;

  factory IndicatorItem.fromJson(Map<String, dynamic> json) =>
      _$IndicatorItemFromJson(json);
}

@freezed
class EconomyData with _$EconomyData {
  const factory EconomyData({
    required String countryCode,
    required Map<String, IndicatorItem> indicators,
    Map<String, String>? summary,
    DateTime? updatedAt,
  }) = _EconomyData;

  factory EconomyData.fromJson(Map<String, dynamic> json) =>
      _$EconomyDataFromJson(json);
}
