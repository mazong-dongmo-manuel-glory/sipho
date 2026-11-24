import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/cloud_functions_service.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_profile_provider.dart';

class QuestItem {
  final String id;
  final String title;
  final int progress;
  final int target;
  final String status; // active | completed | claimed | expired
  final String templateId;
  final String type; // ADD_TRANSACTION | COMPLETE_LESSON | …

  const QuestItem({
    required this.id,
    required this.title,
    required this.progress,
    required this.target,
    required this.status,
    this.templateId = '',
    this.type = '',
  });

  bool get isDone => status == 'completed' || status == 'claimed' || progress >= target;

  /// Route in-app pour progresser la quête.
  String? get actionRoute {
    final t = type.toUpperCase();
    if (t == 'ADD_TRANSACTION' ||
        templateId.contains('log_expense') ||
        templateId.contains('catch')) {
      return '/expenses/add';
    }
    if (t == 'COMPLETE_LESSON' || templateId.contains('lesson')) {
      return '/learn';
    }
    return null;
  }
}

/// Libellés de repli si Firestore n’a pas encore `name` (ids bruts).
String questTitleFallback(String templateId, String docId, {required bool fr}) {
  final key = templateId.isNotEmpty
      ? templateId
      : docId
          .replaceFirst(RegExp(r'^daily_'), '')
          .replaceFirst(RegExp(r'^catchup_'), 'catch_up')
          .replaceFirst(RegExp(r'_\d{4}-\d{2}-\d{2}$'), '');
  return switch (key) {
    'log_expenses' => fr ? 'Noter 3 dépenses aujourd’hui' : 'Log 3 expenses today',
    'daily_lesson' => fr ? 'Fais une micro-leçon' : 'Do a micro-lesson',
    'catch_up' || 'catchup' =>
      fr ? 'Rattrapage : note une dépense' : 'Catch up: log one expense',
    _ => fr ? 'Quête du jour' : 'Daily quest',
  };
}

String _resolveQuestTitle(Map<String, dynamic> data, String id, {required bool fr}) {
  final name = data['name'];
  if (name is String && name.trim().isNotEmpty) return name.trim();
  if (name is Map) {
    final localized = (name[fr ? 'fr' : 'en'] ?? name['fr'] ?? name['en'])?.toString();
    if (localized != null && localized.trim().isNotEmpty) return localized.trim();
  }
  final title = data['title'];
  if (title is String && title.trim().isNotEmpty) return title.trim();
  if (title is Map) {
    final localized = (title[fr ? 'fr' : 'en'] ?? title['fr'] ?? title['en'])?.toString();
    if (localized != null && localized.trim().isNotEmpty) return localized.trim();
  }
  final templateId = (data['templateId'] as String?) ?? '';
  return questTitleFallback(templateId, id, fr: fr);
}

class QuestsNotifier extends StateNotifier<List<QuestItem>> {
  QuestsNotifier(this._ref) : super(const []) {
    _bind();
  }

  final Ref _ref;
  StreamSubscription? _sub;

  void _bind() {
    _ref.listen<String?>(authUidProvider, (_, uid) {
      _sub?.cancel();
      if (uid == null) {
        state = const [];
        return;
      }
      unawaited(_ref.read(cloudFunctionsServiceProvider).refreshDailyQuests());
      _sub = _ref
          .read(firestoreProvider)
          .collection('users')
          .doc(uid)
          .collection('quests')
          .snapshots()
          .listen((snap) {
        final fr = _ref.read(userProfileProvider).locale.toLowerCase().startsWith('fr');
        final items = snap.docs.map((d) {
          final data = d.data();
          return QuestItem(
            id: d.id,
            title: _resolveQuestTitle(data, d.id, fr: fr),
            progress: (data['progress'] as num?)?.toInt() ?? 0,
            target: (data['target'] as num?)?.toInt() ?? 1,
            status: (data['status'] as String?) ?? 'active',
            templateId: (data['templateId'] as String?) ?? '',
            type: (data['type'] as String?) ?? '',
          );
        }).toList();
        // Actives / complétées d’abord ; ignorer expired/claimed en bas de liste.
        items.sort((a, b) {
          int rank(QuestItem q) => switch (q.status) {
                'active' => 0,
                'completed' => 1,
                'claimed' => 2,
                _ => 3,
              };
          return rank(a).compareTo(rank(b));
        });
        state = items;
      }, onError: (_) {});
    }, fireImmediately: true);
  }

  Future<Map<String, dynamic>> claim(String questId) {
    return _ref.read(cloudFunctionsServiceProvider).claimQuest(questId: questId);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final questsProvider =
    StateNotifierProvider<QuestsNotifier, List<QuestItem>>((ref) {
  return QuestsNotifier(ref);
});
