import 'package:flutter/material.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/widgets/sipho_art.dart';

class OnboardingNameStep extends StatelessWidget {
  const OnboardingNameStep({
    super.key,
    required this.onNameChanged,
    this.initialName = '',
  });

  final ValueChanged<String> onNameChanged;
  final String initialName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SiphoArt.waving(frame: 140),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 110,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.onboardingNameBubble,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          l10n.onboardingNameLabel,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            height: 1.2,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: initialName,
          onChanged: onNameChanged,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            height: 1.2,
            color: AppColors.primaryDark,
          ),
          decoration: InputDecoration(
            hintText: l10n.onboardingNameHint,
            hintStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
            filled: true,
            fillColor: AppColors.mint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.onboardingNameHelper,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            height: 1.2,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
