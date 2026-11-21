import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/core/widgets/xp_toast.dart';

void main() {
  testWidgets('XpToast widget renders title, message and rewards', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: XpToast(
              title: 'Bien joué !',
              message: '2/3 pour ta quête',
              xp: 20,
              seeds: 5,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Bien joué !'), findsOneWidget);
    expect(find.text('2/3 pour ta quête'), findsOneWidget);
    expect(find.text('+20 XP'), findsOneWidget);
    expect(find.text('🌾 +5'), findsOneWidget);
  });
}
