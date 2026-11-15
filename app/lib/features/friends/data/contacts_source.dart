import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/features/friends/domain/contacts.dart';

/// Whether Sipho may read the address book.
enum ContactsAccess { granted, denied, permanentlyDenied }

/// The phone's address book. Reading is read-only and happens only after the user asks for it.
abstract class ContactsSource {
  /// Asks for the permission when it was not decided yet (the system prompt appears here).
  Future<ContactsAccess> requestAccess();

  /// Every contact with at least a name and some e-mail or phone.
  Future<List<DeviceContact>> load();

  /// Opens the system settings page where the permission can be changed.
  Future<void> openSettings();
}

final contactsSourceProvider = Provider<ContactsSource>(
  (ref) => PluginContactsSource(),
);

class PluginContactsSource implements ContactsSource {
  @override
  Future<ContactsAccess> requestAccess() async {
    final status =
        await FlutterContacts.permissions.request(PermissionType.read);
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return ContactsAccess.granted;
      case PermissionStatus.permanentlyDenied:
        return ContactsAccess.permanentlyDenied;
      default:
        return ContactsAccess.denied;
    }
  }

  @override
  Future<List<DeviceContact>> load() async {
    final contacts = await FlutterContacts.getAll(
      properties: {ContactProperty.email, ContactProperty.phone},
    );
    debugPrint('[Contacts] read ${contacts.length} contacts');
    return [
      for (final c in contacts)
        if ((c.displayName ?? '').trim().isNotEmpty &&
            (c.emails.isNotEmpty || c.phones.isNotEmpty))
          DeviceContact(
            id: c.id ?? c.displayName!,
            name: c.displayName!.trim(),
            emails: [for (final e in c.emails) e.address],
            phones: [for (final p in c.phones) p.number],
          ),
    ];
  }

  @override
  Future<void> openSettings() => FlutterContacts.permissions.openSettings();
}
