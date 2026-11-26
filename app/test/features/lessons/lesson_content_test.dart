import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/core/feedback/feedback_settings.dart';
import 'package:sipho/core/sound/sound_catalog.dart';
import 'package:sipho/features/gamification/domain/game_cues.dart';
import 'package:sipho/features/gamification/domain/game_state.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';
import 'package:sipho/features/lessons/domain/lesson_content.dart';
import 'package:sipho/features/lessons/domain/lesson_score.dart';

void main() {
  test('every catalog lesson has its own quiz text', () {
    final emergency = lessonContentFor('emergency_fund').questionFr;
    for (final id in kAllLessonIds) {
      final content = kLessonContent[id];
      expect(content, isNotNull, reason: id);
      if (id != 'emergency_fund') {
        expect(
          content!.questionFr,
          isNot(emergency),
          reason: '$id still shows the emergency-fund quiz',
        );
      }
      expect(content!.optionsFr.length, 4);
      expect(content.optionsEn.length, 4);
      expect(content.correctIndex, inInclusiveRange(0, 3));
      expect(content.optionsFr.every((o) => o.trim().isNotEmpty), isTrue);
      expect(content.simOptionsFr.length, 3);
      expect(content.simCorrectIndex, inInclusiveRange(0, 2));
      expect(lessonContentFor(id).questionFr, content.questionFr);
    }
    expect(lessonContentFor('missing').questionFr, emergency);
    expect(
      lessonContentFor('needs_wants').optionsFr[3],
      'Restaurant gastronomique',
    );
  });

  test('earlier true/false and simulation misses block a perfect score', () {
    expect(
      lessonMistakesAfterAnswer(
        priorMistakes: 0,
        answered: false,
        correct: false,
      ),
      0,
    );
    expect(
      lessonMistakesAfterAnswer(
        priorMistakes: 0,
        answered: true,
        correct: false,
      ),
      1,
    );
    expect(
      lessonCompletionScore(priorMistakes: 0, quizEverWrong: false),
      100,
    );
    expect(
      lessonCompletionScore(priorMistakes: 1, quizEverWrong: false),
      70,
    );
    expect(
      lessonCompletionScore(priorMistakes: 0, quizEverWrong: true),
      70,
    );
  });

  test('cues map to distinct celebration sounds', () {
    expect(cueEffect(SiphoCue.expenseAdded).sound, SiphoSound.ding);
    expect(cueEffect(SiphoCue.lessonWrong).haptic, isNull);
    expect(cueEffect(SiphoCue.softError).sound, SiphoSound.softError);
    expect(cueEffect(SiphoCue.lessonDone).sound, SiphoSound.lessonDone);
    expect(cueEffect(SiphoCue.budgetAlert).sound, SiphoSound.uhOh);
    expect(cueEffect(SiphoCue.giftOpened).voice, SiphoSound.siphoHappy);
  });

  test('game changes celebrate the strongest cue only', () {
    const base = GameState(level: 2, streakDays: 3, leagueId: 'bronze');
    expect(cueForGameChange(null, base), isNull);
    expect(
      cueForGameChange(base, base.copyWith(level: 3, streakDays: 4)),
      SiphoCue.levelUp,
    );
    expect(
      cueForGameChange(base, base.copyWith(leagueId: 'silver')),
      SiphoCue.leagueUp,
    );
    expect(
      cueForGameChange(base, base.copyWith(badges: const ['builder'])),
      SiphoCue.badgeUnlocked,
    );
    expect(
      cueForGameChange(base, base.copyWith(streakDays: 4)),
      SiphoCue.streakExtended,
    );
    expect(cueForGameChange(base, base.copyWith(seeds: 10)), isNull);
  });

  test('feedback prefs round-trip and keep defaults', () {
    expect(FeedbackSettings.fromStored(null), FeedbackSettings.defaults);
    expect(FeedbackSettings.fromStored(''), FeedbackSettings.defaults);
    const custom = FeedbackSettings(sounds: false, haptics: true, voice: true);
    expect(FeedbackSettings.fromStored(custom.stored), custom);
  });
}
