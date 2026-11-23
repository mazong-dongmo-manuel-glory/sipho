import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/ai/sipho_ai_client.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/core/i18n/app_language.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/insights/domain/insight_text.dart';

class InsightState {
  const InsightState({
    this.text,
    this.loading = false,
    this.focusTopic = 'general',
  });

  final InsightText? text;
  final bool loading;
  final String focusTopic;
}

/// Streams non-dismissed insights saved on `users/{uid}/insights` (newest first).
final storedInsightsProvider = StreamProvider<List<InsightText>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const []);

  return ref
      .watch(firestoreProvider)
      .collection('users/$uid/insights')
      .orderBy('createdAt', descending: true)
      .limit(10)
      .snapshots()
      .map((snap) {
    final results = <InsightText>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      if (data['dismissed'] == true) continue;
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      final parsed = parseInsightMap(data, id: doc.id, createdAt: createdAt);
      if (parsed != null) results.add(parsed);
    }
    return results;
  });
});

/// Resolves the active coach advice: latest in-session AI advice, or latest stored insight
/// matching the UI language when locale is known.
final activeCoachAdviceProvider = Provider<InsightText?>((ref) {
  final sessionAdvice = ref.watch(insightControllerProvider).text;
  if (sessionAdvice != null) return sessionAdvice;
  final uiLanguage = normalizeAppLanguage(
    WidgetsBinding.instance.platformDispatcher.locale.languageCode,
  );
  final stored = ref.watch(storedInsightsProvider).valueOrNull;
  if (stored == null || stored.isEmpty) return null;
  for (final insight in stored) {
    if (insight.locale.isEmpty ||
        appLanguagesMatch(insight.locale, uiLanguage)) {
      return insight;
    }
  }
  return null;
});

class InsightController extends Notifier<InsightState> {
  @override
  InsightState build() => const InsightState();

  void selectFocus(String topic) {
    if (state.loading || state.focusTopic == topic) return;
    state = InsightState(text: state.text, focusTopic: topic);
  }

  Future<InsightText> ask(
    SpendSnapshot snapshot, {
    bool acceptQuest = false,
  }) async {
    if (state.loading) {
      throw StateError('Already loading');
    }
    state = InsightState(
      text: state.text,
      loading: true,
      focusTopic: snapshot.focusTopic,
    );
    try {
      final text = await ref.read(insightServiceProvider).generateAdvice(
            snapshot,
            acceptQuest: acceptQuest,
          );
      state = InsightState(text: text, focusTopic: snapshot.focusTopic);
      return text;
    } catch (_) {
      state = InsightState(text: state.text, focusTopic: snapshot.focusTopic);
      rethrow;
    }
  }

  Future<void> dismiss(InsightText advice) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (state.text == advice ||
        (advice.id != null && state.text?.id == advice.id)) {
      state = InsightState(focusTopic: state.focusTopic);
    }
    if (uid != null && advice.id != null && advice.id!.isNotEmpty) {
      await ref
          .read(firestoreProvider)
          .doc('users/$uid/insights/${advice.id}')
          .update({'dismissed': true});
    }
  }
}

final insightControllerProvider =
    NotifierProvider<InsightController, InsightState>(InsightController.new);

final insightServiceProvider = Provider<InsightService>((ref) {
  return InsightService(
    aiClient: ref.watch(siphoAiClientProvider),
    functions: ref.watch(firebaseFunctionsProvider),
  );
});

class InsightService {
  InsightService({
    GenerativeModel? model,
    SiphoAiClient? aiClient,
    FirebaseFunctions? functions,
  })  : _model = model,
        _aiClient = aiClient ?? SiphoAiClient(),
        _functions = functions;

  final GenerativeModel? _model;
  final SiphoAiClient _aiClient;
  final FirebaseFunctions? _functions;

  static Schema get responseSchema => Schema.object(
        properties: {
          'title': Schema.string(),
          'body': Schema.string(),
          'actionStep': Schema.string(),
          'recommendedLessonId': Schema.enumString(
            enumValues: InsightText.validLessonIds,
          ),
          'suggestedQuest': Schema.object(
            nullable: true,
            properties: {
              'name': Schema.string(),
              'description': Schema.string(),
              'type': Schema.enumString(
                enumValues: const ['ADD_TRANSACTION', 'COMPLETE_LESSON'],
              ),
              'target': Schema.integer(),
            },
          ),
        },
        optionalProperties: const ['suggestedQuest'],
      );

  /// Tries the server `generateInsight` callable first (which persists to
  /// `users/{uid}/insights` and can activate quests), falling back to client-side
  /// Firebase AI Logic when Cloud Functions are not deployed yet.
  Future<InsightText> generateAdvice(
    SpendSnapshot snapshot, {
    bool acceptQuest = false,
  }) async {
    if (!snapshot.hasAnyFinancialData) {
      throw StateError('No financial data to describe');
    }

    final fn = _functions;
    if (fn != null && !_serverCoachUnavailable) {
      try {
        final result = await fn
            .httpsCallable('generateInsight')
            .call<Map<String, dynamic>>(
          {
            'monthKey': snapshot.monthKey,
            'focusTopic': snapshot.focusTopic,
            'acceptQuest': acceptQuest,
          },
        );
        final data = result.data;
        final parsed = parseInsightMap(Map<String, dynamic>.from(data));
        if (parsed != null) return parsed;
      } catch (error) {
        if (isServerCoachNotConfigured(error)) {
          // The server has no Gemini key (the app relies on Firebase AI Logic): do not ask
          // again for the rest of the session, it only adds a round trip to every request.
          _serverCoachUnavailable = true;
        }
        debugPrint(
          '[SiphoAI] generateInsight callable unavailable, using client '
          'Firebase AI Logic fallback: $error',
        );
      }
    }

    return write(snapshot);
  }

  bool _serverCoachUnavailable = false;

  /// Whether [error] is the server saying it has no AI key configured (as opposed to a
  /// transient failure, which deserves another try next time).
  @visibleForTesting
  static bool isServerCoachNotConfigured(Object error) =>
      error is FirebaseFunctionsException &&
      error.code == 'failed-precondition' &&
      (error.message ?? '').toLowerCase().contains('not configured');

  Future<InsightText> write(SpendSnapshot snapshot) async {
    if (!snapshot.hasAnyFinancialData) {
      throw StateError('No spending to describe');
    }
    final prompt = buildInsightPrompt(snapshot);

    final String? text;
    if (_model != null) {
      final response = await _model.generateContent([Content.text(prompt)]);
      text = extractGenerativeModelText(response);
    } else {
      text = await _aiClient.generateJson(
        prompt: prompt,
        responseSchema: responseSchema,
        maxOutputTokens: 1536,
      );
    }

    final parsed = text == null ? null : parseInsightText(text);
    if (parsed == null) {
      throw const SiphoAiException(
        code: SiphoAiErrorCode.invalidResponse,
        message: 'Insight was empty or invalid JSON',
      );
    }
    return parsed;
  }
}
