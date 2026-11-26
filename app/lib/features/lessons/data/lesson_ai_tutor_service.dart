import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ai/sipho_ai_client.dart';

/// Aggregated month numbers for the AI tutor (no PII).
class TutorSpendSnapshot {
  const TutorSpendSnapshot({
    required this.locale,
    required this.currency,
    required this.countryCode,
    required this.incomeCents,
    required this.fixedCents,
    required this.totalCents,
    this.categoryCents = const {},
  });

  final String locale;
  final String currency;
  final String countryCode;
  final int incomeCents;
  final int fixedCents;
  final int totalCents;
  final Map<String, int> categoryCents;
}

class LessonTutorReply {
  const LessonTutorReply({
    required this.example,
    required this.tip,
  });

  final String example;
  final String tip;
}

String buildLessonTutorPrompt({
  required String lessonTitle,
  required String question,
  required String explanation,
  required String selectedAnswer,
  required bool answeredCorrectly,
  required TutorSpendSnapshot snapshot,
}) {
  final isFr = snapshot.locale.toLowerCase().startsWith('fr');
  final language = isFr ? 'French' : 'English';
  final categorySummary = snapshot.categoryCents.isEmpty
      ? 'none logged yet'
      : snapshot.categoryCents.entries
          .map((e) => '${e.key}: ${e.value} cents')
          .join(', ');

  return '''
You are Sipho, a warm educational money tutor. Reply in $language.
STRICT GUARDRAILS:
- Use ONLY the integer cents below when mentioning the user's budget (100 cents = 1 ${snapshot.currency}).
- NEVER invent interest rates, inflation rates, tax rules, or prices.
- NEVER name a specific bank, card, broker, or investment product.
- Keep it educational, encouraging, and concise (2 short sentences max per field).

Lesson title: $lessonTitle
Question: $question
Core explanation: $explanation
User's chosen answer: $selectedAnswer (${answeredCorrectly ? "correct" : "incorrect"})

User's real monthly context (no PII):
- Currency: ${snapshot.currency}, Country: ${snapshot.countryCode}
- Monthly net income: ${snapshot.incomeCents > 0 ? "${snapshot.incomeCents} cents" : "not set"}
- Active fixed base: ${snapshot.fixedCents} cents
- Variable spending this month: ${snapshot.totalCents} cents ($categorySummary)

Respond with valid JSON only:
{
  "example": "Connect this lesson concept to the user's real numbers (or currency if no numbers yet).",
  "tip": "1 tiny practical takeaway for today."
}
''';
}

LessonTutorReply? parseLessonTutorReply(String raw) {
  final start = raw.indexOf('{');
  final end = raw.lastIndexOf('}');
  if (start < 0 || end <= start) return null;
  try {
    final decoded = jsonDecode(raw.substring(start, end + 1));
    if (decoded is! Map) return null;
    final example = decoded['example'];
    final tip = decoded['tip'];
    if (example is! String || example.trim().isEmpty) return null;
    return LessonTutorReply(
      example: example.trim(),
      tip: tip is String ? tip.trim() : '',
    );
  } catch (_) {
    return null;
  }
}

final lessonAiTutorServiceProvider = Provider<LessonAiTutorService>((ref) {
  return LessonAiTutorService(aiClient: ref.watch(siphoAiClientProvider));
});

class LessonAiTutorService {
  LessonAiTutorService({
    GenerativeModel? model,
    SiphoAiClient? aiClient,
  })  : _model = model, // ignore: prefer_initializing_formals
        _aiClient = aiClient ?? SiphoAiClient();

  final GenerativeModel? _model;
  final SiphoAiClient _aiClient;

  static Schema get responseSchema => Schema.object(
        properties: {
          'example': Schema.string(),
          'tip': Schema.string(),
        },
      );

  Future<LessonTutorReply> explainForUser({
    required String lessonTitle,
    required String question,
    required String explanation,
    required String selectedAnswer,
    required bool answeredCorrectly,
    required TutorSpendSnapshot snapshot,
  }) async {
    final prompt = buildLessonTutorPrompt(
      lessonTitle: lessonTitle,
      question: question,
      explanation: explanation,
      selectedAnswer: selectedAnswer,
      answeredCorrectly: answeredCorrectly,
      snapshot: snapshot,
    );

    final String? text;
    if (_model != null) {
      final response = await _model.generateContent([Content.text(prompt)]);
      text = extractGenerativeModelText(response);
    } else {
      text = await _aiClient.generateJson(
        prompt: prompt,
        responseSchema: responseSchema,
        maxOutputTokens: 1024,
      );
    }

    final parsed = text == null ? null : parseLessonTutorReply(text);
    if (parsed == null) {
      throw const SiphoAiException(
        code: SiphoAiErrorCode.invalidResponse,
        message: 'Empty or invalid tutor reply',
      );
    }
    return parsed;
  }
}
