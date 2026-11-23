import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_bubble.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../auth/data/user_profile_provider.dart';
import '../../gamification/data/game_state_provider.dart';

/// Frames 03a-06 · Onboarding conversationnel avec Sipho.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  final TextEditingController _nameController = TextEditingController(text: 'Amina');
  String _selectedCountry = 'Canada';
  String _selectedCurrency = 'CAD';
  String _selectedGoal = 'Arrêter d\'être à découvert';

  final List<(String, String, String)> _countries = const [
    ('Canada', '🇨🇦', 'CAD'),
    ('France', '🇫🇷', 'EUR'),
    ('Cameroun', '🇨🇲', 'XAF'),
    ('Côte d\'Ivoire', '🇨🇮', 'XOF'),
    ('Sénégal', '🇸🇳', 'XOF'),
    ('Belgique', '🇧🇪', 'EUR'),
  ];

  final List<(String, String)> _goals = const [
    ('Arrêter d\'être à découvert', '🛡️'),
    ('Épargner pour un projet', '🎯'),
    ('Comprendre mon argent', '💡'),
    ('Préparer ma retraite', '🌴'),
  ];

  void _nextStep() {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      // Fin d'onboarding : enregistrer le profil & attribuer +50 XP
      ref.read(userProfileProvider.notifier).updateProfile(
            displayName: _nameController.text.trim().isEmpty ? 'Amina' : _nameController.text.trim(),
            countryCode: _selectedCountry,
            currency: _selectedCurrency,
            mainGoal: _selectedGoal,
          );
      ref.read(userProfileProvider.notifier).completeOnboarding();
      ref.read(gameStateProvider.notifier).addXp(50);
      ref.read(gameStateProvider.notifier).addBadge('Bâtisseur');

      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SiphoColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Barre de progression
              LinearProgressIndicator(
                value: (_step + 1) / 4.0,
                backgroundColor: SiphoColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(SiphoColors.primary),
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(height: 24),

              // Mascotte Sipho
              SizedBox(
                width: 100,
                height: 100,
                child: SvgPicture.asset(
                  _step == 3 ? 'assets/images/sipho_celebrating.svg' : 'assets/images/sipho_waving.svg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),

              // Contenu par étape
              Expanded(
                child: _buildStepContent(),
              ),

              // Bouton 3D Suivant
              SiphoButton3D(
                label: _step == 3 ? 'TERMINER (+50 XP)' : 'CONTINUER',
                variant: _step == 3 ? SiphoButtonVariant.secondary : SiphoButtonVariant.primary,
                onPressed: _nextStep,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return Column(
          children: [
            const SiphoBubble(
              title: 'Salut ! Moi c\'est Sipho 🐥',
              text: 'Comment tu t\'appelles ? Je serai ton compagnon financier.',
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              style: SiphoTypography.title.copyWith(fontSize: 22),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: SiphoColors.surface,
                hintText: 'Ton prénom',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: SiphoColors.border, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: SiphoColors.border, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: SiphoColors.primary, width: 2),
                ),
              ),
            ),
          ],
        );

      case 1:
        return Column(
          children: [
            const SiphoBubble(
              title: 'Tu vis où ? 🌍',
              text: 'J\'adapte les devises, la fiscalité et les conseils à ton pays.',
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: _countries.map((c) {
                  final isSelected = _selectedCountry == c.$1;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedCountry = c.$1;
                      _selectedCurrency = c.$3;
                    }),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? SiphoColors.primaryLight : SiphoColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? SiphoColors.primary : SiphoColors.border,
                          width: isSelected ? 2.0 : 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(c.$2, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              c.$1,
                              style: SiphoTypography.bodyBold.copyWith(
                                color: isSelected ? SiphoColors.primary : SiphoColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            c.$3,
                            style: SiphoTypography.label.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isSelected ? SiphoColors.primary : SiphoColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );

      case 2:
        return Column(
          children: [
            const SiphoBubble(
              title: 'Quel est ton objectif ? 🎯',
              text: 'Chaque pas compte pour bâtir ton nid financier.',
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: _goals.map((g) {
                  final isSelected = _selectedGoal == g.$1;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedGoal = g.$1),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? SiphoColors.primaryLight : SiphoColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? SiphoColors.primary : SiphoColors.border,
                          width: isSelected ? 2.0 : 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(g.$2, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              g.$1,
                              style: SiphoTypography.bodyBold.copyWith(
                                color: isSelected ? SiphoColors.primary : SiphoColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isSelected) const Icon(Icons.check_circle, color: SiphoColors.primary),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );

      case 3:
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ton nid est prêt ! 🪺',
              textAlign: TextAlign.center,
              style: SiphoTypography.title.copyWith(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              'Félicitations ${_nameController.text.trim()} ! Tu as gagné ton premier badge Bâtisseur et +50 XP pour démarrer.',
              textAlign: TextAlign.center,
              style: SiphoTypography.body.copyWith(color: SiphoColors.textSecondary),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: SiphoColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: SiphoColors.primary, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏡', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Badge Bâtisseur débloqué', style: SiphoTypography.bodyBold),
                      Text('+50 XP · 50 Graines d\'or', style: SiphoTypography.label.copyWith(color: SiphoColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }
}
