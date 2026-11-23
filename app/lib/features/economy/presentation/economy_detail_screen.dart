import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/core/ai/sipho_ai_client.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/core/widgets/sipho_button_3d.dart';
import 'package:sipho/features/economy/data/economy_repository.dart';
import 'package:sipho/features/economy/domain/economy_data.dart';
import 'package:sipho/features/economy/domain/economy_news.dart';
import 'package:sipho/features/economy/domain/economy_tips.dart';
import 'package:sipho/features/finance/data/fx_rates_repository.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/insights/data/insight_service.dart';
import 'package:sipho/features/insights/domain/insight_text.dart';
import 'package:sipho/features/insights/presentation/spend_snapshot_builder.dart';
import 'package:url_launcher/url_launcher.dart';

class EconomyDetailScreen extends ConsumerStatefulWidget {
  const EconomyDetailScreen({super.key});

  @override
  ConsumerState<EconomyDetailScreen> createState() =>
      _EconomyDetailScreenState();
}

class _EconomyDetailScreenState extends ConsumerState<EconomyDetailScreen> {
  int _selectedTabIndex = 0; // 0 = Conseils, 1 = Économie, 2 = Coach IA
  late EconomyTip _currentTip;
  EconomyTipCategory? _selectedCategory;
  String? _selectedCountryCode;

  @override
  void initState() {
    super.initState();
    _currentTip = dailyEconomyTip();
  }

