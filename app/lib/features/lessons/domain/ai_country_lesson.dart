import 'package:sipho/core/i18n/app_language.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';

export 'package:sipho/core/i18n/app_language.dart';

/// Monolingual string helper — duplicates into [LText] for the existing UI.
LText _mono(String value) {
  final t = value.trim();
  return LText(t, t);
}

/// Soft-clean titles that leak a second language after ` & `
/// (e.g. "Mutuelle & Health Buffers" → "Mutuelle" in FR).
String sanitizeMonolingualTitle(String title, String language) {
  final t = title.trim();
  final amp = t.indexOf(' & ');
  if (amp <= 0) return t;
  final left = t.substring(0, amp).trim();
  final right = t.substring(amp + 3).trim();
  if (left.length < 3 || right.length < 2) return t;

  final preferFr = normalizeAppLanguage(language) == 'fr';
  final hasLatinAccents = RegExp(
    r'[àâäéèêëïîôùûüçÀÂÄÉÈÊËÏÎÔÙÛÜÇ]',
  ).hasMatch;
  final leftFr = hasLatinAccents(left);
  final rightFr = hasLatinAccents(right);
  final asciiOnly = RegExp(r"^[A-Za-z0-9 \-/'’]+$");
  final leftAscii = asciiOnly.hasMatch(left);
  final rightAscii = asciiOnly.hasMatch(right);

  if (preferFr) {
    if (rightAscii && !rightFr && left.isNotEmpty) return left;
    if (!leftFr && rightFr) return right;
  } else {
    if (rightAscii && !rightFr && leftFr) return right;
    if (leftAscii && !leftFr && rightFr) return left;
  }
  return t;
}

/// Resolves a string field that may be monolingual or legacy bilingual `{fr,en}`.
String resolveLocalizedField(
  dynamic raw, {
  required String preferredLocale,
}) {
  final lang = normalizeAppLanguage(preferredLocale);
  if (raw is String) {
    return sanitizeMonolingualTitle(raw.trim(), lang);
  }
  if (raw is Map) {
    final preferEn = lang == 'en';
    final primary = preferEn ? 'en' : 'fr';
    final secondary = preferEn ? 'fr' : 'en';
    final a = '${raw[primary] ?? ''}'.trim();
    if (a.isNotEmpty) return sanitizeMonolingualTitle(a, lang);
    return sanitizeMonolingualTitle('${raw[secondary] ?? ''}'.trim(), lang);
  }
  return '';
}

String _str(dynamic raw, {required String preferredLocale}) =>
    resolveLocalizedField(raw, preferredLocale: preferredLocale);

/// Personalized country lesson stored under `users/{uid}/aiLessons/{slotId}`.
/// Content is monolingual (`locale` = user language); awardable id = [slotId].
class AiCountryLesson {
  const AiCountryLesson({
    required this.slotId,
    required this.emoji,
    required this.title,
    required this.objective,
    required this.steps,
    required this.takeaways,
    this.topicId,
    this.theme,
    this.angle,
    this.locale = 'fr',
    this.personalized = true,
  });

  final String slotId;
  final String emoji;
  final String title;
  final String objective;
  final List<LessonStep> steps;
  final List<LText> takeaways;
  final String? topicId;
  final String? theme;
  final String? angle;
  final String locale;
  final bool personalized;

  String get id => slotId;

