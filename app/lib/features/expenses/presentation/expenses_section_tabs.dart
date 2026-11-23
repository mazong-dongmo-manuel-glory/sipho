import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';

/// Selected section inside the Expenses bottom-nav tab.
/// 0 = this month, 1 = socle (fixed), 2 = charts.
final expensesSectionTabProvider = StateProvider<int>((ref) => 0);

/// Shared tabs: Ce mois · Mon socle · Graphiques.
class ExpensesSectionTabs extends StatelessWidget {
  const ExpensesSectionTabs({
    super.key,
    required this.selectedIndex,
    required this.onSelectTab,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n.expensesThisMonth,
      l10n.expensesBase,
      l10n.expensesCharts,
    ];
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: Semantics(
              button: true,
              selected: i == selectedIndex,
              label: labels[i],
              child: GestureDetector(
                onTap: () => onSelectTab(i),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        labels[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: i == selectedIndex
                              ? AppColors.primaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: 0.72,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: i == selectedIndex
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
