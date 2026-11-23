import 'package:flutter/material.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/widgets/sipho_art.dart';

/// Frame Figma 03a · Prénom · Épuré (`2:28915`) — body under the shared chrome.
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
        const SiphoArt.waving(frame: 88),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.soft,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.onboardingNameBubbleTitle,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.onboardingNameBubble,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.onboardingNameLabel,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.3,
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
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: AppColors.primaryDark,
          ),
          decoration: InputDecoration(
            hintText: l10n.onboardingNameHint,
            hintStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.soft,
            contentPadding: const EdgeInsets.all(18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.onboardingNameHelper,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
