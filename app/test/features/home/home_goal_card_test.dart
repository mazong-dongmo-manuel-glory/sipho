import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/features/finance/domain/user_finance.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/goals/data/goal_repository.dart';
import 'package:sipho/features/goals/domain/goal.dart';
import 'package:sipho/features/home/presentation/home_goal_card.dart';

void main() {
  Widget buildTestWidget({
    required List<Goal> goals,
    String currency = 'CAD',
  }) {
    return ProviderScope(
      overrides: [
        userFinanceProvider.overrideWith(
          (ref) => Stream.value(
            UserFinance(
              uid: 'test_user',
              displayName: 'Amina',
              currency: currency,
              countryCode: 'CA',
              monthlyIncomeCents: 0,
            ),
          ),
        ),
        userGoalsProvider.overrideWith((ref) => Stream.value(goals)),
      ],
      child: const MaterialApp(
        locale: Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: HomeGoalTrackerSection()),
      ),
    );
  }

  testWidgets('shows empty goal card when user has no goals', (tester) async {
    await tester.pumpWidget(buildTestWidget(goals: []));
    await tester.pumpAndSettle();

    expect(find.text('Mes objectifs'), findsOneWidget);
    expect(find.text('Créer l\'objectif'), findsOneWidget);
  });

  testWidgets('shows active goal with progress bar and quick deposit button',
      (tester) async {
    final testGoal = Goal(
      id: 'g1',
      title: 'Voyage au Cameroun',
      targetCents: 300000,
      savedCents: 120000,
      emoji: '✈️',
      createdAt: DateTime(2026, 11, 1),
    );

    await tester.pumpWidget(buildTestWidget(goals: [testGoal]));
    await tester.pumpAndSettle();

    expect(find.text('Voyage au Cameroun'), findsOneWidget);
    expect(find.text('✈️'), findsOneWidget);
    expect(find.text('+ Épargner'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
