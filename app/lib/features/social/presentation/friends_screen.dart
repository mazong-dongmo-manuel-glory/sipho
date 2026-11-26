import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../../core/widgets/sipho_page_header.dart';
import '../../../core/firebase/cloud_functions_service.dart';
import '../data/challenges_provider.dart';
import '../data/friends_provider.dart';

/// Frame 43 · Amis et défis — callables + stream friendships.
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _codeCtrl = TextEditingController();
  int _tab = 0;
  bool _sending = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  String _mapError(AppLocalizations l10n, Map<String, dynamic> result) {
    final code = (result['code'] as String?) ?? '';
    return switch (code) {
      'not-found' => l10n.friendsErrCodeNotFound,
      'invalid-argument' => l10n.friendsErrOwnCode,
      'already-exists' => l10n.friendsErrAlreadyDone,
      'resource-exhausted' => l10n.friendsErrLimit,
      'unavailable' || 'deadline-exceeded' => l10n.friendsErrNetwork,
      'failed-precondition' || 'permission-denied' => l10n.friendsErrNotAllowed,
      _ => l10n.friendsErrGeneric,
    };
  }

  Future<void> _sendRequest() async {
    final l10n = AppLocalizations.of(context);
    final code = _codeCtrl.text.trim();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.friendsCodeInvalid), backgroundColor: SiphoColors.primaryDark),
      );
      return;
    }
    setState(() => _sending = true);
    final result = await ref.read(friendsProvider.notifier).sendRequest(code);
    if (!mounted) return;
    setState(() => _sending = false);
    if (result['status'] == 'error') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mapError(l10n, result)), backgroundColor: SiphoColors.primaryDark),
      );
      return;
    }
    final status = result['status'] as String?;
    _codeCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == 'accepted' ? l10n.friendsNowFriends : l10n.friendsRequestSent,
        ),
        backgroundColor: SiphoColors.primaryDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final friends = ref.watch(friendsProvider);
    final code = friends.inviteCode ?? '…';

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            SiphoPageHeader(
              title: l10n.friendsChallengesHeading,
              lead: l10n.friendsPrivacy,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  child: _TabChip(
                    label: l10n.friendsTabFriends,
                    selected: _tab == 0,
                    onTap: () => setState(() => _tab = 0),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _TabChip(
                    label: l10n.friendsTabChallenges,
                    selected: _tab == 1,
                    onTap: () => setState(() => _tab = 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_tab == 0) ...[
              SiphoListRow(
                title: l10n.friendsMyCode,
                trailing: code,
                onTap: friends.inviteCode == null
                    ? () => ref.read(friendsProvider.notifier).loadInviteCode()
                    : () async {
                        await Clipboard.setData(ClipboardData(text: code));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.friendsCodeCopied),
                            backgroundColor: SiphoColors.primaryDark,
                          ),
                        );
                      },
              ),
              const SiphoSeparator(),
              Text(
                l10n.friendsAddTitle,
                style: SiphoTypography.bodyBold.copyWith(
                  fontSize: 16,
                  color: SiphoPalette.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              SiphoSoftCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: l10n.friendsAddHint,
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SiphoButton3D(
                label: _sending ? '…' : l10n.friendsAddCta,
                variant: SiphoButtonVariant.dark,
                onPressed: _sending ? null : _sendRequest,
              ),
              const SizedBox(height: 10),
              SiphoButton3D(
                label: l10n.contactsFind,
                variant: SiphoButtonVariant.secondary,
                onPressed: () => context.push('/friends/contacts'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _sending
                    ? null
                    : () async {
                        final code = _codeCtrl.text.trim();
                        if (code.length < 4) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.friendsCodeInvalid),
                              backgroundColor: SiphoColors.primaryDark,
                            ),
                          );
                          return;
                        }
                        setState(() => _sending = true);
                        final result = await ref
                            .read(cloudFunctionsServiceProvider)
                            .referralRedeem(referralCode: code);
                        if (!context.mounted) return;
                        setState(() => _sending = false);
                        final msg = result['status'] == 'error'
                            ? _mapError(l10n, result)
                            : l10n.friendsRedeemDone(
                                (result['xp'] as num?)?.toInt() ?? 0,
                              );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(msg),
                            backgroundColor: SiphoColors.primaryDark,
                          ),
                        );
                      },
                child: Text(
                  l10n.friendsRedeemCta,
                  style: SiphoTypography.bodyBold.copyWith(
                    color: SiphoPalette.textPrimary(context),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (friends.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (friends.accepted.isEmpty &&
                  friends.incoming.isEmpty &&
                  friends.outgoing.isEmpty)
                Text(
                  l10n.friendsEmpty,
                  style: SiphoTypography.body.copyWith(color: SiphoPalette.textSecondary(context)),
                )
              else ...[
                if (friends.incoming.isNotEmpty) ...[
                  Text(
                    l10n.friendsRequestsTitle,
                    style: SiphoTypography.bodyBold.copyWith(color: SiphoPalette.textPrimary(context)),
                  ),
                  const SizedBox(height: 8),
                  ...friends.incoming.map((f) {
                    final name = f.displayName.isEmpty ? l10n.friendsUnknownName : f.displayName;
                    return Column(
                      children: [
                        SiphoListRow(
                          title: name,
                          subtitle: l10n.friendsStats(f.level, f.streak),
                          trailing: l10n.friendsAccept,
                          onTap: () => ref
                              .read(friendsProvider.notifier)
                              .respond(f.pairId, accept: true),
                        ),
                        const SiphoSeparator(),
                      ],
                    );
                  }),
                ],
                if (friends.accepted.isNotEmpty) ...[
                  Text(
                    l10n.friendsListTitle,
                    style: SiphoTypography.bodyBold.copyWith(color: SiphoPalette.textPrimary(context)),
                  ),
                  const SizedBox(height: 8),
                  ...friends.accepted.map((f) {
                    final name = f.displayName.isEmpty ? l10n.friendsUnknownName : f.displayName;
                    return Column(
                      children: [
                        SiphoListRow(
                          title: name,
                          subtitle: l10n.friendsStats(f.level, f.streak),
                          trailing: '🔥 ${f.streak}',
                          onTap: () => context.push(
                                '/profile/public',
                                extra: {'uid': f.otherUid},
                              ),
                        ),
                        const SiphoSeparator(),
                      ],
                    );
                  }),
                ],
                if (friends.outgoing.isNotEmpty) ...[
                  Text(
                    l10n.friendsPendingTitle,
                    style: SiphoTypography.bodyBold.copyWith(color: SiphoPalette.textPrimary(context)),
                  ),
                  const SizedBox(height: 8),
                  ...friends.outgoing.map((f) {
                    final name = f.displayName.isEmpty ? l10n.friendsUnknownName : f.displayName;
                    return Column(
                      children: [
                        SiphoListRow(
                          title: name,
                          subtitle: l10n.friendsPending,
                          trailing: '…',
                        ),
                        const SiphoSeparator(),
                      ],
                    );
                  }),
                ],
              ],
            ] else ...[
              SiphoSoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.friendsChallengeActive,
                      style: SiphoTypography.bodyBold.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.friendsChallengeActiveBody,
                      style: SiphoTypography.body.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ..._buildChallengeRows(context, ref, l10n, friends),
              const SiphoSeparator(),
              SiphoListRow(
                title: l10n.friendsChallengeInvite,
                showChevron: true,
                onTap: friends.accepted.isEmpty
                    ? null
                    : () => _inviteChallenge(context, ref, l10n, friends),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.friendsChallengePrivacy,
                style: SiphoTypography.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: SiphoPalette.textSecondary(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChallengeRows(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    FriendsState friends,
  ) {
    final challenges = ref.watch(challengesProvider);
    if (challenges.isEmpty) {
      return [
        SiphoListRow(
          title: l10n.friendsChallengeWeekly,
          subtitle: l10n.friendsChallengeWeeklySub,
          trailing: friends.accepted.isEmpty ? '—' : '0 / 5',
        ),
      ];
    }
    return [
      for (final c in challenges.take(5)) ...[
        SiphoListRow(
          title: c.title.isNotEmpty ? c.title : l10n.friendsChallengeWeekly,
          subtitle: c.canRespond
              ? (Localizations.localeOf(context).languageCode == 'fr'
                  ? 'En attente de ta réponse'
                  : 'Waiting for your reply')
              : l10n.friendsChallengeWeeklySub,
          trailing: '${c.myProgress} / ${c.targetCount}',
        ),
        if (c.canRespond)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: SiphoButton3D(
                    label: Localizations.localeOf(context).languageCode == 'fr'
                        ? 'Accepter'
                        : 'Accept',
                    height: 44,
                    onPressed: () => _respondChallenge(
                      context,
                      ref,
                      l10n,
                      c,
                      accept: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SiphoButton3D(
                    label: Localizations.localeOf(context).languageCode == 'fr'
                        ? 'Refuser'
                        : 'Decline',
                    variant: SiphoButtonVariant.outline,
                    height: 44,
                    onPressed: () => _respondChallenge(
                      context,
                      ref,
                      l10n,
                      c,
                      accept: false,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          const SiphoSeparator(),
      ],
    ];
  }

  Future<void> _respondChallenge(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    FriendChallenge challenge, {
    required bool accept,
  }) async {
    final result =
        await ref.read(cloudFunctionsServiceProvider).respondFriendChallenge(
              pairId: challenge.pairId,
              challengeId: challenge.id,
              accept: accept,
            );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['status'] == 'error'
              ? l10n.friendsErrGeneric
              : (accept
                  ? (Localizations.localeOf(context).languageCode == 'fr'
                      ? 'Défi accepté'
                      : 'Challenge accepted')
                  : (Localizations.localeOf(context).languageCode == 'fr'
                      ? 'Défi refusé'
                      : 'Challenge declined')),
        ),
        backgroundColor: SiphoColors.primaryDark,
      ),
    );
  }

  Future<void> _inviteChallenge(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    FriendsState friends,
  ) async {
    final fr = Localizations.localeOf(context).languageCode == 'fr';
    const templates = <(String id, String frTitle, String enTitle)>[
      ('marathon_savoir', 'Marathon Savoir', 'Knowledge Marathon'),
      ('zero_ecart', '3 Jours Zéro Écart', '3 Days Under Budget'),
      ('boost_epargne', 'Boost Épargne', 'Savings Boost'),
      ('semaine_champion', 'Semaine Champion', 'Champion Week'),
    ];
    final friend = await showModalBottomSheet<FriendLink>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final f in friends.accepted)
              ListTile(
                title: Text(
                  f.displayName.isEmpty ? l10n.friendsUnknownName : f.displayName,
                ),
                onTap: () => Navigator.pop(ctx, f),
              ),
          ],
        ),
      ),
    );
    if (friend == null || !context.mounted) return;

    final templateId = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final t in templates)
              ListTile(
                title: Text(fr ? t.$2 : t.$3),
                onTap: () => Navigator.pop(ctx, t.$1),
              ),
          ],
        ),
      ),
    );
    if (templateId == null || !context.mounted) return;

    final result =
        await ref.read(cloudFunctionsServiceProvider).createFriendChallenge(
              friendUid: friend.otherUid,
              templateId: templateId,
              locale: fr ? 'fr' : 'en',
            );
    if (!context.mounted) return;
    final title = templates
        .firstWhere((t) => t.$1 == templateId, orElse: () => templates.first);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['status'] == 'error'
              ? l10n.friendsChallengeSendError
              : l10n.friendsChallengeSent(
                  fr ? title.$2 : title.$3,
                  friend.displayName.isEmpty
                      ? l10n.friendsUnknownName
                      : friend.displayName,
                ),
        ),
        backgroundColor: SiphoColors.primaryDark,
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? SiphoPalette.selectedChip(context)
              : SiphoPalette.softSurface(context),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: SiphoTypography.bodyBold.copyWith(
            fontSize: 14,
            color: SiphoPalette.textPrimary(context),
          ),
        ),
      ),
    );
  }
}
