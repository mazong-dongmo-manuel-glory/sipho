import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/sipho_bubble.dart';

class OnboardingCountryStep extends StatelessWidget {
  final String selectedCountry;
  final void Function(String country, String currency) onCountrySelected;

  const OnboardingCountryStep({
    super.key,
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  static const _countries = [
    {'code': 'CA', 'name': 'Canada', 'flag': '🇨🇦', 'currency': 'CAD'},
    {'code': 'FR', 'name': 'France', 'flag': '🇫🇷', 'currency': 'EUR'},
    {'code': 'CM', 'name': 'Cameroun', 'flag': '🇨🇲', 'currency': 'XAF'},
    {'code': 'CI', 'name': 'Côte d\'Ivoire', 'flag': '🇨🇮', 'currency': 'XOF'},
    {'code': 'SN', 'name': 'Sénégal', 'flag': '🇸🇳', 'currency': 'XOF'},
    {'code': 'BE', 'name': 'Belgique', 'flag': '🇧🇪', 'currency': 'EUR'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const SiphoBubble(
          text: 'Tu vis dans quel pays ?\nJ\'adapterai tous les conseils et règles locales.',
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: ListView.separated(
            itemCount: _countries.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final item = _countries[index];
              final isSelected = item['code'] == selectedCountry;
              return InkWell(
                onTap: () => onCountrySelected(item['code']!, item['currency']!),
                borderRadius: AppRadius.cardRadius,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withAlpha(25) : AppColors.surface,
                    borderRadius: AppRadius.cardRadius,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(item['flag']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(item['name']!, style: AppTextStyles.bodySemiBold),
                      ),
                      Text(
                        item['currency']!,
                        style: AppTextStyles.label.copyWith(color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

