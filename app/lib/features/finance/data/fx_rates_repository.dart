import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';

/// FX rates document `fx/latest`: map of currency → rate vs a base (usually USD or CAD).
class FxRates {
  const FxRates({
    required this.base,
    required this.rates,
    this.asOf,
  });

  final String base;
  final Map<String, double> rates;
  final DateTime? asOf;

  /// How many units of [to] equal 1 unit of [from], or null when a rate is missing.
  double? rateTo({required String from, required String to}) {
    final a = from.toUpperCase();
    final b = to.toUpperCase();
    if (a == b) return 1;
    final rateFrom = a == base ? 1.0 : rates[a];
    final rateTo = b == base ? 1.0 : rates[b];
    if (rateFrom == null || rateTo == null || rateFrom == 0) return null;
    return rateTo / rateFrom;
  }

  /// Converts [amountCents] from [from] into [to] using rates vs [base].
  /// Returns null when a rate is missing.
  int? convertCents({
    required int amountCents,
    required String from,
    required String to,
  }) {
    final rate = rateTo(from: from, to: to);
    if (rate == null) return null;
    return (amountCents * rate).round();
  }
}

final fxRatesProvider = StreamProvider<FxRates?>((ref) {
  return ref.watch(firestoreProvider).doc('fx/latest').snapshots().map((snap) {
    final data = snap.data();
    if (data == null) return null;
    final rawRates = data['rates'];
    if (rawRates is! Map) return null;
    final rates = <String, double>{};
    rawRates.forEach((key, value) {
      if (value is num) rates[key.toString().toUpperCase()] = value.toDouble();
    });
    if (rates.isEmpty) return null;
    final asOf = data['asOf'];
    return FxRates(
      base: ((data['base'] as String?) ?? 'USD').toUpperCase(),
      rates: rates,
      asOf: asOf is Timestamp ? asOf.toDate() : null,
    );
  });
});
