import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/core/i18n/app_language.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/friends/data/friend_challenges_repository.dart';
import 'package:sipho/features/friends/domain/friend_challenge.dart';
import 'package:sipho/features/friends/domain/friends.dart';

/// Modal bottom sheet to pick a challenge template and launch a 1v1 duel against a friend.
class ChallengeFriendSheet extends ConsumerStatefulWidget {
  const ChallengeFriendSheet({
    super.key,
    required this.link,
    required this.friendProfile,
  });

  final FriendLink link;
  final PublicProfile friendProfile;

  static Future<void> show(
    BuildContext context, {
    required FriendLink link,
    required PublicProfile friendProfile,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ChallengeFriendSheet(
        link: link,
        friendProfile: friendProfile,
      ),
    );
  }

  @override
  ConsumerState<ChallengeFriendSheet> createState() =>
      _ChallengeFriendSheetState();
}

class _ChallengeFriendSheetState extends ConsumerState<ChallengeFriendSheet> {
  int _selectedIndex = 0;
  bool _busy = false;

  Future<void> _sendChallenge() async {
    if (_busy) return;
    setState(() => _busy = true);

    final l10n = AppLocalizations.of(context);
    final selected = PredefinedChallengeTemplate.catalog[_selectedIndex];
    final friendName = widget.friendProfile.pseudo.isNotEmpty
        ? widget.friendProfile.pseudo
        : l10n.friendsUnknownName;
    final locale =
        normalizeAppLanguage(Localizations.localeOf(context).languageCode);

    try {
      await ref.read(feedbackServiceProvider).play(SiphoCue.fixedPaid);
      await ref.read(friendChallengesRepositoryProvider).createChallenge(
            friendUid: widget.friendProfile.uid,
            templateId: selected.id,
            locale: locale,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.friendsChallengeSent(
                selected.title(locale),
                friendName,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.friendsChallengeSendError)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language =
        normalizeAppLanguage(Localizations.localeOf(context).languageCode);
    final friendName = widget.friendProfile.pseudo.isNotEmpty
        ? widget.friendProfile.pseudo
        : l10n.friendsChallengeFriendFallback;
    const templates = PredefinedChallengeTemplate.catalog;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.friendsChallengeTitle(friendName),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.friendsChallengeSubtitle,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < templates.length; i++) ...[
              _TemplateTile(
                template: templates[i],
                language: language,
                isSelected: _selectedIndex == i,
                onTap: () async {
                  await performSystemHaptic(HapticKind.selection);
                  setState(() => _selectedIndex = i);
                },
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 16),
            SiphoButton3D(
              label: l10n.friendsChallengeSend,
              isLoading: _busy,
              enabled: !_busy,
              color: AppColors.primary,
              shadowColor: AppColors.primaryDark,
              onPressed: _sendChallenge,
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.template,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final PredefinedChallengeTemplate template;
  final String language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mint.withValues(alpha: 0.4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(template.category.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.title(language),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    template.description(language),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${template.rewardXp} XP',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
