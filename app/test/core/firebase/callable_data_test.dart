import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/core/firebase/callable_data.dart';
import 'package:sipho/features/gamification/domain/quest_reward.dart';
import 'package:sipho/features/lessons/domain/lesson_result.dart';

void main() {
  group('callableDataMap', () {
    test('returns empty for null or non-map', () {
      expect(callableDataMap(null), isEmpty);
      expect(callableDataMap('x'), isEmpty);
      expect(callableDataMap(42), isEmpty);
    });

    test('keeps Map<String, dynamic> as-is', () {
      final input = <String, dynamic>{'xpGained': 10};
      expect(identical(callableDataMap(input), input), isTrue);
    });

    test('normalizes Map<Object?, Object?> from FlutterFire', () {
      final raw = <Object?, Object?>{'xpGained': 20, 'seedsGained': 5};
      final map = callableDataMap(raw);
      expect(map['xpGained'], 20);
      expect(map['seedsGained'], 5);
    });
  });

  test('LessonResult.fromCallable accepts FlutterFire-shaped maps', () {
    final raw = <Object?, Object?>{
      'xpGained': 15,
      'seedsGained': 3,
      'newStreak': 2,
      'levelUp': false,
      'newLevel': 1,
      'alreadyCompleted': false,
    };
    final result = LessonResult.fromCallable(
      callableDataMap(raw),
      accuracy: 100,
      durationSeconds: 40,
    );
    expect(result.xpGained, 15);
    expect(result.seedsGained, 3);
  });

  test('QuestReward.fromCallable accepts FlutterFire-shaped maps', () {
    final raw = <Object?, Object?>{
      'xpGained': 12,
      'gemsGained': 4,
      'levelUp': true,
      'alreadyClaimed': false,
    };
    final reward = QuestReward.fromCallable(callableDataMap(raw));
    expect(reward.xpGained, 12);
    expect(reward.gemsGained, 4);
    expect(reward.levelUp, isTrue);
  });
}
