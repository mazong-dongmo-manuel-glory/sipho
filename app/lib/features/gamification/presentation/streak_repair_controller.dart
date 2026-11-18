import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';

final streakRepairControllerProvider =
    NotifierProvider<StreakRepairController, bool>(StreakRepairController.new);

class StreakRepairController extends Notifier<bool> {
  @override
  bool build() => false;

  /// Returns true when the server repaired the streak.
  Future<bool> repair() async {
    if (state) return false;
    state = true;
    try {
      await ref
          .read(firebaseFunctionsProvider)
          .httpsCallable('repairStreak')
          .call<Map<String, dynamic>>();
      state = false;
      return true;
    } catch (error) {
      debugPrint('[Streak] repairStreak failed: $error');
      state = false;
      return false;
    }
  }
}
