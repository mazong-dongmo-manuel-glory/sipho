/// Unified in-app engagement surface (coach hourly, AI advice, soft nudges).
class EngagementPopup {
  const EngagementPopup({
    required this.id,
    required this.emoji,
    required this.title,
    required this.body,
    required this.source,
    this.ctaRoute,
    this.ctaLabelKey,
    this.educationStageId,
    this.educationScore,
  });

  /// Stable id for dedupe (`coach:…`, `advice:…`, `soft:…`).
  final String id;
  final String emoji;
  final String title;
  final String body;

  /// `coach` | `advice` | `soft`
  final String source;

  final String? ctaRoute;

  /// Optional ARB key hint: `log` | `insights` | `learn` | `goals` | `quests`
  final String? ctaLabelKey;

  final String? educationStageId;
  final int? educationScore;

  bool get isCoach => source == 'coach';
  bool get isAdvice => source == 'advice';
  bool get isSoft => source == 'soft';
}
