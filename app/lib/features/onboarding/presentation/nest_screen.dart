import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_expense_draft.dart';

/// Frame Figma 04 · Socle à glisser · Épuré (`2:28921`) — entry before amount/swipe.
class NestScreen extends StatelessWidget {
  const NestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.go('/onboarding'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  size: 32,
                  color: AppColors.textSecondary,
                ),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.onboardingNestTitle,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.onboardingNestLead,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              const SiphoArt.happy(frame: 106),
              const SizedBox(height: 20),
              Text(
                l10n.onboardingNestStrands(3),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: AppColors.textSecondary,
                ),
              ),
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
                      l10n.onboardingNestQuestion,
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
                      l10n.onboardingNestHint,
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
                l10n.onboardingNestSwipe,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                  color: AppColors.primaryDark,
                ),
              ),
              const Spacer(),
              SiphoButton3D(
                label: l10n.onboardingNestYesRent,
                onPressed: () async {
                  final saved = await context.push<bool>(
                    '/fixed-expenses/amount',
                    extra: kSocleTemplates.first,
                  );
                  if (saved == true && context.mounted) {
                    context.go('/onboarding/ready');
                  }
                },
                color: AppColors.primaryDark,
                shadowColor: AppColors.primaryDark,
                height: 52,
                borderRadius: figmaButtonRadius,
              ),
              const SizedBox(height: 12),
              SiphoButton3D(
                label: l10n.onboardingNestSkip,
                onPressed: () => context.go('/onboarding/ready'),
                color: AppColors.surface,
                shadowColor: AppColors.border,
                textColor: AppColors.primaryDark,
                height: 52,
                borderRadius: figmaButtonRadius,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.onboardingNestFooter,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
