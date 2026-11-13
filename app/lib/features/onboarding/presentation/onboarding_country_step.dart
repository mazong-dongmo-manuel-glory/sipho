import 'package:flutter/material.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/widgets/sipho_art.dart';

class OnboardingCountryStep extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = countries.firstWhere((c) => c.$1 == selectedCountry);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        for (final country in countries) ...[
          _CountryRow(
            flag: country.$3,
            name: country.$2,
            selected: country.$1 == selectedCountry,
            onTap: () => onCountrySelected(country.$1, country.$4, country.$5),
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
              Text(region, style: _field),
              const Spacer(),
              Text('\$ $currency', style: _field),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
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
        const SizedBox(height: 16),
        Row(
          children: [
            const SiphoArt.happy(frame: 60),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.onboardingNestRoot(selected.$2),
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
