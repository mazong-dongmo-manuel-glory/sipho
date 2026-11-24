import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/cloud_functions_service.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_profile_provider.dart';
import '../domain/contacts.dart';
import 'contacts_source.dart';
import 'friends_provider.dart';

enum ContactsScanStatus { idle, scanning, ready, denied, error }

class ContactsState {
  const ContactsState({
    this.status = ContactsScanStatus.idle,
    this.lookup,
    this.matches = const [],
    this.invites = const [],
    this.permanentlyDenied = false,
    this.errorCode,
    this.errorMessage,
  });

  final ContactsScanStatus status;
  final ContactLookup? lookup;
  final List<ContactMatch> matches;
  final List<ContactInvite> invites;
  final bool permanentlyDenied;
  final String? errorCode;
  final String? errorMessage;

  bool get isScanning => status == ContactsScanStatus.scanning;
}

class ContactsController extends StateNotifier<ContactsState> {
  ContactsController(this._ref) : super(const ContactsState());

  final Ref _ref;

  Future<void> enableAndScan() async {
    if (state.isScanning) return;
    state = const ContactsState(status: ContactsScanStatus.scanning);
    final access = await _access();
    if (access != ContactsAccess.granted) return;
    final result = await _ref
        .read(cloudFunctionsServiceProvider)
        .setContactDiscovery(enabled: true);
    if (result['status'] == 'error') {
      state = ContactsState(
        status: ContactsScanStatus.error,
        errorCode: result['code']?.toString(),
        errorMessage: result['message']?.toString(),
      );
      return;
    }
    await _scanWithAccess();
  }

  Future<void> scan() async {
    if (state.isScanning) return;
    state = const ContactsState(status: ContactsScanStatus.scanning);
    final access = await _access();
    if (access != ContactsAccess.granted) return;
    await _scanWithAccess();
  }

  Future<void> disable() async {
    final result = await _ref
        .read(cloudFunctionsServiceProvider)
        .setContactDiscovery(enabled: false);
    if (result['status'] == 'error') {
      state = ContactsState(
        status: ContactsScanStatus.error,
        errorCode: result['code']?.toString(),
        errorMessage: result['message']?.toString(),
      );
      return;
    }
    state = const ContactsState();
  }

  Future<Map<String, dynamic>> sendRequest(String uid) {
    return _ref
        .read(cloudFunctionsServiceProvider)
        .sendContactFriendRequest(targetUid: uid);
  }

  Future<void> openSettings() =>
      _ref.read(contactsSourceProvider).openSettings();

  Future<ContactsAccess> _access() async {
    final access = await _ref.read(contactsSourceProvider).requestAccess();
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
      final contacts = await _ref.read(contactsSourceProvider).load();
      final country = _ref.read(userProfileProvider).countryCode;
      final lookup = buildContactLookup(contacts, countryCode: country);
      final matches = <ContactMatch>[];
      for (final batch in lookup.batches) {
        if (batch.isEmpty) continue;
        final result = await _ref
            .read(cloudFunctionsServiceProvider)
            .findContacts(hashes: batch);
        if (result['status'] == 'error') {
          state = ContactsState(
            status: ContactsScanStatus.error,
            errorCode: result['code']?.toString(),
            errorMessage: result['message']?.toString(),
          );
          return;
        }
        final raw = result['matches'];
        if (raw is List) {
          for (final item in raw) {
            if (item is Map &&
                item['uid'] is String &&
                item['hash'] is String) {
              matches.add(ContactMatch(
                uid: item['uid'] as String,
                hash: item['hash'] as String,
              ));
            }
          }
        }
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
    } catch (error) {
      debugPrint('[Contacts] scan failed: $error');
      state = ContactsState(
        status: ContactsScanStatus.error,
        errorMessage: error.toString(),
      );
    }
  }
}

final contactsControllerProvider =
    StateNotifierProvider.autoDispose<ContactsController, ContactsState>((ref) {
  return ContactsController(ref);
});

final contactDiscoveryProvider = StreamProvider.autoDispose<bool>((ref) {
  final uid = ref.watch(authUidProvider);
  if (uid == null) return Stream.value(false);
  return ref
      .watch(firestoreProvider)
      .doc('users/$uid/social/contacts')
      .snapshots()
      .map((doc) => doc.data()?['enabled'] == true);
});

final contactSuggestionsProvider =
    Provider.autoDispose<List<ContactSuggestion>>((ref) {
  final scan = ref.watch(contactsControllerProvider);
  final lookup = scan.lookup;
  final uid = ref.watch(authUidProvider);
  if (lookup == null || uid == null) return const [];
  final friends = ref.watch(friendsProvider);
  final known = <String>{
    uid,
    for (final l in friends.accepted) l.otherUid,
    for (final l in friends.incoming) l.otherUid,
    for (final l in friends.outgoing) l.otherUid,
  };
  return buildSuggestions(
    lookup: lookup,
    matches: scan.matches,
    knownUids: known,
  );
});
