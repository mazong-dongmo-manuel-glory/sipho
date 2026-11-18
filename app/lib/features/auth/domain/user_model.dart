class SiphoUser {
  const SiphoUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    this.currency = 'CAD',
    this.countryCode = 'CA',
    this.locale = 'en',
    this.streakDays = 0,
    this.seeds = 0,
    this.level = 1,
    this.totalXp = 0,
    this.createdAt,
    this.lastActiveAt,
  });

  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String currency;
  final String countryCode;
  final String locale;
  final int streakDays;
  final int seeds;
  final int level;
  final int totalXp;
  final DateTime? createdAt;
  final DateTime? lastActiveAt;

  factory SiphoUser.fromJson(Map<String, dynamic> json) => SiphoUser(
        uid: json['uid'] as String? ?? '',
        email: json['email'] as String? ?? '',
        displayName: json['displayName'] as String? ?? '',
        photoUrl: json['photoUrl'] as String? ?? '',
        currency: json['currency'] as String? ?? 'CAD',
        countryCode: json['countryCode'] as String? ?? 'CA',
        locale: json['locale'] as String? ?? 'en',
        streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
        seeds: (json['seeds'] as num?)?.toInt() ?? 0,
        level: (json['level'] as num?)?.toInt() ?? 1,
        totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'currency': currency,
        'countryCode': countryCode,
        'locale': locale,
        'streakDays': streakDays,
        'seeds': seeds,
        'level': level,
        'totalXp': totalXp,
      };
}
