import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/feedback/feedback_cue.dart';
import 'package:sipho/core/feedback/feedback_service.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/insights/data/insight_service.dart';
import 'package:sipho/features/insights/domain/insight_text.dart';
import 'package:sipho/features/insights/presentation/spend_snapshot_builder.dart';

class InsightDetailScreen extends ConsumerStatefulWidget {
  const InsightDetailScreen({super.key});

  @override
  ConsumerState<InsightDetailScreen> createState() => _InsightDetailScreenState();
}

class _InsightDetailScreenState extends ConsumerState<InsightDetailScreen> {
  String _selectedTopic = 'general';

  Future<void> _generateNewAdvice() async {
    final l10n = AppLocalizations.of(context);
    final snapshot = buildCurrentSpendSnapshot(
      ref: ref,
      context: context,
      focusTopic: _selectedTopic,
    );

    if (!snapshot.hasAnyFinancialData) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.coachEmptyBody)),
      );
      return;
    }

    try {
      await ref.read(insightControllerProvider.notifier).ask(snapshot);
      ref.read(feedbackServiceProvider).play(SiphoCue.fixedPaid);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeInsightError)),
      );
    }
  }

  void _acceptQuest(InsightText advice) {
    ref.read(feedbackServiceProvider).play(SiphoCue.questClaimed);
    // Dismiss active advice once accepted
    ref.read(insightControllerProvider.notifier).dismiss(advice);

    if (advice.recommendedLessonId.isNotEmpty) {
      context.push('/lesson/${advice.recommendedLessonId}');
    } else {
      context.push('/learn');
    }
  }

  void _dismissAdvice(InsightText advice) {
    ref.read(insightControllerProvider.notifier).dismiss(advice);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final insightState = ref.watch(insightControllerProvider);
    final activeAdvice = ref.watch(activeCoachAdviceProvider);
    final previousInsights = ref.watch(storedInsightsProvider).valueOrNull ?? const [];

    final topics = [
      ('general', l10n.coachTopicGeneral),
      ('spending', l10n.coachTopicSpending),
      ('fixed', l10n.coachTopicFixed),
      ('goal', l10n.coachTopicGoal),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.coachTitle,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
            vertical: 12,
          ),
          children: [
            // Header card with Mascot
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.seedPill,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: SvgPicture.asset(
                      'assets/images/sipho_waving.svg',
                      semanticsLabel: 'Sipho Coach',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.coachTitle,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.coachSubtitle,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            height: 1.3,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Topic filter selector
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: topics.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final t = topics[i];
                  final selected = t.$1 == _selectedTopic;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedTopic = t.$1);
                      ref.read(insightControllerProvider.notifier).selectFocus(t.$1);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primaryDark : AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected ? AppColors.primaryDark : AppColors.border,
                        ),
                      ),
                      child: Text(
                        t.$2,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: selected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Main Frame 23 Card: Conseil de Sipho
            if (activeAdvice != null)
              _ActiveAdviceCard(
                advice: activeAdvice,
                onAccept: () => _acceptQuest(activeAdvice),
                onDismiss: () => _dismissAdvice(activeAdvice),
              )
            else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Text('🔍', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 12),
                    Text(
                      l10n.coachEmptyBody,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            // Action button: Demander un conseil
            SiphoButton3D(
              label: activeAdvice == null
                  ? l10n.coachGenerateCta
                  : l10n.coachRefreshCta,
              isLoading: insightState.loading,
              onPressed: insightState.loading ? null : _generateNewAdvice,
              height: 50,
            ),
            const SizedBox(height: 28),
            // Previous insights list
            if (previousInsights.length > 1) ...[
              Text(
                l10n.coachPreviousTitle,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              for (final past in previousInsights.skip(1)) ...[
                _PreviousAdviceTile(advice: past),
                const SizedBox(height: 10),
              ],
            ],
            const SizedBox(height: 16),
            // Legal disclaimer
            Text(
              l10n.adviceDisclaimer,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Frame 23 Card matching Figma design
class _ActiveAdviceCard extends StatelessWidget {
  const _ActiveAdviceCard({
    required this.advice,
    required this.onAccept,
    required this.onDismiss,
  });

  final InsightText advice;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasQuest = advice.suggestedQuest != null || advice.actionStep.isNotEmpty;
    final questText = advice.suggestedQuest?.description.isNotEmpty == true
        ? advice.suggestedQuest!.description
        : (advice.suggestedQuest?.name ?? advice.actionStep);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.seedPill,
                  shape: BoxShape.circle,
                ),
                child: const Text('🔍', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  advice.title.isNotEmpty ? advice.title : l10n.coachTitle,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            advice.body,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          if (hasQuest) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          l10n.adviceQuest,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    questText,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          SiphoButton3D(
            label: l10n.adviceAccept,
            height: 48,
            onPressed: onAccept,
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: onDismiss,
              child: Text(
                l10n.adviceLater,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviousAdviceTile extends StatelessWidget {
  const _PreviousAdviceTile({required this.advice});

  final InsightText advice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            advice.title.isNotEmpty ? advice.title : advice.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          if (advice.title.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              advice.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