  void _shuffleTip() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentTip = pickRandomEconomyTip(
        currentId: _currentTip.id,
        category: _selectedCategory,
      );
    });
  }

  void _onSelectCategory(EconomyTipCategory? cat) {
    setState(() {
      _selectedCategory = cat;
      _currentTip = pickRandomEconomyTip(
        category: cat,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final finance = ref.watch(userFinanceProvider).valueOrNull;
    final country = _selectedCountryCode ??
        ((finance?.countryCode.isNotEmpty ?? false)
            ? finance!.countryCode
            : 'CA');
    final economyAsync = ref.watch(countryEconomyProvider(country));

    final monthKey = currentMonthKey();
    ref.watch(userFinanceProvider);
    ref.watch(transactionsForMonthProvider(monthKey));
    ref.watch(activeFixedExpensesProvider);
    ref.watch(monthSummaryProvider(monthKey));

    final coachState = ref.watch(insightControllerProvider);
    final activeAdvice = ref.watch(activeCoachAdviceProvider);
    final history =
        ref.watch(storedInsightsProvider).valueOrNull ?? const <InsightText>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, l10n, country),
            _buildTabBar(l10n),
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  _buildTipsTab(locale, l10n),
                  _buildEconomyTab(locale, country, economyAsync, l10n),
                  _buildCoachTab(
                    l10n: l10n,
                    state: coachState,
                    activeAdvice: activeAdvice,
                    history: history,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    String currentCountry,
  ) {
    return Padding(
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
                  l10n.economyTitle,
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
          _CountrySelectorBadge(
            currentCountry: currentCountry,
            onChanged: (code) {
              setState(() => _selectedCountryCode = code);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(AppLocalizations l10n) {
    final tabs = [
      ('💡', 'Conseils variés', 'Varied Tips'),
      ('📈', 'Info Éco', 'Economy Info'),
      ('🤖', 'Coach IA', 'AI Coach'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: 8,
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedTabIndex = i);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedTabIndex == i
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(tabs[i].$1, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            Localizations.localeOf(context)
                                    .languageCode
                                    .startsWith('fr')
                                ? tabs[i].$2
                                : tabs[i].$3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _selectedTabIndex == i
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsTab(String locale, AppLocalizations l10n) {
    final categories = [
      (null, l10n.ecoTipCatAll),
      (EconomyTipCategory.budget, l10n.ecoTipCatBudget),
      (EconomyTipCategory.saving, l10n.ecoTipCatSaving),
      (EconomyTipCategory.economy, l10n.ecoTipCatEconomy),
      (EconomyTipCategory.security, l10n.ecoTipCatSecurity),
      (EconomyTipCategory.invest, l10n.ecoTipCatInvest),
      (EconomyTipCategory.lifestyle, l10n.ecoTipCatLifestyle),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        8,
        AppSpacing.pagePadding,
        24,
      ),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final cat in categories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.mint,
                    checkmarkColor: AppColors.primaryDark,
                    side: BorderSide(
                      color: _selectedCategory == cat.$1
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                    labelStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _selectedCategory == cat.$1
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                    ),
                    label: Text(cat.$2),
                    selected: _selectedCategory == cat.$1,
                    onSelected: (_) => _onSelectCategory(cat.$1),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.accent, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _currentTip.localizedCategory(locale),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _currentTip.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _currentTip.title.of(locale),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _currentTip.body.of(locale),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.ecoTipActionLabel,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: AppColors.terracotta,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _currentTip.actionTip.of(locale),
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${l10n.ecoTipSource}: ${_currentTip.source}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SiphoButton3D(
          label: l10n.ecoTipShuffle,
          onPressed: _shuffleTip,
        ),
      ],
    );
  }

  Widget _buildEconomyTab(
    String locale,
    String countryCode,
    AsyncValue<EconomyData> economyAsync,
    AppLocalizations l10n,
  ) {
    final isFr = locale.startsWith('fr');
    final newsAsync = ref.watch(countryEconomyNewsProvider(countryCode));
    final worldNewsAsync = countryCode.toUpperCase() == 'WORLD'
        ? null
        : ref.watch(countryEconomyNewsProvider('WORLD'));
    final fx = ref.watch(fxRatesProvider).valueOrNull;
    ref.watch(marketRefreshProvider);
    final currency = ref.watch(userFinanceProvider).valueOrNull?.currency ?? '';
    final news = _resolveNewsFeed(
      newsAsync.valueOrNull,
      worldNewsAsync?.valueOrNull,
    );

    final header = <Widget>[
      _FxRatesCard(l10n: l10n, isFr: isFr, fx: fx, currency: currency),
      const SizedBox(height: 14),
    ];

    return economyAsync.when(
      loading: () => ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          8,
          AppSpacing.pagePadding,
          24,
        ),
        children: [
          ...header,
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          const SizedBox(height: 18),
          _EconomyNewsSection(
            l10n: l10n,
            isFr: isFr,
            feed: news,
            onRefresh: () => ref.invalidate(marketRefreshProvider),
          ),
        ],
      ),
      error: (_, __) => ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          8,
          AppSpacing.pagePadding,
          24,
        ),
        children: [
          ...header,
          Text(l10n.ecoIndicatorsUnavailable),
          const SizedBox(height: 18),
          _EconomyNewsSection(
            l10n: l10n,
            isFr: isFr,
            feed: news,
            onRefresh: () => ref.invalidate(marketRefreshProvider),
          ),
        ],
      ),
      data: (data) {
        final indicators = data.indicators;
        final summary = data.summary?[locale.substring(0, 2)] ??
            data.summary?['fr'] ??
            data.summary?['en'] ??
            '';

        final inflation = indicators['inflation'];
        final rate = indicators['policy_rate'];
        final benchmark = indicators['savings_benchmark'];
        final newsFeed = _resolveNewsFeed(
          newsAsync.valueOrNull,
          worldNewsAsync?.valueOrNull,
        );

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            8,
            AppSpacing.pagePadding,
            24,
          ),
          children: [
            ...header,
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    emoji: '📉',
                    label: l10n.ecoMetricInflation,
                    value: inflation != null
                        ? '${inflation.value} ${inflation.unit}'
                        : '—',
                    subtext: inflation?.source ?? '',
                    color: AppColors.terracotta,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    emoji: '🏛️',
                    label: l10n.ecoMetricPolicyRate,
                    value: rate != null ? '${rate.value} ${rate.unit}' : '—',
                    subtext: rate?.source ?? '',
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (benchmark != null) ...[
              _MetricCard(
                emoji: '🌱',
                label: l10n.ecoMetricSavingsBenchmark,
                value: '${benchmark.value} ${benchmark.unit}',
                subtext: benchmark.source,
                color: AppColors.accent,
              ),
              const SizedBox(height: 14),
            ],
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        l10n.ecoWhatItMeans,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    summary,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.ecoBenchmarkDisclaimer(inflation?.date ?? '2026'),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _EconomyNewsSection(
              l10n: l10n,
              isFr: isFr,
              feed: newsFeed,
              onRefresh: () => ref.invalidate(marketRefreshProvider),
            ),
          ],
        );
      },
    );
  }

  EconomyNewsFeed _resolveNewsFeed(
    EconomyNewsFeed? primary,
    EconomyNewsFeed? world,
  ) {
    if (primary != null && primary.items.isNotEmpty) return primary;
    if (world != null && world.items.isNotEmpty) return world;
    return primary ?? world ?? EconomyNewsFeed.empty;
  }

  Widget _buildCoachTab({
    required AppLocalizations l10n,
    required InsightState state,
    required InsightText? activeAdvice,
    required List<InsightText> history,
  }) {
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
        if (!mounted) return;
        await showSiphoAiErrorSnackBar(
          context,
          error,
          l10n,
          fallback: l10n.homeInsightError,
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        8,
        AppSpacing.pagePadding,
        24,
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
              state.loading ? l10n.homeInsightWorking : l10n.coachEmptyBody,
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
                fontSize: 22,
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
                fontSize: 16,
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
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.coachActionTitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activeAdvice.actionStep,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SiphoButton3D(
                  label: l10n.coachRefreshCta,
                  color: AppColors.surface,
                  textColor: AppColors.primaryDark,
                  onPressed: state.loading ? null : requestAdvice,
                ),
              ),
            ],
          ),
        ],
        if (activeAdvice == null) ...[
          const SizedBox(height: 12),
          SiphoButton3D(
            label: state.loading ? l10n.homeInsightWorking : l10n.coachGenerateCta,
            onPressed: state.loading ? null : requestAdvice,
          ),
        ],
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.subtext,
    required this.color,
  });

  final String emoji;
  final String label;
  final String value;
  final String subtext;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          if (subtext.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtext,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CountrySelectorBadge extends StatelessWidget {
  const _CountrySelectorBadge({
    required this.currentCountry,
    required this.onChanged,
  });

  final String currentCountry;
  final ValueChanged<String> onChanged;

  static const _countries = [
    ('CA', '🇨🇦 CA'),
    ('FR', '🇫🇷 FR'),
    ('CM', '🇨🇲 CM'),
    ('CI', '🇨🇮 CI'),
    ('SN', '🇸🇳 SN'),
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _flagFor(currentCountry),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              currentCountry.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
      itemBuilder: (context) => [
        for (final c in _countries)
          PopupMenuItem<String>(
            value: c.$1,
            child: Text(
              c.$2,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }

  String _flagFor(String code) {
    switch (code.toUpperCase()) {
      case 'CA':
        return '🇨🇦';
      case 'FR':
        return '🇫🇷';
      case 'CM':
        return '🇨🇲';
      case 'CI':
        return '🇨🇮';
      case 'SN':
        return '🇸🇳';
      default:
        return '🌍';
    }
  }
}

class _FxRatesCard extends StatelessWidget {
  const _FxRatesCard({
    required this.l10n,
    required this.isFr,
    required this.fx,
    required this.currency,
  });

  final AppLocalizations l10n;
  final bool isFr;
  final FxRates? fx;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final lines = _lines();
    final asOf = fx?.asOf;
    final dated = asOf == null
        ? ''
        : '${asOf.year}-${asOf.month.toString().padLeft(2, '0')}-${asOf.day.toString().padLeft(2, '0')}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.ecoFxTitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.ecoFxBlurb,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          if (lines.isEmpty)
            Text(
              l10n.ecoFxEmpty,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            )
          else
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  line,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
          if (dated.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              dated,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<String> _lines() {
    final rates = fx;
    if (rates == null) return const [];
    final preferred = <String>[
      currency.toUpperCase(),
      'CAD',
      'EUR',
      'XOF',
      'XAF',
      'GBP',
    ];
    final seen = <String>{};
    final lines = <String>[];
    for (final code in preferred) {
      if (code.length != 3 || seen.contains(code) || code == rates.base) {
        continue;
      }
      final value = rates.rateTo(from: rates.base, to: code);
      if (value == null) continue;
      seen.add(code);
      lines.add('1 ${rates.base} = ${_format(value)} $code');
      if (lines.length == 4) break;
    }
    return lines;
  }

  String _format(double value) {
    final digits = value >= 100 ? 2 : 4;
    final raw = value.toStringAsFixed(digits);
    return isFr ? raw.replaceAll('.', ',') : raw;
  }
}

class _EconomyNewsSection extends StatelessWidget {
  const _EconomyNewsSection({
    required this.l10n,
    required this.isFr,
    required this.feed,
    this.onRefresh,
  });

  final AppLocalizations l10n;
  final bool isFr;
  final EconomyNewsFeed feed;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.ecoNewsTitle,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.ecoNewsSubtitle,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        if (feed.items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.soft,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              l10n.ecoNewsEmpty,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                height: 1.3,
                color: AppColors.primaryDark,
              ),
            ),
          )
        else
          for (final item in feed.items) ...[
            _EconomyNewsCard(l10n: l10n, isFr: isFr, item: item),
            const SizedBox(height: 20),
          ],
        Text(
          l10n.ecoNewsFooter,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        SiphoButton3D(
          label: l10n.ecoNewsRefresh,
          onPressed: onRefresh,
          color: AppColors.primaryDark,
          shadowColor: AppColors.primaryDark,
        ),
      ],
    );
  }
}

class _EconomyNewsCard extends StatelessWidget {
  const _EconomyNewsCard({
    required this.l10n,
    required this.isFr,
    required this.item,
  });

  final AppLocalizations l10n;
  final bool isFr;
  final EconomyNewsItem item;

  @override
  Widget build(BuildContext context) {
    final when = item.publishedAt?.toLocal();
    final date = when == null
        ? ''
        : DateFormat.yMMMd(isFr ? 'fr' : 'en').format(when);
    final source = item.source.trim();
    final sourceLine = [
      if (source.isNotEmpty) source,
      if (date.isNotEmpty) date,
    ].join(' · ');
    final quote = item.takeaway.trim().isEmpty
        ? ''
        : l10n.ecoNewsSiphoQuote(item.takeaway.trim());

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: item.url.isEmpty
            ? null
            : () async {
                final uri = Uri.tryParse(item.url);
                if (uri == null) return;
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.soft,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: AppColors.primaryDark,
                ),
              ),
              if (quote.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  quote,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    height: 1.3,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
              if (sourceLine.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  sourceLine,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    height: 1.3,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
