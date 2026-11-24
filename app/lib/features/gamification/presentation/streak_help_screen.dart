import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/firebase/cloud_functions_service.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_page_header.dart';

/// Frame 70 · Série · Coup de main (réparation sous 24 h).
class StreakHelpScreen extends ConsumerWidget {
  const StreakHelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    SiphoPageHeader(
                      title: l10n.streakHelpHeading,
                      lead: l10n.streakHelpLead,
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
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: SiphoPalette.softSurface(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.streakHelpCardTitle,
                            style: SiphoTypography.bodyBold.copyWith(
                              fontSize: 16,
                              color: SiphoPalette.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.streakHelpCardBody,
                            style: SiphoTypography.body.copyWith(
                              fontSize: 16,
                              color: SiphoPalette.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.streakHelpCost,
                      style: SiphoTypography.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              SiphoButton3D(
                label: l10n.streakHelpCta,
                variant: SiphoButtonVariant.dark,
                onPressed: () async {
                  await ref.read(cloudFunctionsServiceProvider).repairStreak();
                  if (!context.mounted) return;
                  context.go('/streak');
                },
              ),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  l10n.streakHelpSkip,
                  style: SiphoTypography.bodyBold.copyWith(
                    color: SiphoPalette.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
