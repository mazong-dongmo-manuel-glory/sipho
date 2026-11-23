import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/features/friends/data/friends_repository.dart';
import 'package:sipho/features/friends/domain/friends.dart';
import 'package:sipho/features/friends/presentation/challenge_friend_sheet.dart';
import 'package:sipho/features/friends/presentation/contacts_section.dart';
import 'package:sipho/features/friends/presentation/friend_challenge_card.dart';
import 'package:sipho/features/friends/presentation/friend_challenges_providers.dart';
import 'package:sipho/features/friends/presentation/friends_failure_text.dart';
import 'package:sipho/features/friends/presentation/friends_providers.dart';
import 'package:sipho/features/leaderboard/presentation/league_labels.dart';

/// Friends and invitations: my code (copy / share), add a friend by code, requests and the list.
/// Embedded in the "Friends" tab of the ranking screen.
class FriendsPanel extends ConsumerStatefulWidget {
  const FriendsPanel({
    super.key,
    this.onShare = _defaultShare,
    this.launch = defaultLaunch,
  });

  /// Opens the system share sheet. Replaceable in tests.
  final Future<void> Function(String text) onShare;

  /// Opens an `sms:` / `mailto:` link. Replaceable in tests.
  final Future<bool> Function(Uri uri) launch;

  static Future<void> _defaultShare(String text) async {
    await Share.share(text);
  }

  @override
  ConsumerState<FriendsPanel> createState() => _FriendsPanelState();
}

