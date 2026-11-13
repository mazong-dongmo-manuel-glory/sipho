import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_radius.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/app/theme/app_text_styles.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/expenses/presentation/expense_category_label.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_expense_draft.dart';

class FixedExpenseSwipeScreen extends StatefulWidget {
  const FixedExpenseSwipeScreen({super.key});

  @override
  State<FixedExpenseSwipeScreen> createState() =>
      _FixedExpenseSwipeScreenState();
}

class _FixedExpenseSwipeScreenState extends State<FixedExpenseSwipeScreen> {
  int _currentIndex = 0;

  Future<void> _onAnswer(bool isYes) async {
    if (isYes) {
      final saved = await context.push<bool>(
        '/fixed-expenses/amount',
        extra: kSocleTemplates[_currentIndex],
      );
      if (saved != true || !mounted) return;
    }
    if (_currentIndex < kSocleTemplates.length - 1) {
      setState(() => _currentIndex++);
      return;
    }
    if (mounted) context.go('/onboarding/ready');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final item = kSocleTemplates[_currentIndex];
    final name = expenseCategoryLabel(l10n, item.categoryId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.socleProgress(_currentIndex + 1, kSocleTemplates.length),
          style: AppTextStyles.h3,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.cardRadius,
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(item.emoji, style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.socleAsk(name),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h2,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _onAnswer(false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.buttonRadius,
                        ),
                      ),
                      child: Text(l10n.socleNo),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SiphoButton3D(
                      text: l10n.socleYes,
                      onPressed: () => _onAnswer(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
