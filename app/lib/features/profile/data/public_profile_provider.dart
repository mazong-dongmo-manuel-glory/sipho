import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';

class PublicProfile {
  final String uid;
  final String pseudo;
  final int level;
  final int streak;
  final String league;
  final List<String> badges;
  final int lessonsCompleted;

  const PublicProfile({
    required this.uid,
    this.pseudo = '',
    this.level = 1,
    this.streak = 0,
    this.league = 'bronze',
    this.badges = const [],
    this.lessonsCompleted = 0,
  });
}

final publicProfileProvider =
    StreamProvider.autoDispose.family<PublicProfile?, String?>((ref, uidArg) {
  final selfUid = ref.watch(authUidProvider);
  final uid = (uidArg == null || uidArg.isEmpty) ? selfUid : uidArg;
  if (uid == null) return Stream.value(null);

  return ref.watch(firestoreProvider).doc('publicProfiles/$uid').snapshots().map((snap) {
    final data = snap.data();
    if (data == null) {
      return PublicProfile(uid: uid);
    }
    final badges = (data['badges'] as List?)?.map((e) => e.toString()).toList() ??
        const <String>[];
    return PublicProfile(
      uid: uid,
      pseudo: (data['pseudo'] as String?) ??
          (data['displayName'] as String?) ??
          '',
      level: (data['level'] as num?)?.toInt() ?? 1,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      league: (data['league'] as String?) ??
          (data['leagueId'] as String?) ??
          'bronze',
      badges: badges,
      lessonsCompleted: (data['lessonsCompleted'] as num?)?.toInt() ??
          (data['lessons'] as num?)?.toInt() ??
          0,
    );
  });
});
