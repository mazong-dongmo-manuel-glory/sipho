import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('welcome screen shows the Figma copy in order', (tester) async {
    // Figma frame includes Apple; force iOS so the button is visible in the test.
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump();

    const ordered = <String>[
      'Ton futur toi\nte dit merci.',
      'Deux minutes pour poser les premières bases.',
      'Pas besoin d’être expert.',
      'Continuer avec Apple',
      'Continuer avec Google',
      'En continuant, tu acceptes nos conditions et notre politique de confidentialité.',
      'Créer mon compte',
    ];

    var previousTop = -1.0;
    for (final text in ordered) {
      final finder = find.text(text);
      expect(finder, findsOneWidget);
      final top = tester.getTopLeft(finder).dy;
      expect(top, greaterThan(previousTop));
      previousTop = top;
    }

    expect(tester.takeException(), isNull);

    // Must clear before the binding verifies foundation invariants (tearDown is too late).
    debugDefaultTargetPlatformOverride = null;
  });
}
