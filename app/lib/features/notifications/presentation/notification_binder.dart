import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/notifications/data/notification_service.dart';
import 'package:sipho/features/notifications/domain/notif_prefs.dart';

class NotificationBinder extends ConsumerStatefulWidget {
  const NotificationBinder({super.key});

  @override
  ConsumerState<NotificationBinder> createState() => _NotificationBinderState();
}

class _NotificationBinderState extends ConsumerState<NotificationBinder> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_attach);
  }

  Future<void> _attach() async {
    final service = ref.read(notificationServiceProvider);
    service.onRoute = (route) {
      ref.read(pendingNotificationRouteProvider.notifier).state = route;
    };
    try {
      await service.attach();
    } catch (error) {
      debugPrint('Notifications unavailable: $error');
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

final notifPrefsProvider = StreamProvider<NotifPrefs>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(NotifPrefs.defaults);
  return FirebaseFirestore.instance.doc('users/$uid').snapshots().map((doc) {
    final raw = doc.data()?['notifPrefs'];
    if (raw is Map) return NotifPrefs.fromMap(raw);
    return NotifPrefs.defaults;
  });
});
