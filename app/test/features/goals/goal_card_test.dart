import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/features/goals/domain/goal.dart';
import 'package:sipho/features/goals/presentation/goal_card.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('fr'),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('displays goal details, progress and deposit button', (tester) async {
    bool deposited = false;
    final goal = Goal(
      id: 'g1',
      title: 'Voyage au Cameroun',
      targetCents: 300000,
      savedCents: 120000,
      emoji: '✈️',
      createdAt: DateTime(2026, 11, 1),
    );

    await tester.pumpWidget(_wrap(
      GoalCard(
        goal: goal,
        currency: 'CAD',
        onDeposit: () => deposited = true,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Voyage au Cameroun'), findsOneWidget);
    expect(find.text('✈️'), findsOneWidget);
    expect(find.text('40 %'), findsOneWidget);
    expect(find.textContaining('200'), findsOneWidget);
    expect(find.textContaining('000'), findsOneWidget);

    // Tap deposit button
    await tester.tap(find.text('Ajouter une épargne'));
    expect(deposited, isTrue);
  });

  testWidgets('displays completion badge when goal is reached', (tester) async {
    final goal = Goal(
      id: 'g2',
      title: 'Fonds d\'urgence',
      targetCents: 100000,
      savedCents: 100000,
      emoji: '🛡️',
      completedAt: DateTime.now(),
      createdAt: DateTime(2026, 11, 1),
    );

    await tester.pumpWidget(_wrap(
      GoalCard(
        goal: goal,
        currency: 'CAD',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Fonds d\'urgence'), findsOneWidget);
    expect(find.text('Objectif atteint 🎉'), findsOneWidget);
    expect(find.text('Ajouter une épargne'), findsNothing);
  });
}
