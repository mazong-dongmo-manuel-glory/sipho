import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../../core/widgets/sipho_page_header.dart';
import '../../auth/data/user_profile_provider.dart';
import '../../economy/data/economy_provider.dart';

/// Frame 53 · Mode voyage — prefs user + taux `fx/latest`.
class TravelModeScreen extends ConsumerStatefulWidget {
  const TravelModeScreen({super.key});

  @override
  ConsumerState<TravelModeScreen> createState() => _TravelModeScreenState();
}

class _TravelModeScreenState extends ConsumerState<TravelModeScreen> {
  bool? _enabled;
  String? _currency;
  static const _currencies = ['EUR', 'USD', 'XOF', 'GBP', 'CAD'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(userProfileProvider);
    final eco = ref.watch(economyProvider);
    final enabled = _enabled ?? user.travelModeEnabled;
    final currency = _currency ??
        (user.travelCurrency.isNotEmpty ? user.travelCurrency : 'EUR');
    final main = user.currency.toUpperCase();
    final travel = currency.toUpperCase();

    String fxHint;
    if (travel == main) {
      fxHint = '1 $main = 1 $main';
    } else {
      final base = eco.fxBase;
      double? rateMain = travel == base
          ? 1.0
          : eco.fxRates[travel];
      double? rateHome = main == base ? 1.0 : eco.fxRates[main];
      if (rateMain != null && rateHome != null && rateMain != 0) {
        final homePerTravel = rateHome / rateMain;
        fxHint =
            '1 $travel ≈ ${homePerTravel.toStringAsFixed(homePerTravel >= 100 ? 0 : 2)} $main';
      } else {
        fxHint = l10n.travelModeFxBody;
      }
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
                      title: l10n.travelModeHeading,
                      lead: l10n.travelModeLead,
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n.travelModeToggle,
                        style: SiphoTypography.bodyBold.copyWith(
                          fontSize: 16,
                          color: SiphoPalette.textPrimary(context),
                        ),
                      ),
                      value: enabled,
                      activeThumbColor: SiphoColors.primary,
                      onChanged: (v) => setState(() => _enabled = v),
                    ),
                    const SiphoSeparator(),
                    SiphoListRow(
                      title: l10n.travelModeCurrency,
                      trailing: travel,
                      onTap: () async {
                        final picked = await showModalBottomSheet<String>(
                          context: context,
                          builder: (ctx) => SafeArea(
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                for (final c in {
                                  main,
                                  ..._currencies,
                                })
                                  ListTile(
                                    title: Text(c),
                                    trailing: c == travel ? const Icon(Icons.check) : null,
                                    onTap: () => Navigator.pop(ctx, c),
                                  ),
                              ],
                            ),
                          ),
                        );
                        if (picked != null) {
                          setState(() => _currency = picked);
                        }
                      },
                    ),
                    const SiphoSeparator(),
                    SiphoListRow(
                      title: l10n.travelModeFxHint,
                      subtitle: fxHint,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: SiphoPalette.softSurface(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        enabled
                            ? (Localizations.localeOf(context).languageCode ==
                                    'fr'
                                ? 'À l’ajout d’une dépense, Sipho proposera $travel et convertira vers $main.'
                                : 'When adding an expense, Sipho will offer $travel and convert to $main.')
                            : l10n.travelModeCard,
                        style: SiphoTypography.bodyBold.copyWith(
                          fontSize: 16,
                          color: SiphoPalette.textPrimary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SiphoButton3D(
                label: l10n.saveBtn,
                variant: SiphoButtonVariant.dark,
                onPressed: () async {
                  await ref.read(userProfileProvider.notifier).saveTravelMode(
                        enabled: enabled,
                        currency: travel,
                      );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
