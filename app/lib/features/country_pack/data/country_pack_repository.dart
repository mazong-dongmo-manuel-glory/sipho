import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/country_pack.dart';

final countryPackRepositoryProvider = Provider<CountryPackRepository>((ref) {
  return CountryPackRepository(FirebaseFirestore.instance);
});

class CountryPackRepository {
  final FirebaseFirestore _firestore;

  CountryPackRepository(this._firestore);

  Future<CountryPack?> getCountryPack(String countryCode) async {
    final doc = await _firestore.doc('countries/$countryCode').get();
    if (!doc.exists || doc.data() == null) {
      // Fallback to generic
      final genericDoc = await _firestore.doc('countries/generic').get();
      if (!genericDoc.exists || genericDoc.data() == null) return null;
      return CountryPack.fromJson(genericDoc.data()!);
    }
    return CountryPack.fromJson(doc.data()!);
  }
}

