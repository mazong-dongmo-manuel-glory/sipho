import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/lessons/domain/learn_quests.dart';

ServerQuestRecord _quest(
  String id, {
  String period = 'daily',
  String status = 'active',
  int progress = 0,
  int target = 3,
  String type = 'ADD_TRANSACTION',
}) =>
    ServerQuestRecord(
      id: id,
      title: id,
      description: '',
      type: type,
      progress: progress,
      target: target,
      rewardXp: 15,
      status: status,
      isAiGenerated: false,
      period: period,
    );

void main() {
  group('dailyQuestsForHome', () {
    test('keeps only daily quests that are neither claimed nor expired', () {
      final result = dailyQuestsForHome([
        _quest('a'),
        _quest('weekly', period: 'weekly'),
        _quest('ai', period: ''),
        _quest('claimed', status: 'claimed'),
        _quest('expired', status: 'expired'),
        _quest('done', status: 'completed', progress: 3),
      ]);
      expect(result.map((q) => q.id), ['a', 'done']);
    });

    test('unfinished quests come first and the original order is kept', () {
      final result = dailyQuestsForHome([
        _quest('done1', status: 'completed', progress: 3),
        _quest('todo1'),
        _quest('done2', progress: 3),
        _quest('todo2', progress: 1),
      ]);
      expect(result.map((q) => q.id), ['todo1', 'todo2', 'done1']);
    });

    test('shows at most $kHomeMaxDailyQuests quests', () {
      final result = dailyQuestsForHome([
        for (var i = 0; i < 6; i++) _quest('q$i'),
      ]);
      expect(result, hasLength(kHomeMaxDailyQuests));
    });

    test('no server quest means nothing is shown (no invented progress)', () {
      expect(dailyQuestsForHome(const []), isEmpty);
    });

    test('the lesson quest and the expense quest are both shown', () {
      final result = dailyQuestsForHome([
        _quest('log', type: 'ADD_TRANSACTION'),
        _quest('lesson', type: 'COMPLETE_LESSON', target: 1),
      ]);
      expect(result.map((q) => q.id), ['log', 'lesson']);
    });
  });

  group('homeQuestRoute', () {
    test('an unfinished expense quest opens the add-expense form', () {
      expect(homeQuestRoute(_quest('log')), '/expenses/add');
    });

    test('a lesson quest opens the Learn tab', () {
      expect(
        homeQuestRoute(_quest('lesson', type: 'COMPLETE_LESSON', target: 1)),
        '/learn',
      );
    });

    test('a finished quest opens the Learn tab where it is claimed', () {
      expect(
        homeQuestRoute(_quest('log', status: 'completed', progress: 3)),
        '/learn',
      );
      expect(homeQuestRoute(_quest('log', progress: 3)), '/learn');
    });
  });
}
