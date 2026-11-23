import 'package:flutter/material.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_bubble.dart';

/// Frame 15 · Chemin de leçons (Duolingo style) - FIGMA.md §150 & Specification_Sipho.pdf §2.6.
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SiphoColors.background,
      appBar: AppBar(
        title: const Text('Apprendre', style: SiphoTypography.title),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Bannière Unité 1
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SiphoColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UNITÉ 1 · LES BASES',
                  style: SiphoTypography.label.copyWith(
                    color: Colors.white70,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Comprendre ton argent et ton socle',
                  style: SiphoTypography.subtitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Bulle mascotte
          const SiphoBubble(
            title: 'À toi de jouer !',
            text: '2 à 3 minutes par jour suffisent pour bâtir ta liberté financière.',
          ),
          const SizedBox(height: 32),

          // Chemin vertical de nœuds 3D sinueux
          Center(
            child: Column(
              children: [
                _LessonNode(
                  title: 'Le nid et les dépenses fixes',
                  isCompleted: true,
                  number: '1',
                  onTap: () {},
                ),
                _PathConnector(),
                _LessonNode(
                  title: 'Le reste à vivre au quotidien',
                  isCurrent: true,
                  number: '2',
                  onTap: () {},
                ),
                _PathConnector(),
                _LessonNode(
                  title: 'Le fonds d\'urgence',
                  isLocked: true,
                  number: '3',
                  onTap: () {},
                ),
                _PathConnector(),
                _LessonNode(
                  title: 'La règle 50 / 30 / 20',
                  isLocked: true,
                  number: '4',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _LessonNode extends StatelessWidget {
  final String title;
  final String number;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLocked;
  final VoidCallback onTap;

  const _LessonNode({
    required this.title,
    required this.number,
    this.isCompleted = false,
    this.isCurrent = false,
    this.isLocked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color faceColor = SiphoColors.primary;
    Color edgeColor = SiphoColors.primaryDark;
    Widget icon = Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24));

    if (isCompleted) {
      faceColor = SiphoColors.accentGold;
      edgeColor = const Color(0xFFC79200);
      icon = const Icon(Icons.check_rounded, color: Colors.white, size: 32);
    } else if (isLocked) {
      faceColor = const Color(0xFFCBD5E1);
      edgeColor = const Color(0xFF94A3B8);
      icon = const Icon(Icons.lock_rounded, color: Colors.white, size: 28);
    }

    return Column(
      children: [
        GestureDetector(
          onTap: isLocked ? null : onTap,
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: edgeColor,
              shape: BoxShape.circle,
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: faceColor,
                shape: BoxShape.circle,
              ),
              child: Center(child: icon),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 160,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: SiphoTypography.label.copyWith(
              color: isLocked ? SiphoColors.textMuted : SiphoColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _PathConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 32,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: SiphoColors.border,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
