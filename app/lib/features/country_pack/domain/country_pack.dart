class CountryPack {
  const CountryPack({
    required this.code,
    required this.name,
    required this.currency,
    required this.packLevel,
    this.version = 1,
    this.verifiedAt,
    this.regions = const {},
    this.savingsAccounts = const [],
    this.retirement = const {},
    this.regulatorNotice,
    this.defaultFixedExpenses = const [],
  });

  final String code;
  final String name;
  final String currency;
  final String packLevel; // full | partial | generic
  final int version;
  final String? verifiedAt;
  final Map<String, dynamic> regions;
  final List<Map<String, dynamic>> savingsAccounts;
  final Map<String, dynamic> retirement;
  final Map<String, String>? regulatorNotice;
  final List<String> defaultFixedExpenses;

  factory CountryPack.fromJson(Map<String, dynamic> json) => CountryPack(
        code: json['code'] as String? ?? '',
        name: json['name'] as String? ?? '',
        currency: json['currency'] as String? ?? 'CAD',
        packLevel: json['packLevel'] as String? ?? 'generic',
        version: (json['version'] as num?)?.toInt() ?? 1,
        verifiedAt: json['verifiedAt'] as String?,
        regions: json['regions'] is Map
            ? Map<String, dynamic>.from(json['regions'] as Map)
            : const {},
        savingsAccounts: (json['savingsAccounts'] as List?)
                ?.whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            const [],
        retirement: json['retirement'] is Map
            ? Map<String, dynamic>.from(json['retirement'] as Map)
            : const {},
        regulatorNotice: json['regulatorNotice'] is Map
            ? {
                for (final e in (json['regulatorNotice'] as Map).entries)
                  e.key.toString(): '${e.value}',
              }
            : null,
        defaultFixedExpenses:
            (json['defaultFixedExpenses'] as List?)?.map((e) => '$e').toList() ??
                const [],
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'currency': currency,
        'packLevel': packLevel,
        'version': version,
        'verifiedAt': verifiedAt,
        'regions': regions,
        'savingsAccounts': savingsAccounts,
        'retirement': retirement,
        'regulatorNotice': regulatorNotice,
        'defaultFixedExpenses': defaultFixedExpenses,
      };
}
