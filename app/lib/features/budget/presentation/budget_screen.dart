import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/money/money.dart';
import 'package:sipho/core/money/money_formatter.dart';
import 'package:sipho/core/widgets/gauge_horizontal.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/features/budget/domain/month_chart.dart';
import 'package:sipho/features/expenses/presentation/expense_category_label.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final monthKey = currentMonthKey();
    final transactions = ref.watch(transactionsForMonthProvider(monthKey));
    final currency =
        ref.watch(userFinanceProvider).valueOrNull?.currency ?? 'CAD';
    final locale = Localizations.localeOf(context).toString();
    final monthLabel = DateFormat.yMMMM(locale).format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: transactions.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (_, __) => Center(child: Text(l10n.expensesLoadError)),
          data: (items) {
            final chart = buildMonthChart([
              for (final tx in items)
                (
                  category: tx.category,
                  cents: tx.spendMainCents,
                  date: tx.date,
                ),
            ]);

            final hasData = chart.slices.isNotEmpty;

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                16,
                AppSpacing.pagePadding,
                100,
              ),
              children: [
                // ── En-tête — maquette 14 · Budgets ──
                Text(
                  l10n.budgetTitle,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  monthLabel,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Message de synthèse ──
                if (hasData)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.soft,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      l10n.budgetIntro,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),

                // ── Jauges par catégorie — style épuré ──
                if (!hasData)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Text(
                      l10n.chartsEmpty,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  for (final slice in chart.slices) ...[
                    _BudgetRow(
                      name: slice.category == 'other'
                          ? l10n.chartsOtherName
                          : expenseCategoryLabel(l10n, slice.category),
                      amount: MoneyFormatter.format(
                        Money(cents: slice.cents, currency: currency),
                        locale: locale,
                      ),
                      percent: chart.totalCents == 0
                          ? 0
                          : slice.cents / chart.totalCents,
                    ),
                    const SizedBox(height: 24),
                  ],

                // ── Sipho + conseil si loisirs dépassés ──
                if (hasData) ...[
                  const SizedBox(height: 8),
                  _SiphoAdviceCard(l10n: l10n),
                  const SizedBox(height: 20),
                  // Bouton graphiques
                  _GraphsRow(l10n: l10n, onTap: () => context.push('/charts')),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Ligne de jauge épurée — maquette 14
class _BudgetRow extends StatelessWidget {
  const _BudgetRow({
    required this.name,
    required this.amount,
    required this.percent,
  });

  final String name;
  final String amount;
  final double percent;

  @override
  Widget build(BuildContext context) {
    final p = percent.clamp(0.0, 1.0);
    final Color gaugeColor;
    final String status;
    final l10n = AppLocalizations.of(context);

    if (p >= 0.90) {
      gaugeColor = AppColors.budgetOver;
      status = l10n.budgetStatusOver;
    } else if (p >= 0.70) {
      gaugeColor = AppColors.budgetWarn;
      status = l10n.budgetStatusWarn;
    } else {
      gaugeColor = AppColors.budgetOk;
      status = l10n.budgetStatusOk;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            Text(
              '${(p * 100).round()} % · $status',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: gaugeColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GaugeHorizontal(
          progress: p,
          color: gaugeColor,
          backgroundColor: AppColors.hairline,
        ),
      ],
    );
  }
}

/// Conseil de Sipho — maquette 14
class _SiphoAdviceCard extends StatelessWidget {
  const _SiphoAdviceCard({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SiphoArt.worried(frame: 56),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.budgetSiphoAdviceTitle,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.budgetSiphoAdviceBody,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lien vers les graphiques
class _GraphsRow extends StatelessWidget {
  const _GraphsRow({required this.l10n, required this.onTap});
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.budgetGraphsTitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    l10n.budgetGraphsSubtitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              '→',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
