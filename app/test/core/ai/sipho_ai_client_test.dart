import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/core/ai/sipho_ai_client.dart';
import 'package:sipho/features/expenses/data/receipt_parser.dart';
import 'package:sipho/features/lessons/data/lesson_ai_tutor_service.dart';

void main() {
  test('rejects retired Gemini 1.x / 2.x models and accepts Gemini 3.x / 4.x',
      () {
    expect(isSupportedGeminiModelName(''), isFalse);
    expect(isSupportedGeminiModelName('gemini-1.5-flash'), isFalse);
    expect(isSupportedGeminiModelName('gemini-2.0-flash'), isFalse);
    expect(isSupportedGeminiModelName('gemini-2.5-flash'), isFalse);
    expect(isSupportedGeminiModelName('gemini-3.5-flash-lite'), isTrue);
    expect(isSupportedGeminiModelName('gemini-3.8-flash'), isTrue);
    expect(isSupportedGeminiModelName('gemini-4-hydrogen'), isTrue);
  });

  test('detects PNG, WebP, HEIC, and JPEG magic bytes accurately', () {
    final png =
        Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
    final webp = Uint8List.fromList([
      0x52, 0x49, 0x46, 0x46, 0x00, 0x00, 0x00, 0x00, //
      0x57, 0x45, 0x42, 0x50,
    ]);
    final heic = Uint8List.fromList([
      0x00, 0x00, 0x00, 0x18, 0x66, 0x74, 0x79, 0x70, //
      0x68, 0x65, 0x69, 0x63,
    ]);
    final jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);

    expect(detectImageMimeType(png), 'image/png');
    expect(detectImageMimeType(webp), 'image/webp');
    expect(detectImageMimeType(heic), 'image/heic');
    expect(detectImageMimeType(jpeg), 'image/jpeg');
  });

  test('extractResponseTextFromJson skips Gemini 3/4 thought parts', () {
    final raw = jsonEncode({
      'promptFeedback': <String, Object?>{},
      'candidates': [
        {
          'finishReason': 'FINISH_REASON_UNSPECIFIED',
          'content': {
            'role': 'model',
            'parts': [
              {
                'thought': true,
                'text': 'Internal reasoning with {non-json braces}',
              },
              {
                'text': '{"example":"Réel","tip":"Astuce"}',
              },
            ],
          },
        },
      ],
    });

    expect(
        extractResponseTextFromJson(raw), '{"example":"Réel","tip":"Astuce"}');
  });

  test('falls back automatically to next model on 404 and omits temperature',
      () async {
    final calledModels = <String>[];
    Map<String, Object?>? capturedGenerationConfig;

    final client = SiphoAiClient(
      projectId: 'sipho-f5a01',
      apiKey: 'test-key',
      appId: '1:123:ios:abc',
      candidateModels: const ['gemini-3.5-flash-lite', 'gemini-3.8-flash'],
      transport: (uri, headers, body) async {
        calledModels.add(uri.path);
        final decoded = jsonDecode(body) as Map<String, Object?>;
        capturedGenerationConfig =
            decoded['generationConfig'] as Map<String, Object?>?;
        if (uri.path.contains('gemini-3.5-flash-lite')) {
          return (
            statusCode: 404,
            body: jsonEncode({
              'error': {
                'code': 404,
                'message': 'Model not found',
                'status': 'NOT_FOUND',
              },
            }),
          );
        }
        return (
          statusCode: 200,
          body: jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'text': jsonEncode({
                        'title': 'Budget clair',
                        'body': 'Tu as dépensé 42 CAD en épicerie.',
                        'actionStep': 'Note chaque achat.',
                        'recommendedLessonId': 'track_spending',
                      }),
                    },
                  ],
                },
              },
            ],
          }),
        );
      },
    );

    final text = await client.generateJson(prompt: 'Donne un conseil budget.');

    expect(calledModels, hasLength(2));
    expect(calledModels.first, contains('gemini-3.5-flash-lite'));
    expect(calledModels.last, contains('gemini-3.8-flash'));
    expect(capturedGenerationConfig?.containsKey('temperature'), isFalse);
    expect(text, contains('Budget clair'));
  });

  test(
      'ReceiptParser and LessonAiTutorService work end-to-end with PNG & tutor reply',
      () async {
    String? sentMimeType;
    final receiptClient = SiphoAiClient(
      projectId: 'sipho-f5a01',
      apiKey: 'test-key',
      candidateModels: const ['gemini-3.5-flash-lite'],
      transport: (uri, headers, body) async {
        final decoded = jsonDecode(body) as Map<String, Object?>;
        final contents = decoded['contents'] as List<Object?>;
        final first = contents.first as Map<String, Object?>;
        final parts = first['parts'] as List<Object?>;
        final inlinePart = parts.first as Map<String, Object?>;
        final inlineData = inlinePart['inlineData'] as Map<String, Object?>;
        sentMimeType = inlineData['mimeType'] as String?;
        return (
          statusCode: 200,
          body: jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'text': jsonEncode({
                        'isReceipt': true,
                        'merchant': 'IGA',
                        'date': '2026-11-13',
                        'currency': 'CAD',
                        'totalCents': 4849,
                        'suggestedCategory': 'groceries',
                        'confidence': 0.95,
                      }),
                    },
                  ],
                },
              },
            ],
          }),
        );
      },
    );

    final pngBytes =
        Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
    final parsedReceipt =
        await ReceiptParser(aiClient: receiptClient).parse(pngBytes);
    expect(sentMimeType, 'image/png');
    expect(parsedReceipt.totalCents, 4849);
    expect(parsedReceipt.merchant, 'IGA');

    final tutorClient = SiphoAiClient(
      projectId: 'sipho-f5a01',
      apiKey: 'test-key',
      candidateModels: const ['gemini-3.5-flash-lite'],
      transport: (uri, headers, body) async => (
        statusCode: 200,
        body: jsonEncode({
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'text': jsonEncode({
                      'example':
                          'Avec 950 CAD de charges fixes, vise un coussin.',
                      'tip': 'Automatise un petit virement.',
                    }),
                  },
                ],
              },
            },
          ],
        }),
      ),
    );

    final reply =
        await LessonAiTutorService(aiClient: tutorClient).explainForUser(
      lessonTitle: "Le fonds d'urgence",
      question: 'Où placer un coussin ?',
      explanation: 'Sur un compte liquide accessible.',
      selectedAnswer: 'Dans un compte épargne',
      answeredCorrectly: true,
      snapshot: const TutorSpendSnapshot(
        locale: 'fr',
        currency: 'CAD',
        countryCode: 'CA',
        incomeCents: 0,
        fixedCents: 95000,
        totalCents: 0,
        categoryCents: {},
      ),
    );
    expect(reply.example, contains('950 CAD'));
    expect(reply.tip, contains('virement'));
  });

  test(
      'classifies disabled Firebase AI Logic API with SiphoAiErrorCode.apiNotEnabled',
      () async {
    final client = SiphoAiClient(
      projectId: 'sipho-f5a01',
      apiKey: 'test-key',
      candidateModels: const ['gemini-3.5-flash-lite'],
      transport: (uri, headers, body) async => (
        statusCode: 403,
        body: jsonEncode({
          'error': {
            'code': 403,
            'message':
                'Firebase AI Logic API (firebasevertexai.googleapis.com) has not been used in project sipho-f5a01 before or it is disabled.',
            'status': 'PERMISSION_DENIED',
          },
        }),
      ),
    );

    expect(
      () => client.generateJson(prompt: 'ping'),
      throwsA(
        isA<SiphoAiException>().having(
          (e) => e.code,
          'code',
          SiphoAiErrorCode.apiNotEnabled,
        ),
      ),
    );
  });

  group('429 responses', () {
    Future<Object?> failureFor(String message) async {
      final client = SiphoAiClient(
        projectId: 'sipho-f5a01',
        apiKey: 'test-key',
        candidateModels: const ['gemini-3.5-flash-lite'],
        transport: (uri, headers, body) async => (
          statusCode: 429,
          body: jsonEncode({
            'error': {
              'code': 429,
              'message': message,
              'status': 'RESOURCE_EXHAUSTED',
            },
          }),
        ),
      );
      try {
        await client.generateJson(prompt: 'ping');
      } on SiphoAiException catch (error) {
        return error.code;
      }
      return null;
    }

    test('depleted prepayment credits are not a "try again later" quota',
        () async {
      expect(
        await failureFor(
          'Your prepayment credits are depleted. Please go to AI Studio at '
          'https://ai.studio/projects to manage your project and billing.',
        ),
        SiphoAiErrorCode.creditsDepleted,
      );
    });

    test('a plain rate limit stays a temporary quota', () async {
      expect(
        await failureFor('Resource has been exhausted (e.g. check quota).'),
        SiphoAiErrorCode.quotaExceeded,
      );
    });
  });

}
