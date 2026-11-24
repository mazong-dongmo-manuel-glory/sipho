/// Pack pays Firestore `countries/{code}` (ou `generic`).
class CountryPack {
  final String code;
  final String name;
  final String currency;
  final List<String> defaultFixedExpenses;

  const CountryPack({
    required this.code,
    required this.name,
    required this.currency,
    this.defaultFixedExpenses = const [],
  });

  factory CountryPack.fromFirestore(String id, Map<String, dynamic> data) {
    final raw = data['defaultFixedExpenses'];
    final ids = raw is List
        ? raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList()
        : const <String>[];
    return CountryPack(
      code: (data['code'] as String?)?.toUpperCase() ?? id.toUpperCase(),
      name: (data['name'] as String?)?.trim().isNotEmpty == true
          ? data['name'] as String
          : id,
      currency: (data['currency'] as String?)?.trim().isNotEmpty == true
          ? data['currency'] as String
          : 'CAD',
      defaultFixedExpenses: ids,
    );
  }
}

/// Libellé + emoji pour un id de charge fixe du pack.
({String labelFr, String labelEn, String emoji}) fixedExpenseMeta(String id) {
  return switch (id) {
    'rent' || 'logement' => (
        labelFr: 'Loyer',
        labelEn: 'Rent',
        emoji: '🏠',
      ),
    'internet' || 'internet_data' => (
        labelFr: 'Internet',
        labelEn: 'Internet',
        emoji: '📶',
      ),
    'electricity' || 'electricity_cie' || 'utilities' => (
        labelFr: 'Électricité',
        labelEn: 'Electricity',
        emoji: '💡',
      ),
    'water' || 'water_sodeci' => (
        labelFr: 'Eau',
        labelEn: 'Water',
        emoji: '💧',
      ),
    'phone' => (
        labelFr: 'Téléphone',
        labelEn: 'Phone',
        emoji: '📱',
      ),
    'groceries' || 'groceries_market' => (
        labelFr: 'Épicerie',
        labelEn: 'Groceries',
        emoji: '🛒',
      ),
    'transport' || 'transport_gbaka' => (
        labelFr: 'Transport',
        labelEn: 'Transport',
        emoji: '🚌',
      ),
    'insurance' => (
        labelFr: 'Assurance',
        labelEn: 'Insurance',
        emoji: '🛡️',
      ),
    'family_support' || 'family' => (
        labelFr: 'Soutien famille',
        labelEn: 'Family support',
        emoji: '💌',
      ),
    _ => (
        labelFr: id.replaceAll('_', ' '),
        labelEn: id.replaceAll('_', ' '),
        emoji: '📌',
      ),
  };
}

/// Fallback si Firestore `countries/*` est vide / hors ligne.
const kFallbackCountryPacks = <CountryPack>[
  CountryPack(
    code: 'CA',
    name: 'Canada',
    currency: 'CAD',
    defaultFixedExpenses: [
      'rent',
      'internet',
      'electricity',
      'phone',
      'groceries',
      'transport',
      'insurance',
    ],
  ),
  CountryPack(
    code: 'FR',
    name: 'France',
    currency: 'EUR',
    defaultFixedExpenses: [
      'rent',
      'internet',
      'electricity',
      'phone',
      'groceries',
      'transport',
      'insurance',
    ],
  ),
  CountryPack(
    code: 'CM',
    name: 'Cameroun',
    currency: 'XAF',
    defaultFixedExpenses: [
      'rent',
      'electricity',
      'internet',
      'phone',
      'groceries',
      'transport',
      'family_support',
    ],
  ),
  CountryPack(
    code: 'CI',
    name: "Côte d'Ivoire",
    currency: 'XOF',
    defaultFixedExpenses: [
      'rent',
      'electricity_cie',
      'water_sodeci',
      'internet_data',
      'phone',
      'groceries_market',
      'transport_gbaka',
      'family_support',
    ],
  ),
  CountryPack(
    code: 'SN',
    name: 'Sénégal',
    currency: 'XOF',
    defaultFixedExpenses: [
      'rent',
      'electricity',
      'internet',
      'phone',
      'groceries',
      'transport',
      'family_support',
    ],
  ),
  CountryPack(
    code: 'GENERIC',
    name: 'International',
    currency: 'USD',
    defaultFixedExpenses: [
      'rent',
      'internet',
      'utilities',
      'groceries',
      'transport',
      'insurance',
    ],
  ),
];
