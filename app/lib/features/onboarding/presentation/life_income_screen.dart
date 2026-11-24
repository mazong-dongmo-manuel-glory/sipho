import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../../core/widgets/sipho_page_header.dart';
import '../../auth/data/user_profile_provider.dart';

/// Frame 60 · Onboarding · Vie et revenu.
class LifeIncomeScreen extends ConsumerStatefulWidget {
  const LifeIncomeScreen({super.key});

  @override
  ConsumerState<LifeIncomeScreen> createState() => _LifeIncomeScreenState();
}

class _LifeIncomeScreenState extends ConsumerState<LifeIncomeScreen> {
  String _life = 'active';
  final _incomeController = TextEditingController(text: '2800');

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _continue({required bool withIncome}) async {
    final l10n = AppLocalizations.of(context);
    final lifeLabel = switch (_life) {
      'studies' => l10n.lifeStageStudies,
      'transition' => l10n.lifeStageTransition,
      'retired' => l10n.lifeStageRetired,
      _ => l10n.lifeStageActive,
    };
    int? cents;
    if (withIncome) {
      final major = double.tryParse(
            _incomeController.text.replaceAll(' ', '').replaceAll(',', '.'),
          ) ??
          0;
      cents = (major * 100).round();
    }
    ref.read(userProfileProvider.notifier).updateProfile(
          lifeStage: lifeLabel,
          monthlyIncomeCents: cents ?? 0,
        );
    // Crée users/{uid} (quests serveur) avant le socle Firestore.
    await ref.read(userProfileProvider.notifier).persistCreate();
    if (!mounted) return;
    context.go('/onboarding/nest');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stages = [
      ('studies', l10n.lifeStageStudies),
      ('active', l10n.lifeStageActive),
      ('transition', l10n.lifeStageTransition),
      ('retired', l10n.lifeStageRetired),
    ];

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  SiphoPageHeader(
                    title: l10n.lifeIncomeHeading,
                    lead: l10n.lifeIncomeLead,
                  ),
                  const SizedBox(height: 20),
                  for (final s in stages) ...[
                    SiphoListRow(
                      title: s.$2,
                      trailing: _life == s.$1 ? '✓' : '○',
                      onTap: () => setState(() => _life = s.$1),
                    ),
                    const SiphoSeparator(),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: SiphoPalette.softSurface(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.lifeIncomeOptionalLabel,
                          style: SiphoTypography.bodyBold.copyWith(
                            fontSize: 16,
                            color: SiphoPalette.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _incomeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: SiphoTypography.bodyBold.copyWith(
                            fontSize: 16,
                            color: SiphoPalette.textPrimary(context),
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.lifeIncomeHint,
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.lifeIncomeNoIncomeHint,
                    style: SiphoTypography.body.copyWith(
                      fontSize: 14,
                      color: SiphoPalette.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  SiphoButton3D(
                    label: l10n.continueBtn,
                    variant: SiphoButtonVariant.dark,
                    onPressed: () => _continue(withIncome: true),
                  ),
                  TextButton(
                    onPressed: () => _continue(withIncome: false),
                    child: Text(
                      l10n.lifeIncomeSkipIncome,
                      style: SiphoTypography.bodyBold.copyWith(
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
