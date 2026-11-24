import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/firebase/cloud_functions_service.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../../core/widgets/sipho_page_header.dart';
import '../../auth/data/user_profile_provider.dart';
import '../data/contacts_controller.dart';
import '../data/friends_provider.dart';
import '../data/phone_linker.dart';
import '../domain/contacts.dart';

/// Retrouver ses amis via le carnet (empreintes SHA-256, opt-in réciproque).
class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  bool _busy = false;
  static const _invitesPerPage = 10;
  int _invitesShown = _invitesPerPage;

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? SiphoColors.primaryDark : null,
        ),
      );
  }

  String _mapError(AppLocalizations l10n, String? code, String? message) {
    return switch (code) {
      'failed-precondition' => l10n.contactsErrEmail,
      'resource-exhausted' => l10n.friendsErrLimit,
      'unavailable' || 'deadline-exceeded' => l10n.friendsErrNetwork,
      'permission-denied' || 'not-found' => l10n.friendsErrNotAllowed,
      _ => (message != null && message.isNotEmpty)
          ? message
          : l10n.friendsErrGeneric,
    };
  }

  Future<void> _start(AppLocalizations l10n) async {
    final agreed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.contactsConsentTitle),
        content: SingleChildScrollView(child: Text(l10n.contactsConsentBody)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelBtn),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.contactsConsentAccept),
          ),
        ],
      ),
    );
    if (agreed != true || !mounted) return;
    setState(() => _invitesShown = _invitesPerPage);
    await ref.read(contactsControllerProvider.notifier).enableAndScan();
    if (!mounted) return;
    final scan = ref.read(contactsControllerProvider);
    if (scan.status == ContactsScanStatus.error) {
      _toast(_mapError(l10n, scan.errorCode, scan.errorMessage), error: true);
    }
  }

  Future<void> _refresh(AppLocalizations l10n) async {
    setState(() => _invitesShown = _invitesPerPage);
    await ref.read(contactsControllerProvider.notifier).scan();
    if (!mounted) return;
    final scan = ref.read(contactsControllerProvider);
    if (scan.status == ContactsScanStatus.error) {
      _toast(_mapError(l10n, scan.errorCode, scan.errorMessage), error: true);
    }
  }

  Future<void> _stop(AppLocalizations l10n) async {
    await ref.read(contactsControllerProvider.notifier).disable();
    _toast(l10n.contactsStopped);
  }

  Future<void> _add(AppLocalizations l10n, ContactSuggestion s) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final result =
          await ref.read(contactsControllerProvider.notifier).sendRequest(s.uid);
      if (result['status'] == 'error') {
        _toast(
          _mapError(
            l10n,
            result['code']?.toString(),
            result['message']?.toString(),
          ),
          error: true,
        );
        return;
      }
      _toast(
        result['status'] == 'accepted'
            ? l10n.friendsNowFriends
            : l10n.friendsRequestSent,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _invite(
    AppLocalizations l10n,
    Uri Function(String message) build,
  ) async {
    var code = ref.read(friendsProvider).inviteCode;
    code ??= await ref.read(friendsProvider.notifier).loadInviteCode();
    if (code == null || code.isEmpty) {
      _toast(l10n.friendsErrGeneric, error: true);
      return;
    }
    try {
      final ok = await launchUrl(build(l10n.friendsShareMessage(code)));
      if (!ok) _toast(l10n.contactsInviteFailed, error: true);
    } catch (_) {
      _toast(l10n.contactsInviteFailed, error: true);
    }
  }

  String _phoneErrorText(AppLocalizations l10n, PhoneLinkFailure failure) {
    return switch (failure) {
      PhoneLinkFailure.invalidNumber => l10n.contactsErrPhoneInvalid,
      PhoneLinkFailure.tooManyRequests => l10n.contactsErrPhoneTooMany,
      PhoneLinkFailure.invalidCode => l10n.contactsErrPhoneCode,
      PhoneLinkFailure.alreadyUsed => l10n.contactsErrPhoneUsed,
      PhoneLinkFailure.network => l10n.friendsErrNetwork,
      PhoneLinkFailure.unknown => l10n.friendsErrGeneric,
    };
  }

  Future<String?> _prompt({
    required String title,
    required String label,
    required String confirm,
    String? hint,
    TextInputType? keyboardType,
    int maxLength = 20,
  }) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: keyboardType,
          maxLength: maxLength,
          decoration: InputDecoration(labelText: label, hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancelBtn),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: Text(confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _addPhone(AppLocalizations l10n, {required bool enabled}) async {
    if (_busy) return;
    final country = ref.read(userProfileProvider).countryCode;
    final calling = callingCodeFor(country);
    final raw = await _prompt(
      title: l10n.contactsPhoneTitle,
      label: l10n.contactsPhoneLabel,
      hint: calling == null ? '+…' : '+$calling …',
      confirm: l10n.contactsSendCode,
      keyboardType: TextInputType.phone,
    );
    if (raw == null || !mounted) return;
    final phone = normalizeContactPhone(raw, countryCode: country);
    if (phone == null) {
      _toast(l10n.contactsErrPhoneInvalid, error: true);
      return;
    }

    setState(() => _busy = true);
    try {
      final linker = ref.read(phoneLinkerProvider);
      final verifiedAlready = await linker.sendCode(phone);
      if (!verifiedAlready) {
        if (!mounted) return;
        final smsCode = await _prompt(
          title: l10n.contactsCodeTitle,
          label: l10n.contactsCodeLabel,
          confirm: l10n.contactsVerify,
          keyboardType: TextInputType.number,
          maxLength: 6,
        );
        if (smsCode == null) return;
        await linker.confirm(smsCode);
      }
      if (!mounted) return;
      // Re-index so the new verified number is findable.
      await ref
          .read(cloudFunctionsServiceProvider)
          .setContactDiscovery(enabled: true);
      if (enabled) {
        await ref.read(contactsControllerProvider.notifier).scan();
      }
      _toast(l10n.contactsPhoneAdded);
    } on PhoneLinkException catch (error) {
      _toast(_phoneErrorText(l10n, error.failure), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scan = ref.watch(contactsControllerProvider);
    final discovery = ref.watch(contactDiscoveryProvider).valueOrNull ?? false;
    final suggestions = ref.watch(contactSuggestionsProvider);
    final scanning = scan.isScanning;
    final phone = ref.watch(phoneLinkerProvider).linkedPhone;

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            SiphoPageHeader(
              title: l10n.contactsTitle,
              lead: l10n.contactsIntro,
            ),
            const SizedBox(height: 12),
            if (phone != null)
              Text(
                l10n.contactsPhoneLinked(phone),
                style: SiphoTypography.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: SiphoPalette.textSecondary(context),
                ),
              )
            else ...[
              Text(
                l10n.contactsAddPhoneHint,
                style: SiphoTypography.body.copyWith(
                  color: SiphoPalette.textSecondary(context),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => _addPhone(l10n, enabled: discovery),
                child: Text(
                  l10n.contactsAddPhone,
                  style: SiphoTypography.bodyBold.copyWith(
                    color: SiphoPalette.textPrimary(context),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (scan.status == ContactsScanStatus.idle && !discovery)
              SiphoButton3D(
                label: scanning ? '…' : l10n.contactsFind,
                variant: SiphoButtonVariant.dark,
                onPressed: scanning ? null : () => _start(l10n),
              )
            else if (scan.status == ContactsScanStatus.denied) ...[
              Text(
                l10n.contactsDenied,
                style: SiphoTypography.bodyBold.copyWith(
                  color: SiphoPalette.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.contactsDeniedSettings,
                style: SiphoTypography.body.copyWith(
                  color: SiphoPalette.textSecondary(context),
                ),
              ),
              if (scan.permanentlyDenied) ...[
                const SizedBox(height: 12),
                SiphoButton3D(
                  label: l10n.contactsOpenSettings,
                  variant: SiphoButtonVariant.dark,
                  onPressed: () =>
                      ref.read(contactsControllerProvider.notifier).openSettings(),
                ),
              ],
            ] else ...[
              if (scanning)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: SiphoButton3D(
                        label: l10n.contactsRefresh,
                        variant: SiphoButtonVariant.secondary,
                        onPressed: () => _refresh(l10n),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.contactsSuggestionsTitle,
                  style: SiphoTypography.bodyBold.copyWith(
                    fontSize: 16,
                    color: SiphoPalette.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                if (suggestions.isEmpty)
                  Text(
                    l10n.contactsNoneOnSipho,
                    style: SiphoTypography.body.copyWith(
                      color: SiphoPalette.textSecondary(context),
                    ),
                  )
                else
                  for (final s in suggestions) ...[
                    SiphoListRow(
                      title: s.contactName.isEmpty ? s.uid : s.contactName,
                      trailing: l10n.contactsAdd,
                      onTap: _busy ? null : () => _add(l10n, s),
                    ),
                    const SiphoSeparator(),
                  ],
                if (scan.invites.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    l10n.contactsInviteTitle,
                    style: SiphoTypography.bodyBold.copyWith(
                      fontSize: 16,
                      color: SiphoPalette.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final invite
                      in scan.invites.take(_invitesShown)) ...[
                    SiphoListRow(
                      title: invite.name,
                      subtitle: invite.phone ?? invite.email ?? '',
                      trailing: invite.phone != null
                          ? l10n.contactsInviteSms
                          : l10n.contactsInviteEmail,
                      onTap: () {
                        if (invite.phone != null) {
                          _invite(
                            l10n,
                            (msg) => smsInviteUri(invite.phone!, msg),
                          );
                        } else if (invite.email != null) {
                          _invite(
                            l10n,
                            (msg) => emailInviteUri(
                              invite.email!,
                              l10n.contactsInviteSubject,
                              msg,
                            ),
                          );
                        }
                      },
                    ),
                    const SiphoSeparator(),
                  ],
                  if (scan.invites.length > _invitesShown)
                    TextButton(
                      onPressed: () => setState(
                        () => _invitesShown += _invitesPerPage,
                      ),
                      child: Text(l10n.contactsMore),
                    ),
                ],
                if (discovery) ...[
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => _stop(l10n),
                    child: Text(
                      l10n.contactsStop,
                      style: SiphoTypography.bodyBold.copyWith(
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }
}
