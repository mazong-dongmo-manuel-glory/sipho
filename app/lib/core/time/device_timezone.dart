import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

/// Sentinel stored in `users/{uid}.timezone` when the OS gives no IANA id. The server treats it
/// as invalid and falls back to [DeviceTimezone.utcOffsetMinutes].
const kUnknownTimezone = 'unknown';

/// The device time zone, in the two forms the backend needs:
///  * [id]: IANA id such as "Asia/Kolkata" or "America/Toronto" (exact, handles daylight saving),
///  * [utcOffsetMinutes]: current offset in MINUTES (never whole hours: +05:30 and +05:45 exist).
@immutable
class DeviceTimezone {
  const DeviceTimezone({required this.id, required this.utcOffsetMinutes});

  final String? id;
  final int utcOffsetMinutes;

  /// Fields to merge into `users/{uid}`. `timezone` is omitted when unknown so that a valid
  /// stored id is never overwritten by a failed lookup.
  Map<String, Object> toProfileFields() => {
        if (id != null) 'timezone': id!,
        'utcOffsetMinutes': utcOffsetMinutes,
      };

  /// Value to use when creating a profile (the rules require a `timezone` string).
  Map<String, Object> toCreateFields() => {
        'timezone': id ?? kUnknownTimezone,
        'utcOffsetMinutes': utcOffsetMinutes,
      };
}

bool isPlausibleIanaId(String? id) {
  if (id == null || id.isEmpty || id.length > 64) return false;
  return id == 'UTC' || id.contains('/');
}

/// Reads the device time zone. [idProvider] and [now] exist for tests.
Future<DeviceTimezone> readDeviceTimezone({
  Future<String> Function()? idProvider,
  DateTime? now,
}) async {
  String? id;
  try {
    final raw = idProvider != null
        ? await idProvider()
        : (await FlutterTimezone.getLocalTimezone()).identifier;
    final trimmed = raw.trim();
    if (isPlausibleIanaId(trimmed)) id = trimmed;
  } catch (error) {
    debugPrint('Device time zone unavailable: $error');
  }
  return DeviceTimezone(
    id: id,
    utcOffsetMinutes: (now ?? DateTime.now()).timeZoneOffset.inMinutes,
  );
}
