import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/friends/data/friend_challenges_repository.dart';
import 'package:sipho/features/friends/domain/friend_challenge.dart';

class FriendChallengeCard extends ConsumerWidget {
  const FriendChallengeCard({
    super.key,
    required this.challenge,
  });

  final FriendChallenge challenge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final myUid = ref.watch(authStateProvider).value?.uid ?? '';
    final isSender = challenge.isSender(myUid);
    final myProg = challenge.myProgress(myUid);
    final otherProg = challenge.otherProgress(myUid);
    final otherName = challenge.otherName(myUid);
    final isPendingForMe =
        challenge.status == ChallengeStatus.pending && !isSender;
    final isPendingByMe =
        challenge.status == ChallengeStatus.pending && isSender;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: challenge.status == ChallengeStatus.active
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                challenge.category.emoji,
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      challenge.description,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+${challenge.rewardXp} XP',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 1v1 Progress comparison
          Row(
            children: [
              Expanded(
                child: _PlayerProgress(
                  name: 'Toi',
                  progress: myProg,
                  target: challenge.targetCount,
                  color: AppColors.primary,
                  isLeading: myProg >= otherProg && myProg > 0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '⚔️',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Expanded(
                child: _PlayerProgress(
                  name: otherName,
                  progress: otherProg,
                  target: challenge.targetCount,
                  color: AppColors.accent,
                  isLeading: otherProg > myProg,
                ),
              ),
            ],
          ),
          if (isPendingForMe) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await performSystemHaptic(HapticKind.selection);
                      await ref
                          .read(friendChallengesRepositoryProvider)
                          .respondChallenge(
                            pairId: challenge.pairId,
                            challengeId: challenge.id,
                            accept: false,
                          );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.friendsDecline,
                      style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      await ref.read(feedbackServiceProvider).play(SiphoCue.fixedPaid);
                      await ref
                          .read(friendChallengesRepositoryProvider)
                          .respondChallenge(
                            pairId: challenge.pairId,
                            challengeId: challenge.id,
                            accept: true,
                          );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Relever ⚔️',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (isPendingByMe) ...[
            const SizedBox(height: 10),
            Center(
              child: Text(
                'En attente de $otherName...',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ] else if (challenge.status == ChallengeStatus.completed) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                challenge.winnerUid == myUid
                    ? '🏆 Défi remporté ! Félicitations !'
                    : '🏁 Défi terminé par $otherName',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlayerProgress extends StatelessWidget {
  const _PlayerProgress({
    required this.name,
    required this.progress,
    required this.target,
    required this.color,
    required this.isLeading,
  });

  final String name;
  final int progress;
  final int target;
  final Color color;
  final bool isLeading;

  @override
  Widget build(BuildContext context) {
    final frac = target <= 0 ? 0.0 : (progress / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: isLeading ? FontWeight.w900 : FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            Text(
              '$progress/$target',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: frac,
            minHeight: 8,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
