import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/friends/data/contacts_source.dart';
import 'package:sipho/features/friends/data/friends_repository.dart';
import 'package:sipho/features/friends/domain/contacts.dart';
import 'package:sipho/features/friends/domain/friends.dart';
import 'package:sipho/features/friends/presentation/friends_providers.dart';

enum ContactsScanStatus { idle, scanning, ready, denied, error }

class ContactsState {
  const ContactsState({
    this.status = ContactsScanStatus.idle,
    this.lookup,
    this.matches = const [],
    this.invites = const [],
    this.permanentlyDenied = false,
    this.failure,
  });

  final ContactsScanStatus status;

  /// What was sent to the server and who owns each hash (kept in memory only).
  final ContactLookup? lookup;
  final List<ContactMatch> matches;

  /// Contacts that are not on Sipho yet and can be invited.
  final List<ContactInvite> invites;

  /// The permission was refused for good: only the system settings can change it.
  final bool permanentlyDenied;
  final FriendsFailure? failure;

  bool get isScanning => status == ContactsScanStatus.scanning;
}

/// Looks the address book up on demand. Nothing is read before the user asks, nothing is stored on
/// the device or the server from the book itself: only fingerprints leave the phone.
class ContactsController extends AutoDisposeNotifier<ContactsState> {
  @override
  ContactsState build() => const ContactsState();

  /// After the user agreed: ask for the permission, then opt in and scan. Declining the
  /// permission leaves the user not discoverable.
  Future<void> enableAndScan() async {
    if (state.isScanning) return;
    state = const ContactsState(status: ContactsScanStatus.scanning);
    final access = await _access();
    if (access != ContactsAccess.granted) return;
    try {
      await ref
          .read(friendsRepositoryProvider)
          .setContactDiscovery(enabled: true);
    } on FriendsException catch (error) {
      state = ContactsState(
        status: ContactsScanStatus.error,
        failure: error.failure,
      );
      return;
    }
    await _scanWithAccess();
  }

  /// Refresh for a user who already opted in.
  Future<void> scan() async {
    if (state.isScanning) return;
    state = const ContactsState(status: ContactsScanStatus.scanning);
    final access = await _access();
    if (access != ContactsAccess.granted) return;
    await _scanWithAccess();
  }

  /// Stops being findable and forgets any result.
  Future<void> disable() async {
    try {
      await ref
          .read(friendsRepositoryProvider)
          .setContactDiscovery(enabled: false);
      state = const ContactsState();
    } on FriendsException catch (error) {
      state = ContactsState(
        status: ContactsScanStatus.error,
        failure: error.failure,
      );
    }
  }

  /// The account gained a verified phone number: index it too. When the user was not
  /// discoverable yet (no usable e-mail), this is what finally opts them in.
  Future<void> reindexAfterPhone({required bool alreadyEnabled}) async {
    if (!alreadyEnabled) return enableAndScan();
    try {
      await ref
          .read(friendsRepositoryProvider)
          .setContactDiscovery(enabled: true);
    } on FriendsException catch (error) {
      state = ContactsState(
        status: ContactsScanStatus.error,
        failure: error.failure,
      );
    }
  }

  Future<FriendRequestOutcome> sendRequest(String uid) {
    return ref.read(friendsRepositoryProvider).sendContactRequest(uid);
  }

  /// Opens the system settings (permission refused for good).
  Future<void> openSettings() =>
      ref.read(contactsSourceProvider).openSettings();

  Future<ContactsAccess> _access() async {
    final access = await ref.read(contactsSourceProvider).requestAccess();
    if (access != ContactsAccess.granted) {
      state = ContactsState(
        status: ContactsScanStatus.denied,
        permanentlyDenied: access == ContactsAccess.permanentlyDenied,
      );
    }
    return access;
  }

  Future<void> _scanWithAccess() async {
    try {
      final contacts = await ref.read(contactsSourceProvider).load();
      final country = ref.read(contactsCountryProvider);
      final lookup = buildContactLookup(contacts, countryCode: country);
      final repository = ref.read(friendsRepositoryProvider);
      final matches = <ContactMatch>[];
      for (final batch in lookup.batches) {
        matches.addAll(await repository.findContacts(batch));
      }
      state = ContactsState(
        status: ContactsScanStatus.ready,
        lookup: lookup,
        matches: matches,
        invites: buildInvites(
          contacts: contacts,
          matches: matches,
          countryCode: country,
        ),
      );
    } on FriendsException catch (error) {
      state = ContactsState(
        status: ContactsScanStatus.error,
        failure: error.failure,
      );
    } catch (error) {
      debugPrint('[Contacts] scan failed: $error');
      state = const ContactsState(
        status: ContactsScanStatus.error,
        failure: FriendsFailure.unknown,
      );
    }
  }
}

final contactsControllerProvider =
    NotifierProvider.autoDispose<ContactsController, ContactsState>(
  ContactsController.new,
);

/// The user's country (ISO code): how their contacts' local phone numbers are read.
final contactsCountryProvider = Provider.autoDispose<String?>((ref) {
  final code = ref.watch(userFinanceProvider).valueOrNull?.countryCode;
  return (code == null || code.isEmpty) ? null : code;
});

/// Whether the user opted in to contact discovery (server-owned flag).
final contactDiscoveryProvider = StreamProvider.autoDispose<bool>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(false);
  return ref.watch(friendsRepositoryProvider).watchContactDiscovery(uid);
});

/// Contacts on Sipho worth proposing: it follows the live friend links, so a person disappears
/// from the list as soon as a request is sent or answered.
final contactSuggestionsProvider =
    Provider.autoDispose<List<ContactSuggestion>>((ref) {
  final scan = ref.watch(contactsControllerProvider);
  final lookup = scan.lookup;
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (lookup == null || uid == null) return const [];
  final links =
      ref.watch(friendLinksProvider).valueOrNull ?? const FriendLinks();
  return buildSuggestions(
    lookup: lookup,
    matches: scan.matches,
    links: links,
    myUid: uid,
  );
});
