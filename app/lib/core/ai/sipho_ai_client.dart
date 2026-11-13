import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';

const _appCheckDebugChannel =
    MethodChannel('com.cargonomade.sipho/app_check_debug');

/// Reads the native Android/iOS Firebase App Check debug secret in debug builds.
Future<String?> readNativeAppCheckDebugToken() async {
  if (!kDebugMode) return null;
  try {
    final token =
        await _appCheckDebugChannel.invokeMethod<String>('getDebugToken');
    if (token != null && token.trim().isNotEmpty) {
      return token.trim();
    }
  } catch (_) {}
  return null;
}

/// Default active Gemini model on Firebase AI Logic (Gemini Developer API).
/// Replaces `gemini-2.0-flash`, which was retired on June 1, 2026.
const defaultAiModel = 'gemini-3.5-flash-lite';

/// Ordered fallback chain of supported no-billing-required Firebase AI Logic models.
const fallbackAiModels = <String>[
  defaultAiModel,
  'gemini-3.8-flash',
  'gemini-4-hydrogen',
];

const _retiredModelPrefixes = <String>[
  'gemini-1.',
  'gemini-2.0',
  'gemini-2.5',
];

enum SiphoAiErrorCode {
  apiNotEnabled,
  appCheckRejected,
  modelUnavailable,
  quotaExceeded,
  networkError,
  emptyResponse,
  invalidResponse,
  unknown,
}

class SiphoAiException implements Exception {
  const SiphoAiException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  final SiphoAiErrorCode code;
  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'SiphoAiException(${code.name}, status=$statusCode): $message';
}

typedef AiHttpTransport = Future<({int statusCode, String body})> Function(
  Uri uri,
  Map<String, String> headers,
  String body,
);

final siphoAiClientProvider = Provider<SiphoAiClient>((ref) {
  return SiphoAiClient();
});

/// Detects image MIME type from magic bytes so PNG/WebP/HEIC gallery screenshots
/// are never mislabeled as `image/jpeg`.
String detectImageMimeType(Uint8List bytes) {
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47) {
    return 'image/png';
  }
  if (bytes.length >= 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    return 'image/webp';
  }
  if (bytes.length >= 12 &&
      bytes[4] == 0x66 &&
      bytes[5] == 0x74 &&
      bytes[6] == 0x79 &&
      bytes[7] == 0x70) {
    final brand = String.fromCharCodes(bytes.sublist(8, 12)).toLowerCase();
    if (brand.startsWith('hei') || brand.startsWith('mif')) {
      return 'image/heic';
    }
  }
  return 'image/jpeg';
}

/// Checks whether [modelName] is non-empty and not on the retired 1.x / 2.x list.
bool isSupportedGeminiModelName(String modelName) {
  final trimmed = modelName.trim().toLowerCase();
  if (trimmed.isEmpty) return false;
  for (final prefix in _retiredModelPrefixes) {
    if (trimmed.startsWith(prefix)) return false;
  }
  return true;
}

/// Extracts the cleanest text response from a `GenerativeModel` response
/// (used when a mock/custom `GenerativeModel` is injected in unit tests).
String? extractGenerativeModelText(GenerateContentResponse response) {
  final parts = response.candidates.firstOrNull?.content.parts;
  if (parts != null && parts.isNotEmpty) {
    for (final part in parts.reversed) {
      if (part is TextPart && part.text.trim().isNotEmpty) {
        return part.text;
      }
    }
  }
  return response.text;
}

/// Resilient Firebase AI Logic client (Gemini Developer API) compatible with
/// Gemini 3.x / 4.x models, App Check headers, Remote Config model overrides,
/// and automatic model fallback.
class SiphoAiClient {
  SiphoAiClient({
    FirebaseApp? app,
    FirebaseAuth? auth,
    FirebaseAppCheck? appCheck,
    FirebaseRemoteConfig? remoteConfig,
    AiHttpTransport? transport,
    List<String>? candidateModels,
    String? projectId,
    String? apiKey,
    String? appId,
  })  : _app = app,
        _auth = auth,
        _appCheck = appCheck,
        _remoteConfig = remoteConfig,
        _transport = transport ?? _defaultHttpTransport,
        _candidateModels = candidateModels,
        _projectIdOverride = projectId,
        _apiKeyOverride = apiKey,
        _appIdOverride = appId;

  final FirebaseApp? _app;
  final FirebaseAuth? _auth;
  final FirebaseAppCheck? _appCheck;
  final FirebaseRemoteConfig? _remoteConfig;
  final AiHttpTransport _transport;
  final List<String>? _candidateModels;
  final String? _projectIdOverride;
  final String? _apiKeyOverride;
  final String? _appIdOverride;

