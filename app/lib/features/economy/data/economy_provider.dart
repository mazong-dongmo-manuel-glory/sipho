import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_profile_provider.dart';

class EconomyHeadline {
  final String title;
  final String? takeaway;
  final String? source;
  final String? dateLabel;

  const EconomyHeadline({
    required this.title,
    this.takeaway,
    this.source,
    this.dateLabel,
  });
}

class EconomyCard {
  final String title;
  final String? value;
  final String? source;
  final String? dateLabel;

  const EconomyCard({
    required this.title,
    this.value,
    this.source,
    this.dateLabel,
  });
}

class EconomySnapshot {
  final String countryCode;
  final String summary;
  final String? source;
  final List<EconomyHeadline> headlines;
  final List<EconomyCard> cards;
  final String fxBase;
  final Map<String, double> fxRates;
  final bool loading;
  final String? error;

  const EconomySnapshot({
    this.countryCode = 'CA',
    this.summary = '',
    this.source,
    this.headlines = const [],
    this.cards = const [],
    this.fxBase = 'EUR',
    this.fxRates = const {},
    this.loading = false,
    this.error,
  });

  EconomySnapshot copyWith({
    String? countryCode,
    String? summary,
    String? source,
    List<EconomyHeadline>? headlines,
    List<EconomyCard>? cards,
    String? fxBase,
    Map<String, double>? fxRates,
    bool? loading,
    String? error,
  }) {
    return EconomySnapshot(
      countryCode: countryCode ?? this.countryCode,
      summary: summary ?? this.summary,
      source: source ?? this.source,
      headlines: headlines ?? this.headlines,
      cards: cards ?? this.cards,
      fxBase: fxBase ?? this.fxBase,
      fxRates: fxRates ?? this.fxRates,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class EconomyNotifier extends StateNotifier<EconomySnapshot> {
  EconomyNotifier(this._ref) : super(const EconomySnapshot(loading: true)) {
    _bind();
  }

  final Ref _ref;
  final _subs = <StreamSubscription>[];

  void _bind() {
    void reload() {
      for (final s in _subs) {
        s.cancel();
      }
      _subs.clear();

      final uid = _ref.read(authUidProvider);
      if (uid == null) {
        state = const EconomySnapshot();
        return;
      }
      final country = _ref.read(userProfileProvider).countryCode.toUpperCase();
      final locale = _ref.read(userProfileProvider).locale;
      final fr = locale.toLowerCase().startsWith('fr');
      state = state.copyWith(loading: true, countryCode: country, error: null);

      final db = _ref.read(firestoreProvider);
      _subs.add(db.doc('economy/$country').snapshots().listen((snap) {
        final data = snap.data();
        final summaryMap = data?['summary'];
        String summary = '';
        if (summaryMap is Map) {
          summary = (summaryMap[fr ? 'fr' : 'en'] ??
                  summaryMap['fr'] ??
                  summaryMap['en'] ??
                  '')
              .toString();
        } else if (data?['summary'] is String) {
          summary = data!['summary'] as String;
        }

        final cards = <EconomyCard>[];
        final rawCards = data?['dailyCards'] ?? data?['indicators'];
        if (rawCards is List) {
          for (final raw in rawCards.take(12)) {
            if (raw is! Map) continue;
            final title = (raw['title'] ??
                    raw['label'] ??
                    raw['name'] ??
                    raw['id'] ??
                    '')
                .toString();
            if (title.isEmpty) continue;
            final value = (raw['value'] ?? raw['display'] ?? raw['rate'])
                ?.toString();
            cards.add(EconomyCard(
              title: title,
              value: value,
              source: (raw['source'] as String?),
              dateLabel: (raw['asOf'] ?? raw['date'] ?? raw['updatedAt'])
                  ?.toString(),
            ));
          }
        }

        state = state.copyWith(
          summary: summary.isEmpty
              ? (fr
                  ? 'Les indicateurs officiels arrivent bientôt pour $country.'
                  : 'Official indicators for $country are on their way.')
              : summary,
          source: cards.isNotEmpty ? cards.first.source : null,
          cards: cards,
          loading: false,
        );
      }, onError: (e) {
        state = state.copyWith(loading: false, error: e.toString());
      }));

      _subs.add(db.doc('economyNews/$country').snapshots().listen((snap) {
        final items = snap.data()?['items'] ?? snap.data()?['headlines'];
        final headlines = <EconomyHeadline>[];
        if (items is List) {
          for (final raw in items.take(20)) {
            if (raw is! Map) continue;
            final title = (raw['title'] ?? raw['headline'] ?? '').toString();
            if (title.isEmpty) continue;
            headlines.add(EconomyHeadline(
              title: title,
              takeaway: (raw['takeaway'] ?? raw['summary'])?.toString(),
              source: (raw['source'] ?? raw['outlet'])?.toString(),
              dateLabel: (raw['publishedAt'] ?? raw['date'])?.toString(),
            ));
          }
        }
        state = state.copyWith(headlines: headlines, loading: false);
      }, onError: (_) {}));

      _subs.add(db.doc('fx/latest').snapshots().listen((snap) {
        final data = snap.data();
        final ratesRaw = data?['rates'];
        final rates = <String, double>{};
        if (ratesRaw is Map) {
          ratesRaw.forEach((k, v) {
            if (v is num) rates[k.toString()] = v.toDouble();
          });
        }
        state = state.copyWith(
          fxBase: (data?['base'] as String?) ?? 'EUR',
          fxRates: rates,
          loading: false,
        );
      }, onError: (_) {}));
    }

    _ref.listen(authUidProvider, (_, __) => reload(), fireImmediately: true);
    _ref.listen(userProfileProvider, (_, __) => reload());
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}

final economyProvider =
    StateNotifierProvider<EconomyNotifier, EconomySnapshot>((ref) {
  return EconomyNotifier(ref);
});
