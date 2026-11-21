class NotifPrefs {
  const NotifPrefs({
    this.streakReminder = false,
    this.budgetAlert = false,
    this.fixedDue = false,
    this.tips = false,
    this.economy = false,
  });

  final bool streakReminder;
  final bool budgetAlert;
  final bool fixedDue;
  final bool tips;
  final bool economy;

  static const defaults = NotifPrefs();

  static const optedIn = NotifPrefs(
    streakReminder: true,
    budgetAlert: true,
    fixedDue: true,
    tips: true,
    economy: true,
  );

  factory NotifPrefs.fromMap(Map<dynamic, dynamic> raw) {
    bool read(String key) => raw[key] == true;
    return NotifPrefs(
      streakReminder: read('streakReminder'),
      budgetAlert: read('budgetAlert'),
      fixedDue: read('fixedDue'),
      tips: read('tips'),
      economy: read('economy'),
    );
  }

  Map<String, bool> toMap() => {
        'streakReminder': streakReminder,
        'budgetAlert': budgetAlert,
        'fixedDue': fixedDue,
        'tips': tips,
        'economy': economy,
      };

  NotifPrefs copyWith({
    bool? streakReminder,
    bool? budgetAlert,
    bool? fixedDue,
    bool? tips,
    bool? economy,
  }) {
    return NotifPrefs(
      streakReminder: streakReminder ?? this.streakReminder,
      budgetAlert: budgetAlert ?? this.budgetAlert,
      fixedDue: fixedDue ?? this.fixedDue,
      tips: tips ?? this.tips,
      economy: economy ?? this.economy,
    );
  }
}
