import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';

const _kDeviceIdKey = 'sipho_fcm_device_id';

/// Enregistre le jeton FCM dans `users/{uid}/devices/{deviceId}`.
class DeviceRegistration {
  DeviceRegistration(this._ref);

  final Ref _ref;
  StreamSubscription<String>? _tokenSub;
  bool _listeningAuth = false;

  Future<String> _deviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_kDeviceIdKey);
    if (id == null || id.isEmpty) {
      id = 'd_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';
      await prefs.setString(_kDeviceIdKey, id);
    }
    return id.length > 80 ? id.substring(0, 80) : id;
  }

  String get _platform {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'other';
  }

  /// Demande la permission système puis écrit le token si accordée.
  Future<bool> requestAndRegister() async {
    final messaging = _ref.read(firebaseMessagingProvider);
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final authorized =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!authorized) return false;
    return registerCurrentToken();
  }

  Future<bool> registerCurrentToken() async {
    final uid = _ref.read(authUidProvider);
    if (uid == null) return false;
    final messaging = _ref.read(firebaseMessagingProvider);
    String? token;
    try {
      token = await messaging.getToken();
    } catch (e) {
      debugPrint('[FCM] getToken failed: $e');
      return false;
    }
    if (token == null || token.length <= 10) return false;

    final deviceId = await _deviceId();
    await _ref
        .read(firestoreProvider)
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(deviceId)
        .set({
      'fcmToken': token,
      'platform': _platform,
      'active': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return true;
  }

  /// À appeler une fois au démarrage de l’app (après auth).
  void ensureListening() {
    if (!_listeningAuth) {
      _listeningAuth = true;
      _ref.listen<String?>(authUidProvider, (prev, uid) {
        if (uid == null) return;
        unawaited(registerCurrentToken());
      }, fireImmediately: true);
    }
    _tokenSub ??=
        _ref.read(firebaseMessagingProvider).onTokenRefresh.listen((_) {
      unawaited(registerCurrentToken());
    });
  }
}

final deviceRegistrationProvider = Provider<DeviceRegistration>((ref) {
  final service = DeviceRegistration(ref);
  ref.onDispose(() {
    service._tokenSub?.cancel();
  });
  return service;
});
