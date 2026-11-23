import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/recap/domain/month_recap.dart';

void main() {
  test('an empty month stays empty instead of inventing figures', () {
    expect(
      buildMonthRecap(current: const [], previous: const []).expenseCount,
      0,
    );
  });

  test('uses main-currency cents and the category that fell the most', () {
    final facts = buildMonthRecap(
      current: const [
        (
          category: 'restaurants',
          amountCents: 8000,
          amountMainCents: 8000,
          feeCents: null,
        ),
        (
          category: 'groceries',
          amountCents: 4000,
          amountMainCents: 4000,
          feeCents: null,
        ),
      ],
      previous: const [
        (
          category: 'restaurants',
          amountCents: 10000,
          amountMainCents: 10000,
          feeCents: null,
        ),
        (
          category: 'groceries',
          amountCents: 4000,
          amountMainCents: 4000,
          feeCents: null,
        ),
      ],
    );
    expect(facts.expenseCount, 2);
    expect(facts.spentCents, 12000);
    expect(facts.savedCents, 2000);
    expect(facts.focusCategory, 'restaurants');
    expect(facts.focusImproved, isTrue);
    expect(facts.focusPercent, 20);
    expect(facts.changePercent, -14);
  });

  test('without a drop, the largest category is the share of the month', () {
    final facts = buildMonthRecap(
      current: const [
        (
          category: 'family',
          amountCents: 3000,
          amountMainCents: null,
          feeCents: null,
        ),
        (
          category: 'shopping',
          amountCents: 1000,
          amountMainCents: null,
          feeCents: null,
        ),
      ],
      previous: const [],
    );
    expect(facts.focusCategory, 'family');
    expect(facts.focusImproved, isFalse);
    expect(facts.focusPercent, 75);
    expect(facts.savedCents, 0);
    expect(facts.changePercent, isNull);
  });

  test('family transfer fees count toward spent', () {
    final facts = buildMonthRecap(
      current: const [
        (
          category: 'family',
          amountCents: 5000,
          amountMainCents: 5000,
          feeCents: 250,
        ),
      ],
      previous: const [],
    );
    expect(facts.spentCents, 5250);
    expect(facts.focusCategory, 'family');
  });
}
