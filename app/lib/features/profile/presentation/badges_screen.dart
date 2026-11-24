import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../gamification/data/game_state_provider.dart';
import '../../gamification/domain/badges.dart';

/// Frame 40 · Badges · ids serveur (`game/state.badges`).
class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(gameStateProvider).badges.toSet();
    final fr = Localizations.localeOf(context).languageCode == 'fr';

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Text(
              'Mes badges',
              style: SiphoTypography.title.copyWith(
                fontSize: 28,
                color: SiphoPalette.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${unlocked.length} débloqués · Jamais d’XP sur un badge',
              style: SiphoTypography.body.copyWith(
                fontSize: 16,
                color: SiphoPalette.textSecondary(context),
              ),
            ),
            const SizedBox(height: 20),
            ...kBadges.map(
              (b) {
                final owned = unlocked.contains(b.id);
                return Column(
                  children: [
                    SiphoListRow(
                      title: '${b.emoji}  ${fr ? b.titleFr : b.titleEn}',
                      subtitle: fr ? b.subtitleFr : b.subtitleEn,
                      trailing: owned ? '✓' : '🔒',
                      onTap: owned
                          ? () => context.push('/badges/earned', extra: {
                                'id': b.id,
                                'title': fr ? b.titleFr : b.titleEn,
                              })
                          : null,
                    ),
                    const SiphoSeparator(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
