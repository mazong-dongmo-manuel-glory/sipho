import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/features/splash/presentation/splash_screen.dart';

void main() {
  testWidgets('splash shows the wordmark, tagline, and first-step button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SplashScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('sipho'), findsOneWidget);
    expect(find.textContaining('Fais-toi un cadeau'), findsOneWidget);
    expect(find.text('Faire le premier pas'), findsOneWidget);
  });
}