class _FriendsPanelState extends ConsumerState<FriendsPanel> {
  final _addController = TextEditingController();
  final _redeemController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _addController.dispose();
    _redeemController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Runs [action] once at a time and reports a failure in a snack bar.
  Future<void> _run(
    AppLocalizations l10n,
    Future<void> Function() action,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } on FriendsException catch (error) {
      _toast(friendsFailureText(l10n, error.failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendRequest(AppLocalizations l10n) {
    final code = normalizeFriendCode(_addController.text);
    if (!isPlausibleFriendCode(code)) {
      _toast(l10n.friendsCodeInvalid);
      return Future.value();
    }
    return _run(l10n, () async {
      final outcome = await ref.read(friendsRepositoryProvider).sendRequest(
            code,
          );
      _addController.clear();
      _toast(
        outcome == FriendRequestOutcome.nowFriends
            ? l10n.friendsNowFriends
            : l10n.friendsRequestSent,
      );
    });
  }

  Future<void> _redeem(AppLocalizations l10n) {
    final code = normalizeFriendCode(_redeemController.text);
    if (!isPlausibleFriendCode(code)) {
      _toast(l10n.friendsCodeInvalid);
      return Future.value();
    }
    return _run(l10n, () async {
      final xp = await ref.read(friendsRepositoryProvider).redeemReferral(code);
      _redeemController.clear();
      _toast(l10n.friendsRedeemDone(xp));
    });
  }

  Future<void> _confirmRemove(
    AppLocalizations l10n,
    FriendLink link,
    String name,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.friendsRemoveConfirm(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelBtn),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.friendsRemove),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _run(
      l10n,
      () => ref.read(friendsRepositoryProvider).remove(link.pairId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final links = ref.watch(friendLinksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MyCodeCard(onShare: widget.onShare),
        const SizedBox(height: 16),
        _SectionTitle(l10n.friendsAddTitle),
        _CodeField(
          controller: _addController,
          hint: l10n.friendsAddHint,
          cta: l10n.friendsAddCta,
          busy: _busy,
          onSubmit: () => _sendRequest(l10n),
        ),
        const SizedBox(height: 16),
        ContactsSection(launch: widget.launch),
        const SizedBox(height: 16),
        ...links.when(
          loading: () => const [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
          error: (_, __) => [_Hint(l10n.friendsErrGeneric)],
          data: (data) => [
            if (data.incoming.isNotEmpty) ...[
              _SectionTitle(l10n.friendsRequestsTitle),
              for (final link in data.incoming)
                _PersonRow(
                  uid: link.uid,
                  actions: (name) => [
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => _run(
                                l10n,
                                () => ref
                                    .read(friendsRepositoryProvider)
                                    .respond(link.pairId, accept: false),
                              ),
                      child: Text(l10n.friendsDecline),
                    ),
                    FilledButton(
                      onPressed: _busy
                          ? null
                          : () => _run(
                                l10n,
                                () => ref
                                    .read(friendsRepositoryProvider)
                                    .respond(link.pairId, accept: true),
                              ),
                      child: Text(l10n.friendsAccept),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
            ],
            _SectionTitle(l10n.friendsListTitle),
            const _ActiveChallengesSection(),
            if (data.friends.isEmpty)
              _Hint(l10n.friendsEmpty)
            else
              _FriendsList(
                links: data.friends,
                onRemove: (link, name) => _confirmRemove(l10n, link, name),
              ),
            if (data.outgoing.isNotEmpty) ...[
              const SizedBox(height: 12),
              _SectionTitle(l10n.friendsPendingTitle),
              for (final link in data.outgoing)
                _PersonRow(
                  uid: link.uid,
                  showStats: false,
                  actions: (name) => [
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => _run(
                                l10n,
                                () => ref
                                    .read(friendsRepositoryProvider)
                                    .remove(link.pairId),
                              ),
                      child: Text(l10n.cancelBtn),
                    ),
                  ],
                ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        _RedeemSection(
          controller: _redeemController,
          busy: _busy,
          onSubmit: () => _redeem(l10n),
        ),
        _Hint(l10n.friendsPrivacy),
      ],
    );
  }
}

class _MyCodeCard extends ConsumerWidget {
  const _MyCodeCard({required this.onShare});

  final Future<void> Function(String text) onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final code = ref.watch(inviteCodeProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const SiphoArt.happy(frame: 47),
          const SizedBox(width: 12),
          Expanded(
            child: code.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.friendsCodeError),
                  TextButton(
                    onPressed: () => ref.invalidate(inviteCodeProvider),
                    child: Text(l10n.retryBtn),
                  ),
                ],
              ),
              data: (value) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.friendsMyCode,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  Semantics(
                    label: '${l10n.friendsMyCode}: $value',
                    excludeSemantics: true,
                    child: SelectableText(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 26,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await Clipboard.setData(ClipboardData(text: value));
                          messenger.showSnackBar(
                            SnackBar(content: Text(l10n.friendsCodeCopied)),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: Text(l10n.friendsCopy),
                      ),
                      FilledButton.icon(
                        onPressed: () =>
                            onShare(l10n.friendsShareMessage(value)),
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: Text(l10n.friendsShare),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeField extends StatelessWidget {
  const _CodeField({
    required this.controller,
    required this.hint,
    required this.cta,
    required this.busy,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final String hint;
  final String cta;
  final bool busy;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            enableSuggestions: false,
            maxLength: 20,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              hintText: hint,
              counterText: '',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: busy ? null : onSubmit,
          child: Text(cta),
        ),
      ],
    );
  }
}

class _RedeemSection extends StatelessWidget {
  const _RedeemSection({
    required this.controller,
    required this.busy,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      shape: const Border(),
      collapsedShape: const Border(),
      title: Text(
        l10n.friendsRedeemTitle,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
      children: [
        _CodeField(
          controller: controller,
          hint: l10n.friendsAddHint,
          cta: l10n.friendsRedeemCta,
          busy: busy,
          onSubmit: onSubmit,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ActiveChallengesSection extends ConsumerWidget {
  const _ActiveChallengesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(activeChallengesProvider);
    if (challenges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        _SectionTitle(AppLocalizations.of(context).friendsChallengesSection),
        for (final challenge in challenges)
          FriendChallengeCard(challenge: challenge),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _FriendsList extends ConsumerWidget {
  const _FriendsList({required this.links, required this.onRemove});

  final List<FriendLink> links;
  final void Function(FriendLink link, String name) onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = <String, PublicProfile>{};
    for (final link in links) {
      final profile = ref.watch(publicProfileProvider(link.uid)).valueOrNull;
      if (profile != null) profiles[link.uid] = profile;
    }
    final order = sortFriends(profiles.values).map((p) => p.uid).toList();
    // Friends whose profile has not loaded yet stay at the end rather than disappearing.
    final pending = [
      for (final link in links)
        if (!profiles.containsKey(link.uid)) link,
    ];
    final byUid = {for (final link in links) link.uid: link};

    return Column(
      children: [
        for (final uid in order)
          _PersonRow(
            uid: uid,
            sharedStreak: byUid[uid]?.sharedStreak ?? 0,
            actions: (name) => [
              IconButton(
                tooltip: AppLocalizations.of(context).friendsChallengeTooltip,
                onPressed: () {
                  final link = byUid[uid]!;
                  final profile = profiles[uid] ??
                      PublicProfile(uid: uid, pseudo: name);
                  ChallengeFriendSheet.show(
                    context,
                    link: link,
                    friendProfile: profile,
                  );
                },
                icon: const Icon(
                  Icons.flash_on_rounded,
                  color: AppColors.accent,
                ),
              ),
              IconButton(
                tooltip: AppLocalizations.of(context).friendsRemove,
                onPressed: () => onRemove(byUid[uid]!, name),
                icon: const Icon(Icons.person_remove_outlined),
              ),
            ],
          ),
        for (final link in pending)
          _PersonRow(
            uid: link.uid,
            sharedStreak: link.sharedStreak,
          ),
      ],
    );
  }
}

/// One person: avatar, pseudo and, optionally, level / streak / league, plus actions.
class _PersonRow extends ConsumerWidget {
  const _PersonRow({
    required this.uid,
    this.showStats = true,
    this.sharedStreak = 0,
    this.actions,
  });

  final String uid;
  final bool showStats;
  final int sharedStreak;
  final List<Widget> Function(String name)? actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(publicProfileProvider(uid)).valueOrNull;
    final name = (profile?.pseudo.isNotEmpty ?? false)
        ? profile!.pseudo
        : l10n.friendsUnknownName;
    final stats = profile == null || !showStats
        ? null
        : '${l10n.friendsStats(profile.level, profile.streak)}'
            ' · ${leagueTierLabel(l10n, profile.league)}'
            '${sharedStreak > 0 ? " · 🔥 $sharedStreak j partagés" : ""}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SiphoArt.happy(frame: 47),
          const SizedBox(width: 8),
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
                if (stats != null)
                  Text(
                    stats,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          ...?actions?.call(name),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
