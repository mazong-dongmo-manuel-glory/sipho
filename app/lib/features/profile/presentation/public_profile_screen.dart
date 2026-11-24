import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../../core/widgets/sipho_page_header.dart';
import '../../gamification/domain/badges.dart';
import '../data/public_profile_provider.dart';

/// Frame 42 · Profil public (jamais de montants).
class PublicProfileScreen extends ConsumerWidget {
  const PublicProfileScreen({super.key});

  String _leagueLabel(AppLocalizations l10n, String tier) {
    return switch (tier.toLowerCase()) {
      'bronze' => l10n.leagueTierBronze,
      'silver' => l10n.leagueTierSilver,
      'gold' => l10n.leagueTierGold,
      'sapphire' => l10n.leagueTierSapphire,
      'ruby' => l10n.leagueTierRuby,
      'emerald' => l10n.leagueTierEmerald,
      'amethyst' => l10n.leagueTierAmethyst,
      'pearl' => l10n.leagueTierPearl,
      'obsidian' => l10n.leagueTierObsidian,
      'diamond' => l10n.leagueTierDiamond,
      _ => tier,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final extra = GoRouterState.of(context).extra;
    String? uid;
    if (extra is Map) {
      uid = extra['uid']?.toString();
    } else if (extra is String) {
      uid = extra;
    }
    final async = ref.watch(publicProfileProvider(uid));

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              SiphoPageHeader(
                title: l10n.publicProfileHeading,
                lead: l10n.publicProfileLead,
              ),
            ],
          ),
          data: (profile) {
            final name = (profile?.pseudo.isNotEmpty == true)
                ? profile!.pseudo
                : l10n.friendsUnknownName;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              children: [
                SiphoPageHeader(
                  title: l10n.publicProfileHeading,
                  lead: l10n.publicProfileLead,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 110,
                    height: 110,
                    child: SvgPicture.asset(
                      'assets/images/sipho_happy.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: SiphoTypography.title.copyWith(
                    fontSize: 24,
                    color: SiphoPalette.textPrimary(context),
                  ),
                ),
                Text(
                  _leagueLabel(l10n, profile?.league ?? 'bronze'),
                  style: SiphoTypography.body.copyWith(
                    color: SiphoPalette.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 20),
                SiphoListRow(
                  title: l10n.publicProfileStreak,
                  trailing: '${profile?.streak ?? 0}',
                ),
                const SiphoSeparator(),
                SiphoListRow(
                  title: l10n.publicProfileLevel,
                  trailing: '${profile?.level ?? 1}',
                ),
                const SiphoSeparator(),
                SiphoListRow(
                  title: l10n.publicProfileBadges,
                  trailing: '${profile?.badges.length ?? 0}',
                ),
                const SiphoSeparator(),
                SiphoListRow(
                  title: l10n.publicProfileLessons,
                  trailing: '${profile?.lessonsCompleted ?? 0}',
                ),
                if (profile != null && profile.badges.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.publicProfileBadges,
                    style: SiphoTypography.bodyBold.copyWith(
                      fontSize: 16,
                      color: SiphoPalette.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final id in profile.badges) ...[
                    Builder(builder: (context) {
                      final fr =
                          Localizations.localeOf(context).languageCode == 'fr';
                      BadgeDef? def;
                      for (final b in kBadges) {
                        if (b.id == id) {
                          def = b;
                          break;
                        }
                      }
                      final title = def == null
                          ? id
                          : (fr ? def.titleFr : def.titleEn);
                      final emoji = def?.emoji ?? '🏅';
                      return Column(
                        children: [
                          SiphoListRow(
                            title: '$emoji  $title',
                          ),
                          const SiphoSeparator(),
                        ],
                      );
                    }),
                  ],
                ],
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: SiphoPalette.softSurface(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    l10n.publicProfilePrivacy,
                    style: SiphoTypography.bodyBold.copyWith(
                      fontSize: 16,
                      color: SiphoPalette.textPrimary(context),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
