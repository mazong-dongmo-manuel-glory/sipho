import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';

class NotifPrefs {
  final bool streak;
  final bool budget;
  final bool tips;
  final bool fixedDue;
  final bool economy;
  final bool social;
  final int preferredHour;

  const NotifPrefs({
    this.streak = true,
    this.budget = true,
    this.tips = true,
    this.fixedDue = true,
    this.economy = false,
    this.social = true,
    this.preferredHour = 19,
  });

  NotifPrefs copyWith({
    bool? streak,
    bool? budget,
    bool? tips,
    bool? fixedDue,
    bool? economy,
    bool? social,
    int? preferredHour,
  }) {
    return NotifPrefs(
      streak: streak ?? this.streak,
      budget: budget ?? this.budget,
      tips: tips ?? this.tips,
      fixedDue: fixedDue ?? this.fixedDue,
      economy: economy ?? this.economy,
      social: social ?? this.social,
      preferredHour: preferredHour ?? this.preferredHour,
    );
  }

  Map<String, dynamic> toPrefsMap() => {
        'streak_reminder': streak,
        'budget_alert': budget,
        'fixed_due': fixedDue,
        'tips': tips,
        'economy': economy,
        'social': social,
      };
}

class NotifPrefsNotifier extends StateNotifier<NotifPrefs> {
  NotifPrefsNotifier(this._ref) : super(const NotifPrefs()) {
    _bind();
  }

  final Ref _ref;
  StreamSubscription? _sub;

  void _bind() {
    _ref.listen<String?>(authUidProvider, (_, uid) {
      _sub?.cancel();
      if (uid == null) {
        state = const NotifPrefs();
        return;
      }
      _sub = _ref
          .read(firestoreProvider)
          .collection('users')
          .doc(uid)
          .collection('notifState')
          .doc('state')
          .snapshots()
          .listen((snap) {
        final data = snap.data();
        if (data == null) return;
        final prefs = data['prefs'];
        final map = prefs is Map ? prefs : const {};
        state = NotifPrefs(
          streak: map['streak_reminder'] != false,
          budget: map['budget_alert'] != false,
          tips: map['tips'] != false,
          fixedDue: map['fixed_due'] != false,
          economy: map['economy'] == true,
          social: map['social'] != false,
          preferredHour: (data['preferredHour'] as num?)?.toInt() ?? 19,
        );
      }, onError: (_) {});
    }, fireImmediately: true);
  }

  Future<void> setFlag(String key, bool value) async {
    final uid = _ref.read(authUidProvider);
    if (uid == null) return;
    final next = switch (key) {
      'streak' => state.copyWith(streak: value),
      'budget' => state.copyWith(budget: value),
      'tips' => state.copyWith(tips: value),
      'fixedDue' => state.copyWith(fixedDue: value),
      'economy' => state.copyWith(economy: value),
      'social' => state.copyWith(social: value),
      _ => state,
    };
    state = next;
    await _ref
        .read(firestoreProvider)
        .collection('users')
        .doc(uid)
        .collection('notifState')
        .doc('state')
        .set({'prefs': next.toPrefsMap()}, SetOptions(merge: true));
  }

  Future<void> setHour(int hour) async {
    final uid = _ref.read(authUidProvider);
    if (uid == null) return;
    state = state.copyWith(preferredHour: hour.clamp(0, 23));
    await _ref
        .read(firestoreProvider)
        .collection('users')
        .doc(uid)
        .collection('notifState')
        .doc('state')
        .set({'preferredHour': state.preferredHour}, SetOptions(merge: true));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final notifPrefsProvider =
    StateNotifierProvider<NotifPrefsNotifier, NotifPrefs>((ref) {
  return NotifPrefsNotifier(ref);
});
