import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/core/time/device_timezone.dart';
import 'package:sipho/features/auth/domain/user_model.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) => AuthRepository(
      firebaseAuth: ref.watch(firebaseAuthProvider),
      firestore: ref.watch(firestoreProvider),
    );

class AuthRepository {
  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _auth = firebaseAuth,
        _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User aborted the Google Sign-in flow
        return null;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      if (result.user != null) {
        await ensureProfile(result.user!);
      }
      return result;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)) {
        // Native Apple sign-in via Firebase on Apple devices
        final appleProvider = AppleAuthProvider();
        appleProvider.addScope('email');
        appleProvider.addScope('name');
        final result = await _auth.signInWithProvider(appleProvider);
        if (result.user != null) {
          await ensureProfile(result.user!);
        }
        return result;
      } else {
        // Fallback using sign_in_with_apple plugin
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        final OAuthCredential credential =
            OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        final result = await _auth.signInWithCredential(credential);
        final fullName = [
          appleCredential.givenName,
          appleCredential.familyName,
        ].whereType<String>().where((s) => s.isNotEmpty).join(' ');

        if (result.user != null) {
          await ensureProfile(result.user!, displayName: fullName);
        }
        return result;
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return null;
      }
      debugPrint('Apple Sign-In Authorization error: $e');
      rethrow;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled' || e.code == 'web-context-cancelled') {
        return null;
      }
      debugPrint('Apple Sign-In Firebase error: $e');
      rethrow;
    } catch (e) {
      debugPrint('Apple Sign-In error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      if (await GoogleSignIn().isSignedIn()) {
        await GoogleSignIn().signOut();
      }
    } catch (e) {
      debugPrint('Google Sign-Out non-critical error: $e');
    }
    await _auth.signOut();
  }

  Future<SiphoUser?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return SiphoUser.fromJson({...doc.data()!, 'uid': uid});
  }

  /// Writes the profile fields required by Firestore rules.
  Future<void> ensureProfile(User user, {String? displayName}) async {
    final doc = _firestore.collection('users').doc(user.uid);
    final existing = await doc.get();
    final name = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : (user.displayName ?? '');
    final deviceLocale = PlatformDispatcher.instance.locale;
    final language =
        deviceLocale.languageCode.toLowerCase().startsWith('fr') ? 'fr' : 'en';
    final region = deviceLocale.countryCode?.toUpperCase();
    final country = (region != null && region.length == 2) ? region : 'CA';
    final timezone = await readDeviceTimezone();

    if (!existing.exists) {
      await doc.set({
        'email': user.email ?? '',
        'displayName': name,
        'photoUrl': user.photoURL ?? '',
        'countryCode': country,
        'currency': 'CAD',
        'locale': language,
        // IANA id + offset in minutes (not whole hours): see device_timezone.dart.
        ...timezone.toCreateFields(),
        'onboardingDone': false,
        'monthlyIncomeCents': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    final updates = <String, dynamic>{
      'lastActiveAt': FieldValue.serverTimestamp(),
    };
    if (name.isNotEmpty &&
        (existing.data()?['displayName'] as String? ?? '').isEmpty) {
      updates['displayName'] = name;
    }
    final data = existing.data() ?? {};
    if (data['countryCode'] == null) updates['countryCode'] = country;
    if (data['currency'] == null) updates['currency'] = 'CAD';
    if (data['locale'] == null) updates['locale'] = language;
    // Refreshed on every launch so a daylight-saving change or a trip is picked up.
    updates.addAll(timezone.toProfileFields());
    if (data['timezone'] == null && timezone.id == null) {
      updates['timezone'] = kUnknownTimezone;
    }
    if (data['onboardingDone'] == null) updates['onboardingDone'] = false;
    await doc.update(updates);
  }

  Future<void> updateMonthlyIncome(int cents) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Not signed in');
    }
    await ensureProfile(user);
    await _firestore.collection('users').doc(user.uid).update({
      'monthlyIncomeCents': cents,
    });
  }

  /// Saves the answers from the three onboarding questions.
  /// Completion is a separate write, so the nest screens stay reachable.
  Future<void> saveOnboardingProfile({
    required String displayName,
    required String countryCode,
    required String currency,
    required String region,
    required String goal,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Not signed in');
    }
    await ensureProfile(user, displayName: displayName);
    final deviceLocale = PlatformDispatcher.instance.locale;
    final language =
        deviceLocale.languageCode.toLowerCase().startsWith('fr') ? 'fr' : 'en';
    await _firestore.collection('users').doc(user.uid).update({
      'displayName': displayName,
      'countryCode': countryCode,
      'currency': currency,
      'region': region,
      'goal': goal,
      'locale': language,
    });
  }

  Future<void> finishOnboarding() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Not signed in');
    }
    await ensureProfile(user);
    await _firestore.collection('users').doc(user.uid).update({
      'onboardingDone': true,
    });
  }

  /// Updates editable profile fields on `users/{uid}`.
  Future<void> updateProfile({
    required String displayName,
    required String countryCode,
    required String currency,
    required String region,
    required String goal,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Not signed in');
    }
    final cleanName = displayName.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError('displayName cannot be empty');
    }
    await ensureProfile(user, displayName: cleanName);
    await _firestore.collection('users').doc(user.uid).update({
      'displayName': cleanName,
      'countryCode': countryCode.trim().toUpperCase(),
      'currency': currency.trim().toUpperCase(),
      'region': region.trim(),
      'goal': goal.trim(),
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }
}
