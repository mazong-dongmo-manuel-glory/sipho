import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/core/feedback/feedback_settings.dart';
import 'package:sipho/core/sound/sound_service.dart';
import 'package:sipho/features/finance/domain/user_finance.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/gamification/data/game_state_repository.dart';
import 'package:sipho/features/gamification/domain/game_state.dart';
import 'package:sipho/features/gamification/domain/quest_reward.dart';
import 'package:sipho/features/gamification/presentation/chest_open_screen.dart';
import 'package:sipho/features/lessons/domain/lesson_result.dart';
import 'package:sipho/features/lessons/presentation/lesson_done_screen.dart';

class _SilentBackend implements SoundBackend {
  @override
  Future<void> init() async {}
  @override
  Future<void> play(String assetPath) async {}
  @override
  Future<void> preload(String assetPath) async {}
  @override
  Future<void> dispose() async {}
}

Map<String, dynamic> _response({
  int xp = 20,
  int seeds = 5,
  bool alreadyCompleted = false,
  String? unit,
  int unitXp = 0,
  int unitSeeds = 0,
  bool levelUp = false,
}) =>
    {
      'xpGained': xp,
      'seedsGained': seeds,
      'newStreak': 4,
      'levelUp': levelUp,
      'newLevel': 3,
      'alreadyCompleted': alreadyCompleted,
      'unitCompleted': unit,
      'unitBonusXp': unitXp,
      'unitBonusSeeds': unitSeeds,
    };

