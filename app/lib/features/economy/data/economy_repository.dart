import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/economy_data.dart';

final economyRepositoryProvider = Provider<EconomyRepository>((ref) {
  return EconomyRepository(FirebaseFirestore.instance);
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
}

