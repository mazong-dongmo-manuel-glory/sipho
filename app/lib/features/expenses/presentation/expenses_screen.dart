import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../expenses/data/expenses_provider.dart';
import '../../fixed_expenses/data/fixed_expenses_provider.dart';
import '../../gamification/data/game_state_provider.dart';

/// Frame 12 & 13 · Dépenses du mois & Mon socle branché à Riverpod.
class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SiphoColors.background,
      appBar: AppBar(
        title: const Text('Dépenses', style: SiphoTypography.title),
        bottom: TabBar(
          controller: _tabController,
          labelColor: SiphoColors.primary,
          unselectedLabelColor: SiphoColors.textSecondary,
          indicatorColor: SiphoColors.primary,
          labelStyle: SiphoTypography.bodyBold,
          tabs: const [
            Tab(text: 'Ce mois'),
            Tab(text: 'Mon socle'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _MonthlyExpensesView(),
          _FixedExpensesView(),
        ],
      ),
    );
  }
}

class _MonthlyExpensesView extends ConsumerWidget {
  const _MonthlyExpensesView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);
    final totalCents = ref.watch(totalVariableExpensesCentsProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Total dynamique du mois
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SiphoColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SiphoColors.border, width: 1.5),
          ),
          child: Column(
            children: [
              Text('TOTAL DÉPENSÉ CE MOIS-CI', style: SiphoTypography.label),
              const SizedBox(height: 6),
              Text(
                Money(cents: totalCents).formatWhole(),
                style: SiphoTypography.amountHero.copyWith(fontSize: 40),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text('Historique des dépenses', style: SiphoTypography.subtitle.copyWith(fontSize: 16)),
        const SizedBox(height: 10),
        ...expenses.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _ExpenseTile(
                emoji: e.emoji,
                title: e.title,
                category: e.category,
                amount: e.amount,
                hasReceipt: e.hasReceipt,
              ),
            )),
      ],
    );
  }
}

class _FixedExpensesView extends ConsumerWidget {
  const _FixedExpensesView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixedExpenses = ref.watch(fixedExpensesProvider);
    final totalFixedCents = ref.watch(totalFixedExpensesCentsProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: SiphoColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SiphoColors.border, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MON SOCLE MENSUEL', style: SiphoTypography.label),
                  const SizedBox(height: 4),
                  Text('${Money(cents: totalFixedCents).formatWhole()} / mois',
                      style: SiphoTypography.amountHero.copyWith(fontSize: 28)),
                ],
              ),
              const Text('🪺', style: TextStyle(fontSize: 36)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...fixedExpenses.map((f) => _FixedExpenseRow(
              emoji: f.emoji,
              title: f.name,
              amount: f.amount.formatWhole(),
              dueDay: f.dueDay,
              isPaid: f.isPaid,
              onToggle: () {
                ref.read(fixedExpensesProvider.notifier).togglePaid(f.id);
                if (!f.isPaid) {
                  ref.read(gameStateProvider.notifier).addXp(10);
                }
              },
            )),
      ],
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String category;
  final Money amount;
  final bool hasReceipt;

  const _ExpenseTile({
    required this.emoji,
    required this.title,
    required this.category,
    required this.amount,
    this.hasReceipt = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: SiphoColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiphoColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: SiphoTypography.bodyBold),
                Row(
                  children: [
                    Text(category, style: SiphoTypography.label),
                    if (hasReceipt) ...[
                      const SizedBox(width: 6),
                      Text('· 📷 scanné', style: SiphoTypography.label.copyWith(color: SiphoColors.primary)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            amount.format(),
            style: SiphoTypography.bodyBold.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _FixedExpenseRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String amount;
  final String dueDay;
  final bool isPaid;
  final VoidCallback onToggle;

  const _FixedExpenseRow({
    required this.emoji,
    required this.title,
    required this.amount,
    required this.dueDay,
    required this.isPaid,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: SiphoColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SiphoColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: SiphoTypography.bodyBold),
                  Text('$amount · $dueDay', style: SiphoTypography.label),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isPaid ? SiphoColors.primaryLight : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                isPaid ? 'Payé ✓' : 'À payer',
                style: SiphoTypography.label.copyWith(
                  color: isPaid ? SiphoColors.primary : SiphoColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
