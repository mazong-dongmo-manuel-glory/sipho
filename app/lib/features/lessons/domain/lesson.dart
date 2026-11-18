class LessonStep {
  const LessonStep({
    required this.type,
    this.siphoEmotion,
    required this.text,
    this.question,
    this.options,
    this.explanation,
  });

  final String type; // story | quiz | simulation
  final String? siphoEmotion;
  final Map<String, String> text;
  final Map<String, String>? question;
  final List<Map<String, dynamic>>? options;
  final Map<String, String>? explanation;

  factory LessonStep.fromJson(Map<String, dynamic> json) => LessonStep(
        type: json['type'] as String? ?? 'story',
        siphoEmotion: json['siphoEmotion'] as String?,
        text: _stringMap(json['text']),
        question: json['question'] == null ? null : _stringMap(json['question']),
        options: (json['options'] as List?)
            ?.whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
        explanation:
            json['explanation'] == null ? null : _stringMap(json['explanation']),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'siphoEmotion': siphoEmotion,
        'text': text,
        'question': question,
        'options': options,
        'explanation': explanation,
      };
}

class Lesson {
  const Lesson({
    required this.id,
    required this.unit,
    required this.order,
    required this.countries,
    required this.title,
    required this.steps,
    this.rewardXp = 20,
    this.rewardGems = 5,
    this.version = 1,
  });

  final String id;
  final int unit;
  final int order;
  final List<String> countries;
  final Map<String, String> title;
  final List<LessonStep> steps;
  final int rewardXp;
  final int rewardGems;
  final int version;

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String? ?? '',
        unit: (json['unit'] as num?)?.toInt() ?? 1,
        order: (json['order'] as num?)?.toInt() ?? 0,
        countries: (json['countries'] as List?)?.map((e) => '$e').toList() ??
            const ['*'],
        title: _stringMap(json['title']),
        steps: (json['steps'] as List?)
                ?.whereType<Map>()
                .map((e) => LessonStep.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            const [],
        rewardXp: (json['rewardXp'] as num?)?.toInt() ?? 20,
        rewardGems: (json['rewardGems'] as num?)?.toInt() ?? 5,
        version: (json['version'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'unit': unit,
        'order': order,
        'countries': countries,
        'title': title,
        'steps': [for (final s in steps) s.toJson()],
        'rewardXp': rewardXp,
        'rewardGems': rewardGems,
        'version': version,
      };
}

Map<String, String> _stringMap(dynamic raw) {
  if (raw is! Map) return {};
  return {
    for (final entry in raw.entries) entry.key.toString(): '${entry.value}',
  };
}
