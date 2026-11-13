import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/money/amount_input.dart';
import 'package:sipho/core/time/local_day.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/expenses/data/transaction_repository.dart';
import 'package:sipho/features/expenses/domain/expense_category.dart';
import 'package:sipho/features/expenses/domain/transaction.dart';
import 'package:sipho/features/expenses/presentation/expense_category_label.dart';

Future<void> showEditExpenseSheet(
  BuildContext context,
  SiphoTransaction transaction,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _EditExpenseSheet(transaction: transaction),
  );
}

class _EditExpenseSheet extends ConsumerStatefulWidget {
  const _EditExpenseSheet({required this.transaction});

  final SiphoTransaction transaction;

  @override
  ConsumerState<_EditExpenseSheet> createState() => _EditExpenseSheetState();
}

class _EditExpenseSheetState extends ConsumerState<_EditExpenseSheet> {
  late final TextEditingController _amount;
  late final TextEditingController _merchant;
  late final TextEditingController _note;
  late String _category;
  late String _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    final cents = tx.amountCents;
    final formatted = cents % 100 == 0
        ? '${cents ~/ 100}'
        : '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';
    _amount = TextEditingController(text: formatted);
    _amount.addListener(() {
      if (mounted) setState(() {});
    });
    _merchant = TextEditingController(text: tx.merchant ?? '');
    _note = TextEditingController(text: tx.note ?? '');
    _category = tx.category;
    _date = tx.date;
  }

  @override
  void dispose() {
    _amount.dispose();
    _merchant.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(_date) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _save(AppLocalizations l10n) async {
    final cents = AmountInput.parseCents(_amount.text.trim());
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (cents <= 0 || uid == null || _saving) return;

    setState(() => _saving = true);
    try {
      final safeDate = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(_date)
          ? _date
          : LocalDay.now().isoDate;
      await ref.read(transactionRepositoryProvider).updateTransaction(
            uid,
            widget.transaction.copyWith(
              amountCents: cents,
              amountMainCents: cents,
              category: _category,
              date: safeDate,
              merchant: _merchant.text.trim(),
              note: _note.text.trim(),
            ),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.editExpenseSaved)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.expenseSaveError)),
      );
    }
  }

  Future<void> _delete(AppLocalizations l10n) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null || _saving) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(transactionRepositoryProvider)
          .deleteTransaction(uid, widget.transaction.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.expenseDeleted)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.expenseSaveError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final validAmount = AmountInput.parseCents(_amount.text.trim()) > 0;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.editExpenseTitle,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _saving ? null : () => _delete(l10n),
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.terracotta,
                    ),
                    label: Text(
                      l10n.deleteBtn,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        color: AppColors.terracotta,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(l10n.expenseAmount, style: _labelStyle),
              const SizedBox(height: 6),
              TextField(
                controller: _amount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
                decoration: InputDecoration(
                  suffixText: widget.transaction.currency,
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.validateMerchant, style: _labelStyle),
              const SizedBox(height: 6),
              TextField(
                controller: _merchant,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
                decoration: InputDecoration(
                  hintText: l10n.editExpenseMerchantHint,
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.expenseNote, style: _labelStyle),
              const SizedBox(height: 6),
              TextField(
                controller: _note,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
                decoration: InputDecoration(
                  hintText: l10n.editExpenseNoteHint,
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.expenseDate, style: _labelStyle),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _date,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.expenseCategory, style: _labelStyle),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final cat in kQuickExpenseCategories)
                    ChoiceChip(
                      label: Text(
                        '${cat.emoji} ${expenseCategoryLabel(l10n, cat.id)}',
                      ),
                      selected: _category == cat.id,
                      onSelected: (_) => setState(() => _category = cat.id),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              SiphoButton3D(
                label: l10n.incomeSheetCta,
                enabled: validAmount,
                isLoading: _saving,
                color: AppColors.primary,
                shadowColor: AppColors.primaryDark,
                height: 52,
                borderRadius: figmaButtonRadius,
                onPressed: () => _save(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _labelStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 12,
  fontWeight: FontWeight.w800,
  color: AppColors.textSecondary,
);
