import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/firebase_providers.dart';

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

PhoneLinkFailure phoneLinkFailureFromCode(String code) {
  return switch (code) {
    'invalid-phone-number' || 'missing-phone-number' =>
      PhoneLinkFailure.invalidNumber,
    'too-many-requests' || 'quota-exceeded' => PhoneLinkFailure.tooManyRequests,
    'invalid-verification-code' ||
    'invalid-verification-id' ||
    'session-expired' ||
    'code-expired' =>
      PhoneLinkFailure.invalidCode,
    'credential-already-in-use' ||
    'provider-already-linked' ||
    'account-exists-with-different-credential' =>
      PhoneLinkFailure.alreadyUsed,
    'network-request-failed' => PhoneLinkFailure.network,
    _ => PhoneLinkFailure.unknown,
  };
}

/// Adds a phone number, verified by SMS, to the signed-in account.
abstract class PhoneLinker {
  String? get linkedPhone;
  Future<bool> sendCode(String e164);
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
          PhoneLinkException(phoneLinkFailureFromCode(error.code)),
        );
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
