import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';

/// "Payé ✓" button: records a manual bill as paid for the current month through the
/// `markFixedPaid` Cloud Function. The row/card flips to its paid state when the month document
/// updates, so nothing is toggled locally.
class FixedPaidButton extends ConsumerWidget {
  const FixedPaidButton({super.key, required this.fixedId});

  final String fixedId;

  Future<void> _pay(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok =
        await ref.read(fixedPaidControllerProvider.notifier).markPaid(fixedId);
    if (!ok && context.mounted) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.fixedMarkPaidError)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(fixedPaidControllerProvider).contains(fixedId);
    return Semantics(
      button: true,
      label: l10n.fixedExpenseMarkPaid,
      child: SizedBox(
        height: 30,
        child: OutlinedButton(
          onPressed: busy ? null : () => _pay(context, ref),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            minimumSize: const Size(0, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: busy
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  l10n.homePaid,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}
