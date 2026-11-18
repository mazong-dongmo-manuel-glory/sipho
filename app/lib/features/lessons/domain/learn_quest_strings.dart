import 'package:sipho/app/l10n/app_localizations.dart';

/// Localized copy for Learn-tab quests (ARB-backed — no hardcoded FR/EN in domain).
class LearnQuestStrings {
  LearnQuestStrings({
    required this.completeLessonTitle,
    required this.completeLessonSubtitle,
    required this.finishUnitTitle,
    required this.finishUnitSubtitle,
    required this.buildFoundationTitle,
    required this.buildFoundationSubtitle,
    required this.trackThreeTitle,
    required this.trackThreeSubtitle,
    required this.lessonChallengeFallback,
    required this.trackingChallengeFallback,
    required this.personalizedChallengeFallback,
  });

  final String completeLessonTitle;
  final String completeLessonSubtitle;
  final String Function(int lessonCount) finishUnitTitle;
  final String Function(String unitTitle, int bonusXp) finishUnitSubtitle;
  final String buildFoundationTitle;
  final String buildFoundationSubtitle;
  final String trackThreeTitle;
  final String trackThreeSubtitle;
  final String lessonChallengeFallback;
  final String trackingChallengeFallback;
  final String personalizedChallengeFallback;

  factory LearnQuestStrings.fromL10n(AppLocalizations l10n) {
    return LearnQuestStrings(
      completeLessonTitle: l10n.learnQuestCompleteLesson,
      completeLessonSubtitle: l10n.learnQuestCompleteLessonSub,
      finishUnitTitle: l10n.learnQuestFinishUnit,
      finishUnitSubtitle: l10n.learnQuestFinishUnitSub,
      buildFoundationTitle: l10n.learnQuestBuildFoundation,
      buildFoundationSubtitle: l10n.learnQuestBuildFoundationSub,
      trackThreeTitle: l10n.learnQuestTrackThree,
      trackThreeSubtitle: l10n.learnQuestTrackThreeSub,
      lessonChallengeFallback: l10n.learnQuestLessonChallenge,
      trackingChallengeFallback: l10n.learnQuestTrackingChallenge,
      personalizedChallengeFallback: l10n.learnQuestPersonalized,
    );
  }
}
