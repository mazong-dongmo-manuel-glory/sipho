import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Hashes the server accepts in one `findContacts` call.
const int contactHashesPerCall = 1000;

/// Most hashes sent per scan (five calls).
const int maxContactHashes = 5000;

final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

String? normalizeContactEmail(String? raw) {
  if (raw == null) return null;
  final email = raw.trim().toLowerCase();
  if (email.isEmpty || email.length > 254) return null;
  return _emailPattern.hasMatch(email) ? email : null;
}

String hashContactEmail(String normalizedEmail) =>
    sha256.convert(utf8.encode(normalizedEmail)).toString();

String hashContactPhone(String e164) =>
    sha256.convert(utf8.encode(e164)).toString();

class _Dialing {
  const _Dialing(this.code, {this.dropsTrunkZero = false});
  final String code;
  final bool dropsTrunkZero;
}

const Map<String, _Dialing> _dialing = {
  'FR': _Dialing('33', dropsTrunkZero: true),
  'BE': _Dialing('32', dropsTrunkZero: true),
  'MA': _Dialing('212', dropsTrunkZero: true),
  'CA': _Dialing('1'),
  'US': _Dialing('1'),
  'CI': _Dialing('225'),
  'SN': _Dialing('221'),
  'CM': _Dialing('237'),
  'ML': _Dialing('223'),
  'BF': _Dialing('226'),
  'TG': _Dialing('228'),
  'BJ': _Dialing('229'),
};

String? callingCodeFor(String? countryCode) =>
    _dialing[countryCode?.trim().toUpperCase()]?.code;

String? normalizeContactPhone(String? raw, {String? countryCode}) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;

  String international;
  if (trimmed.startsWith('+')) {
    international = digits;
  } else if (digits.startsWith('00')) {
    international = digits.substring(2);
  } else {
    final dialing = _dialing[countryCode?.trim().toUpperCase()];
    if (dialing == null) return null;
    var national = digits;
    if (dialing.code == '1' &&
        national.length == 11 &&
        national.startsWith('1')) {
      national = national.substring(1);
    } else if (dialing.dropsTrunkZero && national.startsWith('0')) {
      national = national.substring(1);
    }
    international = '${dialing.code}$national';
  }

  for (final dialing in _dialing.values) {
    if (dialing.dropsTrunkZero &&
        international.startsWith('${dialing.code}0')) {
      international =
          dialing.code + international.substring(dialing.code.length + 1);
      break;
    }
  }

  if (international.length < 8 || international.length > 15) return null;
  if (international.startsWith('0')) return null;
  return '+$international';
}

class DeviceContact {
  const DeviceContact({
    required this.id,
    required this.name,
    this.emails = const [],
    this.phones = const [],
  });

  final String id;
  final String name;
  final List<String> emails;
  final List<String> phones;
}

class ContactLookup {
  const ContactLookup({required this.hashes, required this.byHash});

  final List<String> hashes;
  final Map<String, List<DeviceContact>> byHash;

  List<List<String>> get batches => [
        for (var i = 0; i < hashes.length; i += contactHashesPerCall)
          hashes.sublist(
            i,
            i + contactHashesPerCall > hashes.length
                ? hashes.length
                : i + contactHashesPerCall,
          ),
      ];
}

List<String> contactHashes(DeviceContact contact, {String? countryCode}) {
  final hashes = <String>{};
  for (final raw in contact.emails) {
    final email = normalizeContactEmail(raw);
    if (email != null) hashes.add(hashContactEmail(email));
  }
  for (final raw in contact.phones) {
    final phone = normalizeContactPhone(raw, countryCode: countryCode);
    if (phone != null) hashes.add(hashContactPhone(phone));
  }
  return hashes.toList();
}

ContactLookup buildContactLookup(
  Iterable<DeviceContact> contacts, {
  String? countryCode,
}) {
  final hashes = <String>[];
  final byHash = <String, List<DeviceContact>>{};
  for (final contact in contacts) {
    for (final hash in contactHashes(contact, countryCode: countryCode)) {
      final owners = byHash[hash];
      if (owners != null) {
        if (!owners.contains(contact)) owners.add(contact);
        continue;
      }
      if (hashes.length >= maxContactHashes) continue;
      hashes.add(hash);
      byHash[hash] = [contact];
    }
  }
  return ContactLookup(hashes: hashes, byHash: byHash);
}

class ContactMatch {
  const ContactMatch({required this.uid, required this.hash});
  final String uid;
  final String hash;
}

class ContactSuggestion {
  const ContactSuggestion({required this.uid, required this.contactName});
  final String uid;
  final String contactName;
}

/// [knownUids] = me + friends + pending requests.
List<ContactSuggestion> buildSuggestions({
  required ContactLookup lookup,
  required Iterable<ContactMatch> matches,
  required Set<String> knownUids,
}) {
  final byUid = <String, ContactSuggestion>{};
  for (final match in matches) {
    if (knownUids.contains(match.uid) || byUid.containsKey(match.uid)) {
      continue;
    }
    final owners = lookup.byHash[match.hash];
    final name = (owners != null && owners.isNotEmpty) ? owners.first.name : '';
    byUid[match.uid] = ContactSuggestion(uid: match.uid, contactName: name);
  }
  final list = byUid.values.toList()
    ..sort((a, b) {
      final byName =
          a.contactName.toLowerCase().compareTo(b.contactName.toLowerCase());
      return byName != 0 ? byName : a.uid.compareTo(b.uid);
    });
  return list;
}

class ContactInvite {
  const ContactInvite({required this.contact, this.phone, this.email});
  final DeviceContact contact;
  final String? phone;
  final String? email;
  String get name => contact.name;
}

List<ContactInvite> buildInvites({
  required Iterable<DeviceContact> contacts,
  required Iterable<ContactMatch> matches,
  String? countryCode,
  int limit = 200,
}) {
  final matched = {for (final m in matches) m.hash};
  final invites = <ContactInvite>[];
  for (final contact in contacts) {
    final emails = [
      for (final raw in contact.emails)
        if (normalizeContactEmail(raw) != null) normalizeContactEmail(raw)!,
    ];
    final onSipho =
        contactHashes(contact, countryCode: countryCode).any(matched.contains);
    if (onSipho) continue;
    final phone = _firstDialable(contact.phones);
    final email = emails.isEmpty ? null : emails.first;
    if (phone == null && email == null) continue;
    invites.add(ContactInvite(contact: contact, phone: phone, email: email));
  }
  invites.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return invites.length > limit ? invites.sublist(0, limit) : invites;
}

String? dialableNumber(String raw) {
  final trimmed = raw.trim();
  final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length < 6) return null;
  return trimmed.startsWith('+') ? '+$digits' : digits;
}

String? _firstDialable(Iterable<String> phones) {
  for (final raw in phones) {
    final number = dialableNumber(raw);
    if (number != null) return number;
  }
  return null;
}

Uri smsInviteUri(String phone, String message) =>
    Uri.parse('sms:$phone?body=${Uri.encodeComponent(message)}');

Uri emailInviteUri(String email, String subject, String message) => Uri.parse(
      'mailto:$email?subject=${Uri.encodeComponent(subject)}'
      '&body=${Uri.encodeComponent(message)}',
    );
