import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/core/money/amount_input.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/goals/data/goal_repository.dart';
import 'package:sipho/features/goals/domain/goal.dart';

Future<void> showAddGoalSheet(BuildContext context, {String currency = 'CAD'}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => AddGoalSheet(currency: currency),
  );
}

class AddGoalSheet extends ConsumerStatefulWidget {
  const AddGoalSheet({super.key, this.currency = 'CAD'});

  final String currency;

  @override
  ConsumerState<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<AddGoalSheet> {
  static const _emojis = ['🎯', '✈️', '🛡️', '🏠', '💻', '🚗', '🎓', '🎁', '🌴', '💍'];

  String _selectedEmoji = '🎯';
  late final TextEditingController _titleController;
  late final TextEditingController _targetController;
  late final TextEditingController _savedController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _targetController = TextEditingController();
    _savedController = TextEditingController();
    _titleController.addListener(() => setState(() {}));
    _targetController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _savedController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final title = _titleController.text.trim();
    final target = AmountInput.parseCents(_targetController.text);
    return title.isNotEmpty && target > 0;
  }

  Future<void> _handleSave() async {
    if (!_isValid || _saving) return;
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;

    setState(() => _saving = true);
    try {
      final targetCents = AmountInput.parseCents(_targetController.text);
      final savedCents = AmountInput.parseCents(_savedController.text);

      final goal = Goal(
        id: '',
        title: _titleController.text.trim(),
        targetCents: targetCents,
        savedCents: savedCents,
        emoji: _selectedEmoji,
        createdAt: DateTime.now(),
      );

      await ref.read(goalRepositoryProvider).createGoal(uid, goal);
      ref.read(feedbackServiceProvider).play(SiphoCue.questClaimed);

      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        24,
        AppSpacing.pagePadding,
        24 + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.addGoalTitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Emoji selector
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _emojis.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final e = _emojis[i];
                  final selected = e == _selectedEmoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = e),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.seedPill : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? AppColors.categoryGold : AppColors.border,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Title field
            Text(
              l10n.goalTitleLabel,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: l10n.goalTitleHint,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            // Target amount field
            Text(
              '${l10n.goalTargetLabel} (${widget.currency})',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _targetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '1 000',
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            // Already saved field
            Text(
              '${l10n.goalSavedLabel} (${widget.currency})',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _savedController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '0',
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            const SizedBox(height: 24),
            SiphoButton3D(
              label: l10n.addGoalBtn,
              onPressed: _isValid && !_saving ? _handleSave : null,
              isLoading: _saving,
              height: 52,
            ),
          ],
        ),
      ),
    );
  }
}
