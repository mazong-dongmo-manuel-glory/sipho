import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/features/friends/data/friends_repository.dart';
import 'package:sipho/features/friends/data/phone_linker.dart';
import 'package:sipho/features/friends/domain/contacts.dart';
import 'package:sipho/features/friends/domain/friends.dart';
import 'package:sipho/features/friends/presentation/contacts_controller.dart';
import 'package:sipho/features/friends/presentation/friends_failure_text.dart';
import 'package:sipho/features/friends/presentation/friends_providers.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens an `sms:` or `mailto:` link; `false` when nothing could handle it.
Future<bool> defaultLaunch(Uri uri) async {
  try {
    return await launchUrl(uri);
  } catch (_) {
    return false;
  }
}

const int _invitesPerPage = 10;

/// Find friends among the phone's contacts and invite the others. Everything starts from an
/// explicit tap: the permission prompt and the lookup never run on their own.
class ContactsSection extends ConsumerStatefulWidget {
  const ContactsSection({super.key, this.launch = defaultLaunch});

  final Future<bool> Function(Uri uri) launch;

  @override
  ConsumerState<ContactsSection> createState() => _ContactsSectionState();
}

class _ContactsSectionState extends ConsumerState<ContactsSection> {
  bool _busy = false;
  int _invitesShown = _invitesPerPage;
  String? _phone;

  @override
  void initState() {
    super.initState();
    _phone = ref.read(phoneLinkerProvider).linkedPhone;
  }

  String _phoneErrorText(AppLocalizations l10n, PhoneLinkFailure failure) {
    switch (failure) {
      case PhoneLinkFailure.invalidNumber:
        return l10n.contactsErrPhoneInvalid;
      case PhoneLinkFailure.tooManyRequests:
        return l10n.contactsErrPhoneTooMany;
      case PhoneLinkFailure.invalidCode:
        return l10n.contactsErrPhoneCode;
      case PhoneLinkFailure.alreadyUsed:
        return l10n.contactsErrPhoneUsed;
      case PhoneLinkFailure.network:
        return l10n.friendsErrNetwork;
      case PhoneLinkFailure.unknown:
        return l10n.friendsErrGeneric;
    }
  }

  Future<String?> _prompt({
    required String title,
    required String label,
    required String confirm,
    String? hint,
    TextInputType? keyboardType,
    int maxLength = 20,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => _TextPromptDialog(
        title: title,
        label: label,
        hint: hint,
        confirm: confirm,
        keyboardType: keyboardType,
        maxLength: maxLength,
      ),
    );
  }

