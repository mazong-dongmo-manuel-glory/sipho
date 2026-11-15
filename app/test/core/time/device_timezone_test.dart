import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/core/time/device_timezone.dart';
import 'package:sipho/features/notifications/data/notification_service.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('readDeviceTimezone', () {
    test('keeps the IANA id and the offset in MINUTES (half-hour zones)', () async {
      // India is UTC+5:30: storing whole hours would turn that into 5.
      final india = await readDeviceTimezone(
        idProvider: () async => 'Asia/Kolkata',
        now: _FixedOffsetDate(const Duration(hours: 5, minutes: 30)),
      );
      expect(india.id, 'Asia/Kolkata');
      expect(india.utcOffsetMinutes, 330);
      expect(india.toProfileFields(),
          {'timezone': 'Asia/Kolkata', 'utcOffsetMinutes': 330});

      final nepal = await readDeviceTimezone(
        idProvider: () async => 'Asia/Kathmandu',
        now: _FixedOffsetDate(const Duration(hours: 5, minutes: 45)),
      );
      expect(nepal.utcOffsetMinutes, 345);
    });

    test('negative half-hour offsets (Newfoundland)', () async {
      final tzInfo = await readDeviceTimezone(
        idProvider: () async => 'America/St_Johns',
        now: _FixedOffsetDate(const Duration(hours: -3, minutes: -30)),
      );
      expect(tzInfo.utcOffsetMinutes, -210);
    });

    test('an unusable id never overwrites a stored one, and creation gets a sentinel', () async {
      final abbreviation = await readDeviceTimezone(
        idProvider: () async => 'EST',
        now: _FixedOffsetDate(const Duration(hours: -5)),
      );
      expect(abbreviation.id, isNull);
      expect(abbreviation.toProfileFields().containsKey('timezone'), isFalse);
      expect(abbreviation.toCreateFields()['timezone'], kUnknownTimezone);

      final failing = await readDeviceTimezone(
        idProvider: () async => throw Exception('no platform'),
        now: _FixedOffsetDate(Duration.zero),
      );
      expect(failing.id, isNull);
      expect(failing.utcOffsetMinutes, 0);
    });

    test('plausible ids', () {
      expect(isPlausibleIanaId('Europe/Paris'), isTrue);
      expect(isPlausibleIanaId('UTC'), isTrue);
      expect(isPlausibleIanaId('CET'), isFalse);
      expect(isPlausibleIanaId(''), isFalse);
      expect(isPlausibleIanaId(null), isFalse);
    });
  });

  group('nextLocalHour (daily reminder)', () {
    test('stays at 19:00 wall-clock across a daylight-saving change', () {
      final toronto = tz.getLocation('America/Toronto');
      // Before the 2026-03-08 spring-forward: 19:00 EST = 00:00Z.
      final before = nextLocalHour(
        toronto,
        tz.TZDateTime(toronto, 2026, 3, 7, 12),
        19,
      );
      expect(before.hour, 19);
      expect(before.toUtc().hour, 0);
      // After it: 19:00 EDT = 23:00Z. A fixed offset would still say 00:00Z (20:00 local).
      final after = nextLocalHour(
        toronto,
        tz.TZDateTime(toronto, 2026, 3, 9, 12),
        19,
      );
      expect(after.hour, 19);
      expect(after.toUtc().hour, 23);
    });

    test('rolls to tomorrow once 19:00 has passed, and handles half-hour zones', () {
      final kolkata = tz.getLocation('Asia/Kolkata');
      final next = nextLocalHour(
        kolkata,
        tz.TZDateTime(kolkata, 2026, 11, 14, 19, 30),
        19,
      );
      expect(next.day, 15);
      expect(next.hour, 19);
      expect(next.toUtc().hour, 13);
      expect(next.toUtc().minute, 30);
    });
  });
}

/// A [DateTime] whose `timeZoneOffset` is fixed, to simulate any device zone in tests.
class _FixedOffsetDate implements DateTime {
  _FixedOffsetDate(this._offset);

  final Duration _offset;

  @override
  Duration get timeZoneOffset => _offset;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
