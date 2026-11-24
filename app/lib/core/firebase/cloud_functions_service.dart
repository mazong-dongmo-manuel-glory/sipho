import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'callable_data.dart';
import 'firebase_providers.dart';

/// Service centralisant et typant tous les appels vers les Cloud Functions Sipho.
class CloudFunctionsService {
  final FirebaseFunctions _functions;

  CloudFunctionsService(this._functions);

  Future<Map<String, dynamic>> markFixedPaid({
    required String fixedId,
    required String monthKey,
  }) async {
    try {
      final callable = _functions.httpsCallable('markFixedPaid');
      final result = await callable.call({
        'fixedId': fixedId,
        'monthKey': monthKey,
      });
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> completeLesson({
    required String lessonId,
    required int score,
    required int durationSeconds,
    String? attemptId,
  }) async {
    try {
      final callable = _functions.httpsCallable('completeLesson');
      final result = await callable.call({
        'lessonId': lessonId,
        'score': score,
        'durationSeconds': durationSeconds < 2 ? 2 : durationSeconds,
        if (attemptId != null) 'attemptId': attemptId,
      });
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> claimQuest({required String questId}) async {
    try {
      final callable = _functions.httpsCallable('claimQuest');
      final result = await callable.call({'questId': questId});
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> refreshDailyQuests() async {
    try {
      final callable = _functions.httpsCallable('refreshDailyQuests');
      final result = await callable.call();
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> confirmNoSpend() async {
    try {
      final callable = _functions.httpsCallable('confirmNoSpend');
      final result = await callable.call();
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> repairStreak() async {
    try {
      final callable = _functions.httpsCallable('repairStreak');
      final result = await callable.call();
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> joinLeague() async {
    try {
      final callable = _functions.httpsCallable('joinLeague');
      final result = await callable.call();
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> buyShopItem({required String itemId}) async {
    try {
      final callable = _functions.httpsCallable('buyShopItem');
      final result = await callable.call({'itemId': itemId});
      return callableDataMap(result.data);
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
        'code': _fnCode(e),
        'reason': _fnReason(e),
      };
    }
  }

  Future<Map<String, dynamic>> equipShopItem({
    required String itemId,
    required bool equipped,
  }) async {
    try {
      final callable = _functions.httpsCallable('equipShopItem');
      final result = await callable.call({
        'itemId': itemId,
        'equipped': equipped,
      });
      return callableDataMap(result.data);
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
        'code': _fnCode(e),
        'reason': _fnReason(e),
      };
    }
  }

  Future<Map<String, dynamic>> getInviteCode() async {
    try {
      final callable = _functions.httpsCallable('getInviteCode');
      final result = await callable.call();
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> sendFriendRequest({required String referralCode}) async {
    try {
      final callable = _functions.httpsCallable('sendFriendRequest');
      final result = await callable.call({'referralCode': referralCode});
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString(), 'code': _fnCode(e)};
    }
  }

  Future<Map<String, dynamic>> respondFriendRequest({
    required String pairId,
    required bool accept,
  }) async {
    try {
      final callable = _functions.httpsCallable('respondFriendRequest');
      final result = await callable.call({'pairId': pairId, 'accept': accept});
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString(), 'code': _fnCode(e)};
    }
  }

  Future<Map<String, dynamic>> removeFriend({required String pairId}) async {
    try {
      final callable = _functions.httpsCallable('removeFriend');
      final result = await callable.call({'pairId': pairId});
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString(), 'code': _fnCode(e)};
    }
  }

  Future<Map<String, dynamic>> parseReceipt({required String storagePath}) async {
    try {
      final callable = _functions.httpsCallable(
        'parseReceipt',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
      );
      final result = await callable.call({'storagePath': storagePath});
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString(), 'code': _fnCode(e)};
    }
  }

  Future<Map<String, dynamic>> referralRedeem({required String referralCode}) async {
    try {
      final callable = _functions.httpsCallable('referralRedeem');
      final result = await callable.call({'referralCode': referralCode});
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString(), 'code': _fnCode(e)};
    }
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final callable = _functions.httpsCallable(
        'deleteAccount',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 120)),
      );
      final result = await callable.call({'confirmPhrase': 'DELETE MY ACCOUNT'});
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString(), 'code': _fnCode(e)};
    }
  }

  Future<Map<String, dynamic>> generateInsight({
    String focusTopic = 'general',
    bool acceptQuest = false,
    String? monthKey,
  }) async {
    try {
      final callable = _functions.httpsCallable(
        'generateInsight',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 45)),
      );
      final result = await callable.call({
        'focusTopic': focusTopic,
        'acceptQuest': acceptQuest,
        if (monthKey != null) 'monthKey': monthKey,
      });
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString(), 'code': _fnCode(e)};
    }
  }

  Future<Map<String, dynamic>> generateNextLesson({String? locale}) async {
    try {
      final callable = _functions.httpsCallable(
        'generateNextLesson',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
      );
      final result = await callable.call({
        if (locale != null) 'locale': locale,
      });
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString(), 'code': _fnCode(e)};
    }
  }

  Future<Map<String, dynamic>> generateCountryLessons({
    String? locale,
    String? slotId,
    bool forceNew = false,
  }) async {
    try {
      final callable = _functions.httpsCallable(
        'generateCountryLessons',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 90)),
      );
      final result = await callable.call({
        if (locale != null) 'locale': locale,
        if (slotId != null) 'slotId': slotId,
        'forceNew': forceNew,
      });
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString(), 'code': _fnCode(e)};
    }
  }

  Future<Map<String, dynamic>> createFriendChallenge({
    required String friendUid,
    required String templateId,
    String locale = 'fr',
  }) async {
    try {
      final callable = _functions.httpsCallable('createFriendChallenge');
      final result = await callable.call({
        'friendUid': friendUid,
        'templateId': templateId,
        'locale': locale,
      });
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString(), 'code': _fnCode(e)};
    }
  }

  Future<Map<String, dynamic>> respondFriendChallenge({
    required String pairId,
    required String challengeId,
    required bool accept,
  }) async {
    try {
      final callable = _functions.httpsCallable('respondFriendChallenge');
      final result = await callable.call({
        'pairId': pairId,
        'challengeId': challengeId,
        'accept': accept,
      });
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString(), 'code': _fnCode(e)};
    }
  }

  Future<Map<String, dynamic>> setContactDiscovery({required bool enabled}) async {
    try {
      final callable = _functions.httpsCallable('setContactDiscovery');
      final result = await callable.call({'enabled': enabled});
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString(), 'code': _fnCode(e)};
    }
  }

  Future<Map<String, dynamic>> findContacts({
    required List<String> hashes,
  }) async {
    try {
      final callable = _functions.httpsCallable('findContacts');
      final result = await callable.call({'hashes': hashes});
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString(), 'code': _fnCode(e)};
    }
  }

  Future<Map<String, dynamic>> sendContactFriendRequest({
    required String targetUid,
  }) async {
    try {
      final callable = _functions.httpsCallable('sendContactFriendRequest');
      final result = await callable.call({'targetUid': targetUid});
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString(), 'code': _fnCode(e)};
    }
  }

  String _fnCode(Object e) {
    if (e is FirebaseFunctionsException) return e.code;
    return 'unknown';
  }

  String? _fnReason(Object e) {
    if (e is! FirebaseFunctionsException) return null;
    final details = e.details;
    if (details is Map && details['reason'] != null) {
      return details['reason'].toString();
    }
    return null;
  }
}

final cloudFunctionsServiceProvider = Provider<CloudFunctionsService>((ref) {
  final functions = ref.watch(firebaseFunctionsProvider);
  return CloudFunctionsService(functions);
});
