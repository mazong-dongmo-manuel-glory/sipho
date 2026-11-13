import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_radius.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/app/theme/app_text_styles.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';

class FixedExpenseSwipeScreen extends StatefulWidget {
  const FixedExpenseSwipeScreen({super.key});

  @override
  State<FixedExpenseSwipeScreen> createState() => _FixedExpenseSwipeScreenState();
}

class _FixedExpenseSwipeScreenState extends State<FixedExpenseSwipeScreen> {
  final List<Map<String, String>> _defaultExpenses = [
    {'title': 'Loyer / Hypothèque', 'emoji': '🏠', 'cat': 'rent'},
    {'title': 'Internet', 'emoji': '📶', 'cat': 'internet'},
    {'title': 'Électricité & Énergie', 'emoji': '💡', 'cat': 'electricity'},
    {'title': 'Forfait Mobile', 'emoji': '📱', 'cat': 'phone'},
    {'title': 'Épicerie (enveloppe)', 'emoji': '🛒', 'cat': 'groceries'},
    {'title': 'Transport (pass/essence)', 'emoji': '🚌', 'cat': 'transport'},
  ];

  int _currentIndex = 0;

  void _onAnswer(bool isYes) {
    if (isYes) {
      context.push('/fixed-expenses/detail', extra: _defaultExpenses[_currentIndex]);
    }
    setState(() {
      if (_currentIndex < _defaultExpenses.length - 1) {
        _currentIndex++;
      } else {
        context.go('/onboarding/celebration');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = _defaultExpenses[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '${_currentIndex + 1}/${_defaultExpenses.length} brins du nid',
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
                    Text(item['emoji']!, style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Tu paies un(e) ${item['title']} ?',
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
                      child: const Text('NON ✕'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SiphoButton3D(
                      text: 'OUI ✓',
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

