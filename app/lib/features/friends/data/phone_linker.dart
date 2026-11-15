import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';

/// Why verifying a phone number failed, in terms the UI can explain.
enum PhoneLinkFailure {
  invalidNumber,
  tooManyRequests,
  invalidCode,
  alreadyUsed,
  network,
  unknown,
}

class PhoneLinkException implements Exception {
  const PhoneLinkException(this.failure);

  final PhoneLinkFailure failure;

  @override
  String toString() => 'PhoneLinkException($failure)';
}

/// Maps a Firebase Auth error code to a [PhoneLinkFailure].
PhoneLinkFailure phoneLinkFailureFromCode(String code) {
  switch (code) {
    case 'invalid-phone-number':
    case 'missing-phone-number':
      return PhoneLinkFailure.invalidNumber;
    case 'too-many-requests':
    case 'quota-exceeded':
      return PhoneLinkFailure.tooManyRequests;
    case 'invalid-verification-code':
    case 'invalid-verification-id':
    case 'session-expired':
    case 'code-expired':
      return PhoneLinkFailure.invalidCode;
    case 'credential-already-in-use':
    case 'provider-already-linked':
    case 'account-exists-with-different-credential':
      return PhoneLinkFailure.alreadyUsed;
    case 'network-request-failed':
      return PhoneLinkFailure.network;
    default:
      return PhoneLinkFailure.unknown;
  }
}

/// Adds a phone number, verified by SMS, to the signed-in account. The number is what lets
/// contacts who only have it find this user (the server indexes verified numbers only).
abstract class PhoneLinker {
  /// The account's verified number in E.164, or `null`.
  String? get linkedPhone;

  /// Sends the SMS. Returns `true` when the number was verified without typing a code (Android
  /// can read the SMS itself) and is already linked; `false` when [confirm] must follow.
  Future<bool> sendCode(String e164);

  /// Verifies the code received by SMS and links the number to the account.
  Future<void> confirm(String smsCode);
}

final phoneLinkerProvider = Provider<PhoneLinker>(
  (ref) => FirebasePhoneLinker(ref.watch(firebaseAuthProvider)),
);

class FirebasePhoneLinker implements PhoneLinker {
  FirebasePhoneLinker(this._auth);

  final FirebaseAuth _auth;
  String? _verificationId;
  int? _resendToken;

  @override
  String? get linkedPhone {
    final phone = _auth.currentUser?.phoneNumber;
    return (phone == null || phone.isEmpty) ? null : phone;
  }

  @override
  Future<bool> sendCode(String e164) {
    final user = _auth.currentUser;
    if (user == null) {
      return Future.error(const PhoneLinkException(PhoneLinkFailure.unknown));
    }
    final done = Completer<bool>();

    void fail(Object error) {
      if (done.isCompleted) return;
      if (error is FirebaseAuthException) {
        debugPrint('[PhoneLink] failed: ${error.code}');
        done.completeError(
            PhoneLinkException(phoneLinkFailureFromCode(error.code)));
      } else {
        debugPrint('[PhoneLink] failed: $error');
        done.completeError(const PhoneLinkException(PhoneLinkFailure.unknown));
      }
    }

    _auth
        .verifyPhoneNumber(
          phoneNumber: e164,
          forceResendingToken: _resendToken,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (credential) async {
            try {
              await user.linkWithCredential(credential);
              await user.reload();
              if (!done.isCompleted) done.complete(true);
            } catch (error) {
              fail(error);
            }
          },
          verificationFailed: fail,
          codeSent: (id, token) {
            _verificationId = id;
            _resendToken = token;
            if (!done.isCompleted) done.complete(false);
          },
          codeAutoRetrievalTimeout: (id) => _verificationId ??= id,
        )
        .catchError(fail);

    return done.future;
  }

  @override
  Future<void> confirm(String smsCode) async {
    final user = _auth.currentUser;
    final id = _verificationId;
    if (user == null || id == null) {
      throw const PhoneLinkException(PhoneLinkFailure.unknown);
    }
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: id,
        smsCode: smsCode.trim(),
      );
      await user.linkWithCredential(credential);
      await user.reload();
    } on FirebaseAuthException catch (error) {
      debugPrint('[PhoneLink] confirm failed: ${error.code}');
      throw PhoneLinkException(phoneLinkFailureFromCode(error.code));
    }
  }
}
