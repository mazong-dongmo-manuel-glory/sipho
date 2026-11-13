import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
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
        await _upsertUser(result.user!);
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
          await _upsertUser(result.user!);
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

        final OAuthCredential credential = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        final result = await _auth.signInWithCredential(credential);
        final fullName = [
          appleCredential.givenName,
          appleCredential.familyName,
        ].whereType<String>().where((s) => s.isNotEmpty).join(' ');

        if (result.user != null) {
          await _upsertUser(result.user!, displayName: fullName);
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

  Future<void> _upsertUser(User user, {String? displayName}) async {
    final doc = _firestore.collection('users').doc(user.uid);
    final existing = await doc.get();
    final name = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : (user.displayName ?? '');

    if (!existing.exists) {
      await doc.set({
        'email': user.email ?? '',
        'displayName': name,
        'photoUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    } else {
      final updates = <String, dynamic>{
        'lastActiveAt': FieldValue.serverTimestamp(),
      };
      if (name.isNotEmpty &&
          (existing.data()?['displayName'] as String? ?? '').isEmpty) {
        updates['displayName'] = name;
      }
      await doc.update(updates);
    }
  }
}
