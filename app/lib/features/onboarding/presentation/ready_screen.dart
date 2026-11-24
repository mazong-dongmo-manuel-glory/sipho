import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../auth/data/user_profile_provider.dart';

/// Frame 06 · Première victoire — badge serveur `builder` (pas de faux XP).
class ReadyScreen extends ConsumerWidget {
  const ReadyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fr = Localizations.localeOf(context).languageCode == 'fr';

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      fr ? 'Ton nid est prêt.' : 'Your nest is ready.',
                      style: SiphoTypography.title.copyWith(
                        fontSize: 28,
                        color: SiphoPalette.textPrimary(context),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fr
                          ? 'C’est le début, et c’est déjà quelque chose.'
                          : 'It’s the start — and that already counts.',
                      style: SiphoTypography.body.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 154,
                      height: 154,
                      child: SvgPicture.asset(
                        'assets/images/sipho_celebrating.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SiphoSoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fr
                                ? '🏡 Badge « Nid construit »'
                                : '🏡 “Nest built” badge',
                            style: SiphoTypography.bodyBold.copyWith(
                              fontSize: 16,
                              color: SiphoPalette.textPrimary(context),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            fr
                                ? 'Pour avoir construit ton socle. Les badges ne donnent pas d’XP.'
                                : 'For building your foundation. Badges don’t grant XP.',
                            style: SiphoTypography.body.copyWith(
                              fontSize: 16,
                              color: SiphoPalette.textPrimary(context),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SiphoListRow(
                      title: fr ? 'Socle configuré' : 'Foundation set up',
                      trailing: '✓',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      fr
                          ? 'Ton argent reste privé.'
                          : 'Your money stays private.',
                      style: SiphoTypography.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: SiphoPalette.textSecondary(context),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SiphoButton3D(
                label: fr ? 'Découvrir mon accueil' : 'See my home',
                variant: SiphoButtonVariant.dark,
                onPressed: () async {
                  await ref
                      .read(userProfileProvider.notifier)
                      .completeOnboarding();
                  if (!context.mounted) return;
                  context.go('/onboarding/notifications');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
