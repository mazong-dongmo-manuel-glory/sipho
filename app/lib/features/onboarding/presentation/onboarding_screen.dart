import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../auth/data/user_profile_provider.dart';
import '../../auth/domain/user_profile.dart';
import '../../countries/data/countries_provider.dart';
import '../../countries/domain/country_pack.dart';

/// Frames 03a–06 · Onboarding conversationnel style Épuré.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  final TextEditingController _nameController = TextEditingController();
  String _selectedCode = 'CA';
  String _selectedCurrency = 'CAD';
  String _selectedGoal = 'avoid_overdraft';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _next(List<CountryPack> packs) {
    // 0 prénom · 1 pays · 2 objectif → vie/revenu (60) → socle
    if (_step < 2) {
      setState(() => _step++);
      return;
    }

    final fr = Localizations.localeOf(context).languageCode == 'fr';
    final name = _nameController.text.trim().isEmpty
        ? (fr ? 'Toi' : 'You')
        : _nameController.text.trim();
    final goalLabel = switch (_selectedGoal) {
      'save_project' => fr ? 'Épargner pour un projet' : 'Save for a project',
      'understand' => fr ? 'Comprendre mon argent' : 'Understand my money',
      'retire' => fr ? 'Préparer ma retraite' : 'Prepare for retirement',
      _ => fr ? 'Arrêter d’être à découvert' : 'Stop going into overdraft',
    };

    CountryPack? pack;
    for (final p in packs) {
      if (p.code == _selectedCode) {
        pack = p;
        break;
      }
    }
    final code = pack?.code ?? _selectedCode;
    final currency = pack?.currency ?? _selectedCurrency;
    ref.read(userProfileProvider.notifier).updateProfile(
          displayName: name,
          countryCode: code,
          currency: currency,
          locale: fr ? 'fr' : 'en',
          timezone: timezoneForCountry(code),
          utcOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
          mainGoal: goalLabel,
        );
    context.go('/onboarding/life');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final packsAsync = ref.watch(countriesListProvider);
    final packs = packsAsync.valueOrNull ??
        kFallbackCountryPacks.where((p) => p.code != 'GENERIC').toList();

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  ..._buildStep(l10n, packs),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SiphoButton3D(
                label: l10n.continueBtn,
                variant: SiphoButtonVariant.dark,
                onPressed: () => _next(packs),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStep(AppLocalizations l10n, List<CountryPack> packs) {
    switch (_step) {
      case 0:
        return [
          Text(
            l10n.onboardingNameHeading,
            style: SiphoTypography.title.copyWith(
              fontSize: 28,
              color: SiphoPalette.textPrimary(context),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingNameLead,
            style: SiphoTypography.body.copyWith(
              fontSize: 16,
              color: SiphoPalette.textSecondary(context),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 88,
            height: 88,
            child: SvgPicture.asset('assets/images/sipho_waving.svg', fit: BoxFit.contain),
          ),
          const SizedBox(height: 16),
          SiphoSoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.onboardingNameBubbleTitle,
                  style: SiphoTypography.bodyBold.copyWith(
                    fontSize: 16,
                    color: SiphoPalette.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.onboardingNameBubble,
                  style: SiphoTypography.body.copyWith(
                    fontSize: 16,
                    color: SiphoPalette.textPrimary(context),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.onboardingNameLabel,
            style: SiphoTypography.label.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: SiphoPalette.textSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            decoration: BoxDecoration(
              color: SiphoPalette.softSurface(context),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _nameController,
              style: SiphoTypography.bodyBold.copyWith(
                fontSize: 16,
                color: SiphoPalette.textPrimary(context),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingNameHelper,
            style: SiphoTypography.label.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: SiphoPalette.textSecondary(context),
            ),
          ),
        ];
      case 1:
        final fr = Localizations.localeOf(context).languageCode == 'fr';
        CountryPack? selected;
        for (final p in packs) {
          if (p.code == _selectedCode) {
            selected = p;
            break;
          }
        }
        selected ??= packs.isEmpty ? null : packs.first;
        return [
          Text(
            fr ? 'Où vit ton nid ?' : 'Where does your nest live?',
            style: SiphoTypography.title.copyWith(
              fontSize: 28,
              color: SiphoPalette.textPrimary(context),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            fr
                ? '02 / 05 · Pour des repères qui te parlent.'
                : '02 / 05 · For cues that speak your language.',
            style: SiphoTypography.body.copyWith(
              fontSize: 16,
              color: SiphoPalette.textSecondary(context),
            ),
          ),
          const SizedBox(height: 20),
          ...packs.map((c) {
            final isSelected = _selectedCode == c.code;
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: InkWell(
                onTap: () => setState(() {
                  _selectedCode = c.code;
                  _selectedCurrency = c.currency;
                }),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.name,
                        style: SiphoTypography.bodyBold.copyWith(
                          fontSize: 16,
                          color: SiphoPalette.textPrimary(context),
                          decoration:
                              isSelected ? TextDecoration.underline : null,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check,
                        color: SiphoPalette.textPrimary(context),
                        size: 18,
                      ),
                  ],
                ),
              ),
            );
          }),
          if (selected != null)
            SiphoSoftCard(
              child: Text(
                '${selected.name} · ${selected.currency}',
                style: SiphoTypography.bodyBold.copyWith(
                  fontSize: 16,
                  color: SiphoPalette.textPrimary(context),
                ),
              ),
            ),
        ];
      case 2:
      default:
        final goals = [
          ('avoid_overdraft', l10n.onboardingGoalOverdraft),
          ('save_project', l10n.onboardingGoalProject),
          ('understand', l10n.onboardingGoalUnderstand),
          ('retire', l10n.onboardingGoalRetire),
        ];
        return [
          Text(
            l10n.onboardingGoalHeading,
            style: SiphoTypography.title.copyWith(
              fontSize: 28,
              color: SiphoPalette.textPrimary(context),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '03 / 05 · On avance un petit pas à la fois.',
            style: SiphoTypography.body.copyWith(
              fontSize: 16,
              color: SiphoPalette.textSecondary(context),
            ),
          ),
          const SizedBox(height: 20),
          ...goals.map((g) {
            final selected = _selectedGoal == g.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: InkWell(
                onTap: () => setState(() => _selectedGoal = g.$1),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        g.$2,
                        style: SiphoTypography.bodyBold.copyWith(
                          fontSize: 16,
                          color: SiphoPalette.textPrimary(context),
                          decoration: selected ? TextDecoration.underline : null,
                        ),
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check, color: SiphoPalette.textPrimary(context), size: 18),
                  ],
                ),
              ),
            );
          }),
          SiphoSoftCard(
            child: Text(
              'Aucun objectif n’est trop petit.',
              style: SiphoTypography.bodyBold.copyWith(
                fontSize: 16,
                color: SiphoPalette.textPrimary(context),
              ),
            ),
          ),
        ];
    }
  }
}
