import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('welcome screen shows the Figma copy in order', (tester) async {
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
      'SIPHO',
      'Bienvenue\nchez Sipho !',
      'Le guide gamifié vers ta\nprospérité financière',
      'Continuer avec Apple',
      'Continuer avec Google',
      'En continuant, tu acceptes nos conditions\net notre politique de confidentialité.',
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
  });
}
