import 'package:flutter/material.dart';
import 'package:sipho/app/theme/app_radius.dart';
import 'package:sipho/app/theme/app_text_styles.dart';

/// Giant numpad for entering monetary amounts (in cents).
class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    super.key,
    this.valueText,
    void Function(String digit)? onKeyTap,
    void Function(String digit)? onDigitPressed,
    VoidCallback? onDelete,
    VoidCallback? onDeletePressed,
    this.onConfirm,
    this.confirmLabel = 'OK',
    this.confirmEnabled = true,
  })  : onKeyTap = onKeyTap ?? onDigitPressed,
        onDelete = onDelete ?? onDeletePressed;

  final String? valueText;
  final void Function(String digit)? onKeyTap;
  final VoidCallback? onDelete;
  final VoidCallback? onConfirm;
  final String confirmLabel;
  final bool confirmEnabled;

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (valueText != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              valueText!,
              style: AppTextStyles.amountDisplay,
            ),
          ),
          const Divider(),
        ],
        // Keys
        for (final row in _keys)
          Row(
            children: row.map((key) {
              final isDelete = key == '⌫';
              return Expanded(
                child: _KeyButton(
                  label: key,
                  onTap: isDelete
                      ? (onDelete ?? () {})
                      : () => onKeyTap?.call(key),
                ),
              );
            }).toList(),
          ),
        if (onConfirm != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: confirmEnabled ? onConfirm : null,
                child: Text(confirmLabel),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.cardRadius,
      child: SizedBox(
        height: 64,
        child: Center(
          child: Text(label, style: AppTextStyles.headlineMedium),
        ),
      ),
    );
  }
}
