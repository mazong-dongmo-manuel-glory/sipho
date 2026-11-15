import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/core/time/local_day.dart';

void main() {
  // Noon UTC keeps the calendar date stable for almost every timezone; the
  // expectations are still derived from `toLocal()` so the test never depends
  // on the machine's timezone.
  LocalDay at(int y, int m, int d) =>
      LocalDay.fromUtc(DateTime.utc(y, m, d, 12));

  group('LocalDay', () {
    test('formats ISO day and month with zero padding', () {
      final day = at(2026, 3, 5);
      final local = DateTime.utc(2026, 3, 5, 12).toLocal();
      String two(int n) => n.toString().padLeft(2, '0');
      expect(
          day.isoDate, '${local.year}-${two(local.month)}-${two(local.day)}');
      expect(day.isoMonth, '${local.year}-${two(local.month)}');
      expect(day.toString(), day.isoDate);
    });

    test('start and end of day cover the whole local day', () {
      final day = at(2026, 11, 14);
      expect(day.startOfDay.hour, 0);
      expect(day.startOfDay.minute, 0);
      expect(day.endOfDay.hour, 23);
      expect(day.endOfDay.minute, 59);
      expect(day.endOfDay.isAfter(day.startOfDay), isTrue);
      expect(day.endOfDay.difference(day.startOfDay).inHours, lessThan(25));
    });

    test('month boundaries: first of the month and first of the next month',
        () {
      final day = at(2026, 11, 14);
      expect(day.startOfMonth.day, 1);
      expect(day.startOfNextMonth.day, 1);
      expect(day.startOfNextMonth.isAfter(day.startOfMonth), isTrue);
    });

    test('the next month rolls over to January of the next year', () {
      final day = at(2026, 12, 15);
      final next = day.startOfNextMonth;
      expect(next.month, 1);
      expect(next.year, day.year + 1);
    });

    test('isSameDay compares calendar days, not instants', () {
      final day = at(2026, 11, 14);
      expect(day.isSameDay(day.startOfDay), isTrue);
      expect(day.isSameDay(day.endOfDay), isTrue);
      expect(
          day.isSameDay(day.endOfDay.add(const Duration(hours: 2))), isFalse);
      expect(day.isSameDay(day.startOfDay.subtract(const Duration(hours: 2))),
          isFalse);
    });

    test('weekday follows DateTime (1 = Monday … 7 = Sunday)', () {
      final day = at(2026, 11, 14);
      expect(day.weekday, day.startOfDay.weekday);
      expect(day.weekday, inInclusiveRange(1, 7));
    });

    test('now() is today', () {
      expect(LocalDay.now().isSameDay(DateTime.now()), isTrue);
    });
  });
}
