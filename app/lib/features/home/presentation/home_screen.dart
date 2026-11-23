import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/game_bar.dart';
import '../../auth/data/user_profile_provider.dart';
import '../../budget/data/remaining_budget_provider.dart';
import '../../expenses/data/expenses_provider.dart';
import '../../fixed_expenses/data/fixed_expenses_provider.dart';
import '../../gamification/data/game_state_provider.dart';

/// Frame 08 · Accueil (écran principal) réactif et connecté à Riverpod.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final game = ref.watch(gameStateProvider);
    final remainingCents = ref.watch(remainingBudgetCentsProvider);
    final totalFixedCents = ref.watch(totalFixedExpensesCentsProvider);
    final totalVariableCents = ref.watch(totalVariableExpensesCentsProvider);
    final fixedExpenses = ref.watch(fixedExpensesProvider);

    final remainingMoney = Money(cents: remainingCents, currency: user.currency);
    final incomeMoney = Money(cents: user.monthlyIncomeCents, currency: user.currency);
    final fixedMoney = Money(cents: totalFixedCents, currency: user.currency);
    final variableMoney = Money(cents: totalVariableCents, currency: user.currency);

    final nextFixed = fixedExpenses.firstWhere(
      (e) => !e.isPaid,
      orElse: () => fixedExpenses.first,
    );

    return Scaffold(
      backgroundColor: SiphoColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Barre de statut de jeu connectée
            GameBar(
              streakDays: game.streakDays,
              seeds: game.seeds,
              level: game.level,
            ),
            const SizedBox(height: 16),

            // Salutation avec Sipho
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour ${user.displayName} ! 👋',
                      style: SiphoTypography.title.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ton nid grandit chaque jour.',
                      style: SiphoTypography.label,
                    ),
                  ],
                ),
                SizedBox(
                  width: 56,
                  height: 56,
                  child: SvgPicture.asset(
                    'assets/images/sipho_happy.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Grande carte « Reste à vivre » calculé dynamiquement
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: SiphoColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: SiphoColors.border, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'RESTE À VIVRE',
                    style: SiphoTypography.label.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                      color: SiphoColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    remainingMoney.formatWhole(),
                    style: SiphoTypography.amountHero.copyWith(
                      color: remainingMoney.isNegative ? SiphoColors.danger : SiphoColors.primary,
                      fontSize: 54,
                    ),
                  ),
                  Text(
                    'disponible pour ce mois-ci',
                    style: SiphoTypography.label,
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: SiphoColors.border, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatItem(label: 'Revenu', amount: incomeMoney.formatWhole()),
                      _StatItem(label: 'Fixes', amount: fixedMoney.formatWhole()),
                      _StatItem(label: 'Dépensé', amount: variableMoney.formatWhole()),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Carte « Prochaine dépense fixe »
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: SiphoColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: SiphoColors.border, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: SiphoColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(child: Text(nextFixed.emoji, style: const TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nextFixed.name, style: SiphoTypography.bodyBold),
                        Text('${nextFixed.amount.formatWhole()} · ${nextFixed.dueDay}', style: SiphoTypography.label),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(fixedExpensesProvider.notifier).togglePaid(nextFixed.id);
                      if (!nextFixed.isPaid) {
                        ref.read(gameStateProvider.notifier).addXp(10);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${nextFixed.name} marqué payé ! +10 XP 🌾'),
                            backgroundColor: SiphoColors.primary,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: nextFixed.isPaid ? const Color(0xFFF1F5F9) : SiphoColors.primary,
                      foregroundColor: nextFixed.isPaid ? SiphoColors.textSecondary : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: Text(
                      nextFixed.isPaid ? 'Payé ✓' : 'Payer',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quêtes du jour
            Text(
              'Quêtes du jour',
              style: SiphoTypography.subtitle,
            ),
            const SizedBox(height: 12),
            _QuestTile(
              emoji: '📝',
              title: 'Note 3 dépenses',
              progress: '2 / 3',
              progressRatio: 0.66,
              xp: '+20 XP',
            ),
            const SizedBox(height: 10),
            _QuestTile(
              emoji: '📖',
              title: 'Fais une leçon',
              progress: '0 / 1',
              progressRatio: 0.0,
              xp: '+20 XP',
            ),
            const SizedBox(height: 10),
            _QuestTile(
              emoji: '🎯',
              title: 'Reste sous ton budget restos',
              progress: 'Complété ✓',
              progressRatio: 1.0,
              xp: '+30 XP',
              isCompleted: true,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String amount;

  const _StatItem({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: SiphoTypography.label.copyWith(fontSize: 12)),
        const SizedBox(height: 2),
        Text(amount, style: SiphoTypography.bodyBold.copyWith(fontSize: 14)),
      ],
    );
  }
}

class _QuestTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String progress;
  final double progressRatio;
  final String xp;
  final bool isCompleted;

  const _QuestTile({
    required this.emoji,
    required this.title,
    required this.progress,
    required this.progressRatio,
    required this.xp,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SiphoColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SiphoColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: SiphoTypography.bodyBold.copyWith(fontSize: 14)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progressRatio,
                    backgroundColor: SiphoColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? SiphoColors.primary : SiphoColors.accentGold,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            xp,
            style: SiphoTypography.label.copyWith(
              color: SiphoColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
