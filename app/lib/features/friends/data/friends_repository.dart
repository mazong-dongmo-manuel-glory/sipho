import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/features/friends/domain/contacts.dart';
import 'package:sipho/features/friends/domain/friends.dart';

/// Thrown by [FriendsRepository] actions; the UI turns [failure] into a message.
class FriendsException implements Exception {
  const FriendsException(this.failure);

  final FriendsFailure failure;

  @override
  String toString() => 'FriendsException($failure)';
}

final friendsRepositoryProvider = Provider<FriendsRepository>((ref) {
  return FriendsRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseFunctionsProvider),
  );
});

/// Friends and invitations. Reads go straight to Firestore (read-only for the client); every
/// change goes through a Cloud Function, which owns the rules.
class FriendsRepository {
  FriendsRepository(this._firestore, this._functions);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  /// Every friendship (accepted and pending) the user is part of.
  Stream<List<FriendshipRecord>> watchFriendships(String uid) {
    return _firestore
        .collection('friendships')
        .where('users', arrayContains: uid)
        .snapshots()
        .map(
          (snap) => [
            for (final doc in snap.docs)
              FriendshipRecord.fromMap(doc.id, doc.data()),
          ],
        );
  }

  Stream<PublicProfile?> watchPublicProfile(String uid) {
    return _firestore.doc('publicProfiles/$uid').snapshots().map(
          (doc) => doc.exists ? PublicProfile.fromMap(uid, doc.data()) : null,
        );
  }

  /// The user's own invite code (created on first use, stable afterwards).
  Future<String> inviteCode() async {
    final data = await _call('getInviteCode', const {});
    final code = data['code'];
    if (code is! String || code.isEmpty) {
      throw const FriendsException(FriendsFailure.unknown);
    }
    return code;
  }

  Future<FriendRequestOutcome> sendRequest(String code) async {
    final data = await _call('sendFriendRequest', {'referralCode': code});
    return data['status'] == 'accepted'
        ? FriendRequestOutcome.nowFriends
        : FriendRequestOutcome.pending;
  }

  Future<void> respond(String pairId, {required bool accept}) async {
    await _call('respondFriendRequest', {'pairId': pairId, 'accept': accept});
  }

  Future<void> remove(String pairId) async {
    await _call('removeFriend', {'pairId': pairId});
  }

  /// Redeems a friend's invite code (once per account). Returns the XP gained.
  Future<int> redeemReferral(String code) async {
    final data = await _call('referralRedeem', {'referralCode': code});
    return (data['xpGained'] as num?)?.toInt() ?? 0;
  }

  /// Whether the user chose to be found (and to look people up) through contacts.
  Stream<bool> watchContactDiscovery(String uid) {
    return _firestore.doc('users/$uid/social/contacts').snapshots().map(
          (doc) => doc.data()?['enabled'] == true,
        );
  }

  /// Opts in or out of contact discovery. Opting in needs a verified e-mail on the account.
  Future<void> setContactDiscovery({required bool enabled}) async {
    await _call('setContactDiscovery', {'enabled': enabled});
  }

  /// Sipho users among [hashes] (SHA-256 of contacts' normalized e-mails), excluding me.
  Future<List<ContactMatch>> findContacts(List<String> hashes) async {
    final data = await _call('findContacts', {'hashes': hashes});
    final raw = data['matches'];
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is Map && item['uid'] is String && item['hash'] is String)
          ContactMatch(
            uid: item['uid'] as String,
            hash: item['hash'] as String,
          ),
    ];
  }

  /// Friend request to a user found through [findContacts].
  Future<FriendRequestOutcome> sendContactRequest(String targetUid) async {
    try {
      final data = await _call('sendContactFriendRequest', {
        'targetUid': targetUid,
      });
      return data['status'] == 'accepted'
          ? FriendRequestOutcome.nowFriends
          : FriendRequestOutcome.pending;
    } on FriendsException catch (error) {
      // Here "not found" means "cannot be reached from contacts", not "bad code".
      if (error.failure == FriendsFailure.codeNotFound) {
        throw const FriendsException(FriendsFailure.notAllowed);
      }
      rethrow;
    }
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
      debugPrint('[Friends] $name failed: ${error.code}');
      throw FriendsException(friendsFailureFromCode(error.code));
    } catch (error) {
      debugPrint('[Friends] $name failed: $error');
      throw const FriendsException(FriendsFailure.unknown);
    }
  }
}
