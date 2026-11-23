import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/core/time/device_timezone.dart';
import 'package:sipho/features/auth/domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  ),
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

  /// Uses the iOS OAuth client from the active Firebase options (sipho-staging
  /// when launched via `main_staging.dart` / `main_dev.dart`).
  GoogleSignIn _googleSignIn() {
    final iosClientId = Firebase.app().options.iosClientId;
    final useIosClient = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS) &&
        iosClientId != null &&
        iosClientId.isNotEmpty;
    return GoogleSignIn(clientId: useIosClient ? iosClientId : null);
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn().signIn();
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
    final onApplePlatform = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);

    try {
      final UserCredential result;
      String? displayName;

      if (onApplePlatform) {
        // Native Sign in with Apple + nonce (reliable on simulator / first-run
        // name capture). Do not pass authorizationCode as accessToken.
        final rawNonce = _generateNonce();
        final nonce = _sha256ofString(rawNonce);
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: nonce,
        );
        final idToken = appleCredential.identityToken;
        if (idToken == null || idToken.isEmpty) {
          throw StateError('Apple Sign-In returned no identity token.');
        }
        final oauthCredential = OAuthProvider('apple.com').credential(
          idToken: idToken,
          rawNonce: rawNonce,
        );
        result = await _auth.signInWithCredential(oauthCredential);
        final appleName = [
          appleCredential.givenName,
          appleCredential.familyName,
        ]
            .whereType<String>()
            .map((p) => p.trim())
            .where((p) => p.isNotEmpty);
        displayName = appleName.isEmpty ? null : appleName.join(' ');
      } else {
        // Android: Firebase OAuth via Custom Tabs. Needs OAuth code flow in
        // Firebase Auth (Services ID kAppleServicesId — see ENVIRONMENTS.md).
        // Native SignInWithApple without web options crashes on Android.
        final appleProvider = AppleAuthProvider()
          ..addScope('email')
          ..addScope('name');
        result = await _auth.signInWithProvider(appleProvider);
        displayName = _displayNameFromAppleProfile(
          result.additionalUserInfo?.profile,
        );
      }

      if (result.user != null) {
        try {
          if (displayName != null &&
              (result.user!.displayName == null ||
                  result.user!.displayName!.trim().isEmpty)) {
            await result.user!.updateDisplayName(displayName);
          }
          await ensureProfile(result.user!, displayName: displayName);
        } catch (e) {
          // Auth already succeeded — don't bounce the user back to login.
          debugPrint('Apple Sign-In profile sync failed: $e');
        }
      }
      return result;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return null;
      }
      debugPrint('Apple Sign-In Authorization error: $e');
      rethrow;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled' ||
          e.code == 'web-context-cancelled' ||
          e.code == 'ERROR_ABORTED_BY_USER') {
        return null;
      }
      debugPrint('Apple Sign-In Firebase error: $e');
      rethrow;
    } catch (e) {
      debugPrint('Apple Sign-In error: $e');
      rethrow;
    }
  }

  /// Best-effort name from Apple OAuth profile (Android / web provider flow).
  static String? _displayNameFromAppleProfile(Map<String, dynamic>? profile) {
    if (profile == null || profile.isEmpty) return null;
    final name = profile['name'];
    if (name is String && name.trim().isNotEmpty) return name.trim();
    if (name is Map) {
      final given = name['firstName'] ?? name['givenName'] ?? name['first_name'];
      final family =
          name['lastName'] ?? name['familyName'] ?? name['last_name'];
      final parts = [given, family]
          .whereType<String>()
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();
      if (parts.isNotEmpty) return parts.join(' ');
    }
    final given = profile['given_name'] ?? profile['first_name'];
    final family = profile['family_name'] ?? profile['last_name'];
    final parts = [given, family]
        .whereType<String>()
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.isEmpty ? null : parts.join(' ');
  }

  /// Cryptographically random nonce for Sign in with Apple → Firebase.
  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signOut() async {
    try {
      final google = _googleSignIn();
      if (await google.isSignedIn()) {
        await google.signOut();
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
    // Keep profile locale aligned with the device UI language (FR/EN only).
    if (data['locale'] != language) updates['locale'] = language;
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

  /// Saves the answers from the onboarding questions.
  /// Completion is a separate write, so the nest screens stay reachable.
  Future<void> saveOnboardingProfile({
    required String displayName,
    required String countryCode,
    required String currency,
    required String region,
    required String goal,
    required String lifeStage,
    int monthlyIncomeCents = 0,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Not signed in');
    }
    await ensureProfile(user, displayName: displayName);
    final deviceLocale = PlatformDispatcher.instance.locale;
    final language =
        deviceLocale.languageCode.toLowerCase().startsWith('fr') ? 'fr' : 'en';
    final income = monthlyIncomeCents < 0 ? 0 : monthlyIncomeCents;
    await _firestore.collection('users').doc(user.uid).update({
      'displayName': displayName,
      'countryCode': countryCode,
      'currency': currency,
      'region': region,
      'goal': goal,
      'lifeStage': lifeStage,
      'monthlyIncomeCents': income,
      'locale': language,
    });
  }

  Future<void> finishOnboarding() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Not signed in');
    }
    await ensureProfile(user);
    // Client must NOT write `users/{uid}/game/state` (rules: write false).
    // Setting onboardingDone triggers the server badge sync (onUserOnboardingDone).
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
