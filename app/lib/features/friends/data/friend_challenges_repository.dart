import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/features/friends/domain/friend_challenge.dart';

final friendChallengesRepositoryProvider =
    Provider<FriendChallengesRepository>((ref) {
  return FriendChallengesRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseFunctionsProvider),
  );
});

/// Reads challenges from Firestore; every mutation goes through Cloud Functions
/// so XP and progress stay server-owned.
class FriendChallengesRepository {
  FriendChallengesRepository(this._firestore, this._functions);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  /// Stream of challenges for a specific friendship pair.
  Stream<List<FriendChallenge>> watchChallengesForPair(String pairId) {
    return _firestore
        .collection('friendships')
        .doc(pairId)
        .collection('challenges')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => [
            for (final doc in snap.docs)
              FriendChallenge.fromMap(doc.id, doc.data()),
          ],
        );
  }

  /// Creates a pending challenge from a server template. Returns the new id.
  Future<String> createChallenge({
    required String friendUid,
    required String templateId,
    String locale = 'fr',
  }) async {
    final data = await _call('createFriendChallenge', {
      'friendUid': friendUid,
      'templateId': templateId,
      'locale': locale,
    });
    final id = data['challengeId'];
    if (id is! String || id.isEmpty) {
      throw StateError('createFriendChallenge returned no challengeId');
    }
    return id;
  }

  /// Accepts or declines a pending challenge (receiver only).
  Future<void> respondChallenge({
    required String pairId,
    required String challengeId,
    required bool accept,
  }) async {
    await _call('respondFriendChallenge', {
      'pairId': pairId,
      'challengeId': challengeId,
      'accept': accept,
    });
  }

  Future<Map<Object?, Object?>> _call(
    String name,
    Map<String, Object?> payload,
  ) async {
    try {
      final result =
          await _functions.httpsCallable(name).call<Map<Object?, Object?>>(
                payload,
              );
      return result.data;
    } on FirebaseFunctionsException catch (error) {
      debugPrint('[FriendChallenges] $name failed: ${error.code}');
      rethrow;
    }
  }
}
