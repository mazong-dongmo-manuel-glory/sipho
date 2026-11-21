import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/goals/domain/goal.dart';

void main() {
  group('Goal domain model', () {
    test('calculates progress and completion correctly', () {
      final goal = Goal(
        id: 'g1',
        title: 'Voyage',
        targetCents: 300000, // 3 000 $
        savedCents: 120000, // 1 200 $
        createdAt: DateTime(2026, 11, 1),
      );

      expect(goal.progress, closeTo(0.40, 0.001));
      expect(goal.remainingCents, 180000);
      expect(goal.isCompleted, isFalse);

      final completedGoal = goal.copyWith(savedCents: 300000);
      expect(completedGoal.progress, 1.0);
      expect(completedGoal.remainingCents, 0);
      expect(completedGoal.isCompleted, isTrue);

      final overCompletedGoal = goal.copyWith(savedCents: 350000);
      expect(overCompletedGoal.progress, 1.0); // clamped
      expect(overCompletedGoal.remainingCents, 0);
      expect(overCompletedGoal.isCompleted, isTrue);
    });

    test('handles zero target gracefully', () {
      final zeroTarget = Goal(
        id: 'g2',
        title: 'Zero',
        targetCents: 0,
        savedCents: 0,
        createdAt: DateTime(2026, 11, 1),
      );

      expect(zeroTarget.progress, 0.0);
      expect(zeroTarget.remainingCents, 0);
      expect(zeroTarget.isCompleted, isFalse);
    });

    test('serializes and deserializes from JSON', () {
      final now = DateTime(2026, 11, 18, 12, 0);
      final goal = Goal(
        id: 'g3',
        title: 'Fonds d\'urgence',
        targetCents: 500000,
        savedCents: 250000,
        deadline: '2027-01-01',
        emoji: '🛡️',
        createdAt: now,
      );

      final json = goal.toJson();
      expect(json['id'], 'g3');
      expect(json['title'], 'Fonds d\'urgence');
      expect(json['targetCents'], 500000);
      expect(json['savedCents'], 250000);
      expect(json['deadline'], '2027-01-01');
      expect(json['emoji'], '🛡️');

      final restored = Goal.fromJson(json);
      expect(restored.id, goal.id);
      expect(restored.title, goal.title);
      expect(restored.targetCents, goal.targetCents);
      expect(restored.savedCents, goal.savedCents);
      expect(restored.emoji, '🛡️');
      expect(restored.deadline, '2027-01-01');
    });
  });
}
