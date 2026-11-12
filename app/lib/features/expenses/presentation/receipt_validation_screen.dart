import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/sipho_bubble.dart';
import '../../../core/widgets/sipho_button_3d.dart';

class ReceiptValidationScreen extends StatefulWidget {
  const ReceiptValidationScreen({super.key});

  @override
  State<ReceiptValidationScreen> createState() => _ReceiptValidationScreenState();
}

class _ReceiptValidationScreenState extends State<ReceiptValidationScreen> {
  final _merchantCtrl = TextEditingController(text: 'IGA Supermarché');
  final _amountCtrl = TextEditingController(text: '48.49');
  final _dateCtrl = TextEditingController(text: '2026-11-10');
  String _category = 'groceries';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Validation IA')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SiphoBubble(
                text: 'J\'ai lu ton reçu avec Gemini ! ⚡\nVérifie et valide avant d\'enregistrer.',
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.cardRadius,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _merchantCtrl,
                      decoration: const InputDecoration(labelText: 'Marchand'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Montant total (\$)'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _dateCtrl,
                      decoration: const InputDecoration(labelText: 'Date (AAAA-MM-JJ)'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SiphoButton3D(
                text: 'VALIDER (+15 XP)',
                onPressed: () {
                  context.go('/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

