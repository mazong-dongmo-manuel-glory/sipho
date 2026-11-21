import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/features/insights/data/insight_service.dart';
import 'package:sipho/features/insights/domain/insight_text.dart';
import 'package:sipho/features/insights/presentation/insight_detail_screen.dart';

Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('fr'),
      home: child,
    ),
  );
}

void main() {
  testWidgets('InsightDetailScreen displays active advice, quest and disclaimer', (tester) async {
    const testAdvice = InsightText(
      title: 'Attention aux restos',
      body: 'Tes sorties au resto ont augmenté de 38 % ce mois-ci.',
      suggestedQuest: SuggestedCoachQuest(
        name: '2 repas maison',
        description: '2 repas maison de plus cette semaine',
        type: 'COMPLETE_LESSON',
        target: 2,
      ),
      recommendedLessonId: 'needs_wants',
    );

    await tester.pumpWidget(
      _wrap(
        const InsightDetailScreen(),
        overrides: [
          activeCoachAdviceProvider.overrideWithValue(testAdvice),
          storedInsightsProvider.overrideWith((ref) => Stream.value([testAdvice])),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Conseils de Sipho'), findsWidgets);
    expect(find.text('Tes sorties au resto ont augmenté de 38 % ce mois-ci.'), findsOneWidget);
    expect(find.text('QUÊTE · +50 XP'), findsOneWidget);
    expect(find.text('2 repas maison de plus cette semaine'), findsOneWidget);
    expect(find.text('ACCEPTER LA QUÊTE'), findsOneWidget);
    expect(find.text('Plus tard'), findsOneWidget);

    final disclaimer = find.textContaining('Contenu éducatif');
    await tester.scrollUntilVisible(
      disclaimer,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(disclaimer, findsOneWidget);
  });
}
