import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/features/friends/data/friends_repository.dart';
import 'package:sipho/features/friends/data/phone_linker.dart';
import 'package:sipho/features/friends/domain/contacts.dart';
import 'package:sipho/features/friends/domain/friends.dart';
import 'package:sipho/features/friends/presentation/contacts_controller.dart';
import 'package:sipho/features/friends/presentation/friends_panel.dart';
import 'package:sipho/features/friends/presentation/friends_providers.dart';

import 'fake_phone_linker.dart';

FriendshipRecord _record(
  String id,
  List<String> users,
  String status,
  String requester,
) =>
    FriendshipRecord(
      pairId: id,
      users: users,
      status: status,
      requesterUid: requester,
    );

class _FakeRepository implements FriendsRepository {
  final calls = <String>[];
  FriendsFailure? failWith;
  FriendRequestOutcome outcome = FriendRequestOutcome.pending;

  void _maybeFail() {
    final failure = failWith;
    if (failure != null) throw FriendsException(failure);
  }

  @override
  Future<String> inviteCode() async => 'ABCD2345';

  @override
  Future<FriendRequestOutcome> sendRequest(String code) async {
    calls.add('send:$code');
    _maybeFail();
    return outcome;
  }

  @override
  Future<void> respond(String pairId, {required bool accept}) async {
    calls.add('respond:$pairId:$accept');
    _maybeFail();
  }

  @override
  Future<void> remove(String pairId) async {
    calls.add('remove:$pairId');
    _maybeFail();
  }

  @override
  Future<int> redeemReferral(String code) async {
    calls.add('redeem:$code');
    _maybeFail();
    return 25;
  }

  @override
  Stream<List<FriendshipRecord>> watchFriendships(String uid) =>
      const Stream.empty();

  @override
  Stream<PublicProfile?> watchPublicProfile(String uid) => const Stream.empty();

  // Contacts are covered in contacts_test.dart.
  @override
  Stream<bool> watchContactDiscovery(String uid) => Stream.value(false);

  @override
  Future<void> setContactDiscovery({required bool enabled}) async {}

  @override
  Future<List<ContactMatch>> findContacts(List<String> hashes) async => [];

  @override
  Future<FriendRequestOutcome> sendContactRequest(String targetUid) async =>
      FriendRequestOutcome.pending;
}

