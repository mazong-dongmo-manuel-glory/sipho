import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/features/gamification/data/game_state_repository.dart';
import 'package:sipho/features/gamification/domain/game_state.dart';
import 'package:sipho/features/gamification/domain/streak_week.dart';
import 'package:sipho/features/gamification/presentation/streak_screen.dart';

String _isoToday() {
  final now = DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${now.year}-${two(now.month)}-${two(now.day)}';
}

Future<void> _pump(WidgetTester tester, {required GameState? state}) async {
  tester.view.physicalSize = const Size(800, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        gameStateStreamProvider.overrideWith((ref) => Stream.value(state)),
      ],
      child: const MaterialApp(
        locale: Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StreakScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('shows the real streak and only the days of that streak',
      (tester) async {
    await _pump(
      tester,
      state: GameState(
        streak: StreakInfo(current: 2, best: 9, lastActiveDay: _isoToday()),
      ),
    );

    expect(find.text('2'), findsOneWidget);
    expect(find.text('13'), findsNothing);

    final expectedChecks = streakWeekMarks(
      lastActiveDay: _isoToday(),
      current: 2,
      today: DateTime.now(),
    ).where((m) => m).length;
    expect(expectedChecks, inInclusiveRange(1, 2));
    expect(find.text('✓'), findsNWidgets(expectedChecks));
  });

  testWidgets('without any streak data it shows 0 and no checked day',
      (tester) async {
    await _pump(tester, state: null);

    expect(find.text('0'), findsOneWidget);
    expect(find.text('✓'), findsNothing);
  });

  testWidgets('weekday initials follow the app locale, Monday first',
      (tester) async {
    await _pump(tester, state: null);

    expect(StreakScreen.weekdayInitials('fr'),
        ['L', 'M', 'M', 'J', 'V', 'S', 'D']);
    expect(StreakScreen.weekdayInitials('en'),
        ['M', 'T', 'W', 'T', 'F', 'S', 'S']);
  });
}
