import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/features/economy/data/economy_repository.dart';
import 'package:sipho/features/economy/domain/economy_data.dart';
import 'package:sipho/features/economy/domain/economy_news.dart';
import 'package:sipho/features/finance/data/fx_rates_repository.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';

/// Country economy snapshot on Home: inflation / rate chips + top local headline.
class HomeCountryEconomyCard extends ConsumerWidget {
  const HomeCountryEconomyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isFr = Localizations.localeOf(context).languageCode.startsWith('fr');
    final finance = ref.watch(userFinanceProvider).valueOrNull;
    final country = (finance?.countryCode.isNotEmpty ?? false)
        ? finance!.countryCode.toUpperCase()
        : 'CA';
    final economy = ref.watch(userEconomyProvider).valueOrNull;
    final news = ref.watch(userEconomyNewsProvider).valueOrNull;
    final fx = ref.watch(fxRatesProvider).valueOrNull;
    ref.watch(marketRefreshProvider);
    final headline = _headline(news);
    final inflation = _indicator(economy, const ['inflation', 'cpi']);
    final rate = _indicator(economy, const ['policy_rate', 'keyRate', 'key_rate']);
    final fxLine = _fxLine(l10n, fx, finance?.currency ?? '', isFr: isFr);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/economy'),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: AppColors.economyCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _flagFor(country),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.homeCountryEconomyTitle(country),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  Text(
                    l10n.homeEconomyRead,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (inflation != null || rate != null || fxLine != null) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (inflation != null)
                      _Chip(
                        label: l10n.homeEconomyInflationChip(
                          _formatValue(inflation, isFr: isFr),
                        ),
                      ),
                    if (rate != null)
                      _Chip(
                        label: l10n.homeEconomyRateChip(
                          _formatValue(rate, isFr: isFr),
                        ),
                      ),
                    if (fxLine != null) _Chip(label: fxLine),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              Text(
                headline != null
                    ? '${headline.emoji} ${headline.title}'
                    : (economy?.summary?[isFr ? 'fr' : 'en'] ??
                        l10n.homeEconomyTitle),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: AppColors.primaryDark,
                ),
              ),
              if (headline != null && headline.takeaway.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  headline.takeaway,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: AppColors.textSecondary,
                  ),
                ),
              ] else if (headline == null) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.homeEconomyImpact,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String? _fxLine(
    AppLocalizations l10n,
    FxRates? fx,
    String currency, {
    required bool isFr,
  }) {
    if (fx == null) return null;
    final quote = currency.toUpperCase() == fx.base || currency.trim().length != 3
        ? 'EUR'
        : currency.toUpperCase();
    if (quote == fx.base) return null;
    final value = fx.rateTo(from: fx.base, to: quote);
    if (value == null) return null;
    final digits = value >= 100 ? 2 : 4;
    final raw = value.toStringAsFixed(digits);
    final formatted = isFr ? raw.replaceAll('.', ',') : raw;
    return l10n.homeFxChip(fx.base, formatted, quote);
  }

  EconomyNewsItem? _headline(EconomyNewsFeed? feed) {
    if (feed == null || feed.isEmpty) return null;
    for (final item in feed.items) {
      if (item.title.trim().isNotEmpty) return item;
    }
    return null;
  }

  IndicatorItem? _indicator(EconomyData? data, List<String> keys) {
    if (data == null) return null;
    for (final key in keys) {
      final item = data.indicators[key];
      if (item != null) return item;
    }
    return null;
  }

  String _formatValue(IndicatorItem item, {required bool isFr}) {
    final value = item.value;
    final raw = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value
            .toStringAsFixed(2)
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), '');
    final formatted = isFr ? raw.replaceAll('.', ',') : raw;
    return '$formatted${item.unit}';
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
      case 'US':
        return '🇺🇸';
      case 'GB':
      case 'UK':
        return '🇬🇧';
      default:
        return '🌍';
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
