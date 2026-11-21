import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/core/widgets/category_chip.dart';

void main() {
  testWidgets('CategoryChip renders emoji and label correctly in standard mode', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryChip(
            emoji: '🍔',
            label: 'Restaurants',
            isSelected: true,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('🍔'), findsOneWidget);
    expect(find.text('Restaurants'), findsOneWidget);

    await tester.tap(find.text('🍔'));
    expect(tapped, isTrue);
  });

  testWidgets('CategoryChip renders icon in compact mode', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CategoryChip(
            icon: Icons.wifi_rounded,
            label: 'Internet',
            compact: true,
            isSelected: false,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.wifi_rounded), findsOneWidget);
    expect(find.text('Internet'), findsOneWidget);
  });
}
