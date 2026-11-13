class UserFinance {
  const UserFinance({
    required this.uid,
    required this.displayName,
    required this.currency,
    required this.monthlyIncomeCents,
    this.countryCode = '',
    this.region = '',
    this.goal = '',
    this.completedLessonIds = const [],
    this.createdAt,
    this.onboardingDone = false,
  });

  final String uid;
  final String displayName;
  final String currency;
  final int monthlyIncomeCents;
  final String countryCode;
  final String region;
  final String goal;
  final List<String> completedLessonIds;
  final DateTime? createdAt;
  final bool onboardingDone;

  static const empty = UserFinance(
    uid: '',
    displayName: '',
    currency: 'CAD',
    monthlyIncomeCents: 0,
  );

  String get firstName {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }
}