void main() {
  group('splitFriendships', () {
    test('sorts documents into friends, requests to answer and requests sent',
        () {
      final links = splitFriendships([
        _record('me_a', ['me', 'a'], 'accepted', 'a'),
        _record('b_me', ['b', 'me'], 'pending', 'b'), // b asked me
        _record('c_me', ['c', 'me'], 'pending', 'me'), // I asked c
      ], 'me');
      expect(links.friends.map((l) => l.uid), ['a']);
      expect(links.incoming.map((l) => l.uid), ['b']);
      expect(links.outgoing.map((l) => l.uid), ['c']);
      expect(links.incoming.single.pairId, 'b_me');
    });

    test('ignores documents of other people and malformed ones', () {
      final links = splitFriendships([
        _record('x_y', ['x', 'y'], 'accepted', 'x'),
        _record('empty', [], 'accepted', ''),
        _record('odd', ['me', 'z'], 'pending', 'nobody'),
      ], 'me');
      expect(links.isEmpty, isTrue);
    });
  });

  group('sortFriends', () {
    test('longest streak first, then level, then name', () {
      final sorted = sortFriends(const [
        PublicProfile(uid: '1', pseudo: 'Zoé', level: 2, streak: 5),
        PublicProfile(uid: '2', pseudo: 'Amy', level: 2, streak: 5),
        PublicProfile(uid: '3', pseudo: 'Bob', level: 9, streak: 5),
        PublicProfile(uid: '4', pseudo: 'Cal', level: 1, streak: 30),
      ]);
      expect(sorted.map((p) => p.pseudo), ['Cal', 'Bob', 'Amy', 'Zoé']);
    });
  });

  group('friend codes', () {
    test('typed or pasted codes are cleaned like the server does', () {
      expect(normalizeFriendCode(' abcd 2345\n'), 'ABCD2345');
      expect(isPlausibleFriendCode('ABCD2345'), isTrue);
    });

    test('obviously wrong input is rejected before any network call', () {
      expect(isPlausibleFriendCode(''), isFalse);
      expect(isPlausibleFriendCode('ABC'), isFalse);
      expect(isPlausibleFriendCode('A' * 21), isFalse);
      expect(isPlausibleFriendCode('AB CD!'), isFalse);
    });
  });

  group('friendsFailureFromCode', () {
    test('maps the server error codes the callables use', () {
      expect(friendsFailureFromCode('not-found'), FriendsFailure.codeNotFound);
      expect(
          friendsFailureFromCode('invalid-argument'), FriendsFailure.ownCode);
      expect(
          friendsFailureFromCode('already-exists'), FriendsFailure.alreadyDone);
      expect(friendsFailureFromCode('resource-exhausted'),
          FriendsFailure.limitReached);
      expect(friendsFailureFromCode('failed-precondition'),
          FriendsFailure.notAllowed);
      expect(friendsFailureFromCode('unavailable'), FriendsFailure.network);
      expect(friendsFailureFromCode('whatever'), FriendsFailure.unknown);
    });
  });

  group('PublicProfile.fromMap', () {
    test('keeps only what friends may see and tolerates missing data', () {
      final profile = PublicProfile.fromMap('u', {
        'pseudo': ' Amina ',
        'level': 4,
        'streak': 9,
        'league': 'gold',
        'secret': 123,
      });
      expect(profile.pseudo, 'Amina');
      expect(profile.level, 4);
      expect(profile.streak, 9);
      expect(profile.league, 'gold');

      final empty = PublicProfile.fromMap('u', null);
      expect(empty.pseudo, '');
      expect(empty.level, 1);
      expect(empty.streak, 0);
    });
  });

  group('FriendsPanel', () {
    late _FakeRepository repo;

    Future<void> pump(
      WidgetTester tester, {
      FriendLinks links = const FriendLinks(),
      Map<String, PublicProfile> profiles = const {},
    }) async {
      tester.view.physicalSize = const Size(900, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      repo = _FakeRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            friendsRepositoryProvider.overrideWithValue(repo),
            friendLinksProvider.overrideWith((ref) => Stream.value(links)),
            inviteCodeProvider.overrideWith((ref) => Future.value('ABCD2345')),
            contactDiscoveryProvider.overrideWith((ref) => Stream.value(false)),
            contactSuggestionsProvider.overrideWithValue(const []),
            phoneLinkerProvider.overrideWithValue(FakePhoneLinker()),
            for (final entry in profiles.entries)
              publicProfileProvider(entry.key)
                  .overrideWith((ref) => Stream.value(entry.value)),
          ],
          child: MaterialApp(
            locale: const Locale('fr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: FriendsPanel(onShare: (_) async {}),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows my code, the privacy promise and an empty state',
        (tester) async {
      await pump(tester);
      expect(find.text('ABCD2345'), findsOneWidget);
      expect(find.textContaining('Jamais tes montants'), findsOneWidget);
      expect(find.textContaining('Invite un ami pour vous encourager'),
          findsOneWidget);
    });

    testWidgets('lists friends by streak with level, streak and league only',
        (tester) async {
      await pump(
        tester,
        links: const FriendLinks(friends: [
          FriendLink(pairId: 'me_a', uid: 'a'),
          FriendLink(pairId: 'b_me', uid: 'b'),
        ]),
        profiles: const {
          'a': PublicProfile(
              uid: 'a', pseudo: 'Amina', level: 3, streak: 2, league: 'gold'),
          'b': PublicProfile(
              uid: 'b', pseudo: 'Bako', level: 5, streak: 12, league: 'bronze'),
        },
      );
      expect(find.text('Amina'), findsOneWidget);
      expect(find.text('Niveau 3 · 🔥 2 · Or'), findsOneWidget);
      expect(find.text('Niveau 5 · 🔥 12 · Bronze'), findsOneWidget);
      final bako = tester.getTopLeft(find.text('Bako')).dy;
      final amina = tester.getTopLeft(find.text('Amina')).dy;
      expect(bako, lessThan(amina));
    });

    testWidgets('an incoming request can be accepted or declined',
        (tester) async {
      await pump(
        tester,
        links: const FriendLinks(incoming: [
          FriendLink(pairId: 'b_me', uid: 'b'),
        ]),
        profiles: const {'b': PublicProfile(uid: 'b', pseudo: 'Bako')},
      );
      expect(find.text('Demandes reçues'), findsOneWidget);
      await tester.tap(find.text('Accepter'));
      await tester.pumpAndSettle();
      expect(repo.calls, ['respond:b_me:true']);

      await tester.tap(find.text('Refuser'));
      await tester.pumpAndSettle();
      expect(repo.calls.last, 'respond:b_me:false');
    });

    testWidgets('a sent request can be cancelled', (tester) async {
      await pump(
        tester,
        links: const FriendLinks(outgoing: [
          FriendLink(pairId: 'c_me', uid: 'c'),
        ]),
        profiles: const {'c': PublicProfile(uid: 'c', pseudo: 'Cléo')},
      );
      expect(find.text('Demandes envoyées'), findsOneWidget);
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(repo.calls, ['remove:c_me']);
    });

    testWidgets('adding a friend cleans the code and confirms', (tester) async {
      await pump(tester);
      await tester.enterText(find.byType(TextField).first, ' abcd 2345 ');
      await tester.tap(find.text('Envoyer la demande'));
      await tester.pumpAndSettle();
      expect(repo.calls, ['send:ABCD2345']);
      expect(find.text('Demande envoyée.'), findsOneWidget);
    });

    testWidgets('a request that crosses an incoming one says you are friends',
        (tester) async {
      await pump(tester);
      repo.outcome = FriendRequestOutcome.nowFriends;
      await tester.enterText(find.byType(TextField).first, 'ABCD2345');
      await tester.tap(find.text('Envoyer la demande'));
      await tester.pumpAndSettle();
      expect(find.text('Vous êtes maintenant amis !'), findsOneWidget);
    });

    testWidgets('an invalid code never reaches the server', (tester) async {
      await pump(tester);
      await tester.enterText(find.byType(TextField).first, 'a!');
      await tester.tap(find.text('Envoyer la demande'));
      await tester.pumpAndSettle();
      expect(repo.calls, isEmpty);
      expect(find.textContaining('code valide'), findsOneWidget);
    });

    testWidgets('server failures are explained, not hidden', (tester) async {
      await pump(tester);
      repo.failWith = FriendsFailure.codeNotFound;
      await tester.enterText(find.byType(TextField).first, 'ZZZZ9999');
      await tester.tap(find.text('Envoyer la demande'));
      await tester.pumpAndSettle();
      expect(find.textContaining("n'existe pas"), findsOneWidget);
    });

    testWidgets('removing a friend asks for confirmation first',
        (tester) async {
      await pump(
        tester,
        links: const FriendLinks(friends: [
          FriendLink(pairId: 'me_a', uid: 'a'),
        ]),
        profiles: const {'a': PublicProfile(uid: 'a', pseudo: 'Amina')},
      );
      await tester.tap(find.byTooltip('Retirer'));
      await tester.pumpAndSettle();
      expect(find.text('Retirer Amina de tes amis ?'), findsOneWidget);
      expect(repo.calls, isEmpty);

      await tester.tap(find.text('Retirer').last);
      await tester.pumpAndSettle();
      expect(repo.calls, ['remove:me_a']);
    });

    testWidgets('declining the confirmation keeps the friend', (tester) async {
      await pump(
        tester,
        links: const FriendLinks(friends: [
          FriendLink(pairId: 'me_a', uid: 'a'),
        ]),
        profiles: const {'a': PublicProfile(uid: 'a', pseudo: 'Amina')},
      );
      await tester.tap(find.byTooltip('Retirer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(repo.calls, isEmpty);
    });

    testWidgets('a referral code can be redeemed from the same screen',
        (tester) async {
      await pump(tester);
      await tester.tap(find.text("J'ai un code de parrainage"));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'wxyz 2345');
      await tester.tap(find.text('Valider le code'));
      await tester.pumpAndSettle();
      expect(repo.calls, ['redeem:WXYZ2345']);
      expect(find.textContaining('+25 XP'), findsOneWidget);
    });
  });
}
