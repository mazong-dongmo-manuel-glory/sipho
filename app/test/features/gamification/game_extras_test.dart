import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/gamification/domain/game_extras.dart';

void main() {
  final today = DateTime(2026, 11, 14);

  group('parseGameExtras', () {
    test('reads the budget-day reward and the no-spend day', () {
      final extras = parseGameExtras({
        'lastBudgetDay': {'dayKey': '2026-11-13', 'xp': 15},
        'noSpendDay': '2026-11-14',
      });
      expect(
          extras.budgetDay, const BudgetDayAward(dayKey: '2026-11-13', xp: 15));
      expect(extras.noSpendDay, '2026-11-14');
    });

    test('ignores missing or malformed values', () {
      expect(parseGameExtras(null), const GameExtras());
      expect(parseGameExtras({}), const GameExtras());
      expect(
        parseGameExtras({
          'lastBudgetDay': {'dayKey': 'hier', 'xp': 15},
          'noSpendDay': 42,
        }),
        const GameExtras(),
      );
      expect(
        parseGameExtras({
          'lastBudgetDay': {'dayKey': '2026-11-13'},
        }).budgetDay,
        isNull,
      );
    });
  });

  group('isBudgetDayBannerVisible', () {
    test('shows the reward during the day that follows it', () {
      expect(
        isBudgetDayBannerVisible(
          const BudgetDayAward(dayKey: '2026-11-13', xp: 15),
          today,
        ),
        isTrue,
      );
    });

    test('hides older rewards, future ones and a missing reward', () {
      expect(
        isBudgetDayBannerVisible(
          const BudgetDayAward(dayKey: '2026-11-12', xp: 15),
          today,
        ),
        isFalse,
      );
      expect(
        isBudgetDayBannerVisible(
          const BudgetDayAward(dayKey: '2026-11-14', xp: 15),
          today,
        ),
        isFalse,
      );
      expect(isBudgetDayBannerVisible(null, today), isFalse);
    });

    test('works across a month boundary', () {
      expect(
        isBudgetDayBannerVisible(
          const BudgetDayAward(dayKey: '2026-10-31', xp: 15),
          DateTime(2026, 11, 1),
        ),
        isTrue,
      );
    });
  });

  group('isNewBudgetDayAward', () {
    const award = BudgetDayAward(dayKey: '2026-11-13', xp: 15);

    test('a first load never counts, even when a reward already exists', () {
      expect(
        isNewBudgetDayAward(previousLoaded: false, previous: null, next: award),
        isFalse,
      );
    });

    test('a reward appearing after a loaded state without one is new', () {
      expect(
        isNewBudgetDayAward(previousLoaded: true, previous: null, next: award),
        isTrue,
      );
    });

    test('the same reward again, or no reward, is not new', () {
      expect(
        isNewBudgetDayAward(previousLoaded: true, previous: award, next: award),
        isFalse,
      );
      expect(
        isNewBudgetDayAward(previousLoaded: true, previous: award, next: null),
        isFalse,
      );
    });

    test('a reward for another day is new', () {
      expect(
        isNewBudgetDayAward(
          previousLoaded: true,
          previous: award,
          next: const BudgetDayAward(dayKey: '2026-11-14', xp: 15),
        ),
        isTrue,
      );
    });
  });

  group('canConfirmNoSpend', () {
    test('is offered when nothing was logged or confirmed today', () {
      expect(
        canConfirmNoSpend(
          extras: const GameExtras(),
          today: today,
          expenseDates: const ['2026-11-13'],
        ),
        isTrue,
      );
    });

    test('is hidden once an expense is logged today', () {
      expect(
        canConfirmNoSpend(
          extras: const GameExtras(),
          today: today,
          expenseDates: const ['2026-11-14'],
        ),
        isFalse,
      );
    });

    test('is hidden once confirmed today, but offered again the next day', () {
      const confirmed = GameExtras(noSpendDay: '2026-11-14');
      expect(
        canConfirmNoSpend(
            extras: confirmed, today: today, expenseDates: const []),
        isFalse,
      );
      expect(
        canConfirmNoSpend(
          extras: confirmed,
          today: DateTime(2026, 11, 15),
          expenseDates: const [],
        ),
        isTrue,
      );
    });

    test('is hidden while the game state is still loading', () {
      expect(
        canConfirmNoSpend(extras: null, today: today, expenseDates: const []),
        isFalse,
      );
    });
  });
}
