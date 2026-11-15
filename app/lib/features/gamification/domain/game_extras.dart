import 'package:flutter/foundation.dart' show setEquals;

/// The "journée sous budget" reward the server wrote for a finished day.
class BudgetDayAward {
  const BudgetDayAward({required this.dayKey, required this.xp});

  /// Local day that was under budget, `yyyy-MM-dd`.
  final String dayKey;
  final int xp;

  @override
  bool operator ==(Object other) =>
      other is BudgetDayAward && other.dayKey == dayKey && other.xp == xp;

  @override
  int get hashCode => Object.hash(dayKey, xp);
}

/// Day-level markers the server keeps next to the game state
/// (`users/{uid}/game/state`): they only drive what the UI shows.
class GameExtras {
  const GameExtras({
    this.budgetDay,
    this.noSpendDay,
    this.ownedItems = const {},
  });

  final BudgetDayAward? budgetDay;

  /// Local day for which the user confirmed "no spending today", if any.
  final String? noSpendDay;

  /// Cosmetic shop items the user bought (written by the server only).
  final Set<String> ownedItems;

  @override
  bool operator ==(Object other) =>
      other is GameExtras &&
      other.budgetDay == budgetDay &&
      other.noSpendDay == noSpendDay &&
      setEquals(other.ownedItems, ownedItems);

  @override
  int get hashCode =>
      Object.hash(budgetDay, noSpendDay, Object.hashAllUnordered(ownedItems));
}

final RegExp _isoDay = RegExp(r'^\d{4}-\d{2}-\d{2}$');

String isoDay(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// Reads the markers from a raw game-state document, ignoring anything malformed.
GameExtras parseGameExtras(Map<String, dynamic>? raw) {
  if (raw == null) return const GameExtras();
  BudgetDayAward? award;
  final rawAward = raw['lastBudgetDay'];
  if (rawAward is Map) {
    final dayKey = rawAward['dayKey'];
    final xp = rawAward['xp'];
    if (dayKey is String && _isoDay.hasMatch(dayKey) && xp is num) {
      award = BudgetDayAward(dayKey: dayKey, xp: xp.toInt());
    }
  }
  final noSpend = raw['noSpendDay'];
  final owned = raw['ownedItems'];
  return GameExtras(
    budgetDay: award,
    noSpendDay: noSpend is String && _isoDay.hasMatch(noSpend) ? noSpend : null,
    ownedItems: owned is List ? {for (final id in owned) id.toString()} : {},
  );
}

/// The reward is evaluated just after midnight, so it is shown during the day that follows.
bool isBudgetDayBannerVisible(BudgetDayAward? award, DateTime today) {
  if (award == null) return false;
  final yesterday = DateTime(today.year, today.month, today.day - 1);
  return award.dayKey == isoDay(yesterday);
}

/// True when [next] is a reward the user has not seen yet. A missing [previous]
/// (first load, or just after a sign-in) never counts: it is not new progress.
bool isNewBudgetDayAward({
  required bool previousLoaded,
  required BudgetDayAward? previous,
  required BudgetDayAward? next,
}) {
  if (!previousLoaded || next == null) return false;
  return previous?.dayKey != next.dayKey;
}

/// The "no spending today" button is offered until an expense is logged or it was confirmed.
bool canConfirmNoSpend({
  required GameExtras? extras,
  required DateTime today,
  required Iterable<String> expenseDates,
}) {
  if (extras == null) return false;
  final todayKey = isoDay(today);
  if (extras.noSpendDay == todayKey) return false;
  return !expenseDates.contains(todayKey);
}
