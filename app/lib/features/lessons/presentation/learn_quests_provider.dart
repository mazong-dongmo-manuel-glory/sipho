import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/core/firebase/callable_data.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/gamification/domain/quest_reward.dart';
import 'package:sipho/features/insights/data/insight_service.dart';
import 'package:sipho/features/lessons/domain/learn_quest_strings.dart';
import 'package:sipho/features/lessons/domain/learn_quests.dart';

/// Asks the server to make sure today's daily quests exist (once per session and account).
///
/// Quests are normally created by the profile trigger and renewed by the hourly rollover; this
/// closes the gaps (rollover not yet run, new quest template deployed during the day). It is
/// best-effort: a failure only means the quests show up at the next rollover.
final dailyQuestsRefreshProvider = FutureProvider<void>((ref) async {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return;
  try {
    await ref
        .read(firebaseFunctionsProvider)
        .httpsCallable('refreshDailyQuests')
        .call<Map<String, dynamic>>();
  } catch (error) {
    debugPrint('[Quests] refreshDailyQuests failed: $error');
  }
});

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
          period: (data['period'] as String?) ?? '',
        ),
      );
    }
    return records;
  });
});

/// Learn-tab quests. Pass [l10n] so titles come from ARB (README rule 6).
final learnQuestsProvider =
    Provider.family<List<LearnQuestItem>, AppLocalizations>((ref, l10n) {
  final languageCode = l10n.localeName;
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
  // wrote it to Firestore), surface it immediately with live progress.
  final aiSuggestion = activeAdvice?.suggestedQuest;
  if (aiSuggestion != null &&
      !mergedServer.any(
        (q) => q.title.toLowerCase() == aiSuggestion.name.toLowerCase(),
      )) {
    // Do not invent progress from lifetime lesson count / all-month spends —
    // that falsely completes daily quests. Server rows own real progress.
    final liveProgress = 0;
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
        status: 'active',
        isAiGenerated: true,
      ),
    );
  }

  return buildLearnQuests(
    strings: LearnQuestStrings.fromL10n(l10n),
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

  /// Claims a completed quest. Returns what the server paid, or null when the claim failed (or
  /// another claim is already running).
  Future<QuestReward?> claim(String serverQuestId) async {
    if (serverQuestId == 'local_ai_coach') return null;
    if (state != null) return null;
    state = serverQuestId;
    try {
      final result = await ref
          .read(firebaseFunctionsProvider)
          .httpsCallable('claimQuest')
          .call({'questId': serverQuestId});
      state = null;
      return QuestReward.fromCallable(callableDataMap(result.data));
    } catch (_) {
      state = null;
      return null;
    }
  }
}

final questClaimControllerProvider =
    NotifierProvider<QuestClaimController, String?>(QuestClaimController.new);
