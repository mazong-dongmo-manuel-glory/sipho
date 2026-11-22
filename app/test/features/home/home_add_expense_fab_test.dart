import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/home/domain/home_add_expense_fab.dart';

void main() {
  test('FAB stays visible even while a reward banner is pending', () {
    expect(shouldShowHomeAddExpenseFab(hasPendingReward: false), isTrue);
    expect(shouldShowHomeAddExpenseFab(hasPendingReward: true), isTrue);
  });

  test('reward banner auto-clears after a short display window', () {
    expect(kHomeRewardDisplayDuration.inSeconds, greaterThanOrEqualTo(2));
    expect(kHomeRewardDisplayDuration.inSeconds, lessThanOrEqualTo(10));
  });
}
