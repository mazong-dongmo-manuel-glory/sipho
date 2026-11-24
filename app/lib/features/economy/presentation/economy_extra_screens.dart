import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../../core/widgets/sipho_page_header.dart';
import '../../../core/widgets/sipho_status_body.dart';
import '../../settings/data/notif_prefs_provider.dart';
import '../data/economy_provider.dart';

/// Frame 55 · Carte éco · Historique (Firestore `economy/{CC}.dailyCards`).
class EcoCardHistoryScreen extends ConsumerWidget {
  const EcoCardHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final eco = ref.watch(economyProvider);
    final cards = eco.cards;

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            SiphoPageHeader(
              title: l10n.ecoHistoryHeading,
              lead: l10n.ecoHistoryLead,
            ),
            const SizedBox(height: 20),
            if (eco.loading)
              const Center(child: CircularProgressIndicator())
            else if (cards.isEmpty)
              Text(
                eco.summary,
                style: SiphoTypography.body.copyWith(
                  color: SiphoPalette.textSecondary(context),
                ),
              )
            else
              for (final c in cards) ...[
                SiphoListRow(
                  title: c.title,
                  subtitle: [
                    if (c.source != null && c.source!.isNotEmpty) c.source!,
                    if (c.dateLabel != null && c.dateLabel!.isNotEmpty)
                      c.dateLabel!,
                  ].join(' · '),
                  trailing: c.value ?? '—',
                ),
                const SiphoSeparator(),
              ],
          ],
        ),
      ),
    );
  }
}

/// Frame 56 · Info Éco · Indisponible.
class EcoUnavailableScreen extends StatelessWidget {
  const EcoUnavailableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: SiphoStatusBody(
          title: l10n.ecoUnavailableHeading,
          lead: l10n.ecoUnavailableLead,
          cardTitle: l10n.ecoUnavailableCardTitle,
          cardBody: l10n.ecoUnavailableCardBody,
          ctaLabel: l10n.retryBtn,
          onCta: () => context.pop(),
        ),
      ),
    );
  }
}

/// Frame 57 · Actus · Archives (`economyNews/{CC}`).
class NewsArchivesScreen extends ConsumerWidget {
  const NewsArchivesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final eco = ref.watch(economyProvider);
    final headlines = eco.headlines;

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            SiphoPageHeader(
              title: l10n.newsArchivesHeading,
              lead: l10n.newsArchivesLead,
            ),
            const SizedBox(height: 20),
            if (headlines.isEmpty)
              Text(
                Localizations.localeOf(context).languageCode == 'fr'
                    ? 'Pas encore d’actus pour ${eco.countryCode}.'
                    : 'No news yet for ${eco.countryCode}.',
                style: SiphoTypography.body.copyWith(
                  color: SiphoPalette.textSecondary(context),
                ),
              )
            else
              for (final h in headlines) ...[
                SiphoListRow(
                  title: h.title,
                  subtitle: [
                    if (h.source != null && h.source!.isNotEmpty) h.source!,
                    if (h.dateLabel != null && h.dateLabel!.isNotEmpty)
                      h.dateLabel!,
                    if (h.takeaway != null && h.takeaway!.isNotEmpty)
                      h.takeaway!,
                  ].where((s) => s.isNotEmpty).join(' · '),
                  showChevron: true,
                ),
                const SiphoSeparator(),
              ],
          ],
        ),
      ),
    );
  }
}

/// Frame 58 · Quiz économique hebdomadaire (éducatif local).
class EcoQuizScreen extends StatefulWidget {
  const EcoQuizScreen({super.key});

  @override
  State<EcoQuizScreen> createState() => _EcoQuizScreenState();
}

class _EcoQuizScreenState extends State<EcoQuizScreen> {
  int? _selected;
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = [
      l10n.ecoQuizOptA,
      l10n.ecoQuizOptB,
      l10n.ecoQuizOptC,
    ];

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
                      title: l10n.ecoQuizHeading,
                      lead: l10n.ecoQuizLead,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.ecoQuizQuestion,
                      style: SiphoTypography.bodyBold.copyWith(
                        fontSize: 18,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (var i = 0; i < options.length; i++) ...[
                      SiphoListRow(
                        title: options[i],
                        trailing: _selected == i ? '✓' : '○',
                        onTap: () => setState(() => _selected = i),
                      ),
                      const SiphoSeparator(),
                    ],
                    if (_checked && _selected != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _selected == 1
                              ? l10n.ecoQuizCorrect
                              : l10n.ecoQuizWrong,
                          style: SiphoTypography.bodyBold.copyWith(
                            color: _selected == 1
                                ? SiphoColors.primary
                                : SiphoColors.accentTerra,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SiphoButton3D(
                label: _checked ? l10n.doneBtn : l10n.confirmBtn,
                variant: SiphoButtonVariant.dark,
                onPressed: () {
                  if (!_checked) {
                    setState(() => _checked = true);
                  } else {
                    context.pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Frame 59 · Alertes économiques → `notifState.prefs`.
class EcoAlertsScreen extends ConsumerStatefulWidget {
  const EcoAlertsScreen({super.key});

  @override
  ConsumerState<EcoAlertsScreen> createState() => _EcoAlertsScreenState();
}

class _EcoAlertsScreenState extends ConsumerState<EcoAlertsScreen> {
  bool _rates = true;
  bool _fx = false;
  bool _inflation = true;
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(notifPrefsProvider);
    if (!_loaded) {
      _loaded = true;
      _rates = prefs.economy;
      _fx = prefs.economy;
      _inflation = prefs.economy;
    }

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
                      title: l10n.ecoAlertsHeading,
                      lead: l10n.ecoAlertsLead,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n.ecoAlertsRates,
                        style: SiphoTypography.bodyBold.copyWith(
                          color: SiphoPalette.textPrimary(context),
                        ),
                      ),
                      value: _rates,
                      activeThumbColor: SiphoColors.primary,
                      onChanged: (v) => setState(() => _rates = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n.ecoAlertsFx,
                        style: SiphoTypography.bodyBold.copyWith(
                          color: SiphoPalette.textPrimary(context),
                        ),
                      ),
                      value: _fx,
                      activeThumbColor: SiphoColors.primary,
                      onChanged: (v) => setState(() => _fx = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n.ecoAlertsInflation,
                        style: SiphoTypography.bodyBold.copyWith(
                          color: SiphoPalette.textPrimary(context),
                        ),
                      ),
                      value: _inflation,
                      activeThumbColor: SiphoColors.primary,
                      onChanged: (v) => setState(() => _inflation = v),
                    ),
                  ],
                ),
              ),
              SiphoButton3D(
                label: l10n.saveBtn,
                variant: SiphoButtonVariant.dark,
                onPressed: () async {
                  final enabled = _rates || _fx || _inflation;
                  await ref
                      .read(notifPrefsProvider.notifier)
                      .setFlag('economy', enabled);
                  if (!context.mounted) return;
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
