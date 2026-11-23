import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/features/economy/domain/economy_data.dart';
import 'package:sipho/features/economy/domain/economy_news.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';

final economyRepositoryProvider = Provider<EconomyRepository>((ref) {
  return EconomyRepository(ref.watch(firestoreProvider));
});

/// Provides economic indicators for [countryCode] with official dated benchmarks
/// as fallback when the Firestore live feed is not configured.
final countryEconomyProvider =
    StreamProvider.family<EconomyData, String>((ref, countryCode) {
  final code = countryCode.toUpperCase().trim();
  final repo = ref.watch(economyRepositoryProvider);
  return repo.watchCountryEconomyWithFallback(code.isEmpty ? 'CA' : code);
});

/// Local economic headlines for [countryCode] (`economyNews/{code}`).
final countryEconomyNewsProvider =
    StreamProvider.family<EconomyNewsFeed, String>((ref, countryCode) {
  final code = countryCode.toUpperCase().trim();
  final resolved = code.isEmpty ? 'CA' : code;
  return ref.watch(economyRepositoryProvider).watchEconomyNews(resolved);
});

/// Automatically resolves the economy data for the currently authenticated user's country.
final userEconomyProvider = StreamProvider<EconomyData>((ref) {
  final finance = ref.watch(userFinanceProvider).valueOrNull;
  final country = (finance?.countryCode.isNotEmpty ?? false)
      ? finance!.countryCode
      : 'CA';
  return ref.watch(countryEconomyProvider(country).stream);
});

/// Local headlines for the signed-in user's country (`economyNews/{code}`).
final userEconomyNewsProvider = StreamProvider<EconomyNewsFeed>((ref) {
  final finance = ref.watch(userFinanceProvider).valueOrNull;
  final country = (finance?.countryCode.isNotEmpty ?? false)
      ? finance!.countryCode
      : 'CA';
  return ref.watch(countryEconomyNewsProvider(country).stream);
});

/// One refresh per session: writes `fx/latest` and today's `economyNews` on the server.
final marketRefreshProvider = FutureProvider<void>((ref) async {
  try {
    await ref.read(economyRepositoryProvider).refreshMarketData();
  } catch (_) {
    // The screen keeps showing whatever Firestore already has.
  }
});

class EconomyRepository {
  final FirebaseFirestore _firestore;

  EconomyRepository(this._firestore);

