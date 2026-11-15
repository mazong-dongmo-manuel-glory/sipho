import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/friends/data/contacts_source.dart';
import 'package:sipho/features/friends/data/friends_repository.dart';
import 'package:sipho/features/friends/data/phone_linker.dart';
import 'package:sipho/features/friends/domain/contacts.dart';
import 'package:sipho/features/friends/domain/friends.dart';
import 'package:sipho/features/friends/presentation/contacts_controller.dart';
import 'package:sipho/features/friends/presentation/contacts_section.dart';
import 'package:sipho/features/friends/presentation/friends_providers.dart';

import 'fake_phone_linker.dart';

class _FakeUser implements User {
  @override
  String get uid => 'me';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSource implements ContactsSource {
  _FakeSource(this.contacts, {this.access = ContactsAccess.granted});

  final List<DeviceContact> contacts;
  ContactsAccess access;
  int accessCalls = 0;
  int loadCalls = 0;
  int settingsCalls = 0;

  @override
  Future<ContactsAccess> requestAccess() async {
    accessCalls++;
    return access;
  }

  @override
  Future<List<DeviceContact>> load() async {
    loadCalls++;
    return contacts;
  }

  @override
  Future<void> openSettings() async => settingsCalls++;
}

class _FakeRepository extends Fake implements FriendsRepository {
  _FakeRepository({this.enabled = false, this.onSipho = const {}});

  bool enabled;

  /// hash -> uid of the Sipho accounts the server would find.
  final Map<String, String> onSipho;
  final calls = <String>[];
  FriendsFailure? failWith;
  final _changes = StreamController<bool>.broadcast();

  @override
  Stream<bool> watchContactDiscovery(String uid) async* {
    yield enabled;
    yield* _changes.stream;
  }

  @override
  Future<void> setContactDiscovery({required bool enabled}) async {
    calls.add('discovery:$enabled');
    final failure = failWith;
    if (failure != null) throw FriendsException(failure);
    this.enabled = enabled;
    _changes.add(enabled);
  }

  @override
  Future<List<ContactMatch>> findContacts(List<String> hashes) async {
    calls.add('find:${hashes.length}');
    return [
      for (final hash in hashes)
        if (onSipho.containsKey(hash))
          ContactMatch(uid: onSipho[hash]!, hash: hash),
    ];
  }

  @override
  Future<FriendRequestOutcome> sendContactRequest(String targetUid) async {
    calls.add('request:$targetUid');
    return FriendRequestOutcome.pending;
  }

