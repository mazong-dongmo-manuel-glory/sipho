import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/amount_keypad.dart';
import '../../../core/widgets/sipho_button_3d.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  String _amountStr = '0';
  String _selectedCategory = 'restaurants';

  final List<Map<String, String>> _categories = [
    {'id': 'restaurants', 'name': 'Restos', 'emoji': '🍔'},
    {'id': 'groceries', 'name': 'Épicerie', 'emoji': '🛒'},
    {'id': 'transport', 'name': 'Transport', 'emoji': '🚌'},
    {'id': 'shopping', 'name': 'Shopping', 'emoji': '🛍️'},
    {'id': 'leisure', 'name': 'Loisirs', 'emoji': '🎮'},
    {'id': 'health', 'name': 'Santé', 'emoji': '💊'},
    {'id': 'home', 'name': 'Maison', 'emoji': '🏡'},
    {'id': 'other', 'name': 'Autre', 'emoji': '✨'},
  ];

  void _onDigit(String d) {
    setState(() {
      if (_amountStr == '0') {
        _amountStr = d;
      } else if (_amountStr.length < 8) {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ajouter une dépense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: AppColors.primary),
            onPressed: () => context.push('/expenses/scan'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Text('$_amountStr \$', style: AppTextStyles.displayXl),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final isSelected = cat['id'] == _selectedCategory;
                  return ChoiceChip(
                    label: Text('${cat['emoji']} ${cat['name']}'),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat['id']!);
                    },
                  );
                },
              ),
            ),
            const Spacer(),
            AmountKeypad(
              onDigitPressed: _onDigit,
              onDeletePressed: _onDelete,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: SiphoButton3D(
                text: 'AJOUTER (+5 XP)',
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

