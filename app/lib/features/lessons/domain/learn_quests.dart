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
  required String languageCode,
  required Set<String> completedLessonIds,
  required int monthExpenseCount,
  required int activeFixedCount,
  required bool hasMonthlyIncome,
  List<ServerQuestRecord> serverQuests = const [],
}) {
  final isFr = languageCode.toLowerCase().startsWith('fr');
  final catalogIds = [for (final lesson in kCatalogLessons) lesson.id];
  final nextId =
      nextLessonId(catalogIds, completedLessonIds) ?? catalogIds.first;
  final completedCount = completedLessonIds.where(catalogIds.contains).length;

  final items = <LearnQuestItem>[
    // 1. Next lesson quest
    LearnQuestItem(
      id: 'learn_first_lesson',
      emoji: '📚',
      title: isFr ? 'Valider une leçon' : 'Complete a lesson',
      subtitle: isFr
          ? 'Réponds juste au quiz pour débloquer la suite'
          : 'Answer the quiz right to unlock the next step',
      progress: completedCount >= 1 ? 1 : 0,
      target: 1,
      actionRoute: '/lesson/$nextId',
    ),
    // 2. Unit mastery quest (all 3 lessons)
    LearnQuestItem(
      id: 'learn_unit_mastery',
      emoji: '🎓',
      title: isFr
          ? 'Terminer l\'unité (${kCatalogLessons.length} leçons)'
          : 'Finish the unit (${kCatalogLessons.length} lessons)',
      subtitle: isFr
          ? 'Fonds d\'urgence, besoins/envies et suivi'
          : 'Emergency fund, needs vs wants, and tracking',
      progress: completedCount,
      target: kCatalogLessons.length,
      actionRoute: '/lesson/$nextId',
    ),
    // 3. Real-life application: set up income + 1 fixed strand
    LearnQuestItem(
      id: 'learn_build_foundation',
      emoji: '🪺',
      title: isFr ? 'Poser ton socle du mois' : 'Set up your monthly base',
      subtitle: isFr
          ? 'Indique ton revenu et au moins 1 charge fixe'
          : 'Set your income and at least 1 fixed bill',
      progress: (hasMonthlyIncome ? 1 : 0) + (activeFixedCount > 0 ? 1 : 0),
      target: 2,
      actionRoute: !hasMonthlyIncome ? '/profile' : '/fixed-expenses',
    ),
    // 4. Real-life habit: log 3 expenses this month
    LearnQuestItem(
      id: 'learn_track_three',
      emoji: '✍️',
      title: isFr ? 'Noter 3 dépenses ce mois-ci' : 'Log 3 expenses this month',
      subtitle: isFr
          ? 'Mets en pratique la leçon sur le suivi'
          : 'Put the spending tracking lesson into practice',
      progress: monthExpenseCount,
      target: 3,
      actionRoute: '/expenses/add',
    ),
  ];

  // Append server / AI coach quests (claimable via `claimQuest` Cloud Function)
  for (final sq in serverQuests) {
    if (sq.status == 'claimed') continue;
    final route =
        sq.type == 'COMPLETE_LESSON' ? '/lesson/$nextId' : '/expenses/add';
    final fallbackTitle = sq.type == 'COMPLETE_LESSON'
        ? (isFr ? 'Défi leçon' : 'Lesson challenge')
        : (isFr ? 'Défi suivi' : 'Tracking challenge');
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
            : (isFr
                ? 'Défi personnalisé Sipho'
                : 'Personalized Sipho challenge'),
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