  List<String> _resolveCandidateModels() {
    if (_candidateModels != null && _candidateModels.isNotEmpty) {
      return _candidateModels;
    }
    final resolved = <String>[];
    try {
      final rc = _remoteConfig ?? FirebaseRemoteConfig.instance;
      final configured = rc.getString('ai_model').trim();
      if (isSupportedGeminiModelName(configured)) {
        resolved.add(configured);
      }
    } catch (_) {
      // Remote Config may not be initialized in unit tests.
    }
    for (final model in fallbackAiModels) {
      if (!resolved.contains(model)) {
        resolved.add(model);
      }
    }
    return resolved;
  }

  Future<Map<String, String>> _buildHeaders({
    required String projectId,
    required String apiKey,
    required String appId,
  }) async {
    final headers = <String, String>{
      'x-goog-api-key': apiKey,
      'x-goog-api-client': 'gl-dart/2.3.0 fire/2.3.0',
      'Content-Type': 'application/json',
      if (appId.isNotEmpty) 'X-Firebase-AppId': appId,
    };

    try {
      final auth =
          _auth ?? (Firebase.apps.isNotEmpty ? FirebaseAuth.instance : null);
      final idToken = await auth?.currentUser?.getIdToken();
      if (idToken != null && idToken.isNotEmpty) {
        headers['Authorization'] = 'Firebase $idToken';
      }
    } catch (error) {
      debugPrint('[SiphoAI] Auth token unavailable: $error');
    }

    try {
      final appCheck = _appCheck ??
          (Firebase.apps.isNotEmpty ? FirebaseAppCheck.instance : null);
      final appCheckToken = await appCheck?.getToken();
      if (appCheckToken != null && appCheckToken.isNotEmpty) {
        headers['X-Firebase-AppCheck'] = appCheckToken;
      }
    } catch (error) {
      debugPrint(
        '[SiphoAI] App Check token unavailable. If App Check is enforced for '
        'Firebase AI Logic on project $projectId, register the '
        'Simulator/Emulator debug token in Firebase Console > App Check > Apps: '
        '$error',
      );
    }

    return headers;
  }

  Future<String> generateJson({
    required String prompt,
    Schema? responseSchema,
    String? systemInstruction,
    Uint8List? imageBytes,
    String? imageMimeType,
    int maxOutputTokens = 1536,
  }) async {
    final String projectId;
    final String apiKey;
    final String appId;
    if (_projectIdOverride != null && _apiKeyOverride != null) {
      projectId = _projectIdOverride;
      apiKey = _apiKeyOverride;
      appId = _appIdOverride ?? '';
    } else {
      final FirebaseApp app;
      try {
        app = _app ?? Firebase.app();
      } catch (error) {
        throw SiphoAiException(
          code: SiphoAiErrorCode.unknown,
          message: 'Firebase is not initialized: $error',
        );
      }
      projectId = app.options.projectId;
      apiKey = app.options.apiKey;
      appId = app.options.appId;
    }

    final headers = await _buildHeaders(
      projectId: projectId,
      apiKey: apiKey,
      appId: appId,
    );
    final models = _resolveCandidateModels();
    final parts = <Map<String, Object?>>[
      if (imageBytes != null && imageBytes.isNotEmpty)
        {
          'inlineData': {
            'mimeType': imageMimeType ?? detectImageMimeType(imageBytes),
            'data': base64Encode(imageBytes),
          },
        },
      {'text': prompt},
    ];

    // Note: Gemini 3.x / 4.x models reject legacy sampling fields like
    // `temperature` and use dynamic thinking counted against `maxOutputTokens`.
    final generationConfig = <String, Object?>{
      'maxOutputTokens': maxOutputTokens,
      'responseMimeType': 'application/json',
      if (responseSchema != null) 'responseSchema': responseSchema.toJson(),
    };

    SiphoAiException? lastError;

    for (final model in models) {
      final normalizedModel =
          model.startsWith('models/') ? model.substring(7) : model;
      final uri = Uri.https(
        'firebasevertexai.googleapis.com',
        '/v1beta/projects/$projectId/models/$normalizedModel:generateContent',
      );
      final payload = <String, Object?>{
        'model': 'models/$normalizedModel',
        'contents': [
          {
            'role': 'user',
            'parts': parts,
          },
        ],
        if (systemInstruction != null && systemInstruction.trim().isNotEmpty)
          'systemInstruction': {
            'role': 'system',
            'parts': [
              {'text': systemInstruction},
            ],
          },
        'generationConfig': generationConfig,
      };

      try {
        final response = await _transport(uri, headers, jsonEncode(payload));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final text = extractResponseTextFromJson(response.body);
          if (text != null && text.trim().isNotEmpty) {
            return text;
          }
          lastError = const SiphoAiException(
            code: SiphoAiErrorCode.emptyResponse,
            message: 'Model returned an empty response.',
          );
          continue;
        }

        final classified = _classifyHttpError(
          statusCode: response.statusCode,
          rawBody: response.body,
          projectId: projectId,
          model: normalizedModel,
        );
        lastError = classified;

        // Retry next fallback model only when the error is model-specific.
        if (classified.code == SiphoAiErrorCode.modelUnavailable) {
          debugPrint(
            '[SiphoAI] Model "$normalizedModel" unavailable, trying next fallback…',
          );
          continue;
        }
        throw classified;
      } on SiphoAiException {
        rethrow;
      } on SocketException catch (error) {
        throw SiphoAiException(
          code: SiphoAiErrorCode.networkError,
          message: error.message,
        );
      } on TimeoutException catch (error) {
        throw SiphoAiException(
          code: SiphoAiErrorCode.networkError,
          message: 'AI request timed out: $error',
        );
      } catch (error) {
        lastError = SiphoAiException(
          code: SiphoAiErrorCode.unknown,
          message: '$error',
        );
      }
    }

