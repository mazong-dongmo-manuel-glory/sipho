import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/money/amount_input.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/fixed_expenses/data/fixed_expense_repository.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_expense.dart';

Future<void> showEditFixedExpenseSheet(
  BuildContext context,
  FixedExpense expense,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _EditFixedExpenseSheet(expense: expense),
  );
}

class _EditFixedExpenseSheet extends ConsumerStatefulWidget {
  const _EditFixedExpenseSheet({required this.expense});

  final FixedExpense expense;

  @override
  ConsumerState<_EditFixedExpenseSheet> createState() =>
      _EditFixedExpenseSheetState();
}

class _EditFixedExpenseSheetState
    extends ConsumerState<_EditFixedExpenseSheet> {
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late int _dueDay;
  late bool _auto;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.expense;
    _name = TextEditingController(text: item.name);
    _name.addListener(() {
      if (mounted) setState(() {});
    });
    final cents = item.amountCents;
    final formatted = cents % 100 == 0
        ? '${cents ~/ 100}'
        : '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';
    _amount = TextEditingController(text: formatted);
    _amount.addListener(() {
      if (mounted) setState(() {});
    });
    _dueDay = item.dueDay.clamp(1, 31);
    _auto = item.payMode != 'manual';
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    final cents = AmountInput.parseCents(_amount.text.trim());
    final cleanName = _name.text.trim();
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (cents <= 0 || cleanName.isEmpty || uid == null || _saving) return;

    setState(() => _saving = true);
    try {
      await ref.read(fixedExpenseRepositoryProvider).updateFixedExpense(
            uid,
            widget.expense.copyWith(
              name: cleanName,
              amountCents: cents,
              dueDay: _dueDay,
              payMode: _auto ? 'auto' : 'manual',
            ),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.editFixedSaved)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.socleSaveError)),
      );
    }
  }

  Future<void> _delete(AppLocalizations l10n) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null || _saving) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(fixedExpenseRepositoryProvider)
          .deleteFixedExpense(uid, widget.expense.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.editFixedDeleted)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.socleSaveError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currency =
        ref.watch(userFinanceProvider).valueOrNull?.currency ?? 'CAD';
    final valid = AmountInput.parseCents(_amount.text.trim()) > 0 &&
        _name.text.trim().isNotEmpty;

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
                  Text(
                    widget.expense.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.editFixedTitle,
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
              const SizedBox(height: 12),
              Text(l10n.editFixedName, style: _labelStyle),
              const SizedBox(height: 6),
              TextField(
                controller: _name,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
              const SizedBox(height: 12),
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
                  suffixText: currency,
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
              if (widget.expense.type != 'envelope') ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.fixedDueValue(_dueDay),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _dueDay > 1
                            ? () => setState(() => _dueDay--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '$_dueDay',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      IconButton(
                        onPressed: _dueDay < 31
                            ? () => setState(() => _dueDay++)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  title: Text(
                    l10n.fixedAuto,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  value: _auto,
                  onChanged: (value) => setState(() => _auto = value),
                ),
              ],
              const SizedBox(height: 16),
              SiphoButton3D(
                label: l10n.incomeSheetCta,
                enabled: valid,
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
