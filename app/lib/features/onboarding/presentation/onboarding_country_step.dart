import 'package:flutter/material.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/features/onboarding/data/location_service.dart';

class OnboardingCountryStep extends StatefulWidget {
  const OnboardingCountryStep({
    super.key,
    required this.selectedCountry,
    required this.region,
    required this.currency,
    required this.onCountrySelected,
  });

  final String selectedCountry;
  final String region;
  final String currency;
  final void Function(String country, String currency, String region)
      onCountrySelected;

  static const countries = [
    ('CA', 'Canada', '🇨🇦', 'CAD', 'Québec'),
    ('FR', 'France', '🇫🇷', 'EUR', 'Île-de-France'),
    ('CM', 'Cameroun', '🇨🇲', 'XAF', 'Centre'),
    ('CI', 'Côte d’Ivoire', '🇨🇮', 'XOF', 'Abidjan'),
    ('SN', 'Sénégal', '🇸🇳', 'XOF', 'Dakar'),
    ('BE', 'Belgique', '🇧🇪', 'EUR', 'Bruxelles'),
  ];

  @override
  State<OnboardingCountryStep> createState() => _OnboardingCountryStepState();
}

class _OnboardingCountryStepState extends State<OnboardingCountryStep> {
  bool _locating = false;

  Future<void> _useLocation() async {
    if (_locating) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _locating = true);
    final labels = await LocationService().resolveApproximateLocation();
    if (!mounted) return;
    setState(() => _locating = false);
    if (labels == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.onboardingLocationDenied)),
      );
      return;
    }
    widget.onCountrySelected(
      labels.countryCode,
      labels.currency,
      labels.region,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final known = OnboardingCountryStep.countries
        .where((c) => c.$1 == widget.selectedCountry);
    final displayName = known.isEmpty
        ? widget.selectedCountry
        : known.first.$2;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        for (final country in OnboardingCountryStep.countries) ...[
          _CountryRow(
            flag: country.$3,
            name: country.$2,
            selected: country.$1 == widget.selectedCountry,
            onTap: () =>
                widget.onCountrySelected(country.$1, country.$4, country.$5),
          ),
          const SizedBox(height: 7),
        ],
        const SizedBox(height: 17),
        Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.region,
                  overflow: TextOverflow.ellipsis,
                  style: _field,
                ),
              ),
              Text('\$ ${widget.currency}', style: _field),
            ],
          ),
        ),
        const SizedBox(height: 18),
        InkWell(
          onTap: _locating ? null : _useLocation,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _locating
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.onboardingLocating,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  )
                : Text(
                    '⌖  ${l10n.onboardingUseLocation}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const SiphoArt.happy(frame: 60),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.onboardingNestRoot(displayName),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const _field = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 16,
  fontWeight: FontWeight.w800,
  height: 1.2,
  color: AppColors.primaryDark,
);

class _CountryRow extends StatelessWidget {
  const _CountryRow({
    required this.flag,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.mint : AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              if (selected)
                const Text(
                  '✓',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
