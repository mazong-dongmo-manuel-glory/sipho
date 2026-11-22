import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/features/onboarding/presentation/nest_ready_screen.dart';

void main() {
  testWidgets('NestReady does not invent a hardcoded XP amount', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: NestReadyScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('+50 XP'), findsNothing);
    expect(find.textContaining('+50'), findsNothing);
  });
}
