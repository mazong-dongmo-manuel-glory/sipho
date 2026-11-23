import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/features/leaderboard/domain/league.dart';

final leagueRepositoryProvider = Provider<LeagueRepository>((ref) {
  return LeagueRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseFunctionsProvider),
  );
});

class LeagueRepository {
  LeagueRepository(this._firestore, this._functions);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  /// Asks the server for this week's group (it joins one if needed). Idempotent.
  Future<LeagueMembership> join() async {
    try {
      final result = await _functions
          .httpsCallable('joinLeague')
          .call<Map<Object?, Object?>>();
      return LeagueMembership.fromCallable(result.data);
    } catch (error) {
      // `unauthenticated` usually means App Check rejected this build (debug token not
      // registered in Firebase Console > App Check) or the user is signed out.
      debugPrint('joinLeague failed: $error');
      rethrow;
    }
  }

  /// Live ranking rows of a group (read-only: written by Cloud Functions).
  Stream<List<LeagueMember>> watchMembers(String leagueKey) {
    return _firestore
        .collection('leagues/$leagueKey/members')
        .orderBy('weeklyXp', descending: true)
        .limit(30)
        .snapshots()
        .map(
          (snapshot) => rankLeagueMembers(
            snapshot.docs
                .map((doc) => LeagueMember.fromMap(doc.id, doc.data())),
          ),
        );
  }

  Stream<LeagueLastResult?> watchLastResult(String uid) {
    return _firestore
        .doc('users/$uid/league/lastResult')
        .snapshots()
        .map((doc) => LeagueLastResult.fromMap(doc.data()));
  }
}
