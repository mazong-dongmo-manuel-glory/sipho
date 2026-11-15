import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';

/// Calls `confirmNoSpend`: "I spent nothing today". The server prolongs the streak and records
/// the confirmation; the UI hides the button once the game state stream reflects it.
class NoSpendController extends Notifier<bool> {
  @override
  bool build() => false; // true while a confirmation is in flight

  Future<bool> confirm() async {
    if (state) return false;
    state = true;
    try {
      await ref
          .read(firebaseFunctionsProvider)
          .httpsCallable('confirmNoSpend')
          .call<Map<String, dynamic>>();
      return true;
    } catch (error) {
      debugPrint('[NoSpend] confirmNoSpend failed: $error');
      return false;
    } finally {
      state = false;
    }
  }
}

final noSpendControllerProvider =
    NotifierProvider<NoSpendController, bool>(NoSpendController.new);
