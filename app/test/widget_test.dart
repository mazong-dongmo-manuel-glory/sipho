import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/main.dart';

void main() {
  testWidgets('SiphoApp smoke test - starts on SplashScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const SiphoApp());
    await tester.pumpAndSettle();

    // Vérifie la présence du logo et du slogan officiel selon Figma 2:28911
    expect(find.text('sipho'), findsOneWidget);
    expect(find.textContaining('Fais-toi un cadeau'), findsOneWidget);
    expect(find.text('FAIRE LE PREMIER PAS'), findsOneWidget);
  });
}
