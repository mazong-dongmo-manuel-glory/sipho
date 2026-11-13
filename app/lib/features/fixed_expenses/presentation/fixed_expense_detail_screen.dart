import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/app/theme/app_text_styles.dart';
import 'package:sipho/core/widgets/amount_keypad.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';

class FixedExpenseDetailScreen extends StatefulWidget {
  final String? id;
  final Map<String, String>? initialData;

  const FixedExpenseDetailScreen({super.key, this.id, this.initialData});

  @override
  State<FixedExpenseDetailScreen> createState() => _FixedExpenseDetailScreenState();
}

class _FixedExpenseDetailScreenState extends State<FixedExpenseDetailScreen> {
  String _amountStr = '0';
  final int _dueDay = 1;
  final bool _autoPay = true;

  void _onDigit(String d) {
    setState(() {
      if (_amountStr == '0') {
        _amountStr = d;
      } else if (_amountStr.length < 7) {
        _amountStr += d;
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (_amountStr.length > 1) {
        _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      } else {
        _amountStr = '0';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.initialData?['title'] ?? 'Dépense fixe';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(title, style: AppTextStyles.h3)),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Text(
              '$_amountStr \$',
              style: AppTextStyles.displayXl,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _autoPay
                  ? 'Prélevé automatiquement le $_dueDay du mois'
                  : 'À payer le $_dueDay du mois',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            const Spacer(),
            AmountKeypad(
              onDigitPressed: _onDigit,
              onDeletePressed: _onDelete,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: SiphoButton3D(
                text: 'AJOUTER AU NID',
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
