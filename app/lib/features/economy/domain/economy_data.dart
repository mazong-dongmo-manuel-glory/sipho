class IndicatorItem {
  const IndicatorItem({
    required this.value,
    required this.unit,
    required this.source,
    required this.date,
  });

  final double value;
  final String unit;
  final String source;
  final String date;

  factory IndicatorItem.fromJson(Map<String, dynamic> json) => IndicatorItem(
        value: (json['value'] as num?)?.toDouble() ?? 0,
        unit: json['unit'] as String? ?? '',
        source: json['source'] as String? ?? '',
        date: json['date'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'value': value,
        'unit': unit,
        'source': source,
        'date': date,
      };
}

class EconomyData {
  const EconomyData({
    required this.countryCode,
    required this.indicators,
    this.summary,
    this.updatedAt,
  });

  final String countryCode;
  final Map<String, IndicatorItem> indicators;
  final Map<String, String>? summary;
  final DateTime? updatedAt;

  factory EconomyData.fromJson(Map<String, dynamic> json) {
    final raw = json['indicators'];
    final indicators = <String, IndicatorItem>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is Map) {
          indicators[key.toString()] =
              IndicatorItem.fromJson(Map<String, dynamic>.from(value));
        }
      });
    }
    return EconomyData(
      countryCode: json['countryCode'] as String? ?? '',
      indicators: indicators,
      summary: json['summary'] is Map
          ? {
              for (final e in (json['summary'] as Map).entries)
                e.key.toString(): '${e.value}',
            }
          : null,
      updatedAt: json['updatedAt'] is DateTime
          ? json['updatedAt'] as DateTime
          : DateTime.tryParse('${json['updatedAt']}'),
    );
  }

  Map<String, dynamic> toJson() => {
        'countryCode': countryCode,
        'indicators': {
          for (final e in indicators.entries) e.key: e.value.toJson(),
        },
        'summary': summary,
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
