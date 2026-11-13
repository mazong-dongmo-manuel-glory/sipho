import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_expense_draft.dart';

class NestScreen extends StatelessWidget {
  const NestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.go('/onboarding'),
                  child: const Text(
                    '‹',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.onboardingNestTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              const SiphoArt.happy(frame: 125),
              Text(
                l10n.onboardingNestStrands(3),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 333,
                height: 235,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🏠', style: TextStyle(fontSize: 60)),
                    const SizedBox(height: 12),
                    Text(
                      l10n.onboardingNestQuestion,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.onboardingNestHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        height: 1.2,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoundAction(
                    label: '×',
                    color: AppColors.border,
                    foreground: AppColors.textSecondary,
                    onTap: () => context.go('/onboarding/ready'),
                  ),
                  const SizedBox(width: 57),
                  _RoundAction(
                    label: '✓',
                    color: AppColors.primary,
                    foreground: Colors.white,
                    onTap: () async {
                      final saved = await context.push<bool>(
                        '/fixed-expenses/amount',
                        extra: kSocleTemplates.first,
                      );
                      if (saved == true && context.mounted) {
                        context.go('/onboarding/ready');
                      }
                    },
                  ),
                ],
              ),
              const Spacer(),
              Text(
                l10n.onboardingNestSwipe,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.label,
    required this.color,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 84,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: label == '×' ? 36 : 32,
            fontWeight: FontWeight.w900,
            height: 1.2,
            color: foreground,
          ),
        ),
      ),
    );
  }
}
