import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/features/expenses/domain/transaction.dart';
import 'package:sipho/features/expenses/presentation/expenses_list_screen.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('fr'),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('displays regular expense with category and amount', (tester) async {
    final tx = SiphoTransaction(
      id: 'tx1',
      amountCents: 4500,
      currency: 'CAD',
      category: 'restaurants',
      merchant: 'Café Paris',
      date: '2026-11-18',
      createdAt: DateTime(2026, 11, 18),
    );

    await tester.pumpWidget(_wrap(ExpenseTile(transaction: tx, userCurrency: 'CAD')));
    await tester.pumpAndSettle();

    expect(find.text('Café Paris'), findsOneWidget);
    expect(find.textContaining('Restos'), findsOneWidget);
    expect(find.textContaining('45'), findsOneWidget);
    expect(find.text('scanné'), findsNothing);
  });

  testWidgets('displays scanned badge for receipt transactions', (tester) async {
    final tx = SiphoTransaction(
      id: 'tx2',
      amountCents: 4849,
      currency: 'CAD',
      category: 'groceries',
      merchant: 'IGA',
      source: 'receipt',
      date: '2026-11-10',
      createdAt: DateTime(2026, 11, 10),
    );

    await tester.pumpWidget(_wrap(ExpenseTile(transaction: tx, userCurrency: 'CAD')));
    await tester.pumpAndSettle();

    expect(find.text('IGA'), findsOneWidget);
    expect(find.text('scanné'), findsOneWidget);
  });

  testWidgets('displays foreign conversion in subtitle and converted amount on right', (tester) async {
    final tx = SiphoTransaction(
      id: 'tx3',
      amountCents: 2500,
      currency: 'EUR',
      amountMainCents: 3680,
      fxRate: 1.472,
      category: 'leisure',
      merchant: 'Musée',
      date: '2026-11-12',
      createdAt: DateTime(2026, 11, 12),
    );

    await tester.pumpWidget(_wrap(ExpenseTile(transaction: tx, userCurrency: 'CAD')));
    await tester.pumpAndSettle();

    expect(find.text('Musée'), findsOneWidget);
    // Subtitle contains conversion arrow: 25,00 € → 36,80 $
    expect(find.textContaining('→'), findsOneWidget);
    expect(find.textContaining('25'), findsOneWidget);
    expect(find.textContaining('36,80'), findsWidgets);
  });
}
