import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/features/finance/domain/user_finance.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/gamification/data/game_state_repository.dart';
import 'package:sipho/features/insights/data/insight_service.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';
import 'package:sipho/features/lessons/presentation/learn_path.dart';
import 'package:sipho/features/lessons/presentation/learn_quests_provider.dart';
import 'package:sipho/features/lessons/presentation/learn_screen.dart';

void main() {
  group('path layout', () {
    test('nodes wind from side to side and stay inside the range', () {
      final offsets = [for (var i = 0; i < 16; i++) pathNodeOffset(i)];
      expect(offsets.every((o) => o >= -1 && o <= 1), isTrue);
      expect(offsets.any((o) => o > 0), isTrue);
      expect(offsets.any((o) => o < 0), isTrue);
      expect(pathNodeOffset(0), 0);
    });

    test('two neighbours never sit exactly on top of each other', () {
      // A straight column would look like a list, not a path.
      var shifted = 0;
      for (var i = 0; i < 8; i++) {
        if (pathNodeOffset(i) != pathNodeOffset(i + 1)) shifted++;
      }
      expect(shifted, 8);
    });

    test('a lesson is done, the next one is current, the rest are locked', () {
      LessonNodeState of(String id, Set<String> done, String? next) =>
          lessonNodeState(lessonId: id, completed: done, nextId: next);
      expect(of('a', {'a'}, 'b'), LessonNodeState.done);
      expect(of('b', {'a'}, 'b'), LessonNodeState.current);
      expect(of('c', {'a'}, 'b'), LessonNodeState.locked);
      // Nothing left to play: everything is done.
      expect(of('a', {'a'}, null), LessonNodeState.done);
    });

    test('country slots: focus is current, others available', () {
      LessonNodeState of(String id, Set<String> done, String? next) =>
          lessonNodeState(
            lessonId: id,
            completed: done,
            nextId: next,
            unlockIndependently: true,
          );
      expect(of('ca_slot_01', {}, 'ca_slot_01'), LessonNodeState.current);
      expect(of('ca_slot_02', {}, 'ca_slot_01'), LessonNodeState.available);
      expect(
        of('ca_slot_01', {'ca_slot_01'}, 'ca_slot_02'),
        LessonNodeState.done,
      );
    });
  });

  group('LearnScreen', () {
    late GoRouter router;

    Future<void> pump(
      WidgetTester tester, {
      Set<String> completed = const {},
      String countryCode = '',
    }) async {
      tester.view.physicalSize = const Size(800, 4000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, __) => const LearnScreen()),
          GoRoute(
            path: '/lesson/:id',
            builder: (_, state) =>
                Scaffold(body: Text('PLAYER ${state.pathParameters['id']}')),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userFinanceProvider.overrideWith((ref) => Stream.value(
                  UserFinance(
                    uid: 'u',
                    displayName: 'Amina',
                    currency: 'CAD',
                    countryCode: countryCode,
                    monthlyIncomeCents: 0,
                    completedLessonIds: completed.toList(),
                  ),
                )),
            gameStateStreamProvider.overrideWith((ref) => Stream.value(null)),
            storedInsightsProvider.overrideWith((ref) => Stream.value([])),
            serverQuestsStreamProvider.overrideWith((ref) => Stream.value([])),
            transactionsForMonthProvider
                .overrideWith((ref, key) => Stream.value(const [])),
            activeFixedExpensesProvider
                .overrideWith((ref) => Stream.value(const [])),
          ],
          child: MaterialApp.router(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    Future<void> settle(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    testWidgets('the fixed country pack is not an extra unit', (tester) async {
      await pump(tester, countryCode: 'CA');
      expect(find.text('UNIT 1'), findsOneWidget);
      expect(find.text('UNIT 4'), findsOneWidget);
      expect(find.text('UNIT 5'), findsNothing);
      expect(find.text('Canada lessons'), findsNothing);
      expect(find.text('YOUR TURN'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('shows both units with their subtitle and every lesson',
        (tester) async {
      await pump(tester);
      expect(find.text('UNIT 1'), findsOneWidget);
      expect(find.text('UNIT 2'), findsOneWidget);
      expect(find.text('UNIT 3'), findsOneWidget);
      expect(find.text('UNIT 4'), findsOneWidget);
      for (final unit in kCatalogUnits) {
        expect(find.text(unit.titleEn), findsOneWidget);
        expect(find.text(unit.subtitle.en), findsOneWidget);
      }
      for (final lesson in kCatalogLessons) {
        expect(find.textContaining(lesson.titleEn), findsOneWidget,
            reason: lesson.id);
      }
      expect(find.text('0/3 lessons'), findsNWidgets(4));
    });

    testWidgets('only the first lesson is playable at the start',
        (tester) async {
      await pump(tester);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(11));
      expect(find.byIcon(Icons.star_rounded), findsNothing);
      expect(find.text('YOUR TURN'), findsOneWidget);
    });

    testWidgets('finished lessons turn into stars and the next one opens',
        (tester) async {
      await pump(
        tester,
        completed: {'emergency_fund', 'needs_wants'},
      );
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(2));
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(9));
      expect(find.text('2/3 lessons'), findsOneWidget);
    });

    testWidgets('tapping the current lesson opens its card, then starts it',
        (tester) async {
      await pump(tester);
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await settle(tester);

      final first = kCatalogLessons.first;
      expect(find.text('Lesson 1 of 3'), findsOneWidget);
      expect(find.text('WHAT YOU WILL LEARN'), findsOneWidget);
      expect(find.text(first.objective.en), findsOneWidget);
      expect(find.text('⏱  ${first.minutes} min'), findsOneWidget);
      expect(find.text('📚  ${first.steps.length} steps'), findsOneWidget);
      expect(find.text('⭐  up to +$kLessonMaxXp XP'), findsOneWidget);

      await tester.tap(find.text('START'));
      await settle(tester);
      expect(find.text('PLAYER ${first.id}'), findsOneWidget);
    });

    testWidgets('a locked lesson explains why and cannot be started',
        (tester) async {
      await pump(tester);
      await tester.tap(find.byIcon(Icons.lock_rounded).first);
      await settle(tester);

      expect(find.text('Finish the previous lesson first to unlock this one.'),
          findsOneWidget);
      expect(find.text('START'), findsNothing);

      await tester.tap(find.text('CLOSE'));
      await settle(tester);
      expect(find.textContaining('PLAYER'), findsNothing);
    });

    testWidgets('a finished lesson can be replayed without a reward promise',
        (tester) async {
      await pump(tester, completed: {'emergency_fund'});
      await tester.tap(find.byIcon(Icons.star_rounded));
      await settle(tester);

      expect(find.text('REPLAY'), findsOneWidget);
      expect(
          find.text('Already completed: replay to practice.'), findsOneWidget);
      expect(find.textContaining('up to +'), findsNothing);

      await tester.tap(find.text('REPLAY'));
      await settle(tester);
      expect(find.text('PLAYER emergency_fund'), findsOneWidget);
    });

    testWidgets('the end-of-unit gifts stay closed at the start',
        (tester) async {
      await pump(tester);
      final gifts = tester
          .widgetList<UnitGiftNode>(find.byType(UnitGiftNode))
          .map((g) => g.reached);
      expect(gifts, [false, false, false, false]);
    });

    testWidgets('the end-of-unit gift opens once the unit is complete',
        (tester) async {
      final unit1 = kCatalogUnits.first.lessons.map((l) => l.id).toSet();
      await pump(tester, completed: unit1);
      final gifts = tester
          .widgetList<UnitGiftNode>(find.byType(UnitGiftNode))
          .map((g) => g.reached)
          .toList();
      expect(gifts, [true, false, false, false]);
    });
  });
}
