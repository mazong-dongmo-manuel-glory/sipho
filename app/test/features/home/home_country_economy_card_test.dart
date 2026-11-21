import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/features/economy/data/economy_repository.dart';
import 'package:sipho/features/economy/domain/economy_data.dart';
import 'package:sipho/features/economy/domain/economy_news.dart';
import 'package:sipho/features/finance/domain/user_finance.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/home/presentation/home_country_economy_card.dart';

void main() {
  testWidgets('shows country chips and local headline on home', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userFinanceProvider.overrideWith(
            (ref) => Stream.value(
              const UserFinance(
                uid: 'u1',
                displayName: 'Amina',
                currency: 'CAD',
                countryCode: 'CA',
                monthlyIncomeCents: 280000,
              ),
            ),
          ),
          userEconomyProvider.overrideWith(
            (ref) => Stream.value(
              const EconomyData(
                countryCode: 'CA',
                indicators: {
                  'inflation': IndicatorItem(
                    value: 2.1,
                    unit: '%',
                    source: 'StatCan',
                    date: '2026-10',
                  ),
                  'policy_rate': IndicatorItem(
                    value: 3.75,
                    unit: '%',
                    source: 'BoC',
                    date: '2026-10',
                  ),
                },
              ),
            ),
          ),
          userEconomyNewsProvider.overrideWith(
            (ref) => Stream.value(
              const EconomyNewsFeed(
                countryCode: 'CA',
                fetchedAt: null,
                provider: 'test',
                items: [
                  EconomyNewsItem(
                    id: '1',
                    title: 'Inflation reste proche de 2 %',
                    takeaway: 'Ton budget courses reste le levier principal.',
                    topic: 'inflation',
                    emoji: '📈',
                    source: 'Test',
                    url: 'https://example.com',
                  ),
                ],
              ),
            ),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: HomeCountryEconomyCard()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Économie · CA'), findsOneWidget);
    expect(find.textContaining('Inflation 2,1%'), findsOneWidget);
    expect(find.textContaining('Taux directeur 3,75%'), findsOneWidget);
    expect(find.textContaining('Inflation reste proche de 2 %'), findsOneWidget);
  });
}