  @override
  Stream<PublicProfile?> watchPublicProfile(String uid) =>
      Stream.value(PublicProfile(uid: uid, pseudo: 'pseudo_$uid'));
}

DeviceContact _contact(
  String id,
  String name, {
  List<String> emails = const [],
  List<String> phones = const [],
}) =>
    DeviceContact(id: id, name: name, emails: emails, phones: phones);

String _hash(String email) => hashContactEmail(email);

void main() {
  group('contact e-mail fingerprints', () {
    test('normalization trims, lower-cases and rejects non-addresses', () {
      expect(normalizeContactEmail('  Awa.Diop@Example.COM '),
          'awa.diop@example.com');
      expect(normalizeContactEmail(''), isNull);
      expect(normalizeContactEmail('not-an-email'), isNull);
      expect(normalizeContactEmail('a@b'), isNull);
      expect(normalizeContactEmail('a b@c.com'), isNull);
      expect(normalizeContactEmail(null), isNull);
      expect(normalizeContactEmail('${'a' * 250}@b.co'), isNull);
    });

    // Same vector as functions/src/__tests__/contacts.test.ts: both sides must agree.
    test('hash matches the server for a known address', () {
      expect(
        hashContactEmail('awa@example.com'),
        '462ca6eb415951837196183616b1ec6e1ea779a1cf66967aaaa4666460dfc36c',
      );
    });
  });

  group('phone numbers', () {
    test('international numbers are taken as they are', () {
      expect(normalizeContactPhone('+225 07 07 07 07 07'), '+2250707070707');
      expect(normalizeContactPhone('+1 (514) 555-1234'), '+15145551234');
      expect(normalizeContactPhone('0033 6 12 34 56 78'), '+33612345678');
    });

    test('a local number is completed with the user\'s country', () {
      // Côte d'Ivoire: the leading 0 is part of the number since 2021.
      expect(normalizeContactPhone('07 07 07 07 07', countryCode: 'CI'),
          '+2250707070707');
      // France: the leading 0 is a trunk prefix.
      expect(normalizeContactPhone('06 12 34 56 78', countryCode: 'FR'),
          '+33612345678');
      expect(normalizeContactPhone('77 123 45 67', countryCode: 'sn'),
          '+221771234567');
      expect(normalizeContactPhone('(514) 555-1234', countryCode: 'CA'),
          '+15145551234');
      expect(normalizeContactPhone('1 514 555 1234', countryCode: 'CA'),
          '+15145551234');
    });

    test('the trunk zero written after the calling code is dropped', () {
      expect(normalizeContactPhone('+33 (0)6 12 34 56 78'), '+33612345678');
    });

    test('anything ambiguous is refused rather than guessed', () {
      expect(normalizeContactPhone('07 07 07 07 07'), isNull); // no country
      expect(normalizeContactPhone('0707070707', countryCode: 'ZZ'), isNull);
      expect(normalizeContactPhone('12345', countryCode: 'FR'), isNull);
      expect(normalizeContactPhone('call me', countryCode: 'FR'), isNull);
      expect(normalizeContactPhone('+1234567890123456'), isNull);
      expect(normalizeContactPhone(null), isNull);
    });

    test('calling codes of the supported countries', () {
      expect(callingCodeFor('ci'), '225');
      expect(callingCodeFor('SN'), '221');
      expect(callingCodeFor('FR'), '33');
      expect(callingCodeFor('ZZ'), isNull);
      expect(callingCodeFor(null), isNull);
    });

    // Same vector as functions/src/__tests__/contacts.test.ts: both sides must agree.
    test('hash matches the server for a known number', () {
      expect(
        hashContactPhone('+22507070707'),
        '2bbb8882ffefbff53680ed3f81343e9142c1e2a9ccddb87032b083a87820d9b3',
      );
    });

    test('a contact is findable by phone as well as by e-mail', () {
      final both = _contact('1', 'Awa',
          emails: ['awa@example.com'], phones: ['07 07 07 07 07']);
      final hashes = contactHashes(both, countryCode: 'CI');
      expect(hashes, [
        _hash('awa@example.com'),
        hashContactPhone('+2250707070707'),
      ]);
      // Without the country the local number cannot be read: only the e-mail remains.
      expect(contactHashes(both), [_hash('awa@example.com')]);
    });

    test('a contact matched by phone is suggested, not invited', () {
      final mariam = _contact('1', 'Mariam', phones: ['77 123 45 67']);
      final lookup = buildContactLookup([mariam], countryCode: 'SN');
      final match = ContactMatch(
        uid: 'u_mariam',
        hash: hashContactPhone('+221771234567'),
      );
      expect(lookup.hashes, [match.hash]);
      expect(
        buildSuggestions(
          lookup: lookup,
          matches: [match],
          links: const FriendLinks(),
          myUid: 'me',
        ).single.contactName,
        'Mariam',
      );
      expect(
        buildInvites(contacts: [mariam], matches: [match], countryCode: 'SN'),
        isEmpty,
      );
    });

    test('phone failures map the Firebase error codes', () {
      expect(phoneLinkFailureFromCode('invalid-phone-number'),
          PhoneLinkFailure.invalidNumber);
      expect(phoneLinkFailureFromCode('too-many-requests'),
          PhoneLinkFailure.tooManyRequests);
      expect(phoneLinkFailureFromCode('invalid-verification-code'),
          PhoneLinkFailure.invalidCode);
      expect(phoneLinkFailureFromCode('credential-already-in-use'),
          PhoneLinkFailure.alreadyUsed);
      expect(phoneLinkFailureFromCode('network-request-failed'),
          PhoneLinkFailure.network);
      expect(phoneLinkFailureFromCode('whatever'), PhoneLinkFailure.unknown);
    });
  });

  group('buildContactLookup', () {
    test('one hash per distinct address, whatever the case or the owner', () {
      final awa = _contact('1', 'Awa', emails: ['Awa@Example.com']);
      final awa2 = _contact('2', 'Awa pro', emails: ['awa@example.com']);
      final lookup = buildContactLookup([
        awa,
        awa2,
        _contact('3', 'Broken', emails: ['nope', '']),
        _contact('4', 'Phone only', phones: ['0102030405']),
      ]);
      expect(lookup.hashes, [_hash('awa@example.com')]);
      expect(lookup.byHash[_hash('awa@example.com')], [awa, awa2]);
    });

    test('is split into server-sized batches', () {
      final lookup = buildContactLookup([
        for (var i = 0; i < 2300; i++)
          _contact('$i', 'C$i', emails: ['c$i@example.com']),
      ]);
      expect(lookup.batches.map((b) => b.length), [1000, 1000, 300]);
    });

    test('an enormous address book is cut, never sent whole', () {
      final lookup = buildContactLookup([
        for (var i = 0; i < maxContactHashes + 100; i++)
          _contact('$i', 'C$i', emails: ['c$i@example.com']),
      ]);
      expect(lookup.hashes, hasLength(maxContactHashes));
    });
  });

  group('suggestions and invites', () {
    final awa = _contact('1', 'awa', emails: ['awa@example.com']);
    final zoe = _contact('2', 'Zoé', emails: ['zoe@example.com']);
    final bob = _contact('3', 'Bob', emails: ['bob@example.com']);
    final lookup = buildContactLookup([zoe, awa, bob]);

    List<ContactMatch> matches(Map<String, String> uidByEmail) => [
          for (final e in uidByEmail.entries)
            ContactMatch(uid: e.value, hash: _hash(e.key)),
        ];

    test('hides me, friends and pending requests, sorts by contact name', () {
      final suggestions = buildSuggestions(
        lookup: lookup,
        matches: matches({
          'zoe@example.com': 'u_zoe',
          'awa@example.com': 'u_awa',
          'bob@example.com': 'u_bob',
        }),
        links: const FriendLinks(
          friends: [FriendLink(pairId: 'p', uid: 'u_bob')],
        ),
        myUid: 'me',
      );
      expect(suggestions.map((s) => s.uid), ['u_awa', 'u_zoe']);
      expect(suggestions.map((s) => s.contactName), ['awa', 'Zoé']);
    });

    test('incoming and outgoing requests are not proposed again', () {
      final suggestions = buildSuggestions(
        lookup: lookup,
        matches: matches({
          'zoe@example.com': 'u_zoe',
          'awa@example.com': 'u_awa',
          'bob@example.com': 'me',
        }),
        links: const FriendLinks(
          incoming: [FriendLink(pairId: 'a', uid: 'u_zoe')],
          outgoing: [FriendLink(pairId: 'b', uid: 'u_awa')],
        ),
        myUid: 'me',
      );
      expect(suggestions, isEmpty);
    });

    test('an account found through two addresses is proposed once', () {
      final suggestions = buildSuggestions(
        lookup: lookup,
        matches: matches({
          'awa@example.com': 'u_same',
          'bob@example.com': 'u_same',
        }),
        links: const FriendLinks(),
        myUid: 'me',
      );
      expect(suggestions, hasLength(1));
    });

    test('invites skip people on Sipho and people with no way to reach them',
        () {
      final kofi = _contact('4', 'kofi',
          emails: ['kofi@example.com'], phones: ['+225 07 07 07 07']);
      final nobody = _contact('5', 'Nobody');
      final shortNumber = _contact('6', 'Short', phones: ['112']);
      final mariam = _contact('7', 'Mariam', phones: ['+221 77 123 45 67']);
      final invites = buildInvites(
        contacts: [zoe, kofi, nobody, shortNumber, mariam, awa],
        // Awa is on Sipho (already a friend, so not suggested): never invited either.
        matches: matches({'awa@example.com': 'u_awa'}),
      );
      expect(invites.map((i) => i.name), ['kofi', 'Mariam', 'Zoé']);
      expect(invites[0].phone, '+22507070707');
      expect(invites[0].email, 'kofi@example.com');
      expect(invites[1].phone, '+221771234567');
      expect(invites[1].email, isNull);
      expect(invites[2].phone, isNull);
      expect(invites[2].email, 'zoe@example.com');
    });

    test('dialableNumber keeps digits and a leading plus only', () {
      expect(dialableNumber(' +225 (07) 07-07-07 '), '+22507070707');
      expect(dialableNumber('07 07 07 07'), '07070707');
      expect(dialableNumber('12345'), isNull);
    });

    test('invite links are percent-encoded (no "+" for spaces)', () {
      final sms = smsInviteUri('+225070707', 'Salut Awa & co');
      expect(sms.scheme, 'sms');
      expect(sms.path, '+225070707');
      expect(sms.toString(), contains('Salut%20Awa%20%26%20co'));

      final mail = emailInviteUri('a@b.co', 'Rejoins-moi', 'Hello you');
      expect(mail.scheme, 'mailto');
      expect(mail.toString(), contains('subject=Rejoins-moi'));
      expect(mail.toString(), contains('body=Hello%20you'));
    });
  });

  group('ContactsSection', () {
    final l10n = lookupAppLocalizations(const Locale('fr'));

    final awa = _contact('1', 'Awa Diop',
        emails: ['awa@example.com'], phones: ['+225 01 02 03 04 05']);
    final kofi = _contact('2', 'Kofi',
        emails: ['kofi@example.com'], phones: ['+22507070707']);
    final mariam = _contact('3', 'Mariam', phones: ['+221 77 123 45 67']);

    late _FakeRepository repo;
    late _FakeSource source;
    late FakePhoneLinker linker;
    late List<Uri> launched;

    Future<void> pump(
      WidgetTester tester, {
      bool enabled = false,
      ContactsAccess access = ContactsAccess.granted,
      FriendLinks links = const FriendLinks(),
      Map<String, String>? onSipho,
      FakePhoneLinker? phoneLinker,
    }) async {
      tester.view.physicalSize = const Size(900, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      linker = phoneLinker ?? FakePhoneLinker();
      repo = _FakeRepository(
        enabled: enabled,
        onSipho: onSipho ?? {_hash('awa@example.com'): 'u_awa'},
      );
      source = _FakeSource([awa, kofi, mariam], access: access);
      launched = [];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            friendsRepositoryProvider.overrideWithValue(repo),
            contactsSourceProvider.overrideWithValue(source),
            authStateProvider.overrideWith((ref) => Stream.value(_FakeUser())),
            friendLinksProvider.overrideWith((ref) => Stream.value(links)),
            inviteCodeProvider.overrideWith((ref) => Future.value('ABCD2345')),
            contactsCountryProvider.overrideWithValue('CI'),
            phoneLinkerProvider.overrideWithValue(linker),
          ],
          child: MaterialApp(
            locale: const Locale('fr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: ContactsSection(
                  launch: (uri) async {
                    launched.add(uri);
                    return true;
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> agree(WidgetTester tester) async {
      await tester.tap(find.text(l10n.contactsFind));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.contactsConsentAccept));
      await tester.pumpAndSettle();
    }

    testWidgets('nothing is read or asked before the user taps',
        (tester) async {
      await pump(tester);
      expect(find.text(l10n.contactsIntro), findsOneWidget);
      expect(source.accessCalls, 0);
      expect(source.loadCalls, 0);
      expect(repo.calls, isEmpty);
    });

    testWidgets('the consent explains the trade-off and can be declined',
        (tester) async {
      await pump(tester);
      await tester.tap(find.text(l10n.contactsFind));
      await tester.pumpAndSettle();
      expect(find.text(l10n.contactsConsentTitle), findsOneWidget);
      expect(find.textContaining('empreintes chiffrées'), findsOneWidget);

      await tester.tap(find.text(l10n.cancelBtn));
      await tester.pumpAndSettle();
      expect(source.accessCalls, 0);
      expect(repo.calls, isEmpty);
    });

    testWidgets('agreeing opts in, scans and splits friends from invitations',
        (tester) async {
      await pump(tester);
      await agree(tester);

      expect(repo.calls, ['discovery:true', 'find:5']);
      expect(find.text(l10n.contactsSuggestionsTitle), findsOneWidget);
      expect(find.text('Awa Diop'), findsOneWidget);
      expect(find.text('pseudo_u_awa'), findsOneWidget);

      expect(find.text(l10n.contactsInviteTitle), findsOneWidget);
      // Awa is on Sipho: invited people are Kofi (SMS + e-mail) and Mariam (SMS only).
      expect(
          find.byTooltip('${l10n.contactsInviteSms} · Kofi'), findsOneWidget);
      expect(
          find.byTooltip('${l10n.contactsInviteEmail} · Kofi'), findsOneWidget);
      expect(
          find.byTooltip('${l10n.contactsInviteSms} · Mariam'), findsOneWidget);
      expect(
          find.byTooltip('${l10n.contactsInviteEmail} · Mariam'), findsNothing);
      expect(
          find.byTooltip('${l10n.contactsInviteSms} · Awa Diop'), findsNothing);
    });

    testWidgets('a refused permission leaves the user undiscoverable',
        (tester) async {
      await pump(tester, access: ContactsAccess.denied);
      await agree(tester);
      expect(find.text(l10n.contactsDenied), findsOneWidget);
      expect(repo.calls, isEmpty);
      expect(source.loadCalls, 0);
    });

    testWidgets('a permission refused for good points to the settings',
        (tester) async {
      await pump(tester, access: ContactsAccess.permanentlyDenied);
      await agree(tester);
      expect(find.text(l10n.contactsDeniedSettings), findsOneWidget);
      await tester.tap(find.text(l10n.contactsOpenSettings));
      await tester.pumpAndSettle();
      expect(source.settingsCalls, 1);
    });

    testWidgets('an account without verified e-mail gets a clear message',
        (tester) async {
      await pump(tester);
      repo.failWith = FriendsFailure.notAllowed;
      await agree(tester);
      expect(find.text(l10n.contactsErrEmail), findsOneWidget);
      expect(source.loadCalls, 0);
    });

    testWidgets('adding a suggestion sends a request and confirms',
        (tester) async {
      await pump(tester);
      await agree(tester);
      await tester.tap(find.widgetWithText(FilledButton, l10n.contactsAdd));
      await tester.pumpAndSettle();
      expect(repo.calls, contains('request:u_awa'));
      expect(find.text(l10n.friendsRequestSent), findsOneWidget);
    });

    testWidgets('someone who is already a friend is not suggested',
        (tester) async {
      await pump(
        tester,
        links: const FriendLinks(
          friends: [FriendLink(pairId: 'me_u_awa', uid: 'u_awa')],
        ),
      );
      await agree(tester);
      expect(find.text(l10n.contactsSuggestionsTitle), findsNothing);
      expect(find.text('Awa Diop'), findsNothing);
      // Nor invited: the account exists.
      expect(
          find.byTooltip('${l10n.contactsInviteSms} · Awa Diop'), findsNothing);
    });

    testWidgets('inviting by SMS opens a message carrying my friend code',
        (tester) async {
      await pump(tester);
      await agree(tester);
      await tester.tap(find.byTooltip('${l10n.contactsInviteSms} · Kofi'));
      await tester.pumpAndSettle();
      expect(launched, hasLength(1));
      expect(launched.single.scheme, 'sms');
      expect(launched.single.path, '+22507070707');
      expect(Uri.decodeComponent(launched.single.query), contains('ABCD2345'));
    });

    testWidgets('inviting by e-mail opens a mail with subject and code',
        (tester) async {
      await pump(tester);
      await agree(tester);
      await tester.tap(find.byTooltip('${l10n.contactsInviteEmail} · Kofi'));
      await tester.pumpAndSettle();
      expect(launched.single.scheme, 'mailto');
      expect(launched.single.path, 'kofi@example.com');
      final query = Uri.decodeComponent(launched.single.query);
      expect(query, contains(l10n.contactsInviteSubject));
      expect(query, contains('ABCD2345'));
    });

    Future<void> typeInDialog(
        WidgetTester tester, String text, String cta) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.tap(find.text(cta));
      await tester.pumpAndSettle();
    }

    testWidgets('a contact who only has a phone number is found by it',
        (tester) async {
      await pump(
        tester,
        onSipho: {hashContactPhone('+221771234567'): 'u_mariam'},
      );
      await agree(tester);
      // Mariam has no e-mail: only her number (international format) can match.
      expect(find.text('Mariam'), findsOneWidget);
      expect(
          find.widgetWithText(FilledButton, l10n.contactsAdd), findsOneWidget);
      expect(
          find.byTooltip('${l10n.contactsInviteSms} · Mariam'), findsNothing);
      expect(
          find.byTooltip('${l10n.contactsInviteSms} · Kofi'), findsOneWidget);
      expect(find.byTooltip('${l10n.contactsInviteSms} · Awa Diop'),
          findsOneWidget);
    });

    testWidgets('adding my number: SMS code, link, then the number is indexed',
        (tester) async {
      await pump(tester, enabled: true);
      expect(find.text(l10n.contactsAddPhoneHint), findsOneWidget);

      await tester.tap(find.text(l10n.contactsAddPhone));
      await tester.pumpAndSettle();
      await typeInDialog(tester, '07 07 07 07 07', l10n.contactsSendCode);
      expect(linker.sent, ['+2250707070707']);

      await typeInDialog(tester, '123456', l10n.contactsVerify);
      expect(linker.codes, ['123456']);
      expect(repo.calls, ['discovery:true']); // re-indexed with the number
      expect(find.text(l10n.contactsPhoneLinked('+2250707070707')),
          findsOneWidget);
      expect(find.text(l10n.contactsAddPhone), findsNothing);
    });

    testWidgets('a number verified automatically needs no code',
        (tester) async {
      await pump(tester,
          enabled: true, phoneLinker: FakePhoneLinker(instant: true));
      await tester.tap(find.text(l10n.contactsAddPhone));
      await tester.pumpAndSettle();
      await typeInDialog(tester, '+22507070707', l10n.contactsSendCode);
      expect(linker.codes, isEmpty);
      expect(repo.calls, ['discovery:true']);
      expect(
          find.text(l10n.contactsPhoneLinked('+22507070707')), findsOneWidget);
    });

    testWidgets('an invalid number is refused before any SMS is sent',
        (tester) async {
      await pump(tester, enabled: true);
      await tester.tap(find.text(l10n.contactsAddPhone));
      await tester.pumpAndSettle();
      await typeInDialog(tester, '12', l10n.contactsSendCode);
      expect(linker.sent, isEmpty);
      expect(find.text(l10n.contactsErrPhoneInvalid), findsOneWidget);
    });

    testWidgets('a wrong code is explained and nothing is indexed',
        (tester) async {
      await pump(tester, enabled: true);
      await tester.tap(find.text(l10n.contactsAddPhone));
      await tester.pumpAndSettle();
      await typeInDialog(tester, '07 07 07 07 07', l10n.contactsSendCode);
      linker.failConfirm = PhoneLinkFailure.invalidCode;
      await typeInDialog(tester, '000000', l10n.contactsVerify);
      expect(find.text(l10n.contactsErrPhoneCode), findsOneWidget);
      expect(repo.calls, isEmpty);
      expect(find.text(l10n.contactsAddPhone), findsOneWidget);
    });

    testWidgets('a number used by another account is reported', (tester) async {
      await pump(tester, enabled: true);
      await tester.tap(find.text(l10n.contactsAddPhone));
      await tester.pumpAndSettle();
      linker.failSend = PhoneLinkFailure.alreadyUsed;
      await typeInDialog(tester, '07 07 07 07 07', l10n.contactsSendCode);
      expect(find.text(l10n.contactsErrPhoneUsed), findsOneWidget);
    });

    testWidgets('cancelling the code dialog leaves everything unchanged',
        (tester) async {
      await pump(tester, enabled: true);
      await tester.tap(find.text(l10n.contactsAddPhone));
      await tester.pumpAndSettle();
      await typeInDialog(tester, '07 07 07 07 07', l10n.contactsSendCode);
      await tester.tap(find.text(l10n.cancelBtn));
      await tester.pumpAndSettle();
      expect(linker.codes, isEmpty);
      expect(repo.calls, isEmpty);
      expect(find.text(l10n.contactsAddPhone), findsOneWidget);
    });

    testWidgets('an account that already has a verified number shows it',
        (tester) async {
      await pump(tester,
          enabled: true,
          phoneLinker: FakePhoneLinker(linkedPhone: '+22507070707'));
      expect(
          find.text(l10n.contactsPhoneLinked('+22507070707')), findsOneWidget);
      expect(find.text(l10n.contactsAddPhone), findsNothing);
    });

    testWidgets('no usable e-mail: adding a number is what opts the user in',
        (tester) async {
      await pump(tester);
      repo.failWith = FriendsFailure.notAllowed;
      await agree(tester);
      expect(find.text(l10n.contactsErrEmail), findsOneWidget);
      expect(find.text(l10n.contactsAddPhone), findsOneWidget);

      repo.failWith = null;
      repo.calls.clear();
      await tester.tap(find.text(l10n.contactsAddPhone));
      await tester.pumpAndSettle();
      await typeInDialog(tester, '07 07 07 07 07', l10n.contactsSendCode);
      await typeInDialog(tester, '123456', l10n.contactsVerify);

      expect(repo.calls, ['discovery:true', 'find:5']);
      expect(find.text('Awa Diop'), findsOneWidget);
    });

    testWidgets('a user who opted in refreshes on demand and can withdraw',
        (tester) async {
      await pump(tester, enabled: true);
      // Returning user: still nothing happens until they ask.
      expect(source.loadCalls, 0);
      expect(find.text(l10n.contactsRefresh), findsOneWidget);

      await tester.tap(find.text(l10n.contactsRefresh));
      await tester.pumpAndSettle();
      expect(repo.calls, ['find:5']); // already opted in: no second opt-in
      expect(find.text('Awa Diop'), findsOneWidget);

      await tester.tap(find.text(l10n.contactsStop));
      await tester.pumpAndSettle();
      expect(repo.enabled, isFalse);
      expect(repo.calls.last, 'discovery:false');
      expect(find.text(l10n.contactsStopped), findsOneWidget);
      expect(find.text('Awa Diop'), findsNothing);
      expect(find.text(l10n.contactsFind), findsOneWidget);
    });
  });
}
