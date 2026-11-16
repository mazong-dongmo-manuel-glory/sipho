import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/core/feedback/feedback_settings.dart';
import 'package:sipho/core/sound/sound_service.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/finance/domain/user_finance.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/lessons/data/lesson_completion_repository.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';
import 'package:sipho/features/lessons/domain/lesson_result.dart';
import 'package:sipho/features/lessons/presentation/lesson_player_screen.dart';

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

class _FakeCompletion implements LessonCompletionRepository {
  _FakeCompletion({this.failuresBeforeSuccess = 0});

  int failuresBeforeSuccess;
  final calls = <({String lessonId, int score, int seconds})>[];

  @override
  Future<LessonResult> complete({
    required String lessonId,
    required int score,
    required int durationSeconds,
  }) async {
    calls.add((lessonId: lessonId, score: score, seconds: durationSeconds));
    if (failuresBeforeSuccess > 0) {
      failuresBeforeSuccess--;
      throw Exception('offline');
    }
    return LessonResult.fromCallable(
      {'xpGained': 20, 'seedsGained': 5},
      accuracy: score,
      durationSeconds: durationSeconds,
    );
  }
}

void main() {
  final lesson = kCatalogLessons.first;

  late _FakeCompletion completion;
  late GoRouter router;

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> open(WidgetTester tester, {_FakeCompletion? repo}) async {
    completion = repo ?? _FakeCompletion();
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('PATH')),
        ),
        GoRoute(
          path: '/lesson/:id',
          builder: (_, state) =>
              LessonPlayerScreen(lessonId: state.pathParameters['id']),
        ),
        GoRoute(
          path: '/lesson-done',
          builder: (_, state) => Scaffold(
            body: Text('DONE ${(state.extra! as LessonResult).xpGained}'),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          lessonCompletionRepositoryProvider.overrideWithValue(completion),
          userFinanceProvider.overrideWith((ref) => Stream.value(
                const UserFinance(
                  uid: 'u',
                  displayName: 'Amina',
                  currency: 'CAD',
                  monthlyIncomeCents: 0,
                ),
              )),
          transactionsForMonthProvider
              .overrideWith((ref, key) => Stream.value(const [])),
          activeFixedExpensesProvider
              .overrideWith((ref) => Stream.value(const [])),
          feedbackServiceProvider.overrideWithValue(
            FeedbackService(
              sound: SoundService(_SilentBackend()),
              settings: () => FeedbackSettings.defaults,
              haptic: (_) async {},
            ),
          ),
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
    unawaited(router.push('/lesson/${lesson.id}'));
    await settle(tester);
  }

  /// Answers [step] like a learner who knows the lesson.
  Future<void> playStep(
    WidgetTester tester,
    LessonStep step, {
    bool missFirst = false,
  }) async {
    switch (step) {
      case InfoStep():
        await tester.tap(find.text('CONTINUE'));
      case QuizStep():
        if (missFirst) {
          final wrong = step.choices.firstWhere((c) => !c.correct);
          await tester.tap(find.text(wrong.en));
          await tester.pump();
          await tester.tap(find.text('CHECK'));
          await settle(tester);
          expect(find.text('Not yet'), findsOneWidget);
          await tester.tap(find.text('TRY AGAIN'));
          await settle(tester);
        }
        await tester.tap(
          find.text(step.choices.firstWhere((c) => c.correct).en),
        );
        await tester.pump();
        await tester.tap(find.text('CHECK'));
        await settle(tester);
        expect(find.text('Excellent!'), findsOneWidget);
        await tester.tap(find.text('CONTINUE'));
      case TrueFalseStep():
        await tester.tap(find.text(step.answer ? 'True' : 'False'));
        await tester.pump();
        await tester.tap(find.text('CHECK'));
        await settle(tester);
        expect(find.text('Excellent!'), findsOneWidget);
        await tester.tap(find.text('CONTINUE'));
    }
    await settle(tester);
  }

  testWidgets('plays every step, then submits a perfect score', (tester) async {
    await open(tester);
    expect(find.text('DISCOVER'), findsOneWidget);

    for (final step in lesson.steps) {
      await playStep(tester, step);
    }

    // The recap page lists what to remember, then the lesson is submitted.
    expect(find.text('TO REMEMBER'), findsOneWidget);
    expect(find.text(lesson.takeaways.first.en), findsOneWidget);
    await tester.tap(find.text('FINISH'));
    await settle(tester);

    expect(completion.calls, hasLength(1));
    expect(completion.calls.single.lessonId, lesson.id);
    expect(completion.calls.single.score, 100);
    expect(find.text('DONE 20'), findsOneWidget);
  });

  testWidgets('a wrong answer costs accuracy but can be retried',
      (tester) async {
    await open(tester);
    var missed = false;
    for (final step in lesson.steps) {
      await playStep(tester, step, missFirst: step is QuizStep && !missed);
      if (step is QuizStep) missed = true;
    }
    await tester.tap(find.text('FINISH'));
    await settle(tester);

    final score = completion.calls.single.score;
    expect(score, lessonScore(questions: lesson.questionCount, misses: 1));
    expect(score, lessThan(100));
  });

  testWidgets('the check button waits for an answer', (tester) async {
    await open(tester);
    await tester.tap(find.text('CONTINUE'));
    await settle(tester);

    bool checkEnabled() => tester
        .widgetList<SiphoButton3D>(find.byType(SiphoButton3D))
        .single
        .enabled;
    expect(find.text('CHECK'), findsOneWidget);
    expect(checkEnabled(), isFalse);

    final quiz = lesson.steps[1] as QuizStep;
    await tester.tap(find.text(quiz.choices.first.en));
    await tester.pump();
    expect(checkEnabled(), isTrue);
  });

  testWidgets('a failed save keeps the learner on the lesson and can retry',
      (tester) async {
    await open(tester, repo: _FakeCompletion(failuresBeforeSuccess: 1));
    for (final step in lesson.steps) {
      await playStep(tester, step);
    }
    await tester.tap(find.text('FINISH'));
    await settle(tester);

    expect(find.text('DONE 20'), findsNothing);
    expect(find.textContaining("couldn't be saved"), findsOneWidget);

    await tester.tap(find.text('TRY AGAIN'));
    await settle(tester);
    expect(completion.calls, hasLength(2));
    expect(find.text('DONE 20'), findsOneWidget);
  });

  testWidgets('closing before starting leaves without asking', (tester) async {
    await open(tester);
    await tester.tap(find.byIcon(Icons.close));
    await settle(tester);
    expect(find.text('PATH'), findsOneWidget);
  });

  testWidgets('closing mid-lesson asks first; staying keeps the progress',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('CONTINUE'));
    await settle(tester);

    await tester.tap(find.byIcon(Icons.close));
    await settle(tester);
    expect(find.text('Leave the lesson?'), findsOneWidget);

    await tester.tap(find.text('STAY'));
    await settle(tester);
    expect(find.text('Leave the lesson?'), findsNothing);
    expect(find.text('QUESTION'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await settle(tester);
    await tester.tap(find.text('LEAVE'));
    await settle(tester);
    expect(find.text('PATH'), findsOneWidget);
    expect(completion.calls, isEmpty);
  });
}
