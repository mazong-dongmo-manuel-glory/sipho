import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'callable_data.dart';
import 'firebase_providers.dart';

/// Service centralisant et typant tous les appels vers les Cloud Functions Sipho.
/// Région obligatoirement alignée sur us-central1 (cf. ADR-001 & fonctions backend).
class CloudFunctionsService {
  final FirebaseFunctions _functions;

  CloudFunctionsService(this._functions);

  /// Coche une dépense fixe du mois et attribue +10 XP serveur.
  Future<Map<String, dynamic>> markFixedPaid({
    required String fixedExpenseId,
    required String month, // format yyyy-MM
  }) async {
    try {
      final callable = _functions.httpsCallable('markFixedPaid');
      final result = await callable.call({
        'fixedExpenseId': fixedExpenseId,
        'month': month,
      });
      return callableDataMap(result.data);
    } catch (e) {
      // En mode hors ligne ou non authentifié, log sans crasher
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Valide la complétion d'une leçon, attribue XP, gemmes/graines et met à jour la série.
  Future<Map<String, dynamic>> completeLesson({
    required String lessonId,
    required int score,
    required bool perfect,
    int? durationSeconds,
  }) async {
    try {
      final callable = _functions.httpsCallable('completeLesson');
      final result = await callable.call({
        'lessonId': lessonId,
        'score': score,
        'perfect': perfect,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
      });
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Réclame la récompense d'une quête complétée (coffre / XP).
  Future<Map<String, dynamic>> claimQuest({required String questId}) async {
    try {
      final callable = _functions.httpsCallable('claimQuest');
      final result = await callable.call({'questId': questId});
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Rafraîchit les quêtes quotidiennes si un changement de jour ou rollover a eu lieu.
  Future<Map<String, dynamic>> refreshDailyQuests() async {
    try {
      final callable = _functions.httpsCallable('refreshDailyQuests');
      final result = await callable.call();
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Confirme une journée sans dépense (+15 XP).
  Future<Map<String, dynamic>> confirmNoSpend() async {
    try {
      final callable = _functions.httpsCallable('confirmNoSpend');
      final result = await callable.call();
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Répare une série perdue sous 24h avec des graines d'or.
  Future<Map<String, dynamic>> repairStreak() async {
    try {
      final callable = _functions.httpsCallable('repairStreak');
      final result = await callable.call();
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Rejoint la ligue hebdomadaire (groupes de 30 joueurs).
  Future<Map<String, dynamic>> joinLeague() async {
    try {
      final callable = _functions.httpsCallable('joinLeague');
      final result = await callable.call();
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Achat en boutique (gels de série, décorations du nid).
  Future<Map<String, dynamic>> buyShopItem({required String itemId}) async {
    try {
      final callable = _functions.httpsCallable('buyShopItem');
      final result = await callable.call({'itemId': itemId});
      return callableDataMap(result.data);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}

final cloudFunctionsServiceProvider = Provider<CloudFunctionsService>((ref) {
  final functions = ref.watch(firebaseFunctionsProvider);
  return CloudFunctionsService(functions);
});
