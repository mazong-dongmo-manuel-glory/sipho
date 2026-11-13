/// Utilities for working with the user's local calendar day.
class LocalDay {
  const LocalDay._(this._dt);

  final DateTime _dt;

  factory LocalDay.now() => LocalDay._(DateTime.now());

  factory LocalDay.fromUtc(DateTime utc) => LocalDay._(utc.toLocal());

  /// ISO-8601 date string in local timezone: "2024-05-01"
  String get isoDate => '${_dt.year.toString().padLeft(4, '0')}'
      '-${_dt.month.toString().padLeft(2, '0')}'
      '-${_dt.day.toString().padLeft(2, '0')}';

  /// "YYYY-MM" string for monthly aggregation
  String get isoMonth => '${_dt.year.toString().padLeft(4, '0')}'
      '-${_dt.month.toString().padLeft(2, '0')}';

  int get year => _dt.year;
  int get month => _dt.month;
  int get day => _dt.day;
  int get weekday => _dt.weekday; // 1=Mon … 7=Sun

  DateTime get startOfDay => DateTime(_dt.year, _dt.month, _dt.day);

  DateTime get endOfDay =>
      DateTime(_dt.year, _dt.month, _dt.day, 23, 59, 59, 999);

  DateTime get startOfMonth => DateTime(_dt.year, _dt.month);

  DateTime get startOfNextMonth => DateTime(_dt.year, _dt.month + 1);

  bool isSameDay(DateTime other) {
    final o = other.toLocal();
    return o.year == _dt.year && o.month == _dt.month && o.day == _dt.day;
  }

  @override
  String toString() => isoDate;
}
