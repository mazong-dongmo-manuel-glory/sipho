import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/analytics/analytics_service.dart';
import 'package:sipho/core/money/amount_input.dart';
import 'package:sipho/core/time/local_day.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/expenses/data/transaction_repository.dart';
import 'package:sipho/features/expenses/domain/expense_category.dart';
import 'package:sipho/features/expenses/domain/parsed_receipt.dart';
import 'package:sipho/features/expenses/domain/transaction.dart';
import 'package:sipho/features/expenses/presentation/expense_category_label.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';

class ReceiptValidationScreen extends ConsumerStatefulWidget {
  const ReceiptValidationScreen({super.key, required this.draft});

  final ParsedReceipt draft;

  @override
  ConsumerState<ReceiptValidationScreen> createState() =>
      _ReceiptValidationScreenState();
}

class _ReceiptValidationScreenState
    extends ConsumerState<ReceiptValidationScreen> {
  late final TextEditingController _merchant;
  late final TextEditingController _amount;
  late final TextEditingController _date;
  late String _category;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final draft = widget.draft;
    _merchant = TextEditingController(text: draft.merchant ?? '');
    _amount = TextEditingController(
      text: draft.totalCents == null ? '' : _centsField(draft.totalCents!),
    );
    _date = TextEditingController(text: draft.date ?? '');
    _category = draft.category ?? 'groceries';
    _amount.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _merchant.dispose();
    _amount.dispose();
    _date.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cents = AmountInput.parseCents(_amount.text.trim());
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (cents <= 0 || uid == null || _saving) return;
    final currency = widget.draft.currency ??
        ref.read(userFinanceProvider).valueOrNull?.currency ??
        'CAD';
    final date = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(_date.text.trim())
        ? _date.text.trim()
        : LocalDay.now().isoDate;
    final merchant = _merchant.text.trim();
    setState(() => _saving = true);
    try {
      await ref.read(transactionRepositoryProvider).addTransaction(
            uid,
            SiphoTransaction(
              id: '',
              amountCents: cents,
              currency: currency,
              amountMainCents: cents,
              category: _category,
              merchant: merchant.isEmpty ? null : merchant,
              date: date,
              source: 'receipt',
              createdAt: DateTime.now(),
            ),
          );
      try {
        await ref.read(analyticsServiceProvider).logExpenseAdded(
              category: _category,
              amountCents: cents,
              currency: currency,
              source: 'receipt',
            );
      } catch (error) {
        debugPrint('Analytics expense_added skipped: $error');
      }
      if (!mounted) return;
      context.go('/expenses');
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).expenseSaveError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final review = widget.draft.needsReview;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => context.pop(),
                child: Text(
                  '‹  ${l10n.validateTitle}',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SiphoArt.happy(frame: 72),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      review ? l10n.validateBubble : l10n.validateBubbleOk,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _LabeledField(
                label: l10n.validateMerchant,
                controller: _merchant,
              ),
              const SizedBox(height: 12),
              _LabeledField(
                label: review ? l10n.validateDateLabel : l10n.validateDateOk,
                controller: _date,
                highlight: review,
              ),
              const SizedBox(height: 12),
              _LabeledField(
                label: l10n.validateTotal,
                controller: _amount,
                highlight: review,
                keyboard: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.validateCategory,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in kQuickExpenseCategories)
                    ChoiceChip(
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.mint,
                      checkmarkColor: AppColors.primaryDark,
                      side: BorderSide(
                        color: _category == category.id
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      labelStyle: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _category == category.id
                            ? AppColors.primaryDark
                            : AppColors.textSecondary,
                      ),
                      label: Text(
                        '${category.emoji} ${expenseCategoryLabel(l10n, category.id)}',
                      ),
                      selected: _category == category.id,
                      onSelected: (_) =>
                          setState(() => _category = category.id),
                    ),
                ],
              ),
              const Spacer(),
              SiphoButton3D(
                label: l10n.validateCta,
                onPressed: _save,
                isLoading: _saving,
                enabled: AmountInput.parseCents(_amount.text.trim()) > 0,
                color: AppColors.primary,
                shadowColor: AppColors.primaryDark,
                height: 52,
                borderRadius: figmaButtonRadius,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.highlight = false,
    this.keyboard,
  });

  final String label;
  final TextEditingController controller;
  final bool highlight;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: highlight ? AppColors.warnBrown : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: highlight ? AppColors.seedPill : AppColors.surface,
          ),
        ),
      ],
    );
  }
}

String _centsField(int cents) {
  final major = cents ~/ 100;
  final minor = (cents % 100).toString().padLeft(2, '0');
  return '$major.$minor';
}