  factory AiCountryLesson.fromJson(
    String slotId,
    Map<String, dynamic> json, {
    String preferredLocale = 'fr',
  }) {
    final prefer = normalizeAppLanguage(preferredLocale);
    final steps = <LessonStep>[];
    final rawSteps = json['steps'];
    if (rawSteps is List) {
      for (final raw in rawSteps) {
        if (raw is! Map) continue;
        final map = Map<String, dynamic>.from(raw);
        final type = '${map['type'] ?? ''}';
        if (type == 'info') {
          final pointsRaw = map['points'];
          final points = <LText>[];
          if (pointsRaw is List) {
            for (final p in pointsRaw) {
              final text = _str(p, preferredLocale: prefer);
              if (text.isNotEmpty) points.add(_mono(text));
            }
          }
          steps.add(
            InfoStep(
              emoji: '${map['emoji'] ?? '📘'}',
              title: _mono(_str(map['title'], preferredLocale: prefer)),
              body: _mono(_str(map['body'], preferredLocale: prefer)),
              points: points,
            ),
          );
        } else if (type == 'quiz') {
          final choicesRaw = map['choices'];
          final choices = <LessonChoice>[];
          if (choicesRaw is List) {
            for (final c in choicesRaw) {
              if (c is! Map) continue;
              final label = _str(c['text'], preferredLocale: prefer).isNotEmpty
                  ? _str(c['text'], preferredLocale: prefer)
                  : _str(c, preferredLocale: prefer);
              if (label.isEmpty) continue;
              choices.add(
                LessonChoice(
                  fr: label,
                  en: label,
                  correct: c['correct'] == true,
                ),
              );
            }
          }
          if (choices.length >= 2) {
            steps.add(
              QuizStep(
                question: _mono(_str(map['question'], preferredLocale: prefer)),
                choices: choices,
                explanation:
                    _mono(_str(map['explanation'], preferredLocale: prefer)),
              ),
            );
          }
        } else if (type == 'trueFalse') {
          steps.add(
            TrueFalseStep(
              statement:
                  _mono(_str(map['statement'], preferredLocale: prefer)),
              answer: map['answer'] == true,
              explanation:
                  _mono(_str(map['explanation'], preferredLocale: prefer)),
            ),
          );
        }
      }
    }

    final takeaways = <LText>[];
    final rawTake = json['takeaways'];
    if (rawTake is List) {
      for (final t in rawTake) {
        final text = _str(t, preferredLocale: prefer);
        if (text.isNotEmpty) takeaways.add(_mono(text));
      }
    }

    final storedLocale = normalizeAppLanguage('${json['locale'] ?? prefer}');
    final title = sanitizeMonolingualTitle(
      _str(json['title'], preferredLocale: prefer),
      prefer,
    );
    return AiCountryLesson(
      slotId: (json['slotId'] as String?)?.trim().isNotEmpty == true
          ? (json['slotId'] as String).trim()
          : slotId,
      emoji: '${json['emoji'] ?? '🌍'}',
      title: title,
      objective: _str(json['objective'], preferredLocale: prefer),
      steps: steps,
      takeaways: takeaways,
      topicId: json['topicId'] as String?,
      theme: json['theme'] as String?,
      angle: json['angle'] as String?,
      locale: storedLocale,
      personalized: json['personalized'] != false,
    );
  }

  bool get isPlayable =>
      slotId.isNotEmpty &&
      title.isNotEmpty &&
      steps.length >= 2 &&
      steps.any((s) => s.isQuestion);

  CatalogLesson toCatalogLesson({CatalogLesson? fallback}) {
    final monoTitle = sanitizeMonolingualTitle(
      title.isNotEmpty ? title : (fallback?.titleFr ?? slotId),
      locale,
    );
    return CatalogLesson(
      id: slotId,
      emoji: emoji.isNotEmpty ? emoji : (fallback?.emoji ?? '🌍'),
      minutes: fallback?.minutes ?? 3,
      titleFr: monoTitle,
      titleEn: monoTitle,
      objective: objective.isNotEmpty
          ? _mono(objective)
          : (fallback?.objective ?? _mono(objective)),
      steps: steps.isNotEmpty ? steps : (fallback?.steps ?? const []),
      takeaways:
          takeaways.isNotEmpty ? takeaways : (fallback?.takeaways ?? const []),
    );
  }
}

/// Meta document `users/{uid}/aiLessonsMeta/state`.
class AiLessonsMeta {
  const AiLessonsMeta({
    this.lastTopicId,
    this.lastSlotId,
    this.recentTopicIds = const [],
  });

  final String? lastTopicId;
  final String? lastSlotId;
  final List<String> recentTopicIds;

  factory AiLessonsMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AiLessonsMeta();
    final recent = json['recentTopicIds'];
    return AiLessonsMeta(
      lastTopicId: json['lastTopicId'] as String?,
      lastSlotId: json['lastSlotId'] as String?,
      recentTopicIds: recent is List
          ? [
              for (final id in recent)
                if (id is String && id.isNotEmpty) id,
            ]
          : const [],
    );
  }
}

/// Prefer AI overlay when playable **and** matching the UI language.
CatalogLesson resolveCountryLesson(
  CatalogLesson slotPlaceholder,
  AiCountryLesson? ai, {
  String? uiLanguage,
}) {
  if (ai == null || !ai.isPlayable) return slotPlaceholder;
  if (uiLanguage != null &&
      uiLanguage.isNotEmpty &&
      !appLanguagesMatch(ai.locale, uiLanguage)) {
    return slotPlaceholder;
  }
  return ai.toCatalogLesson(fallback: slotPlaceholder);
}
