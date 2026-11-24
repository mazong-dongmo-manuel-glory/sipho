import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../auth/data/user_profile_provider.dart';
import '../domain/country_pack.dart';

/// Packs pays depuis Firestore `countries/*` (hors `generic` dans la liste UI).
final countriesListProvider = StreamProvider<List<CountryPack>>((ref) {
  return ref.watch(firestoreProvider).collection('countries').snapshots().map((
    snap,
  ) {
    final packs = snap.docs
        .map((d) => CountryPack.fromFirestore(d.id, d.data()))
        .where((p) => p.code.toLowerCase() != 'generic')
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    if (packs.isEmpty) {
      return kFallbackCountryPacks
          .where((p) => p.code != 'GENERIC')
          .toList();
    }
    return packs;
  });
});

/// Pack du profil utilisateur, sinon `generic` / fallback CA.
final userCountryPackProvider = Provider<CountryPack>((ref) {
  final code = ref.watch(userProfileProvider).countryCode.toUpperCase();
  final asyncList = ref.watch(countriesListProvider);
  final packs = asyncList.valueOrNull ?? kFallbackCountryPacks;

  for (final p in packs) {
    if (p.code == code) return p;
  }
  for (final p in kFallbackCountryPacks) {
    if (p.code == code) return p;
  }
  return kFallbackCountryPacks.firstWhere(
    (p) => p.code == 'GENERIC',
    orElse: () => kFallbackCountryPacks.first,
  );
});
