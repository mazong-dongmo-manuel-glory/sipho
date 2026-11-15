import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/gamification/domain/streak_week.dart';

void main() {
  // Wednesday 2026-11-11 → week is Mon 2026-11-09 … Sun 2026-11-15.
  final wednesday = DateTime(2026, 11, 11);

  group('streakWeekMarks', () {
    test('no streak or no last active day marks nothing', () {
      const none = [false, false, false, false, false, false, false];
      expect(
        streakWeekMarks(lastActiveDay: null, current: 5, today: wednesday),
        none,
      );
      expect(
        streakWeekMarks(
            lastActiveDay: '2026-11-11', current: 0, today: wednesday),
        none,
      );
    });

    test('a streak ending today inside the week marks its days only', () {
      expect(
        streakWeekMarks(
            lastActiveDay: '2026-11-11', current: 2, today: wednesday),
        [false, true, true, false, false, false, false],
      );
    });

    test('a long streak fills the days from Monday up to the last active day',
        () {
      expect(
        streakWeekMarks(
            lastActiveDay: '2026-11-11', current: 40, today: wednesday),
        [true, true, true, false, false, false, false],
      );
    });

    test('a streak last active yesterday does not mark today', () {
      expect(
        streakWeekMarks(
            lastActiveDay: '2026-11-10', current: 3, today: wednesday),
        [true, true, false, false, false, false, false],
      );
    });

    test('a streak that ended before this week marks nothing', () {
      expect(
        streakWeekMarks(
            lastActiveDay: '2026-11-08', current: 9, today: wednesday),
        List<bool>.filled(7, false),
      );
    });

    test('works across month and year boundaries', () {
      // Friday 2027-01-01 → week is Mon 2026-12-28 … Sun 2027-01-03.
      expect(
        streakWeekMarks(
            lastActiveDay: '2027-01-01',
            current: 4,
            today: DateTime(2027, 1, 1)),
        [false, true, true, true, true, false, false],
      );
    });

    test('is not shifted by daylight saving changes', () {
      // Montreal DST ended on Sunday 2026-11-01; the week starts Mon 2026-10-26.
      expect(
        streakWeekMarks(
            lastActiveDay: '2026-11-01',
            current: 7,
            today: DateTime(2026, 11, 1)),
        List<bool>.filled(7, true),
      );
    });

    test('malformed or impossible dates are ignored', () {
      final none = List<bool>.filled(7, false);
      for (final bad in ['11/11/2026', '2026-11-1', '2026-02-31', '', 'x']) {
        expect(
          streakWeekMarks(lastActiveDay: bad, current: 3, today: wednesday),
          none,
          reason: bad,
        );
      }
    });
  });
}
