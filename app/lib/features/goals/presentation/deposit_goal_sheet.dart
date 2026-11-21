import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/core/money/amount_input.dart';
import 'package:sipho/core/money/money.dart';
import 'package:sipho/core/money/money_formatter.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/goals/data/goal_repository.dart';
import 'package:sipho/features/goals/domain/goal.dart';

Future<void> showDepositGoalSheet(
  BuildContext context, {
  required Goal goal,
  required String currency,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => DepositGoalSheet(goal: goal, currency: currency),
  );
}

class DepositGoalSheet extends ConsumerStatefulWidget {
  const DepositGoalSheet({
    super.key,
    required this.goal,
    required this.currency,
  });

  final Goal goal;
  final String currency;

  @override
  ConsumerState<DepositGoalSheet> createState() => _DepositGoalSheetState();
}

class _DepositGoalSheetState extends ConsumerState<DepositGoalSheet> {
  late final TextEditingController _amountController;
  bool _saving = false;

  static const _presets = [10, 25, 50, 100];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int get _cents => AmountInput.parseCents(_amountController.text);

  void _applyPreset(int dollars) {
    _amountController.text = '$dollars';
  }

  Future<void> _handleConfirm() async {
    final cents = _cents;
    if (cents <= 0 || _saving) return;

    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(goalRepositoryProvider)
          .deposit(uid, widget.goal.id, cents);

      final newTotal = widget.goal.savedCents + cents;
      if (newTotal >= widget.goal.targetCents) {
        ref.read(feedbackServiceProvider).play(SiphoCue.levelUp);
      } else {
        ref.read(feedbackServiceProvider).play(SiphoCue.fixedPaid);
      }

      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final currentSaved = widget.goal.savedCents;
    final projectedSaved = currentSaved + _cents;
    final currentText = MoneyFormatter.format(
      Money(cents: currentSaved, currency: widget.currency),
      locale: locale,
    );
    final targetText = MoneyFormatter.format(
      Money(cents: widget.goal.targetCents, currency: widget.currency),
      locale: locale,
    );
    final projectedText = MoneyFormatter.format(
      Money(cents: projectedSaved, currency: widget.currency),
      locale: locale,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        24,
        AppSpacing.pagePadding,
        24 + bottomInset,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.seedPill,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  widget.goal.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.goalDepositTitle,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      widget.goal.title,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Presets
          Row(
            children: [
              for (final p in _presets)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: () => _applyPreset(p),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        backgroundColor: _cents == p * 100
                            ? AppColors.seedPill
                            : AppColors.surface,
                        side: BorderSide(
                          color: _cents == p * 100
                              ? AppColors.categoryGold
                              : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '+$p',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Amount field
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: InputDecoration(
              hintText: '50',
              prefixText: '${widget.currency} ',
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Preview container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$currentText / $targetText',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (_cents > 0)
                  Text(
                    '→  $projectedText',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SiphoButton3D(
            label: l10n.goalDepositConfirm,
            onPressed: _cents > 0 && !_saving ? _handleConfirm : null,
            isLoading: _saving,
            height: 52,
          ),
        ],
      ),
    );
  }
}
