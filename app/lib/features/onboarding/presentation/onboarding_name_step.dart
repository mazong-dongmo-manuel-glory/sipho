import 'package:flutter/material.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/sipho_bubble.dart';

class OnboardingNameStep extends StatelessWidget {
  final ValueChanged<String> onNameChanged;

  const OnboardingNameStep({
    super.key,
    required this.onNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const SiphoBubble(
          text: 'Salut ! Moi c\'est Sipho 🐤\nComment tu t\'appelles ?',
        ),
        const SizedBox(height: AppSpacing.xxl),
        TextField(
          autofocus: true,
          style: AppTextStyles.h2,
          decoration: const InputDecoration(
            hintText: 'Ton prénom',
          ),
          onChanged: onNameChanged,
        ),
      ],
    );
  }
}

