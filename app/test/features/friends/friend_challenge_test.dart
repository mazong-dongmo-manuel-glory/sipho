import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/friends/domain/friend_challenge.dart';
import 'package:sipho/features/friends/domain/friends.dart';

void main() {
  group('FriendChallenge model', () {
    test('serialization roundtrip and getters', () {
      final now = DateTime(2026, 11, 18);
      final expires = now.add(const Duration(days: 7));

      final challenge = FriendChallenge(
        id: 'c1',
        pairId: 'p1',
        senderUid: 'userA',
        receiverUid: 'userB',
        senderName: 'Alice',
        receiverName: 'Bob',
        title: 'Marathon Savoir',
        description: '3 leçons à terminer',
        category: ChallengeCategory.learning,
        targetCount: 3,
        senderProgress: 2,
        receiverProgress: 1,
        rewardXp: 50,
        status: ChallengeStatus.active,
        createdAt: now,
        expiresAt: expires,
      );

      expect(challenge.isSender('userA'), isTrue);
      expect(challenge.isSender('userB'), isFalse);
      expect(challenge.myProgress('userA'), 2);
      expect(challenge.otherProgress('userA'), 1);
      expect(challenge.otherName('userA'), 'Bob');
      expect(challenge.myFraction('userA'), closeTo(2 / 3, 0.001));
      expect(challenge.isCompleted, isFalse);

      final map = challenge.toMap();
      final fromMap = FriendChallenge.fromMap('c1', map);

      expect(fromMap.id, 'c1');
      expect(fromMap.pairId, 'p1');
      expect(fromMap.senderUid, 'userA');
      expect(fromMap.receiverUid, 'userB');
      expect(fromMap.category, ChallengeCategory.learning);
      expect(fromMap.targetCount, 3);
      expect(fromMap.senderProgress, 2);
      expect(fromMap.receiverProgress, 1);
      expect(fromMap.rewardXp, 50);
      expect(fromMap.status, ChallengeStatus.active);
    });

    test('isCompleted triggers when progress meets target or status completed', () {
      final now = DateTime.now();
      final c1 = FriendChallenge(
        id: 'c1',
        pairId: 'p1',
        senderUid: 'u1',
        receiverUid: 'u2',
        senderName: 'U1',
        receiverName: 'U2',
        title: 'Test',
        description: 'Desc',
        category: ChallengeCategory.budget,
        targetCount: 3,
        senderProgress: 3,
        receiverProgress: 1,
        rewardXp: 30,
        status: ChallengeStatus.active,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 1)),
      );

      expect(c1.isCompleted, isTrue);

      final c2 = c1.copyWith(
        senderProgress: 1,
        status: ChallengeStatus.completed,
      );
      expect(c2.isCompleted, isTrue);
    });

    test('catalog templates are properly defined', () {
      expect(PredefinedChallengeTemplate.catalog, isNotEmpty);
      for (final t in PredefinedChallengeTemplate.catalog) {
        expect(t.title, isNotEmpty);
        expect(t.description, isNotEmpty);
        expect(t.targetCount, greaterThan(0));
        expect(t.rewardXp, greaterThan(0));
        expect(t.durationDays, greaterThan(0));
      }
    });
  });

  group('FriendshipRecord with shared streak', () {
    test('parses sharedStreak correctly', () {
      final record = FriendshipRecord.fromMap('p1', {
        'users': ['u1', 'u2'],
        'status': 'accepted',
        'requesterUid': 'u1',
        'sharedStreak': 5,
      });

      expect(record.sharedStreak, 5);

      final links = splitFriendships([record], 'u1');
      expect(links.friends.first.sharedStreak, 5);
    });
  });
}
