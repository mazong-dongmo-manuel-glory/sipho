import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/sipho_button_3d.dart';

class LessonQuizScreen extends StatefulWidget {
  final String? lessonId;

  const LessonQuizScreen({super.key, this.lessonId});

  @override
  State<LessonQuizScreen> createState() => _LessonQuizScreenState();
}

class _LessonQuizScreenState extends State<LessonQuizScreen> {
  int? _selectedIndex;
  bool _isAnswerChecked = false;

  final List<String> _options = [
    '1 000 \$',
    '2 500 \$',
    '500 \$',
    '1 500 \$',
  ];
  final int _correctIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const LinearProgressIndicator(
          value: 0.5,
          backgroundColor: AppColors.border,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Si ton revenu est de 2 500 \$ et tes dépenses fixes de 1 500 \$, quel est ton Reste à Vivre ?',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: AppSpacing.xl),
              ...List.generate(_options.length, (i) {
                final isSelected = _selectedIndex == i;
                Color borderColor = AppColors.border;
                Color bgColor = AppColors.surface;

                if (_isAnswerChecked) {
                  if (i == _correctIndex) {
                    borderColor = AppColors.success;
                    bgColor = AppColors.success.withAlpha(25);
                  } else if (isSelected) {
                    borderColor = AppColors.danger;
                    bgColor = AppColors.danger.withAlpha(25);
                  }
                } else if (isSelected) {
                  borderColor = AppColors.primary;
                  bgColor = AppColors.primary.withAlpha(20);
                }

                return GestureDetector(
                  onTap: _isAnswerChecked ? null : () => setState(() => _selectedIndex = i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: AppRadius.cardRadius,
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: Text(_options[i], style: AppTextStyles.bodySemiBold),
                  ),
                );
              }),
              const Spacer(),
              if (!_isAnswerChecked)
                SiphoButton3D(
                  text: 'VÉRIFIER',
                  onPressed: _selectedIndex == null
                      ? () {}
                      : () => setState(() => _isAnswerChecked = true),
                )
              else
                SiphoButton3D(
                  text: 'CONTINUER',
                  onPressed: () => context.go('/learn/done'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