    throw lastError ??
        const SiphoAiException(
          code: SiphoAiErrorCode.unknown,
          message: 'No AI model succeeded.',
        );
  }

  SiphoAiException _classifyHttpError({
    required int statusCode,
    required String rawBody,
    required String projectId,
    required String model,
  }) {
    var apiMessage = rawBody;
    var apiStatus = '';
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map) {
        final err = decoded['error'];
        if (err is Map) {
          final msg = err['message'];
          final st = err['status'];
          if (msg is String && msg.isNotEmpty) apiMessage = msg;
          if (st is String) apiStatus = st;
        }
      }
    } catch (_) {}

    final lower = apiMessage.toLowerCase();

    if (statusCode == 404 ||
        (statusCode == 400 &&
            (lower.contains('model') &&
                (lower.contains('not found') ||
                    lower.contains('not supported') ||
                    lower.contains('retired') ||
                    lower.contains('deprecated'))))) {
      debugPrint(
        '[SiphoAI] HTTP $statusCode on model "$model": $apiMessage',
      );
      return SiphoAiException(
        code: SiphoAiErrorCode.modelUnavailable,
        statusCode: statusCode,
        message: apiMessage,
      );
    }

    if (lower.contains('firebasevertexai.googleapis.com') ||
        lower.contains('generativelanguage.googleapis.com') ||
        lower.contains('has not been used in project') ||
        lower.contains('service_disabled') ||
        lower.contains('api keys are not supported') ||
        lower.contains('blocked') && lower.contains('api')) {
      debugPrint(
        '[SiphoAI] Firebase AI Logic API is not enabled on "$projectId". '
        'Open Firebase Console > AI Services > AI Logic > Get started '
        '(Gemini Developer API). Details: $apiMessage',
      );
      return SiphoAiException(
        code: SiphoAiErrorCode.apiNotEnabled,
        statusCode: statusCode,
        message: apiMessage,
      );
    }

    if (statusCode == 401 ||
        (statusCode == 403 &&
            (lower.contains('app check') ||
                lower.contains('appcheck') ||
                lower.contains('unverified') ||
                apiStatus == 'PERMISSION_DENIED'))) {
      debugPrint(
        '[SiphoAI] HTTP $statusCode ($apiStatus) on "$projectId": $apiMessage. '
        'Verify: (1) Firebase Console > AI Services > AI Logic is enabled, and '
        '(2) Firebase Console > App Check > Apps has your debug token registered '
        '(or temporarily delay App Check enforcement for Firebase AI Logic).',
      );
      return SiphoAiException(
        code: SiphoAiErrorCode.appCheckRejected,
        statusCode: statusCode,
        message: apiMessage,
      );
    }

    if (statusCode == 429 || apiStatus == 'RESOURCE_EXHAUSTED') {
      debugPrint('[SiphoAI] Quota exceeded on "$projectId": $apiMessage');
      return SiphoAiException(
        code: SiphoAiErrorCode.quotaExceeded,
        statusCode: statusCode,
        message: apiMessage,
      );
    }

    debugPrint(
      '[SiphoAI] HTTP $statusCode ($apiStatus) on "$model": $apiMessage',
    );
    return SiphoAiException(
      code: SiphoAiErrorCode.unknown,
      statusCode: statusCode,
      message: apiMessage,
    );
  }
}

