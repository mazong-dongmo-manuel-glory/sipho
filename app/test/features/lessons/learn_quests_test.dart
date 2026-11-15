import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/lessons/domain/learn_quests.dart';

void main() {
  test('builds core learning quests with accurate routes and progress', () {
    final quests = buildLearnQuests(
      languageCode: 'fr',
      completedLessonIds: const {'emergency_fund'},
      monthExpenseCount: 2,
      activeFixedCount: 1,
      hasMonthlyIncome: false,
    );

    expect(quests.length, 4);

    final firstLesson = quests.firstWhere((q) => q.id == 'learn_first_lesson');
    expect(firstLesson.isCompleted, isTrue);

    final unitMastery = quests.firstWhere((q) => q.id == 'learn_unit_mastery');
    expect(unitMastery.clampedProgress, 1);
    expect(unitMastery.safeTarget, 3);
    expect(unitMastery.actionRoute, '/lesson/needs_wants');

    final foundation =
        quests.firstWhere((q) => q.id == 'learn_build_foundation');
    expect(foundation.clampedProgress, 1);
    expect(foundation.safeTarget, 2);
    expect(foundation.actionRoute, '/profile');

    final tracking = quests.firstWhere((q) => q.id == 'learn_track_three');
    expect(tracking.clampedProgress, 2);
    expect(tracking.isCompleted, isFalse);
  });

  test('the unit quest follows the unit in progress', () {
    final quests = buildLearnQuests(
      languageCode: 'en',
      completedLessonIds: const {
        'emergency_fund',
        'needs_wants',
        'track_spending',
        'savings_goal',
      },
      monthExpenseCount: 0,
      activeFixedCount: 0,
      hasMonthlyIncome: false,
    );

    final unitMastery = quests.firstWhere((q) => q.id == 'learn_unit_mastery');
    expect(unitMastery.clampedProgress, 1);
    expect(unitMastery.safeTarget, 3);
    expect(unitMastery.subtitle, contains('Saving, one step at a time'));
    expect(unitMastery.actionRoute, '/lesson/pay_yourself_first');
  });

  test('prepends AI server quests and marks completed ones claimable', () {
    final quests = buildLearnQuests(
      languageCode: 'en',
      completedLessonIds: const {},
      monthExpenseCount: 3,
      activeFixedCount: 2,
      hasMonthlyIncome: true,
      serverQuests: const [
        ServerQuestRecord(
          id: 'q_ai_1',
          title: 'Track 3 purchases',
          description: 'Log 3 items this week',
          type: 'ADD_TRANSACTION',
          progress: 3,
          target: 3,
          rewardXp: 20,
          status: 'completed',
          isAiGenerated: true,
        ),
        ServerQuestRecord(
          id: 'q_claimed',
          title: 'Old claimed quest',
          description: 'Should be hidden',
          type: 'COMPLETE_LESSON',
          progress: 1,
          target: 1,
          rewardXp: 15,
          status: 'claimed',
          isAiGenerated: false,
        ),
      ],
    );

    expect(quests.first.id, 'server_q_ai_1');
    expect(quests.first.isAiCoach, isTrue);
    expect(quests.first.claimableOnServer, isTrue);
    expect(quests.first.rewardXp, 20);
    expect(quests.any((q) => q.id == 'server_q_claimed'), isFalse);
  });
}
