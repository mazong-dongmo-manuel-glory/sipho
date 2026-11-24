import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_profile.dart';
import 'auth_repository.dart';
import 'user_repository.dart';

/// Profil utilisateur : miroir local + sync Firestore quand authentifié.
class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier(this._ref) : super(const UserProfile(onboardingDone: false)) {
    _bind();
  }

  final Ref _ref;
  StreamSubscription? _sub;

  void _bind() {
    _ref.listen<String?>(authUidProvider, (prev, uid) {
      _sub?.cancel();
      if (uid == null) {
        state = const UserProfile(onboardingDone: false);
        return;
      }
      _sub = _ref.read(userRepositoryProvider).watchProfile(uid).listen((profile) {
        if (profile != null) state = profile;
      });
    }, fireImmediately: true);
  }

  void updateProfile({
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
  }) {
    state = state.copyWith(
      displayName: displayName,
      countryCode: countryCode,
      currency: currency,
      locale: locale,
      timezone: timezone,
      utcOffsetMinutes: utcOffsetMinutes,
      mainGoal: mainGoal,
      lifeStage: lifeStage,
      monthlyIncomeCents: monthlyIncomeCents,
      onboardingDone: onboardingDone,
    );
  }

  Future<void> persistCreate() async {
    final uid = _ref.read(authUidProvider);
    if (uid == null) return;
    final existing = await _ref.read(userRepositoryProvider).getProfile(uid);
    if (existing == null) {
      await _ref.read(userRepositoryProvider).createProfile(uid, state);
    } else {
      await _ref.read(userRepositoryProvider).updateProfile(uid, {
        ...state.toFirestoreCreate(),
      });
    }
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingDone: true);
    final uid = _ref.read(authUidProvider);
    if (uid == null) return;
    await _ref.read(userRepositoryProvider).completeOnboarding(uid, state);
  }

  /// Persiste le revenu mensuel (cents) vers Firestore.
  Future<void> saveMonthlyIncome(int monthlyIncomeCents) async {
    state = state.copyWith(monthlyIncomeCents: monthlyIncomeCents);
    final uid = _ref.read(authUidProvider);
    if (uid == null) return;
    await _ref.read(userRepositoryProvider).updateProfile(uid, {
      'monthlyIncomeCents': monthlyIncomeCents,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> saveTravelMode({
    required bool enabled,
    required String currency,
  }) async {
    state = state.copyWith(
      travelModeEnabled: enabled,
      travelCurrency: currency,
    );
    final uid = _ref.read(authUidProvider);
    if (uid == null) return;
    await _ref.read(userRepositoryProvider).updateProfile(uid, {
      'travelModeEnabled': enabled,
      'travelCurrency': currency,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier(ref);
});