/// Parses raw JSON returned by Firebase AI Logic, skipping internal Gemini 3/4
/// `thought: true` parts and tolerating newer enum / safety feedback shapes.
String? extractResponseTextFromJson(String rawResponseBody) {
  final Object? decoded;
  try {
    decoded = jsonDecode(rawResponseBody);
  } catch (_) {
    return null;
  }
  if (decoded is! Map) return null;

  final candidates = decoded['candidates'];
  if (candidates is! List || candidates.isEmpty) return null;

  final first = candidates.first;
  if (first is! Map) return null;

  final content = first['content'];
  if (content is! Map) return null;

  final parts = content['parts'];
  if (parts is! List || parts.isEmpty) return null;

  final nonThoughtChunks = <String>[];
  final fallbackChunks = <String>[];

  for (final part in parts) {
    if (part is! Map) continue;
    final text = part['text'];
    if (text is! String || text.trim().isEmpty) continue;
    if (part['thought'] == true) {
      fallbackChunks.add(text);
    } else {
      nonThoughtChunks.add(text);
    }
  }

  if (nonThoughtChunks.isNotEmpty) {
    return nonThoughtChunks.join('\n').trim();
  }
  if (fallbackChunks.isNotEmpty) {
    return fallbackChunks.last.trim();
  }
  return null;
}

Future<({int statusCode, String body})> _defaultHttpTransport(
  Uri uri,
  Map<String, String> headers,
  String body,
) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
  try {
    final request = await client.postUrl(uri).timeout(
          const Duration(seconds: 35),
        );
    headers.forEach(request.headers.set);
    final payloadBytes = utf8.encode(body);
    request.contentLength = payloadBytes.length;
    request.add(payloadBytes);
    final response = await request.close().timeout(
          const Duration(seconds: 35),
        );
    final responseBody = await utf8.decodeStream(response).timeout(
          const Duration(seconds: 20),
        );
    return (statusCode: response.statusCode, body: responseBody);
  } finally {
    client.close(force: false);
  }
}

/// Maps an AI error to a helpful, localized SnackBar string.
String siphoAiUserMessage(
  Object error,
  AppLocalizations l10n, {
  required String fallback,
}) {
  if (error is SiphoAiException) {
    switch (error.code) {
      case SiphoAiErrorCode.apiNotEnabled:
        return l10n.aiErrorNotEnabled;
      case SiphoAiErrorCode.appCheckRejected:
        return l10n.aiErrorAppCheck;
      case SiphoAiErrorCode.quotaExceeded:
        return l10n.aiErrorQuota;
      case SiphoAiErrorCode.networkError:
        return l10n.aiErrorNetwork;
      case SiphoAiErrorCode.modelUnavailable:
      case SiphoAiErrorCode.emptyResponse:
      case SiphoAiErrorCode.invalidResponse:
      case SiphoAiErrorCode.unknown:
        return fallback;
    }
  }
  return fallback;
}

/// Displays a localized AI error SnackBar. In debug builds, if App Check blocked
/// the device, displays the exact native debug UUID and offers a 1-tap Copy action.
Future<void> showSiphoAiErrorSnackBar(
  BuildContext context,
  Object error,
  AppLocalizations l10n, {
  required String fallback,
}) async {
  final baseMessage = siphoAiUserMessage(error, l10n, fallback: fallback);
  String? debugToken;
  if (kDebugMode &&
      error is SiphoAiException &&
      error.code == SiphoAiErrorCode.appCheckRejected) {
    debugToken = await readNativeAppCheckDebugToken();
    if (debugToken != null) {
      debugPrint(
        '[SiphoAI] 👉 App Check Debug Token for this device: $debugToken',
      );
    }
  }
  if (!context.mounted) return;
  final isFr = Localizations.localeOf(context).languageCode == 'fr';
  final fullText =
      debugToken == null ? baseMessage : '$baseMessage\nToken: $debugToken';

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: Duration(seconds: debugToken != null ? 10 : 5),
        content: Text(fullText),
        action: debugToken == null
            ? null
            : SnackBarAction(
                label: isFr ? 'COPIER' : 'COPY',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: debugToken!));
                },
              ),
      ),
    );
}
