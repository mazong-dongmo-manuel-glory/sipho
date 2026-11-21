/// A friendship document (`friendships/{pairId}`), written by Cloud Functions only.
class FriendshipRecord {
  const FriendshipRecord({
    required this.pairId,
    required this.users,
    required this.status,
    required this.requesterUid,
    this.sharedStreak = 0,
  });

  factory FriendshipRecord.fromMap(String id, Map<String, dynamic> data) {
    final rawUsers = data['users'];
    return FriendshipRecord(
      pairId: id,
      users: rawUsers is List ? [for (final u in rawUsers) u.toString()] : [],
      status: (data['status'] as String?) ?? 'pending',
      requesterUid: (data['requesterUid'] as String?) ?? '',
      sharedStreak: (data['sharedStreak'] as num?)?.toInt() ?? 0,
    );
  }

  final String pairId;
  final List<String> users;
  final String status; // pending | accepted
  final String requesterUid;
  final int sharedStreak;

  bool get isAccepted => status == 'accepted';

  /// The other member of the pair, or `null` when [me] is not part of it.
  String? otherUid(String me) {
    if (!users.contains(me)) return null;
    for (final u in users) {
      if (u != me) return u;
    }
    return null;
  }
}

/// One friendship seen from the signed-in user's side.
class FriendLink {
  const FriendLink({
    required this.pairId,
    required this.uid,
    this.sharedStreak = 0,
  });

  final String pairId;

  /// The friend (or the person who asked / was asked).
  final String uid;

  /// Consecutive active days together.
  final int sharedStreak;
}

class FriendLinks {
  const FriendLinks({
    this.friends = const [],
    this.incoming = const [],
    this.outgoing = const [],
  });

  final List<FriendLink> friends;

  /// Requests that wait for my answer.
  final List<FriendLink> incoming;

  /// Requests I sent that were not answered yet.
  final List<FriendLink> outgoing;

  bool get isEmpty => friends.isEmpty && incoming.isEmpty && outgoing.isEmpty;
}

/// Splits raw friendship documents into friends, requests to answer and requests sent.
/// Documents that do not involve [me], or are malformed, are ignored.
FriendLinks splitFriendships(List<FriendshipRecord> records, String me) {
  final friends = <FriendLink>[];
  final incoming = <FriendLink>[];
  final outgoing = <FriendLink>[];
  for (final r in records) {
    final other = r.otherUid(me);
    if (other == null) continue;
    final link = FriendLink(
      pairId: r.pairId,
      uid: other,
      sharedStreak: r.sharedStreak,
    );
    if (r.isAccepted) {
      friends.add(link);
    } else if (r.requesterUid == me) {
      outgoing.add(link);
    } else if (r.requesterUid == other) {
      incoming.add(link);
    }
  }
  return FriendLinks(friends: friends, incoming: incoming, outgoing: outgoing);
}

/// What a friend may see: the public profile only, never any amount.
class PublicProfile {
  const PublicProfile({
    required this.uid,
    required this.pseudo,
    this.level = 1,
    this.streak = 0,
    this.league = 'bronze',
  });

  factory PublicProfile.fromMap(String uid, Map<String, dynamic>? data) {
    return PublicProfile(
      uid: uid,
      pseudo: ((data?['pseudo'] as String?) ?? '').trim(),
      level: (data?['level'] as num?)?.toInt() ?? 1,
      streak: (data?['streak'] as num?)?.toInt() ?? 0,
      league: (data?['league'] as String?) ?? 'bronze',
    );
  }

  final String uid;
  final String pseudo;
  final int level;
  final int streak;
  final String league;
}

/// Friends with the longest streak first, then the highest level, then by name, so every
/// device shows the same order.
List<PublicProfile> sortFriends(Iterable<PublicProfile> friends) {
  final sorted = friends.toList()
    ..sort((a, b) {
      final byStreak = b.streak.compareTo(a.streak);
      if (byStreak != 0) return byStreak;
      final byLevel = b.level.compareTo(a.level);
      if (byLevel != 0) return byLevel;
      final byName = a.pseudo.toLowerCase().compareTo(b.pseudo.toLowerCase());
      return byName != 0 ? byName : a.uid.compareTo(b.uid);
    });
  return sorted;
}

final RegExp _codeChars = RegExp(r'^[A-Z0-9_-]+$');

/// A typed or pasted friend code, cleaned the way the server does it: trimmed and upper-cased,
/// with inner spaces removed (codes are often copied with a line break or a space).
String normalizeFriendCode(String raw) =>
    raw.replaceAll(RegExp(r'\s+'), '').toUpperCase();

/// Whether [code] could be a code at all (the server is the judge of whether it exists).
bool isPlausibleFriendCode(String code) =>
    code.length >= 4 && code.length <= 20 && _codeChars.hasMatch(code);

/// Why a friends action failed, in terms the UI can explain.
enum FriendsFailure {
  codeNotFound,
  ownCode,
  alreadyDone,
  limitReached,
  network,
  notAllowed,
  unknown,
}

/// Maps a Cloud Functions error code to a [FriendsFailure].
FriendsFailure friendsFailureFromCode(String code) {
  switch (code) {
    case 'not-found':
      return FriendsFailure.codeNotFound;
    case 'invalid-argument':
      return FriendsFailure.ownCode;
    case 'already-exists':
      return FriendsFailure.alreadyDone;
    case 'resource-exhausted':
      return FriendsFailure.limitReached;
    case 'failed-precondition':
    case 'permission-denied':
      return FriendsFailure.notAllowed;
    case 'unavailable':
    case 'deadline-exceeded':
      return FriendsFailure.network;
    default:
      return FriendsFailure.unknown;
  }
}

/// Outcome of sending a friend request.
enum FriendRequestOutcome { pending, nowFriends }
