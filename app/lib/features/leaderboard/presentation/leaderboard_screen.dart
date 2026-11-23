import 'package:flutter/material.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_typography.dart';

/// Frame 20 · Ligue Or & Classement - FIGMA.md §43 & Specification_Sipho.pdf §4.5.
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SiphoColors.background,
      appBar: AppBar(
        title: const Text('Classement', style: SiphoTypography.title),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // En-tête de la ligue
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: SiphoColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: SiphoColors.border, width: 1.5),
            ),
            child: Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LIGUE OR', style: SiphoTypography.label.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('Top 7 promus en Saphir', style: SiphoTypography.bodyBold),
                      Text('Fin de la ligue dans 2j 14h', style: SiphoTypography.label),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Lignes de classement
          _LeaderboardRow(rank: 1, name: 'Koffi A.', xp: 840, isTop: true),
          _LeaderboardRow(rank: 2, name: 'Sarah M.', xp: 790, isTop: true),
          _LeaderboardRow(rank: 3, name: 'Amina (Toi)', xp: 750, isMe: true),
          _LeaderboardRow(rank: 4, name: 'Alexandre B.', xp: 620),
          _LeaderboardRow(rank: 5, name: 'Fatou D.', xp: 580),
          _LeaderboardRow(rank: 6, name: 'Marc-André L.', xp: 540),
          _LeaderboardRow(rank: 7, name: 'Chloé R.', xp: 510),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;
  final bool isMe;
  final bool isTop;

  const _LeaderboardRow({
    required this.rank,
    required this.name,
    required this.xp,
    this.isMe = false,
    this.isTop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? SiphoColors.primaryLight : SiphoColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe ? SiphoColors.primary : SiphoColors.border,
          width: isMe ? 2.0 : 1.5,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: SiphoTypography.bodyBold.copyWith(
                color: isTop ? SiphoColors.accentGold : SiphoColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: SiphoTypography.bodyBold.copyWith(
                color: isMe ? SiphoColors.primary : SiphoColors.textPrimary,
              ),
            ),
          ),
          Text(
            '$xp XP',
            style: SiphoTypography.label.copyWith(
              fontWeight: FontWeight.w800,
              color: SiphoColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
