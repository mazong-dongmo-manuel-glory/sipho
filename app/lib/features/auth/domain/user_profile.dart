import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String displayName;
  final String countryCode;
  final String currency;
  final String locale;
  final String timezone;
  final int utcOffsetMinutes;
  final String mainGoal;
  final String lifeStage;
  final int monthlyIncomeCents;
  final bool onboardingDone;
  final bool travelModeEnabled;
  final String travelCurrency;
  final DateTime? createdAt;

  const UserProfile({
    this.displayName = 'Amina',
    this.countryCode = 'CA',
    this.currency = 'CAD',
    this.locale = 'fr',
    this.timezone = 'America/Toronto',
    this.utcOffsetMinutes = -300,
    this.mainGoal = 'Arrêter d\'être à découvert',
    this.lifeStage = 'Vie active',
    this.monthlyIncomeCents = 0,
    this.onboardingDone = false,
    this.travelModeEnabled = false,
    this.travelCurrency = '',
    this.createdAt,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      displayName: (data['displayName'] as String?)?.trim().isNotEmpty == true
          ? data['displayName'] as String
          : 'Amina',
      countryCode: (data['countryCode'] as String?) ?? 'CA',
      currency: (data['currency'] as String?) ?? 'CAD',
      locale: (data['locale'] as String?) ?? 'fr',
      timezone: (data['timezone'] as String?) ?? 'America/Toronto',
      utcOffsetMinutes: (data['utcOffsetMinutes'] as num?)?.toInt() ??
          DateTime.now().timeZoneOffset.inMinutes,
      mainGoal: (data['mainGoal'] as String?) ?? '',
      lifeStage: (data['lifeStage'] as String?) ?? '',
      monthlyIncomeCents: (data['monthlyIncomeCents'] as num?)?.toInt() ?? 0,
      onboardingDone: data['onboardingDone'] == true,
      travelModeEnabled: data['travelModeEnabled'] == true,
      travelCurrency: (data['travelCurrency'] as String?) ?? '',
      createdAt: _parseCreatedAt(data['createdAt']),
    );
  }

  static DateTime? _parseCreatedAt(dynamic raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    return null;
  }

  Map<String, dynamic> toFirestoreCreate() {
    return {
      'displayName': displayName,
      'countryCode': countryCode,
      'currency': currency,
      'locale': locale,
      'timezone': timezone,
      'utcOffsetMinutes': utcOffsetMinutes,
      'onboardingDone': onboardingDone,
      if (mainGoal.isNotEmpty) 'mainGoal': mainGoal,
      if (lifeStage.isNotEmpty) 'lifeStage': lifeStage,
      'monthlyIncomeCents': monthlyIncomeCents,
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? countryCode,
    String? currency,
    String? locale,
    String? timezone,
    int? utcOffsetMinutes,
    String? mainGoal,
    String? lifeStage,
    int? monthlyIncomeCents,
    bool? onboardingDone,
    bool? travelModeEnabled,
    String? travelCurrency,
    DateTime? createdAt,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      countryCode: countryCode ?? this.countryCode,
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
      timezone: timezone ?? this.timezone,
      utcOffsetMinutes: utcOffsetMinutes ?? this.utcOffsetMinutes,
      mainGoal: mainGoal ?? this.mainGoal,
      lifeStage: lifeStage ?? this.lifeStage,
      monthlyIncomeCents: monthlyIncomeCents ?? this.monthlyIncomeCents,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      travelModeEnabled: travelModeEnabled ?? this.travelModeEnabled,
      travelCurrency: travelCurrency ?? this.travelCurrency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Pays affichés → code ISO (règles Firestore).
String countryNameToCode(String name) => switch (name) {
      'Canada' => 'CA',
      'France' => 'FR',
      'Cameroun' => 'CM',
      'Côte d’Ivoire' || "Côte d'Ivoire" => 'CI',
      'Sénégal' => 'SN',
      'Belgique' => 'BE',
      _ => name.length == 2 ? name.toUpperCase() : 'CA',
    };

String timezoneForCountry(String code) => switch (code) {
      'CA' => 'America/Toronto',
      'FR' || 'BE' => 'Europe/Paris',
      'CM' => 'Africa/Douala',
      'CI' => 'Africa/Abidjan',
      'SN' => 'Africa/Dakar',
      _ => 'America/Toronto',
    };
