import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/cloud_functions_service.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';

class InsightCard {
  final String id;
  final String title;
  final String body;
  final String actionStep;
  final String? recommendedLessonId;
  final bool dismissed;

  const InsightCard({
    required this.id,
    required this.title,
    required this.body,
    required this.actionStep,
    this.recommendedLessonId,
    this.dismissed = false,
  });
}

class InsightsNotifier extends StateNotifier<AsyncValue<InsightCard?>> {
  InsightsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _bind();
  }

  final Ref _ref;
  StreamSubscription? _sub;

  void _bind() {
    _ref.listen<String?>(authUidProvider, (_, uid) {
      _sub?.cancel();
      if (uid == null) {
        state = const AsyncValue.data(null);
        return;
      }
      _sub = _ref
          .read(firestoreProvider)
          .collection('users')
          .doc(uid)
          .collection('insights')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots()
          .listen((snap) {
        if (snap.docs.isEmpty) {
          state = const AsyncValue.data(null);
          return;
        }
        final d = snap.docs.first;
        final data = d.data();
        if (data['dismissed'] == true) {
          state = const AsyncValue.data(null);
          return;
        }
        state = AsyncValue.data(InsightCard(
          id: d.id,
          title: (data['title'] as String?) ??
              ((data['content'] as String?)?.split('.').first ?? 'Conseil Sipho'),
          body: (data['content'] as String?) ??
              (data['body'] as String?) ??
              '',
          actionStep: (data['actionStep'] as String?) ?? '',
          recommendedLessonId: data['recommendedLessonId'] as String?,
          dismissed: false,
        ));
      }, onError: (e, st) {
        state = AsyncValue.error(e, st);
      });
    }, fireImmediately: true);
  }

  Future<Map<String, dynamic>> refresh({
    bool acceptQuest = false,
    String focusTopic = 'general',
  }) {
    return _ref.read(cloudFunctionsServiceProvider).generateInsight(
          acceptQuest: acceptQuest,
          focusTopic: focusTopic,
        );
  }

  Future<void> dismiss(String id) async {
    final uid = _ref.read(authUidProvider);
    if (uid == null) return;
    await _ref
        .read(firestoreProvider)
        .collection('users')
        .doc(uid)
        .collection('insights')
        .doc(id)
        .update({'dismissed': true});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final insightsProvider =
    StateNotifierProvider<InsightsNotifier, AsyncValue<InsightCard?>>((ref) {
  return InsightsNotifier(ref);
});
