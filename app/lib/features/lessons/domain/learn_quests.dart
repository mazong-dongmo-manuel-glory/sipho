import 'package:sipho/features/lessons/domain/learn_quest_strings.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';

class ServerQuestRecord {
  const ServerQuestRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.progress,
    required this.target,
    required this.rewardXp,
    required this.status,
    required this.isAiGenerated,
    this.period = '',
  });

  final String id;
  final String title;
  final String description;
  final String type;
  final int progress;
  final int target;
  final int rewardXp;
  final String status; // active | completed | claimed
  final bool isAiGenerated;

  /// `daily` for quests renewed every local day by the server; empty otherwise.
  final String period;
}

/// Maximum number of daily quests the Home tab shows (README: 3 per day).
const int kHomeMaxDailyQuests = 3;

/// The server-issued quests to show on Home: today's daily quests, plus a
/// catch-up quest when one is active. Claimed and expired rows are hidden.
List<ServerQuestRecord> dailyQuestsForHome(List<ServerQuestRecord> quests) {
  bool visible(ServerQuestRecord q) =>
      q.status != 'claimed' && q.status != 'expired';
  final catchup = [
    for (final q in quests)
      if (q.period == 'catchup' && visible(q)) q,
  ];
  final daily = [
    for (final q in quests)
      if (q.period == 'daily' && visible(q)) q,
  ];
  bool done(ServerQuestRecord q) =>
      q.status == 'completed' || q.progress >= q.target;
  // List.sort is not stable, so tie-break on the original index.
  final indexed = [for (var i = 0; i < daily.length; i++) (i, daily[i])];
  indexed.sort((a, b) {
    final byDone = (done(a.$2) ? 1 : 0).compareTo(done(b.$2) ? 1 : 0);
    return byDone != 0 ? byDone : a.$1.compareTo(b.$1);
  });
  final orderedDaily = [for (final e in indexed) e.$2];
  return [...catchup, ...orderedDaily].take(kHomeMaxDailyQuests).toList();
}

/// Where tapping a quest row on Home leads.
///
/// A finished quest (and any lesson quest) goes to the Learn tab, where the reward is claimed and
/// the next lesson is offered; a tracking quest goes straight to the add-expense form.
String homeQuestRoute(ServerQuestRecord quest) {
  final done = quest.status == 'completed' || quest.progress >= quest.target;
  if (done || quest.type == 'COMPLETE_LESSON') return '/learn';
  return '/expenses/add';
}

class LearnQuestItem {
  const LearnQuestItem({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.target,
    required this.actionRoute,
    this.rewardXp,
    this.serverQuestId,
    this.claimableOnServer = false,
    this.isAiCoach = false,
  });

  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final int progress;
  final int target;
  final String actionRoute;
  final int? rewardXp;
  final String? serverQuestId;
  final bool claimableOnServer;
  final bool isAiCoach;

  int get safeTarget => target <= 0 ? 1 : target;

  int get clampedProgress => progress.clamp(0, safeTarget);

  bool get isCompleted => clampedProgress >= safeTarget;

  double get ratio => (clampedProgress / safeTarget).clamp(0.0, 1.0);
}

/// Builds the quests displayed on the Learn tab from real user progress and
/// any active/completed server quests (including AI coach challenges).
List<LearnQuestItem> buildLearnQuests({
  required LearnQuestStrings strings,
  required String languageCode,
  required Set<String> completedLessonIds,
  required int monthExpenseCount,
  required int activeFixedCount,
  required bool hasMonthlyIncome,
  List<ServerQuestRecord> serverQuests = const [],
}) {
  final catalogIds = [for (final lesson in kCatalogLessons) lesson.id];
  final nextId =
      nextLessonId(catalogIds, completedLessonIds) ?? catalogIds.first;
  final completedCount = completedLessonIds.where(catalogIds.contains).length;
  // The unit in progress (or the last one once the whole path is done).
  final unit = (currentUnit(kCatalogUnits, completedLessonIds) ??
          unitProgressList(kCatalogUnits, completedLessonIds).last)
      .unit;
  final unitDone =
      unit.lessons.where((l) => completedLessonIds.contains(l.id)).length;
  final unitTitle = unit.title(languageCode);

  final items = <LearnQuestItem>[
    LearnQuestItem(
      id: 'learn_first_lesson',
      emoji: '📚',
      title: strings.completeLessonTitle,
      subtitle: strings.completeLessonSubtitle,
      progress: completedCount >= 1 ? 1 : 0,
      target: 1,
      actionRoute: '/lesson/$nextId',
    ),
    LearnQuestItem(
      id: 'learn_unit_mastery',
      emoji: '🎓',
      title: strings.finishUnitTitle(unit.lessons.length),
      subtitle: strings.finishUnitSubtitle(unitTitle, unit.bonusXp),
      progress: unitDone,
      target: unit.lessons.length,
      actionRoute: '/lesson/$nextId',
    ),
    LearnQuestItem(
      id: 'learn_build_foundation',
      emoji: '🪺',
      title: strings.buildFoundationTitle,
      subtitle: strings.buildFoundationSubtitle,
      progress: (hasMonthlyIncome ? 1 : 0) + (activeFixedCount > 0 ? 1 : 0),
      target: 2,
      actionRoute: !hasMonthlyIncome ? '/profile' : '/fixed-expenses',
    ),
    LearnQuestItem(
      id: 'learn_track_three',
      emoji: '✍️',
      title: strings.trackThreeTitle,
      subtitle: strings.trackThreeSubtitle,
      progress: monthExpenseCount,
      target: 3,
      actionRoute: '/expenses/add',
    ),
  ];

  for (final sq in serverQuests) {
    if (sq.status == 'claimed') continue;
    final route =
        sq.type == 'COMPLETE_LESSON' ? '/lesson/$nextId' : '/expenses/add';
    final fallbackTitle = sq.type == 'COMPLETE_LESSON'
        ? strings.lessonChallengeFallback
        : strings.trackingChallengeFallback;
    final cleanTitle =
        sq.title.trim().isNotEmpty ? sq.title.trim() : fallbackTitle;
    final done = sq.status == 'completed' || sq.progress >= sq.target;
    final canClaimOnServer = done && sq.id != 'local_ai_coach';

    items.insert(
      0,
      LearnQuestItem(
        id: 'server_${sq.id}',
        emoji: sq.isAiGenerated ? '✨' : '🎯',
        title: cleanTitle,
        subtitle: sq.description.trim().isNotEmpty
            ? sq.description.trim()
            : strings.personalizedChallengeFallback,
        progress: done ? sq.target : sq.progress,
        target: sq.target,
        rewardXp: sq.rewardXp > 0 ? sq.rewardXp : null,
        serverQuestId: canClaimOnServer ? sq.id : null,
        claimableOnServer: canClaimOnServer,
        isAiCoach: sq.isAiGenerated,
        actionRoute: route,
      ),
    );
  }

  return items;
}
