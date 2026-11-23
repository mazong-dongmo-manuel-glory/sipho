import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_profile.dart';

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(const UserProfile());

  void updateProfile({
    String? displayName,
    String? countryCode,
    String? currency,
    String? mainGoal,
    int? monthlyIncomeCents,
  }) {
    state = state.copyWith(
      displayName: displayName,
      countryCode: countryCode,
      currency: currency,
      mainGoal: mainGoal,
      monthlyIncomeCents: monthlyIncomeCents,
    );
  }

  void completeOnboarding() {
    state = state.copyWith(onboardingDone: true);
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});
