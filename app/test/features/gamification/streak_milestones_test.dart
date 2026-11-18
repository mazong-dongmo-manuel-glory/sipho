import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/gamification/domain/streak_milestones.dart';

void main() {
  test('milestones unlock at the documented thresholds', () {
    expect(streakMilestoneReached(2, 3), isFalse);
    expect(streakMilestoneReached(3, 3), isTrue);
    expect(streakMilestoneReached(7, 7), isTrue);
    expect(streakMilestoneReached(29, 30), isFalse);
  });

  test('repair is offered only within 24 h with a freeze and a broken streak', () {
    final now = DateTime.utc(2026, 11, 17, 12);
    expect(
      canOfferStreakRepair(
        brokenAt: now.subtract(const Duration(hours: 2)).toIso8601String(),
        brokenCurrent: 5,
        freezes: 1,
        now: now,
      ),
      isTrue,
    );
    expect(
      canOfferStreakRepair(
        brokenAt: now.subtract(const Duration(hours: 25)).toIso8601String(),
        brokenCurrent: 5,
        freezes: 1,
        now: now,
      ),
      isFalse,
    );
    expect(
      canOfferStreakRepair(
        brokenAt: now.subtract(const Duration(hours: 1)).toIso8601String(),
        brokenCurrent: 5,
        freezes: 0,
        now: now,
      ),
      isFalse,
    );
  });
}
