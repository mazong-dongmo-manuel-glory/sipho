import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/features/profile/domain/shop_catalog.dart';

/// A purchase that did not go through.
class ShopException implements Exception {
  const ShopException(this.refusal);

  final ShopRefusal refusal;

  @override
  String toString() => 'ShopException($refusal)';
}

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepository(ref.watch(firebaseFunctionsProvider));
});

/// Buys shop items through the `buyShopItem` Cloud Function: the server prices
/// the item and checks the rules; seeds are never written by the app.
class ShopRepository {
  ShopRepository(this._functions);

  final FirebaseFunctions _functions;

  /// Throws [ShopException] when the purchase is refused or fails.
  Future<void> buy(String itemId) async {
    try {
      await _functions.httpsCallable('buyShopItem').call<Object?>({
        'itemId': itemId,
      });
    } on FirebaseFunctionsException catch (error) {
      debugPrint('[Shop] buy $itemId failed: ${error.code}');
      final details = error.details;
      throw ShopException(
        shopRefusalFromReason(details is Map ? details['reason'] : null),
      );
    } catch (error) {
      debugPrint('[Shop] buy $itemId failed: $error');
      throw const ShopException(ShopRefusal.other);
    }
  }
}
