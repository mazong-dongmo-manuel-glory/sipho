import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/insights/domain/insight_text.dart';
import 'package:sipho/features/lessons/data/lesson_ai_tutor_service.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';

void main() {
  test('builds tutor prompt with real cents, guardrails, and lesson context',
      () {
    final prompt = buildLessonTutorPrompt(
      lesson: kCatalogLessons.first,
      selectedAnswer: 'Sous le matelas',
      answeredCorrectly: false,
      snapshot: const SpendSnapshot(
        locale: 'fr',
        currency: 'CAD',
        countryCode: 'CA',
        monthKey: '2026-11',
        incomeCents: 250000,
        fixedCents: 95000,
        categoryCents: {'groceries': 15000},
      ),
    );

    expect(prompt, contains('Le fonds d\'urgence'));
    expect(prompt, contains('Sous le matelas (incorrect)'));
    expect(prompt, contains('250000 cents'));
    expect(prompt, contains('95000 cents'));
    expect(prompt, contains('NEVER invent interest rates'));
  });

  test('parses valid tutor JSON and rejects empty example', () {
    final ok = parseLessonTutorReply(
      '{"example":"Avec 950 CAD de charges fixes, vise un premier coussin.","tip":"Mets de côté dès le jour de paie."}',
    );
    expect(ok?.example, contains('950 CAD'));
    expect(ok?.tip, contains('jour de paie'));
    expect(parseLessonTutorReply('{"example":"   ","tip":"x"}'), isNull);
  });
}
