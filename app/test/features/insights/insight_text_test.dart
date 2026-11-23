import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/insights/domain/insight_text.dart';
import 'package:sipho/features/notifications/domain/notif_prefs.dart';

void main() {
  test(
      'the prompt contains the real cents, fixed base, goal, and no invented rate',
      () {
    final prompt = buildInsightPrompt(
      const SpendSnapshot(
        locale: 'fr',
        currency: 'CAD',
        countryCode: 'CA',
        monthKey: '2026-11',
        incomeCents: 300000,
        fixedCents: 120000,
        categoryCents: {'groceries': 4200, 'transport': 800},
        remainingCents: 175000,
        goal: 'save_for_project',
        focusTopic: 'spending',
        completedLessonIds: ['emergency_fund'],
      ),
    );

    expect(prompt, contains('groceries: 4200 cents'));
    expect(prompt, contains('transport: 800 cents'));
    expect(prompt, contains('Fixed monthly base: 120000 cents'));
    expect(prompt, contains('Total spent: 5000 cents'));
    expect(prompt, contains('175000 cents'));
    expect(prompt, contains('needs_wants'));
    expect(prompt.toLowerCase(), isNot(contains('3.4')));
    expect(prompt, contains('Do not invent a rate'));
  });

  test('parses full coach advice with action step, lesson link, and quest', () {
    final text = parseInsightText('''
{
  "title": "Épicerie maîtrisée",
  "body": "Tu as dépensé 42 CAD en épicerie.",
  "actionStep": "Note tes achats dès la caisse cette semaine.",
  "recommendedLessonId": "needs_wants",
  "suggestedQuest": {
    "name": "3 dépenses notées",
    "description": "Note 3 dépenses variables.",
    "type": "ADD_TRANSACTION",
    "target": 3
  }
}
''');
    expect(text?.title, 'Épicerie maîtrisée');
    expect(text?.body, 'Tu as dépensé 42 CAD en épicerie.');
    expect(text?.actionStep, 'Note tes achats dès la caisse cette semaine.');
    expect(text?.recommendedLessonId, 'needs_wants');
    expect(text?.suggestedQuest?.name, '3 dépenses notées');
    expect(text?.suggestedQuest?.target, 3);
    expect(parseInsightText('{"title":"x","body":"  "}'), isNull);
  });

  test(
      'parses stored weeklyInsights document shape (content + questSuggestions)',
      () {
    final mapped = parseInsightMap({
      'content': 'Bilan de la semaine.',
      'recommendedLessonId': 'unknown_lesson_id',
      'questSuggestions': [
        {
          'name': 'Faire une leçon',
          'description': 'Termine ta prochaine leçon.',
          'type': 'COMPLETE_LESSON',
          'target': 1,
        }
      ],
    }, id: '2026-W46');

    expect(mapped?.id, '2026-W46');
    expect(mapped?.body, 'Bilan de la semaine.');
    expect(mapped?.recommendedLessonId, 'track_spending');
    expect(mapped?.suggestedQuest?.type, 'COMPLETE_LESSON');
  });

  test('notification prefs round-trip the scheduler keys', () {
    const prefs = NotifPrefs.optedIn;
    final again = NotifPrefs.fromMap(prefs.toMap());
    expect(again.streakReminder, isTrue);
    expect(again.economy, isTrue);
    expect(again.toMap()['streakReminder'], isTrue);
  });
}
