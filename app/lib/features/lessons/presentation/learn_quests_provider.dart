import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/insights/data/insight_service.dart';
import 'package:sipho/features/lessons/domain/learn_quests.dart';

final serverQuestsStreamProvider =
    StreamProvider<List<ServerQuestRecord>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const []);

  return ref
      .watch(firestoreProvider)
      .collection('users/$uid/quests')
      // Newest first: daily quests are renewed every day, so an unordered `limit` would keep
      // returning the oldest (expired) ones and hide today's quest.
      .orderBy('createdAt', descending: true)
      .limit(20)
      .snapshots()
      .map((snap) {
    final records = <ServerQuestRecord>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      final status = (data['status'] as String?) ?? 'active';
      if (status == 'claimed' || status == 'expired') continue;
      final source = (data['source'] as String?) ?? '';
      records.add(
        ServerQuestRecord(
          id: doc.id,
          title: (data['name'] as String?) ?? '',
          description: (data['description'] as String?) ?? '',
          type: (data['type'] as String?) ?? 'ADD_TRANSACTION',
          progress: (data['progress'] as num?)?.toInt() ?? 0,
          target: (data['target'] as num?)?.toInt() ?? 1,
          rewardXp: (data['rewardXp'] as num?)?.toInt() ?? 15,
          status: status,
          isAiGenerated: source.startsWith('ai_'),
        ),
      );
    }
    return records;
  });
});

final learnQuestsProvider =
    Provider.family<List<LearnQuestItem>, String>((ref, languageCode) {
  final monthKey = currentMonthKey();
  final finance = ref.watch(userFinanceProvider).valueOrNull;
  final transactions =
      ref.watch(transactionsForMonthProvider(monthKey)).valueOrNull ?? const [];
  final fixed = ref.watch(activeFixedExpensesProvider).valueOrNull ?? const [];
  final serverQuests =
      ref.watch(serverQuestsStreamProvider).valueOrNull ?? const [];
  final activeAdvice = ref.watch(activeCoachAdviceProvider);
  final completedSet = (finance?.completedLessonIds ?? const []).toSet();

  final mergedServer = [...serverQuests];

  // If the AI coach produced a suggested quest in client-only mode (before Functions
  // wrote it to Firestore), surface it immediately with live progress!
  final aiSuggestion = activeAdvice?.suggestedQuest;
  if (aiSuggestion != null &&
      !mergedServer.any(
        (q) => q.title.toLowerCase() == aiSuggestion.name.toLowerCase(),
      )) {
    final liveProgress = aiSuggestion.type == 'COMPLETE_LESSON'
        ? completedSet.length
        : transactions.length;
    mergedServer.insert(
      0,
      ServerQuestRecord(
        id: 'local_ai_coach',
        title: aiSuggestion.name,
        description: aiSuggestion.description,
        type: aiSuggestion.type,
        progress: liveProgress,
        target: aiSuggestion.target,
        rewardXp: 0,
        status: liveProgress >= aiSuggestion.target ? 'completed' : 'active',
        isAiGenerated: true,
      ),
    );
  }

  return buildLearnQuests(
    languageCode: languageCode,
    completedLessonIds: completedSet,
    monthExpenseCount: transactions.length,
    activeFixedCount: fixed.length,
    hasMonthlyIncome: (finance?.monthlyIncomeCents ?? 0) > 0,
    serverQuests: mergedServer,
  );
});

class QuestClaimController extends Notifier<String?> {
  @override
  String? build() => null;

  Future<bool> claim(String serverQuestId) async {
    if (serverQuestId == 'local_ai_coach') return false;
    if (state != null) return false;
    state = serverQuestId;
    try {
      await ref
          .read(firebaseFunctionsProvider)
          .httpsCallable('claimQuest')
          .call<Map<String, dynamic>>({'questId': serverQuestId});
      state = null;
      return true;
    } catch (_) {
      state = null;
      return false;
    }
  }
}

final questClaimControllerProvider =
    NotifierProvider<QuestClaimController, String?>(QuestClaimController.new);
