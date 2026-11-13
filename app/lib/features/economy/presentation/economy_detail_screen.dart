import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/ai/sipho_ai_client.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/insights/data/insight_service.dart';
import 'package:sipho/features/insights/domain/insight_text.dart';
import 'package:sipho/features/insights/presentation/spend_snapshot_builder.dart';

class EconomyDetailScreen extends ConsumerWidget {
  const EconomyDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Keep finance streams subscribed so buildCurrentSpendSnapshot reads live values.
    final monthKey = currentMonthKey();
    ref.watch(userFinanceProvider);
    ref.watch(transactionsForMonthProvider(monthKey));
    ref.watch(activeFixedExpensesProvider);
    ref.watch(monthSummaryProvider(monthKey));

    final state = ref.watch(insightControllerProvider);
    final activeAdvice = ref.watch(activeCoachAdviceProvider);
    final history =
        ref.watch(storedInsightsProvider).valueOrNull ?? const <InsightText>[];

    final topics = [
      ('general', '🧭', l10n.coachTopicGeneral),
      ('spending', '🛒', l10n.coachTopicSpending),
      ('fixed', '🏠', l10n.coachTopicFixed),
      ('goal', '🌱', l10n.coachTopicGoal),
    ];

    Future<void> requestAdvice({bool acceptQuest = false}) async {
      final snapshot = buildCurrentSpendSnapshot(
        ref: ref,
        context: context,
        focusTopic: state.focusTopic,
      );
      if (!snapshot.hasAnyFinancialData) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.homeInsightEmpty)),
        );
        return;
      }
      try {
        await ref
            .read(insightControllerProvider.notifier)
            .ask(snapshot, acceptQuest: acceptQuest);
      } catch (error) {
        debugPrint('[SiphoAI] Economy coach advice failed: $error');
        if (!context.mounted) return;
        await showSiphoAiErrorSnackBar(
          context,
          error,
          l10n,
          fallback: l10n.homeInsightError,
        );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                8,
                AppSpacing.pagePadding,
                4,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        context.canPop() ? context.pop() : context.go('/home'),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.adviceKicker,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          l10n.coachTitle,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  8,
                  AppSpacing.pagePadding,
                  20,
                ),
                children: [
                  Text(
                    l10n.coachSubtitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final topic in topics)
                        ChoiceChip(
                          backgroundColor: AppColors.surface,
                          selectedColor: AppColors.mint,
                          checkmarkColor: AppColors.primaryDark,
                          side: BorderSide(
                            color: state.focusTopic == topic.$1
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                          labelStyle: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: state.focusTopic == topic.$1
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
                          ),
                          label: Text('${topic.$2} ${topic.$3}'),
                          selected: state.focusTopic == topic.$1,
                          onSelected: (_) {
                            ref
                                .read(insightControllerProvider.notifier)
                                .selectFocus(topic.$1);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        activeAdvice == null
                            ? const SiphoArt.waving(frame: 145)
                            : const SiphoArt.proud(frame: 145),
                        const Positioned(
                          right: 0,
                          bottom: 14,
                          child: Icon(
                            Icons.auto_awesome,
                            size: 32,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (activeAdvice == null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        state.loading
                            ? l10n.homeInsightWorking
                            : l10n.coachEmptyBody,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    )
                  else ...[
                    if (activeAdvice.title.isNotEmpty) ...[
                      Text(
                        activeAdvice.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        activeAdvice.body,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    if (activeAdvice.actionStep.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.mint,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🎯  ${l10n.coachActionTitle}',
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              activeAdvice.actionStep,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (activeAdvice.suggestedQuest != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                        decoration: BoxDecoration(
                          color: AppColors.seedPill,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.coachQuestBadge,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.warnBrown,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              activeAdvice.suggestedQuest!.name,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            if (activeAdvice
                                .suggestedQuest!.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                activeAdvice.suggestedQuest!.description,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.push(
                              '/lesson/${activeAdvice.recommendedLessonId}',
                            ),
                            icon:
                                const Icon(Icons.menu_book_outlined, size: 18),
                            label: Text(
                              l10n.coachDoLessonCta,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/expenses/add'),
                            icon:
                                const Icon(Icons.add_circle_outline, size: 18),
                            label: Text(
                              l10n.coachLogExpenseCta,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (history.length > 1) ...[
                    const SizedBox(height: 20),
                    Text(
                      l10n.coachPreviousTitle,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final item in history.skip(1).take(3)) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.title.isNotEmpty)
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            if (item.title.isNotEmpty)
                              const SizedBox(height: 4),
                            Text(
                              item.body,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                  const SizedBox(height: 16),
                  SiphoButton3D(
                    label: activeAdvice == null
                        ? l10n.coachGenerateCta
                        : l10n.coachRefreshCta,
                    isLoading: state.loading,
                    onPressed: () => requestAdvice(acceptQuest: true),
                    color: AppColors.primary,
                    shadowColor: AppColors.primaryDark,
                    height: 52,
                    borderRadius: figmaButtonRadius,
                  ),
                  if (activeAdvice != null) ...[
                    const SizedBox(height: 14),
                    Center(
                      child: GestureDetector(
                        onTap: state.loading
                            ? null
                            : () async {
                                await ref
                                    .read(insightControllerProvider.notifier)
                                    .dismiss(activeAdvice);
                              },
                        child: Text(
                          l10n.adviceLater,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    l10n.adviceDisclaimer,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
