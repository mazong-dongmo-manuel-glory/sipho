import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/goals/data/goal_repository.dart';
import 'package:sipho/features/goals/domain/goal.dart';
import 'package:sipho/features/goals/presentation/add_goal_sheet.dart';
import 'package:sipho/features/goals/presentation/deposit_goal_sheet.dart';

class _FakeUser implements User {
  @override
  String get uid => 'u1';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FailingGoals extends Fake implements GoalRepository {
  @override
  Future<void> createGoal(String uid, Goal goal) async {
    throw Exception('firestore down');
  }

  @override
  Future<void> deposit(String uid, String goalId, int amountCents) async {
    throw Exception('firestore down');
  }
}

Future<void> _waitForAuth(WidgetTester tester, Finder sheet) async {
  final container = ProviderScope.containerOf(tester.element(sheet));
  for (var i = 0; i < 20; i++) {
    final auth = container.read(authStateProvider);
    if (auth.hasValue && auth.valueOrNull?.uid != null) return;
    await tester.pump(const Duration(milliseconds: 20));
  }
  fail('authStateProvider never emitted a signed-in user');
}

void main() {
  testWidgets('AddGoalSheet shows snackbar when Firestore create fails',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          goalRepositoryProvider.overrideWithValue(_FailingGoals()),
          authStateProvider.overrideWith((ref) => Stream.value(_FakeUser())),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AddGoalSheet()),
        ),
      ),
    );
    await tester.pump();
    await _waitForAuth(tester, find.byType(AddGoalSheet));

    await tester.enterText(find.byType(TextField).at(0), 'Vacation');
    await tester.enterText(find.byType(TextField).at(1), '500');
    await tester.pump();

    tester.widget<SiphoButton3D>(find.byType(SiphoButton3D)).onPressed!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('DepositGoalSheet shows snackbar when Firestore deposit fails',
      (tester) async {
    final goal = Goal(
      id: 'g1',
      title: 'Bike',
      targetCents: 100000,
      savedCents: 1000,
      emoji: '🚲',
      createdAt: DateTime(2024),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          goalRepositoryProvider.overrideWithValue(_FailingGoals()),
          authStateProvider.overrideWith((ref) => Stream.value(_FakeUser())),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: DepositGoalSheet(goal: goal, currency: 'CAD'),
          ),
        ),
      ),
    );
    await tester.pump();
    await _waitForAuth(tester, find.byType(DepositGoalSheet));

    await tester.enterText(find.byType(TextField), '25');
    await tester.pump();

    tester.widget<SiphoButton3D>(find.byType(SiphoButton3D)).onPressed!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });
}