void main() {
  group('lessonScore', () {
    test('a lesson without a miss is perfect', () {
      expect(lessonScore(questions: 3, misses: 0), 100);
      expect(lessonScore(questions: 0, misses: 4), 100);
    });

    test('every miss lowers the score: right answers over answers given', () {
      expect(lessonScore(questions: 3, misses: 1), 75);
      expect(lessonScore(questions: 3, misses: 3), 50);
      expect(lessonScore(questions: 2, misses: 2), 50);
      expect(lessonScore(questions: 1, misses: 3), 25);
    });

    test('never leaves the 0-100 range the server accepts', () {
      expect(lessonScore(questions: 3, misses: -5), 100);
      for (var misses = 0; misses < 500; misses++) {
        expect(lessonScore(questions: 3, misses: misses),
            inInclusiveRange(0, 100));
      }
    });

    test('retrying until right is no longer a perfect lesson', () {
      // The server pays the "perfect" XP only for exactly 100.
      expect(lessonScore(questions: 3, misses: 1), isNot(100));
      // Even many questions and a single miss stay below 100.
      expect(lessonScore(questions: 40, misses: 1), isNot(100));
    });
  });

  group('formatLessonDuration', () {
    test('formats minutes and padded seconds', () {
      expect(formatLessonDuration(134), '2:14');
      expect(formatLessonDuration(5), '0:05');
      expect(formatLessonDuration(600), '10:00');
    });

    test('a negative duration is shown as zero', () {
      expect(formatLessonDuration(-3), '0:00');
    });
  });

  group('LessonResult.fromCallable', () {
    test('reads the numbers the server paid', () {
      final result = LessonResult.fromCallable(
        _response(xp: 50, seeds: 15, unit: 'unit_1', unitXp: 30, unitSeeds: 10),
        accuracy: 100,
        durationSeconds: 134,
      );
      expect(result.xpGained, 50);
      expect(result.seedsGained, 15);
      expect(result.newStreak, 4);
      expect(result.finishedUnit, isTrue);
      expect(result.unitBonusXp, 30);
      expect(result.unitBonusSeeds, 10);
      expect(result.accuracy, 100);
      expect(result.durationSeconds, 134);
    });

    test('a replay is flagged and a plain lesson finishes no unit', () {
      final result = LessonResult.fromCallable(
        _response(alreadyCompleted: true, xp: 2, seeds: 0),
        accuracy: 50,
        durationSeconds: 30,
      );
      expect(result.alreadyCompleted, isTrue);
      expect(result.finishedUnit, isFalse);
    });

    test('a malformed or missing response counts as zero instead of throwing',
        () {
      final result = LessonResult.fromCallable(
        {'xpGained': 'lots', 'levelUp': 'yes'},
        accuracy: 250,
        durationSeconds: -9,
      );
      expect(result.xpGained, 0);
      expect(result.seedsGained, 0);
      expect(result.levelUp, isFalse);
      expect(result.accuracy, 100);
      expect(result.durationSeconds, 0);
    });
  });

  group('QuestReward.fromCallable', () {
    test('reads the claim response', () {
      final reward = QuestReward.fromCallable(
        {
          'xpGained': 20,
          'gemsGained': 5,
          'levelUp': true,
          'alreadyClaimed': false
        },
      );
      expect(reward.xpGained, 20);
      expect(reward.gemsGained, 5);
      expect(reward.levelUp, isTrue);
      expect(reward.alreadyClaimed, isFalse);
      expect(reward.isEmpty, isFalse);
    });

    test('an already-claimed quest paid nothing', () {
      final reward = QuestReward.fromCallable(
        {
          'xpGained': 0,
          'gemsGained': 0,
          'levelUp': false,
          'alreadyClaimed': true
        },
      );
      expect(reward.alreadyClaimed, isTrue);
      expect(reward.isEmpty, isTrue);
    });
  });

  group('LessonDoneScreen', () {
    Future<void> pump(
      WidgetTester tester,
      LessonResult result, {
      String name = 'Amina Dupont',
    }) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userFinanceProvider.overrideWith((ref) => Stream.value(
                  UserFinance(
                    uid: 'u',
                    displayName: name,
                    currency: 'CAD',
                    monthlyIncomeCents: 0,
                  ),
                )),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: LessonDoneScreen(result: result),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    LessonResult build({
      int xp = 20,
      int seeds = 5,
      int accuracy = 100,
      int seconds = 134,
      bool alreadyCompleted = false,
      String? unit,
      bool levelUp = false,
    }) =>
        LessonResult.fromCallable(
          _response(
            xp: xp,
            seeds: seeds,
            alreadyCompleted: alreadyCompleted,
            unit: unit,
            unitXp: unit == null ? 0 : 30,
            unitSeeds: unit == null ? 0 : 10,
            levelUp: levelUp,
          ),
          accuracy: accuracy,
          durationSeconds: seconds,
        );

    testWidgets('shows the real XP, accuracy and time, not placeholders',
        (tester) async {
      await pump(tester, build(xp: 25, accuracy: 50, seconds: 75));
      expect(find.text('25'), findsOneWidget);
      expect(find.text('50 %'), findsOneWidget);
      expect(find.text('1:15'), findsOneWidget);
      expect(find.text('30'), findsNothing);
      expect(find.text('100 %'), findsNothing);
      expect(find.text('2:14'), findsNothing);
    });

    testWidgets('greets the user by first name, not a hard-coded one',
        (tester) async {
      await pump(tester, build());
      expect(find.text('Well done, Amina!'), findsOneWidget);
    });

    testWidgets('without a name it still congratulates', (tester) async {
      await pump(tester, build(), name: '');
      expect(find.text('Well done!'), findsOneWidget);
    });

    testWidgets('announces seeds, the unit bonus and a level up',
        (tester) async {
      await pump(tester, build(unit: 'unit_1', levelUp: true));
      expect(find.text('+5 gold seeds'), findsOneWidget);
      expect(find.text('Unit complete! Bonus: +30 XP · +10 seeds'),
          findsOneWidget);
      expect(find.text('Level 3 reached!'), findsOneWidget);
    });

    testWidgets('a replay says so and shows no seeds line', (tester) async {
      await pump(tester, build(alreadyCompleted: true, xp: 2, seeds: 0));
      expect(find.text('Lesson already completed: a little more practice.'),
          findsOneWidget);
      expect(find.textContaining('gold seeds'), findsNothing);
    });

    test(
        'continue leads to the streak after a first completion, to the path '
        'after a replay', () {
      expect(LessonDoneScreen.nextRoute(build()), '/streak');
      expect(
          LessonDoneScreen.nextRoute(build(alreadyCompleted: true)), '/learn');
    });
  });

  group('ChestOpenScreen', () {
    Future<void> pump(WidgetTester tester, QuestReward? reward) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateStreamProvider.overrideWith((ref) => Stream.value(
                  const GameState(
                      gems: 40, level: 2, streak: StreakInfo(current: 3)),
                )),
            feedbackServiceProvider.overrideWithValue(
              FeedbackService(
                sound: SoundService(_SilentBackend()),
                settings: () => FeedbackSettings.defaults,
                haptic: (_) async {},
              ),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChestOpenScreen(reward: reward),
          ),
        ),
      );
      await tester.pump();
    }

    Future<void> open(WidgetTester tester) async {
      await tester.tap(find.text('OPEN MY GIFT'));
      await tester.pump();
      await tester.pump();
    }

    testWidgets('shows exactly what the server paid once opened',
        (tester) async {
      await pump(
        tester,
        const QuestReward(
            xpGained: 20, gemsGained: 7, levelUp: false, alreadyClaimed: false),
      );
      expect(find.text('+7 gold seeds'), findsNothing); // closed: nothing yet
      await open(tester);
      expect(find.text('+7 gold seeds'), findsOneWidget);
      expect(find.text('+20 XP'), findsOneWidget);
      expect(find.text('+50 gold seeds'), findsNothing);
      expect(find.textContaining('freeze'), findsNothing);
    });

    testWidgets('announces a level up', (tester) async {
      await pump(
        tester,
        const QuestReward(
            xpGained: 20, gemsGained: 5, levelUp: true, alreadyClaimed: false),
      );
      await open(tester);
      expect(find.text('Level up!'), findsOneWidget);
    });

    testWidgets('an already-opened gift does not promise anything',
        (tester) async {
      await pump(
        tester,
        const QuestReward(
            xpGained: 0, gemsGained: 0, levelUp: false, alreadyClaimed: true),
      );
      await open(tester);
      expect(find.text('This gift has already been opened.'), findsOneWidget);
      expect(find.textContaining('gold seeds'), findsNothing);
    });

    testWidgets('without a reward the gift opens and announces no amount',
        (tester) async {
      await pump(tester, null);
      await open(tester);
      expect(find.textContaining('gold seeds'), findsNothing);
      expect(find.textContaining('XP'), findsNothing);
      expect(find.text('Every small effort counts.'), findsOneWidget);
    });
  });
}
