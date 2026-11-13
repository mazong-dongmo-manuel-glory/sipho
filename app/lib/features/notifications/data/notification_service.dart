import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sipho/features/notifications/domain/notif_prefs.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

const dailyReminderId = 42;
const _devicePrefsKey = 'sipho_device_id';

final pendingNotificationRouteProvider = StateProvider<String?>((ref) => null);

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    FirebaseMessaging.instance,
    FlutterLocalNotificationsPlugin(),
    FirebaseFirestore.instance,
  );
});

void _onLocalNotification(NotificationResponse response) {
  final route = response.payload;
  if (route != null && route.startsWith('/')) {
    notificationRouteHandler?.call(route);
  }
}

void Function(String route)? notificationRouteHandler;

class NotificationService {
  NotificationService(this._fcm, this._local, this._firestore);

  final FirebaseMessaging _fcm;
  final FlutterLocalNotificationsPlugin _local;
  final FirebaseFirestore _firestore;

  bool _ready = false;
  bool _listening = false;
  String? _uid;
  void Function(String route)? onRoute;

  Future<void> attach() async {
    notificationRouteHandler = onRoute;
    await _ensureLocal();
    if (_listening) return;
    _listening = true;
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen(_showForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_openMessage);
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _openMessage(initial);
    _fcm.onTokenRefresh.listen((token) {
      final uid = _uid;
      if (uid != null && token.isNotEmpty) {
        _saveDevice(uid);
      }
    });
  }

  /// Asks the system for permission, stores the token, and schedules 19:00.
  Future<bool> enable({
    required String uid,
    required NotifPrefs prefs,
    required String dailyTitle,
    required String dailyBody,
  }) async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
    await _ensureLocal();
    if (!granted) return false;
    _uid = uid;
    await _saveDevice(uid);
    await savePrefs(
      uid: uid,
      prefs: prefs,
      dailyTitle: dailyTitle,
      dailyBody: dailyBody,
    );
    return true;
  }

  Future<void> savePrefs({
    required String uid,
    required NotifPrefs prefs,
    required String dailyTitle,
    required String dailyBody,
  }) async {
    await _firestore.doc('users/$uid').update({
      'notifPrefs': prefs.toMap(),
      'timezoneOffset': DateTime.now().timeZoneOffset.inHours,
    });
    _uid = uid;
    if (prefs.streakReminder) {
      await scheduleDaily(title: dailyTitle, body: dailyBody);
    } else {
      await _local.cancel(dailyReminderId);
    }
  }

  Future<void> scheduleDaily({
    required String title,
    required String body,
  }) async {
    await _ensureLocal();
    tzdata.initializeTimeZones();
    final when = _nextEveningUtc();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'streak',
        'Streak',
        importance: Importance.defaultImportance,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _local.zonedSchedule(
      dailyReminderId,
      title,
      body,
      when,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '/home',
    );
  }

  Future<void> _ensureLocal() async {
    if (_ready) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onLocalNotification,
    );
    _ready = true;
  }

  Future<void> _showForeground(RemoteMessage message) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final notification = message.notification;
    if (notification == null) return;
    await _ensureLocal();
    await _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tips',
          'Tips',
          importance: Importance.defaultImportance,
        ),
      ),
      payload: message.data['route'] is String
          ? message.data['route'] as String
          : null,
    );
  }

  void _openMessage(RemoteMessage message) {
    final route = message.data['route'];
    if (route is String && route.startsWith('/')) {
      onRoute?.call(route);
    }
  }

  Future<void> _saveDevice(String uid) async {
    String? token;
    try {
      token = await _fcm.getToken();
    } catch (error) {
      debugPrint('FCM token unavailable: $error');
    }
    if (token == null || token.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString(_devicePrefsKey) ??
        DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    await prefs.setString(_devicePrefsKey, deviceId);
    await _firestore.doc('users/$uid/devices/$deviceId').set({
      'fcmToken': token,
      'active': true,
      'platform': defaultTargetPlatform.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

/// Next 19:00 local, expressed in UTC so the plugin can schedule it.
tz.TZDateTime _nextEveningUtc() {
  final now = DateTime.now();
  var evening = DateTime(now.year, now.month, now.day, 19);
  if (!evening.isAfter(now)) {
    evening = evening.add(const Duration(days: 1));
  }
  final utc = evening.subtract(now.timeZoneOffset);
  return tz.TZDateTime.from(utc, tz.UTC);
}
