import 'package:flutter/material.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_typography.dart';

/// Frame 21 · Profil & Récompenses - FIGMA.md §44 & Specification_Sipho.pdf §6.1.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SiphoColors.background,
      appBar: AppBar(
        title: const Text('Profil', style: SiphoTypography.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Carte identité joueur
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: SiphoColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: SiphoColors.border, width: 1.5),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: SiphoColors.primaryLight,
                  child: Text('🪶', style: TextStyle(fontSize: 40)),
                ),
                const SizedBox(height: 12),
                Text('Amina', style: SiphoTypography.title.copyWith(fontSize: 22)),
                Text('Membre depuis novembre 2026 · Canada 🇨🇦', style: SiphoTypography.label),
                const SizedBox(height: 16),
                const Divider(color: SiphoColors.border, height: 1),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ProfileStat(label: 'Série', value: '12 jours 🔥'),
                    _ProfileStat(label: 'Total XP', value: '2 450 ⚡'),
                    _ProfileStat(label: 'Graines', value: '340 🌾'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Badges débloqués
          Text('Badges & Trophées', style: SiphoTypography.subtitle),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BadgeItem(emoji: '🏡', title: 'Bâtisseur', desc: 'Socle configuré'),
              _BadgeItem(emoji: '🔥', title: 'Flamme 7j', desc: '1 semaine active'),
              _BadgeItem(emoji: '📚', title: 'Savant', desc: 'Unité 1 finie'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: SiphoTypography.bodyBold.copyWith(fontSize: 15)),
        const SizedBox(height: 2),
        Text(label, style: SiphoTypography.label.copyWith(fontSize: 12)),
      ],
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;

  const _BadgeItem({
    required this.emoji,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: SiphoColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SiphoColors.border, width: 1.5),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 32))),
        ),
        const SizedBox(height: 6),
        Text(title, style: SiphoTypography.bodyBold.copyWith(fontSize: 13)),
        Text(desc, style: SiphoTypography.label.copyWith(fontSize: 10)),
      ],
    );
  }
}
