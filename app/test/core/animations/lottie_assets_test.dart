import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:sipho/core/animations/lottie_widget.dart';
import 'package:sipho/core/animations/sipho_lotties.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('bundled animations', () {
    for (final path in SiphoLotties.all) {
      test('$path is a valid Lottie file the player can parse', () async {
        final raw = await rootBundle.loadString(path);
        final json = jsonDecode(raw) as Map<String, dynamic>;
        expect(json['layers'], isA<List<dynamic>>());
        expect((json['layers'] as List).isNotEmpty, isTrue);

        final composition = await AssetLottie(path).load();
        expect(composition.duration, greaterThan(Duration.zero));
        expect(composition.bounds.width, greaterThan(0));
      });
    }

    test('the registry lists every file in assets/animations once', () async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final bundled = manifest
          .listAssets()
          .where((a) => a.startsWith('assets/animations/'))
          .toSet();
      expect(SiphoLotties.all.toSet(), bundled);
      expect(SiphoLotties.all.length, SiphoLotties.all.toSet().length);
    });

    test('preloading every animation completes without error', () async {
      await preloadSiphoLotties();
    });
  });

  group('LottieWidget', () {
    testWidgets('a missing file leaves an empty box instead of an error',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LottieWidget(
              assetPath: 'assets/animations/does_not_exist.json',
              width: 40,
              height: 30,
            ),
          ),
        ),
      );
      await tester.runAsync(() => Future<void>.delayed(
            const Duration(milliseconds: 50),
          ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(LottieWidget), findsOneWidget);
    });

    testWidgets('reduce animations freezes the animation', (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: LottieWidget(
                assetPath: SiphoLotties.confetti,
                width: 100,
                height: 100,
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(() => AssetLottie(SiphoLotties.confetti).load());
      await tester.pump();

      final lottie = tester.widget<Lottie>(find.byType(Lottie));
      expect(lottie.animate, isFalse);
      expect(lottie.repeat, isFalse);
    });

    testWidgets('animates by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LottieWidget(assetPath: SiphoLotties.trophyShine),
          ),
        ),
      );
      final lottie = tester.widget<Lottie>(find.byType(Lottie));
      expect(lottie.animate, isTrue);
    });
  });
}
