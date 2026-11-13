import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/ai/sipho_ai_client.dart';
import 'package:sipho/features/expenses/domain/parsed_receipt.dart';

const receiptModel = defaultAiModel;

const _receiptSystemInstruction =
    'Extract only what is visible on the receipt. '
    'Use null when a field is unreadable. Dates are YYYY-MM-DD. '
    'totalCents is the final amount in integer cents. '
    'Never extract a card number, phone number, or address. '
    'If the image is not a receipt, set isReceipt to false.';

final receiptParserProvider = Provider<ReceiptParser>((ref) {
  return ReceiptParser(aiClient: ref.watch(siphoAiClientProvider));
});

class ReceiptParser {
  ReceiptParser({
    GenerativeModel? model,
    SiphoAiClient? aiClient,
  })  : _model = model,
        _aiClient = aiClient ?? SiphoAiClient();

  final GenerativeModel? _model;
  final SiphoAiClient _aiClient;

  static Schema get responseSchema => Schema.object(
        properties: {
          'isReceipt': Schema.boolean(),
          'merchant': Schema.string(nullable: true),
          'date': Schema.string(nullable: true),
          'currency': Schema.string(nullable: true),
          'totalCents': Schema.integer(nullable: true),
          'suggestedCategory': Schema.enumString(
            enumValues: ParsedReceipt.allowedCategories,
            nullable: true,
          ),
          'confidence': Schema.number(),
        },
      );

  Future<ParsedReceipt> parse(Uint8List bytes) async {
    if (bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
      throw StateError('Receipt image is empty or too large');
    }
    final mimeType = detectImageMimeType(bytes);

    final String? text;
    if (_model != null) {
      final response = await _model.generateContent([
        Content.multi([
          InlineDataPart(mimeType, bytes),
          TextPart('Extract this receipt.'),
        ]),
      ]);
      text = extractGenerativeModelText(response);
    } else {
      text = await _aiClient.generateJson(
        prompt: 'Extract this receipt.',
        systemInstruction: _receiptSystemInstruction,
        imageBytes: bytes,
        imageMimeType: mimeType,
        responseSchema: responseSchema,
        maxOutputTokens: 1024,
      );
    }

    if (text == null || text.trim().isEmpty) {
      throw const SiphoAiException(
        code: SiphoAiErrorCode.emptyResponse,
        message: 'Empty receipt reading',
      );
    }
    final parsed = ParsedReceipt.tryParse(text);
    if (parsed == null) {
      throw const SiphoAiException(
        code: SiphoAiErrorCode.invalidResponse,
        message: 'Receipt reading was not valid JSON',
      );
    }
    return parsed;
  }
}
