class UserProfile {
  final String displayName;
  final String countryCode;
  final String currency;
  final String mainGoal;
  final int monthlyIncomeCents;
  final bool onboardingDone;

  const UserProfile({
    this.displayName = 'Amina',
    this.countryCode = 'CA',
    this.currency = 'CAD',
    this.mainGoal = 'Arrêter d\'être à découvert',
    this.monthlyIncomeCents = 280000, // 2 800 $ CAD
    this.onboardingDone = true,
  });

  UserProfile copyWith({
    String? displayName,
    String? countryCode,
    String? currency,
    String? mainGoal,
    int? monthlyIncomeCents,
    bool? onboardingDone,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      countryCode: countryCode ?? this.countryCode,
      currency: currency ?? this.currency,
      mainGoal: mainGoal ?? this.mainGoal,
      monthlyIncomeCents: monthlyIncomeCents ?? this.monthlyIncomeCents,
      onboardingDone: onboardingDone ?? this.onboardingDone,
    );
  }
}
