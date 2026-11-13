import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/app/theme/app_text_styles.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';

class ChestOpenScreen extends StatefulWidget {
  const ChestOpenScreen({super.key});

  @override
  State<ChestOpenScreen> createState() => _ChestOpenScreenState();
}

class _ChestOpenScreenState extends State<ChestOpenScreen> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: GestureDetector(
                  onTap: () => setState(() => _isOpen = true),
                  child: Text(
                    _isOpen ? '✨🎁✨' : '🎁',
                    style: const TextStyle(fontSize: 88),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _isOpen ? 'Cadeau de Sipho ouvert !' : 'Touche pour ouvrir ton cadeau',
                textAlign: TextAlign.center,
                style: AppTextStyles.h2.copyWith(color: AppColors.cream),
              ),
              if (_isOpen) ...[
                const SizedBox(height: AppSpacing.md),
                const Text(
                  '+50 Graines d\'or 🌾\n+1 Gel de série 🧊',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ],
              const Spacer(),
              if (_isOpen)
                SiphoButton3D(
                  text: 'RÉCUPÉRER',
                  onPressed: () => context.pop(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

