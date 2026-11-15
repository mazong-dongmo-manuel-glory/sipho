import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/fixed_expenses/data/fixed_expense_repository.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_expense.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_paid.dart';
import 'package:sipho/features/fixed_expenses/presentation/fixed_paid_button.dart';

FixedExpense _bill(
  String id, {
  int dueDay = 5,
  String payMode = 'manual',
  String type = 'bill',
  bool active = true,
}) {
  return FixedExpense(
    id: id,
    name: id,
    category: 'rent',
    icon: '🏠',
    amountCents: 1000,
    dueDay: dueDay,
    payMode: payMode,
    type: type,
    active: active,
    createdAt: DateTime(2026, 11, 1),
  );
}

class _FakeRepo implements FixedExpenseRepository {
  final calls = <(String, String)>[];
  Object? error;

  @override
  Future<void> markPaid(String fixedId, String monthKey) async {
    calls.add((fixedId, monthKey));
    if (error != null) throw error!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('paid state', () {
    final now = DateTime(2026, 11, 10);

    test('manual bills are paid only once the server recorded it', () {
      final rent = _bill('rent');
      expect(isFixedPaid(rent, paidIds: const {}, now: now), isFalse);
      expect(isFixedPaid(rent, paidIds: const {'rent'}, now: now), isTrue);
      expect(canMarkFixedPaid(rent, paidIds: const {}), isTrue);
      expect(canMarkFixedPaid(rent, paidIds: const {'rent'}), isFalse);
    });

    test('automatic bills count as paid from their due day, and have no button',
        () {
      final auto = _bill('internet', dueDay: 8, payMode: 'auto');
      final later = _bill('phone', dueDay: 20, payMode: 'auto');
      expect(isFixedPaid(auto, paidIds: const {}, now: now), isTrue);
      expect(isFixedPaid(later, paidIds: const {}, now: now), isFalse);
      expect(canMarkFixedPaid(auto, paidIds: const {}), isFalse);
    });

    test('a bill due on the 31st falls on the last day of a short month', () {
      final bill = _bill('rent', dueDay: 31, payMode: 'auto');
      expect(effectiveDueDay(bill, DateTime(2026, 4, 10)), 30);
      expect(isFixedPaid(bill, paidIds: const {}, now: DateTime(2026, 4, 30)),
          isTrue);
      expect(isFixedPaid(bill, paidIds: const {}, now: DateTime(2026, 4, 29)),
          isFalse);
    });

    test('envelopes and inactive bills cannot be marked paid', () {
      expect(
          canMarkFixedPaid(_bill('food', type: 'envelope'), paidIds: const {}),
          isFalse);
      expect(
          isFixedPaid(_bill('food', type: 'envelope'),
              paidIds: const {}, now: now),
          isFalse);
      expect(canMarkFixedPaid(_bill('old', active: false), paidIds: const {}),
          isFalse);
    });

    test('reads paid ids from the month document', () {
      expect(paidIdsFromMonth(null), isEmpty);
      expect(paidIdsFromMonth({'fixedPaid': 'oops'}), isEmpty);
      expect(
        paidIdsFromMonth({
          'fixedPaid': {
            'rent': {'paid': true},
            'phone': {'paid': false},
            'internet': {'category': 'internet'},
          },
        }),
        {'rent'},
      );
    });
  });

  group('FixedPaidButton', () {
    Future<_FakeRepo> pump(WidgetTester tester, {Object? error}) async {
      final repo = _FakeRepo()..error = error;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [fixedExpenseRepositoryProvider.overrideWithValue(repo)],
          child: const MaterialApp(
            locale: Locale('fr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Center(child: FixedPaidButton(fixedId: 'rent')),
            ),
          ),
        ),
      );
      return repo;
    }

    testWidgets('tapping "Payé ✓" calls markFixedPaid for the current month',
        (tester) async {
      final repo = await pump(tester);
      expect(find.text('Payé ✓'), findsOneWidget);

      await tester.tap(find.text('Payé ✓'));
      await tester.pumpAndSettle();

      expect(repo.calls, [('rent', currentMonthKey())]);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('a failure is reported to the user', (tester) async {
      final repo = await pump(tester, error: Exception('offline'));

      await tester.tap(find.text('Payé ✓'));
      await tester.pumpAndSettle();

      expect(repo.calls, hasLength(1));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Impossible de marquer'), findsOneWidget);
    });
  });
}
