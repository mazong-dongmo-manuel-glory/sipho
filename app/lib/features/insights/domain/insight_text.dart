import 'dart:convert';

class SpendSnapshot {
  const SpendSnapshot({
    required this.locale,
    required this.currency,
    required this.countryCode,
    required this.monthKey,
    required this.categoryCents,
    this.incomeCents = 0,
    this.fixedCents = 0,
    this.remainingCents,
    this.goal = '',
    this.focusTopic = 'general',
    this.completedLessonIds = const [],
  });

  final String locale;
  final String currency;
  final String countryCode;
  final String monthKey;
  final Map<String, int> categoryCents;
  final int incomeCents;
  final int fixedCents;
  final int? remainingCents;
  final String goal;
  final String focusTopic;
  final List<String> completedLessonIds;

  int get totalCents =>
      categoryCents.values.fold(0, (total, cents) => total + cents);

  bool get hasAnyFinancialData =>
      totalCents > 0 || fixedCents > 0 || incomeCents > 0;
}

class SuggestedCoachQuest {
  const SuggestedCoachQuest({
    required this.name,
    required this.description,
    required this.type,
    required this.target,
  });

  final String name;
  final String description;
  final String type; // ADD_TRANSACTION | COMPLETE_LESSON
  final int target;
}

class InsightText {
  const InsightText({
    required this.title,
    required this.body,
    this.id,
    this.actionStep = '',
    this.recommendedLessonId = 'track_spending',
    this.suggestedQuest,
    this.focusTopic = 'general',
    this.locale = '',
    this.createdAt,
  });

  final String? id;
  final String title;
  final String body;
  final String actionStep;
  final String recommendedLessonId;
  final SuggestedCoachQuest? suggestedQuest;
  final String focusTopic;
  /// Language the insight was generated in (`fr`|`en`), when known.
  final String locale;
  final DateTime? createdAt;

  static const validLessonIds = [
    'emergency_fund',
    'needs_wants',
    'track_spending',
  ];
}

/// Builds the prompt from the user's own totals. The model is instructed to cite
/// ONLY those integer cents and never invent rates, taxes, or financial products.
String buildInsightPrompt(SpendSnapshot snapshot) {
  final language = snapshot.locale.startsWith('fr') ? 'French' : 'English';
  final lines = snapshot.categoryCents.isEmpty
      ? 'none yet'
      : snapshot.categoryCents.entries
          .map((entry) => '${entry.key}: ${entry.value} cents')
          .join('\n');
  final income =
      snapshot.incomeCents > 0 ? '${snapshot.incomeCents} cents' : 'not set';
  final remaining = snapshot.remainingCents == null
      ? 'unknown'
      : '${snapshot.remainingCents} cents';
  final nextLesson = InsightText.validLessonIds.firstWhere(
    (id) => !snapshot.completedLessonIds.contains(id),
    orElse: () => 'track_spending',
  );
  final goalLine = snapshot.goal.isEmpty ? 'general_balance' : snapshot.goal;

  return '''
You are Sipho, a warm educational money coach. Reply in $language.
Use only the integers below (100 cents = 1 ${snapshot.currency}).
Do not invent a rate, a tax, a price, or a product.
Do not name a bank, a fund, or a specific financial product.
This is educational, not personalized financial, tax, or investment advice.
Country code: ${snapshot.countryCode}
Currency: ${snapshot.currency}
Month: ${snapshot.monthKey}
Main goal: $goalLine
Requested focus: ${snapshot.focusTopic}
Monthly net income: $income
Fixed monthly base: ${snapshot.fixedCents} cents
Spent this month, by category, in integer cents:
$lines
Total spent: ${snapshot.totalCents} cents
Money left after income and bills: $remaining
Write 2-3 warm, clear sentences about these real numbers, plus 1 concrete habit for this week.
Respond with JSON only:
{
  "title": "...",
  "body": "...",
  "actionStep": "...",
  "recommendedLessonId": "$nextLesson",
  "suggestedQuest": {
    "name": "...",
    "description": "...",
    "type": "ADD_TRANSACTION",
    "target": 3
  }
}
''';
}

InsightText? parseInsightText(String raw) {
  final start = raw.indexOf('{');
  final end = raw.lastIndexOf('}');
  if (start < 0 || end <= start) return null;
  try {
    final decoded = jsonDecode(raw.substring(start, end + 1));
    if (decoded is! Map) return null;
    return parseInsightMap(Map<String, dynamic>.from(decoded));
  } catch (_) {
    return null;
  }
}

InsightText? parseInsightMap(
  Map<String, dynamic> decoded, {
  String? id,
  DateTime? createdAt,
}) {
  final rawBody = decoded['body'] ?? decoded['content'];
  if (rawBody is! String || rawBody.trim().isEmpty) return null;

  final title = decoded['title'];
  final actionStep = decoded['actionStep'];
  final rawLesson = decoded['recommendedLessonId'];
  final lessonId =
      rawLesson is String && InsightText.validLessonIds.contains(rawLesson)
          ? rawLesson
          : 'track_spending';
  final topic = decoded['focusTopic'];

  SuggestedCoachQuest? quest;
  final rawQuest = decoded['suggestedQuest'] ??
      ((decoded['questSuggestions'] is List &&
              (decoded['questSuggestions'] as List).isNotEmpty)
          ? (decoded['questSuggestions'] as List).first
          : null);
  if (rawQuest is Map) {
    final qName = rawQuest['name'];
    final qDesc = rawQuest['description'];
    final qType = rawQuest['type'];
    final qTarget = rawQuest['target'];
    if (qName is String && qName.trim().isNotEmpty) {
      quest = SuggestedCoachQuest(
        name: qName.trim(),
        description: qDesc is String ? qDesc.trim() : '',
        type:
            qType == 'COMPLETE_LESSON' ? 'COMPLETE_LESSON' : 'ADD_TRANSACTION',
        target: qTarget is num ? qTarget.toInt().clamp(1, 14) : 3,
      );
    }
  }

  final localeRaw = decoded['locale'];
  final locale = localeRaw is String
      ? (localeRaw.toLowerCase().startsWith('fr') ? 'fr' : 'en')
      : '';

  return InsightText(
    id: id ?? (decoded['id'] is String ? decoded['id'] as String : null),
    title: title is String ? title.trim() : '',
    body: rawBody.trim(),
    actionStep: actionStep is String ? actionStep.trim() : '',
    recommendedLessonId: lessonId,
    suggestedQuest: quest,
    focusTopic:
        topic is String && topic.trim().isNotEmpty ? topic.trim() : 'general',
    locale: locale,
    createdAt: createdAt,
  );
}
