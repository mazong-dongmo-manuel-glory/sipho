import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/money/money.dart';
import '../../../core/widgets/game_bar.dart';
import 'remaining_budget_card.dart';
import 'next_fixed_expense_card.dart';
import 'quest_card.dart';
import 'economy_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const GameBar(
          streakDays: 12,
          gems: 340,
          level: 7,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bonjour Amina !', style: AppTextStyles.h2),
                      Text(
                        'Prête à tresser ton nid ?',
                        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const Text('🐤', style: TextStyle(fontSize: 40)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const RemainingBudgetCard(
                remaining: Money(cents: 64200, currency: 'CAD'),
                income: Money(cents: 280000, currency: 'CAD'),
                fixed: Money(cents: 169000, currency: 'CAD'),
                spent: Money(cents: 46800, currency: 'CAD'),
                progressPercent: 0.68,
              ),
              const SizedBox(height: AppSpacing.md),
              NextFixedExpenseCard(
                title: 'Internet',
                amount: '75 \$',
                dueLabel: 'demain',
                onPay: () {},
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Quêtes du jour', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.sm),
              const QuestCard(
                title: 'Note 3 dépenses',
                progress: 2,
                target: 3,
                rewardXp: 20,
                isCompleted: false,
              ),
              const SizedBox(height: AppSpacing.sm),
              const QuestCard(
                title: 'Fais une leçon',
                progress: 0,
                target: 1,
                rewardXp: 20,
                isCompleted: false,
              ),
              const SizedBox(height: AppSpacing.sm),
              const QuestCard(
                title: 'Reste sous ton budget restos',
                progress: 1,
                target: 1,
                rewardXp: 30,
                isCompleted: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              EconomyCard(
                headline: 'Inflation alimentaire : 3,4%',
                impactText: '≈ +11 \$/mois sur ton panier d\'épicerie',
                onTap: () => context.push('/economy/detail'),
              ),
              const SizedBox(height: 80), // Space for FAB & BottomNav
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/expenses/add'),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }
}

