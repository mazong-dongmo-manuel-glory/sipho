import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/l10n/app_localizations_en.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/core/feedback/feedback_settings.dart';
import 'package:sipho/core/sound/sound_service.dart';
import 'package:sipho/features/gamification/data/game_state_repository.dart';
import 'package:sipho/features/gamification/domain/game_extras.dart';
import 'package:sipho/features/gamification/domain/game_state.dart';
import 'package:sipho/features/profile/data/shop_repository.dart';
import 'package:sipho/features/profile/domain/shop_catalog.dart';
import 'package:sipho/features/profile/presentation/shop_screen.dart';

class _SilentBackend implements SoundBackend {
  @override
  Future<void> init() async {}
  @override
  Future<void> play(String assetPath) async {}
  @override
  Future<void> preload(String assetPath) async {}
  @override
  Future<void> dispose() async {}
}

class _FakeShop implements ShopRepository {
  final calls = <String>[];
  ShopRefusal? refuse;

  @override
  Future<void> buy(String itemId) async {
    calls.add(itemId);
    final refusal = refuse;
    if (refusal != null) throw ShopException(refusal);
  }
}

ShopItem _item(String id) => kShopItems.firstWhere((i) => i.id == id);

void main() {
  group('shopItemStatus', () {
    test('a cosmetic is available when affordable and not owned', () {
      expect(
        shopItemStatus(_item('sun_hat'),
            gems: 120, freezes: 0, owned: const {}),
        ShopItemStatus.available,
      );
      expect(
        shopItemStatus(_item('sun_hat'),
            gems: 119, freezes: 0, owned: const {}),
        ShopItemStatus.tooExpensive,
      );
    });

    test('an owned cosmetic stays owned whatever the balance', () {
      expect(
        shopItemStatus(_item('sun_hat'),
            gems: 0, freezes: 0, owned: const {'sun_hat'}),
        ShopItemStatus.owned,
      );
    });

    test('a freeze is available below the cap, full at the cap', () {
      expect(
        shopItemStatus(_item('streak_freeze'),
            gems: 60, freezes: 1, owned: const {}),
        ShopItemStatus.available,
      );
      expect(
        shopItemStatus(_item('streak_freeze'),
            gems: 999, freezes: kMaxStreakFreezes, owned: const {}),
        ShopItemStatus.stockFull,
      );
    });

    test('server refusals map to their reason', () {
      expect(shopRefusalFromReason('already-owned'), ShopRefusal.alreadyOwned);
      expect(shopRefusalFromReason('max-stock'), ShopRefusal.maxStock);
      expect(shopRefusalFromReason('insufficient-seeds'),
          ShopRefusal.insufficientSeeds);
      expect(shopRefusalFromReason(null), ShopRefusal.other);
      expect(shopRefusalFromReason('???'), ShopRefusal.other);
    });
  });

  test('every item has a title and the owned items are read from the state',
      () {
    final l10n = AppLocalizationsEn();
    for (final item in kShopItems) {
      expect(shopItemTitle(l10n, item.id), isNot(item.id));
    }
    expect(
        parseGameExtras({
          'ownedItems': ['sun_hat', 'scarf_clay']
        }).ownedItems,
        {'sun_hat', 'scarf_clay'});
    expect(parseGameExtras({'ownedItems': 'oops'}).ownedItems, isEmpty);
    expect(parseGameExtras({}).ownedItems, isEmpty);
  });

  test('catalog ids, prices and kinds match the server (shared/shop.ts)', () {
    final file = File('../functions/src/shared/shop.ts');
    if (!file.existsSync()) {
      markTestSkipped('functions/ not found from the app directory');
      return;
    }
    final source = file.readAsStringSync();
    final server = [
      for (final m in RegExp(
        r'id:\s*"(\w+)",\s*price:\s*(\d+),\s*kind:\s*"(\w+)"',
      ).allMatches(source))
        '${m.group(1)}:${m.group(2)}:${m.group(3)}',
    ];
    final app = [
      for (final item in kShopItems)
        '${item.id}:${item.price}:${item.kind.name}',
    ];
    expect(app, server);
    final cap = int.parse(
      RegExp(r'MAX_STREAK_FREEZES\s*=\s*(\d+)').firstMatch(source)!.group(1)!,
    );
    expect(kMaxStreakFreezes, cap);
  });

  group('ShopScreen', () {
    Future<_FakeShop> pump(
      WidgetTester tester, {
      required GameState game,
      Set<String> owned = const {},
    }) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final shop = _FakeShop();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shopRepositoryProvider.overrideWithValue(shop),
            gameStateStreamProvider.overrideWith((ref) => Stream.value(game)),
            gameExtrasStreamProvider.overrideWith(
                (ref) => Stream.value(GameExtras(ownedItems: owned))),
            feedbackServiceProvider.overrideWithValue(
              FeedbackService(
                sound: SoundService(_SilentBackend()),
                settings: () => FeedbackSettings.defaults,
                haptic: (_) async {},
              ),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ShopScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      return shop;
    }

    GameState state({int gems = 0, int freezes = 0}) => GameState(
          gems: gems,
          level: 4,
          streak: StreakInfo(current: 3, freezes: freezes),
        );

    testWidgets('shows the real balance, streak and level, not placeholders',
        (tester) async {
      await pump(tester, game: state(gems: 77));
      expect(find.text('🌾  77'), findsOneWidget);
      expect(find.text('🔥  3'), findsOneWidget);
      expect(find.text('🌾  340'), findsNothing);
      expect(find.text('🔥  12'), findsNothing);
    });

    testWidgets('an affordable item is bought on tap', (tester) async {
      final shop = await pump(tester, game: state(gems: 200));
      await tester.tap(find.text('Buy').first);
      await tester.pumpAndSettle();
      expect(shop.calls, ['sun_hat']);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Sun hat is yours!'), findsOneWidget);
    });

    testWidgets('an item that costs too much cannot be bought', (tester) async {
      final shop = await pump(tester, game: state(gems: 10));
      expect(find.text('Buy'), findsNothing);
      expect(find.text('Not enough seeds'), findsNWidgets(kShopItems.length));
      await tester.tap(find.text('Not enough seeds').first);
      await tester.pumpAndSettle();
      expect(shop.calls, isEmpty);
    });

    testWidgets('owned items and a full freeze stock are shown as such',
        (tester) async {
      final shop = await pump(
        tester,
        game: state(gems: 1000, freezes: 2),
        owned: {'sun_hat'},
      );
      expect(find.text('Owned'), findsOneWidget);
      expect(find.text('Stock full'), findsOneWidget);
      expect(find.text('2/2 in stock'), findsOneWidget);

      await tester.tap(find.text('Owned'));
      await tester.tap(find.text('Stock full'));
      await tester.pumpAndSettle();
      expect(shop.calls, isEmpty);
    });

    testWidgets('a refusal from the server is explained', (tester) async {
      final shop = await pump(tester, game: state(gems: 200));
      shop.refuse = ShopRefusal.alreadyOwned;
      await tester.tap(find.text('Buy').first);
      await tester.pumpAndSettle();
      expect(find.text('You already own this one.'), findsOneWidget);
    });
  });
}