  Stream<EconomyData?> watchCountryEconomy(String countryCode) {
    return _firestore.doc('economy/$countryCode').snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return EconomyData.fromJson(doc.data()!);
    });
  }

  Stream<EconomyData> watchCountryEconomyWithFallback(String countryCode) {
    final code = countryCode.toUpperCase();
    return _firestore.doc('economy/$code').snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return EconomyData.fromJson(doc.data()!);
      }
      return defaultEconomyData(code);
    });
  }

  Stream<EconomyNewsFeed> watchEconomyNews(String countryCode) {
    final code = countryCode.toUpperCase();
    return _firestore.doc('economyNews/$code').snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return EconomyNewsFeed.empty;
      return EconomyNewsFeed.fromJson(doc.data()!);
    });
  }

  /// Asks the staging/prod function `refreshMarketData` to fill FX and headlines.
  Future<void> refreshMarketData() async {
    final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
        .httpsCallable('refreshMarketData');
    await callable.call();
  }

  static EconomyData defaultEconomyData(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'CA':
        return EconomyData(
          countryCode: 'CA',
          indicators: const {
            'inflation': IndicatorItem(
              value: 2.0,
              unit: '%',
              source: 'Statistique Canada (IPC)',
              date: '2026-10',
            ),
            'policy_rate': IndicatorItem(
              value: 3.75,
              unit: '%',
              source: 'Banque du Canada',
              date: '2026-10',
            ),
            'savings_benchmark': IndicatorItem(
              value: 3.25,
              unit: '%',
              source: 'Comptes d\'épargne CELI',
              date: '2026-10',
            ),
          },
          summary: const {
            'fr':
                'L\'inflation se maintient proche de la cible de 2 %. La baisse progressive des taux allège le crédit mais invite à optimiser ses comptes d\'épargne CELI/REER.',
            'en':
                'Inflation sits near the 2% target. Rate reductions ease borrowing costs while encouraging active optimization of TFSA/RRSP accounts.',
          },
          updatedAt: DateTime(2026, 11, 1),
        );
      case 'FR':
        return EconomyData(
          countryCode: 'FR',
          indicators: const {
            'inflation': IndicatorItem(
              value: 1.8,
              unit: '%',
              source: 'Insee (IPC harmonisé)',
              date: '2026-10',
            ),
            'policy_rate': IndicatorItem(
              value: 3.25,
              unit: '%',
              source: 'Banque Centrale Européenne',
              date: '2026-10',
            ),
            'savings_benchmark': IndicatorItem(
              value: 3.0,
              unit: '%',
              source: 'Taux officiel Livret A',
              date: '2026-10',
            ),
          },
          summary: const {
            'fr':
                'L\'inflation ralentit en France. Le Livret A et le LEP garantissent un rendement net d\'impôt protecteur pour ton épargne de précaution.',
            'en':
                'Inflation is slowing in France. Regulated accounts (Livret A, LEP) offer solid tax-free shields for emergency cash reserves.',
          },
          updatedAt: DateTime(2026, 11, 1),
        );
      case 'CM':
        return EconomyData(
          countryCode: 'CM',
          indicators: const {
            'inflation': IndicatorItem(
              value: 4.4,
              unit: '%',
              source: 'INS Cameroun / BEAC',
              date: '2026-10',
            ),
            'policy_rate': IndicatorItem(
              value: 5.0,
              unit: '%',
              source: 'BEAC (Taux d\'Intérêt des Appels d\'Offres)',
              date: '2026-10',
            ),
            'savings_benchmark': IndicatorItem(
              value: 3.5,
              unit: '%',
              source: 'Rémunération plancher épargne bancaire',
              date: '2026-10',
            ),
          },
          summary: const {
            'fr':
                'Tensions persistantes sur les prix des denrées alimentaires et du transport en zone CEMAC. Privilégier les achats groupés et les circuits courts.',
            'en':
                'Persistent pressure on food and transport in the CEMAC region. Prioritise group buying and local markets to preserve purchasing power.',
          },
          updatedAt: DateTime(2026, 11, 1),
        );
      case 'CI':
        return EconomyData(
          countryCode: 'CI',
          indicators: const {
            'inflation': IndicatorItem(
              value: 3.6,
              unit: '%',
              source: 'INS Côte d\'Ivoire / BCEAO',
              date: '2026-10',
            ),
            'policy_rate': IndicatorItem(
              value: 5.5,
              unit: '%',
              source: 'BCEAO (Taux directeur minimum)',
              date: '2026-10',
            ),
            'savings_benchmark': IndicatorItem(
              value: 3.5,
              unit: '%',
              source: 'Comptes épargne et tontines formelles',
              date: '2026-10',
            ),
          },
          summary: const {
            'fr':
                'Croissance soutenue en Côte d\'Ivoire avec une inflation modérée. Bien calibrer ses charges fixes urbaines pour préserver sa capacité d\'épargne.',
            'en':
                'Resilient growth in Côte d\'Ivoire with moderate inflation. Streamline urban fixed charges to safeguard your monthly savings capacity.',
          },
          updatedAt: DateTime(2026, 11, 1),
        );
      case 'SN':
        return EconomyData(
          countryCode: 'SN',
          indicators: const {
            'inflation': IndicatorItem(
              value: 3.4,
              unit: '%',
              source: 'ANSD Sénégal / BCEAO',
              date: '2026-10',
            ),
            'policy_rate': IndicatorItem(
              value: 5.5,
              unit: '%',
              source: 'BCEAO',
              date: '2026-10',
            ),
            'savings_benchmark': IndicatorItem(
              value: 3.5,
              unit: '%',
              source: 'Épargne bancaire UEMOA',
              date: '2026-10',
            ),
          },
          summary: const {
            'fr':
                'Stabilisation de l\'indice des prix au Sénégal. Surveiller particulièrement les dépenses d\'énergie et anticiper les fêtes de famille dans son budget.',
            'en':
                'Price levels are stabilizing in Senegal. Keep an eye on utilities and build buffers for family events well ahead of time.',
          },
          updatedAt: DateTime(2026, 11, 1),
        );
      default:
        return EconomyData(
          countryCode: 'GENERIC',
          indicators: const {
            'inflation': IndicatorItem(
              value: 3.2,
              unit: '%',
              source: 'Moyenne internationale (FMI)',
              date: '2026-10',
            ),
            'policy_rate': IndicatorItem(
              value: 4.0,
              unit: '%',
              source: 'Indice moyen banques centrales',
              date: '2026-10',
            ),
            'savings_benchmark': IndicatorItem(
              value: 3.0,
              unit: '%',
              source: 'Comptes d\'épargne sans risque',
              date: '2026-10',
            ),
          },
          summary: const {
            'fr':
                'L\'inflation internationale se normalise. Suivre ses dépenses au centime près chaque jour reste la clé universelle de la sérénité.',
            'en':
                'Global inflation is normalizing. Tracking spending down to the cent every day remains the universal foundation for financial peace.',
          },
          updatedAt: DateTime(2026, 11, 1),
        );
    }
  }
}