  /// Verifies a phone number by SMS and links it to the account, so contacts who only have the
  /// number can find this user.
  Future<void> _addPhone(
    AppLocalizations l10n, {
    required bool enabled,
  }) async {
    if (_busy) return;
    final country = ref.read(contactsCountryProvider);
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
      _toast(l10n.contactsErrPhoneInvalid);
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
      setState(() => _phone = linker.linkedPhone);
      await ref
          .read(contactsControllerProvider.notifier)
          .reindexAfterPhone(alreadyEnabled: enabled);
      _toast(l10n.contactsPhoneAdded);
    } on PhoneLinkException catch (error) {
      _toast(_phoneErrorText(l10n, error.failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _start(AppLocalizations l10n) async {
    final agreed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.contactsConsentTitle),
        content: Text(l10n.contactsConsentBody),
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
  }

  Future<void> _refresh() {
    setState(() => _invitesShown = _invitesPerPage);
    return ref.read(contactsControllerProvider.notifier).scan();
  }

  Future<void> _stop(AppLocalizations l10n) async {
    await ref.read(contactsControllerProvider.notifier).disable();
    _toast(l10n.contactsStopped);
  }

  Future<void> _add(AppLocalizations l10n, ContactSuggestion s) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final outcome = await ref
          .read(contactsControllerProvider.notifier)
          .sendRequest(s.uid);
      _toast(
        outcome == FriendRequestOutcome.nowFriends
            ? l10n.friendsNowFriends
            : l10n.friendsRequestSent,
      );
    } on FriendsException catch (error) {
      _toast(friendsFailureText(l10n, error.failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _invite(
      AppLocalizations l10n, Uri Function(String) build) async {
    try {
      final code = await ref.read(inviteCodeProvider.future);
      final ok = await widget.launch(build(l10n.friendsShareMessage(code)));
      if (!ok) _toast(l10n.contactsInviteFailed);
    } catch (_) {
      _toast(l10n.contactsInviteFailed);
    }
  }

  String _errorText(AppLocalizations l10n, FriendsFailure? failure) {
    if (failure == FriendsFailure.notAllowed) return l10n.contactsErrEmail;
    return friendsFailureText(l10n, failure ?? FriendsFailure.unknown);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final enabled = ref.watch(contactDiscoveryProvider).valueOrNull ?? false;
    final scan = ref.watch(contactsControllerProvider);
    final suggestions = ref.watch(contactSuggestionsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.contactsTitle,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (!enabled && scan.status == ContactsScanStatus.idle)
            Text(l10n.contactsIntro, style: _bodyStyle),
          const SizedBox(height: 8),
          if (scan.isScanning)
            const LinearProgressIndicator()
          else
            Wrap(
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: enabled ? _refresh : () => _start(l10n),
                  icon: Icon(
                    enabled ? Icons.refresh_rounded : Icons.contacts_rounded,
                    size: 18,
                  ),
                  label: Text(
                    enabled ? l10n.contactsRefresh : l10n.contactsFind,
                  ),
                ),
              ],
            ),
          if (scan.status == ContactsScanStatus.denied) ...[
            const SizedBox(height: 8),
            Text(l10n.contactsDenied, style: _bodyStyle),
            if (scan.permanentlyDenied) ...[
              Text(l10n.contactsDeniedSettings, style: _bodyStyle),
              TextButton(
                onPressed:
                    ref.read(contactsControllerProvider.notifier).openSettings,
                child: Text(l10n.contactsOpenSettings),
              ),
            ],
          ],
          if (scan.status == ContactsScanStatus.error) ...[
            const SizedBox(height: 8),
            Text(_errorText(l10n, scan.failure), style: _bodyStyle),
          ],
          if (_phone != null) ...[
            const SizedBox(height: 8),
            Text(l10n.contactsPhoneLinked(_phone!), style: _bodyStyle),
          ] else if (enabled || scan.status == ContactsScanStatus.error) ...[
            const SizedBox(height: 8),
            Text(l10n.contactsAddPhoneHint, style: _bodyStyle),
            TextButton.icon(
              onPressed: _busy ? null : () => _addPhone(l10n, enabled: enabled),
              icon: const Icon(Icons.phone_outlined, size: 18),
              label: Text(l10n.contactsAddPhone),
            ),
          ],
          if (scan.status == ContactsScanStatus.ready) ...[
            const SizedBox(height: 12),
            if (suggestions.isNotEmpty) ...[
              _Subtitle(l10n.contactsSuggestionsTitle),
              for (final s in suggestions)
                _SuggestionRow(
                  suggestion: s,
                  busy: _busy,
                  onAdd: () => _add(l10n, s),
                ),
            ] else if (scan.matches.isEmpty)
              Text(l10n.contactsNoneOnSipho, style: _bodyStyle),
            if (scan.invites.isNotEmpty) ...[
              const SizedBox(height: 12),
              _Subtitle(l10n.contactsInviteTitle),
              for (final invite in scan.invites.take(_invitesShown))
                _InviteRow(
                  invite: invite,
                  onSms: invite.phone == null
                      ? null
                      : () => _invite(
                            l10n,
                            (message) => smsInviteUri(invite.phone!, message),
                          ),
                  onEmail: invite.email == null
                      ? null
                      : () => _invite(
                            l10n,
                            (message) => emailInviteUri(
                              invite.email!,
                              l10n.contactsInviteSubject,
                              message,
                            ),
                          ),
                ),
              if (scan.invites.length > _invitesShown)
                TextButton(
                  onPressed: () =>
                      setState(() => _invitesShown += _invitesPerPage),
                  child: Text(l10n.contactsMore),
                ),
            ],
          ],
          if (enabled)
            TextButton(
              onPressed: () => _stop(l10n),
              child: Text(l10n.contactsStop),
            ),
        ],
      ),
    );
  }
}

/// A dialog with one text field; pops the typed text, or `null` when cancelled or left empty.
class _TextPromptDialog extends StatefulWidget {
  const _TextPromptDialog({
    required this.title,
    required this.label,
    required this.confirm,
    this.hint,
    this.keyboardType,
    this.maxLength = 20,
  });

  final String title;
  final String label;
  final String confirm;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLength;

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    Navigator.of(context).pop(text.isEmpty ? null : text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: widget.keyboardType,
        maxLength: widget.maxLength,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          counterText: '',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelBtn),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirm)),
      ],
    );
  }
}

const TextStyle _bodyStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 13,
  fontWeight: FontWeight.w700,
  color: AppColors.textSecondary,
);

class _Subtitle extends StatelessWidget {
  const _Subtitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _SuggestionRow extends ConsumerWidget {
  const _SuggestionRow({
    required this.suggestion,
    required this.busy,
    required this.onAdd,
  });

  final ContactSuggestion suggestion;
  final bool busy;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pseudo =
        ref.watch(publicProfileProvider(suggestion.uid)).valueOrNull?.pseudo ??
            '';
    final name = suggestion.contactName.isNotEmpty
        ? suggestion.contactName
        : (pseudo.isNotEmpty ? pseudo : l10n.friendsUnknownName);
    final showPseudo = pseudo.isNotEmpty && pseudo != name;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
                if (showPseudo) Text(pseudo, style: _bodyStyle),
              ],
            ),
          ),
          FilledButton(
            onPressed: busy ? null : onAdd,
            child: Text(l10n.contactsAdd),
          ),
        ],
      ),
    );
  }
}

class _InviteRow extends StatelessWidget {
  const _InviteRow({required this.invite, this.onSms, this.onEmail});

  final ContactInvite invite;
  final VoidCallback? onSms;
  final VoidCallback? onEmail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              invite.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          if (onSms != null)
            IconButton(
              tooltip: '${l10n.contactsInviteSms} · ${invite.name}',
              onPressed: onSms,
              icon: const Icon(Icons.sms_outlined),
            ),
          if (onEmail != null)
            IconButton(
              tooltip: '${l10n.contactsInviteEmail} · ${invite.name}',
              onPressed: onEmail,
              icon: const Icon(Icons.mail_outline_rounded),
            ),
        ],
      ),
    );
  }
}
