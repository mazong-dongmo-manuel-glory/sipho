import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../domain/user_profile.dart';
import 'auth_repository.dart';

class UserRepository {
  final FirebaseFirestore _db;

  UserRepository(this._db);

  DocumentReference<Map<String, dynamic>> _ref(String uid) =>
      _db.collection('users').doc(uid);

  Stream<UserProfile?> watchProfile(String uid) {
    return _ref(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserProfile.fromFirestore(snap.data()!);
    });
  }

  Future<UserProfile?> getProfile(String uid) async {
    final snap = await _ref(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserProfile.fromFirestore(snap.data()!);
  }

  /// Crée le doc utilisateur (déclenche `onUserProfileCreate` côté serveur).
  Future<void> createProfile(String uid, UserProfile profile) async {
    await _ref(uid).set(
      {
        ...profile.toFirestoreCreate(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: false),
    );
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> patch) async {
    await _ref(uid).set(patch, SetOptions(merge: true));
  }

  Future<void> completeOnboarding(String uid, UserProfile profile) async {
    await _ref(uid).set(
      {
        ...profile.toFirestoreCreate(),
        'onboardingDone': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(firestoreProvider));
});

/// Profil live Firestore, ou valeurs locales si hors ligne / absent.
final userProfileStreamProvider = StreamProvider<UserProfile>((ref) {
  final uid = ref.watch(authUidProvider);
  if (uid == null) {
    return Stream.value(const UserProfile(onboardingDone: false));
  }
  final repo = ref.watch(userRepositoryProvider);
  return repo.watchProfile(uid).map(
        (p) => p ?? const UserProfile(onboardingDone: false),
      );
});
