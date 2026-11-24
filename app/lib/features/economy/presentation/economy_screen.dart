import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../../core/widgets/sipho_page_header.dart';
import '../../auth/data/user_profile_provider.dart';
import '../data/economy_provider.dart';

/// Frames 54–59 · Info Éco (Firestore economy + news + FX).
class EconomyScreen extends ConsumerWidget {
  const EconomyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final eco = ref.watch(economyProvider);
    final currency = ref.watch(userProfileProvider).currency.toUpperCase();
    final fxRate = eco.fxRates[currency];

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            SiphoPageHeader(
              title: l10n.ecoHubHeading,
              lead: l10n.ecoHubLead,
            ),
            const SizedBox(height: 20),
            if (eco.loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else
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
                      l10n.ecoHubCardTitle,
                      style: SiphoTypography.bodyBold.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      eco.summary.isEmpty ? l10n.ecoHubCardBody : eco.summary,
                      style: SiphoTypography.body.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      eco.source ?? l10n.ecoHubCardSource,
                      style: SiphoTypography.label.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                    if (fxRate != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        '1 ${eco.fxBase} ≈ ${fxRate.toStringAsFixed(2)} $currency',
                        style: SiphoTypography.bodyBold.copyWith(
                          fontSize: 15,
                          color: SiphoPalette.textPrimary(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            if (eco.headlines.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                l10n.newsArchivesHeading,
                style: SiphoTypography.bodyBold.copyWith(
                  color: SiphoPalette.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              for (final h in eco.headlines) ...[
                SiphoListRow(
                  title: h.title,
                  subtitle: h.takeaway,
                ),
                const SiphoSeparator(),
              ],
            ],
            const SizedBox(height: 16),
            SiphoListRow(
              title: l10n.ecoHistoryHeading,
              showChevron: true,
              onTap: () => context.push('/economy/history'),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: l10n.newsArchivesHeading,
              showChevron: true,
              onTap: () => context.push('/economy/news'),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: l10n.ecoQuizHeading,
              showChevron: true,
              onTap: () => context.push('/economy/quiz'),
            ),
            const SiphoSeparator(),
            SiphoListRow(
              title: l10n.ecoAlertsHeading,
              showChevron: true,
              onTap: () => context.push('/economy/alerts'),
            ),
          ],
        ),
      ),
    );
  }
}
