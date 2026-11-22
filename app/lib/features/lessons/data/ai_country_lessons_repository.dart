import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/core/firebase/callable_data.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/lessons/domain/ai_country_lesson.dart';
import 'package:sipho/features/lessons/domain/country_lesson_catalog.dart';
import 'package:sipho/features/lessons/domain/country_lesson_catalog_extra.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';

final aiCountryLessonsRepositoryProvider =
    Provider<AiCountryLessonsRepository>((ref) {
  return AiCountryLessonsRepository(
    firestore: ref.watch(firestoreProvider),
    functions: FirebaseFunctions.instanceFor(region: 'us-central1'),
  );
});

/// Live map of AI lessons keyed by **slotId** for the signed-in user.
final aiCountryLessonsProvider =
    StreamProvider<Map<String, AiCountryLesson>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null || uid.isEmpty) {
    return Stream.value(const {});
  }
  final locale =
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return ref
      .watch(aiCountryLessonsRepositoryProvider)
      .watchAll(uid, preferredLocale: locale);
});

/// `users/{uid}/aiLessonsMeta/state` (lastTopicId, recentTopicIds, …).
final aiLessonsMetaProvider = StreamProvider<AiLessonsMeta>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null || uid.isEmpty) {
    return Stream.value(const AiLessonsMeta());
  }
  return ref.watch(aiCountryLessonsRepositoryProvider).watchMeta(uid);
});

/// Country slot units with AI content when the slot is filled.
final personalizedCountryUnitsProvider = Provider<List<CatalogUnit>>((ref) {
  final country = ref.watch(userFinanceProvider).valueOrNull?.countryCode;
  final ai = ref.watch(aiCountryLessonsProvider).valueOrNull ?? const {};
  final units = countryUnitsFor(country);
  return [
    for (final unit in units)
      CatalogUnit(
        id: unit.id,
        titleFr: unit.titleFr,
        titleEn: unit.titleEn,
        subtitle: unit.subtitle,
        bonusXp: unit.bonusXp,
        bonusSeeds: unit.bonusSeeds,
        lessons: [
          for (final lesson in unit.lessons)
            resolveCountryLesson(lesson, ai[lesson.id]),
        ],
      ),
  ];
});

/// Prefer AI content for a slot; fall back to path/catalog lessons.
CatalogLesson? playableLessonById(
  String id,
  Map<String, AiCountryLesson> ai,
) {
  final onlyAi = ai[id];
  if (onlyAi != null && onlyAi.isPlayable) {
    return onlyAi.toCatalogLesson(
      fallback: kCountryCatalogLessons.cast<CatalogLesson?>().firstWhere(
            (l) => l?.id == id,
            orElse: () => null,
          ),
    );
  }
  for (final lesson in kAllPlayableLessons) {
    if (lesson.id == id) return lesson;
  }
  return null;
}

class AiCountryLessonsRepository {
  AiCountryLessonsRepository({
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
  })  : _firestore = firestore,
        _functions = functions;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  Stream<Map<String, AiCountryLesson>> watchAll(
    String uid, {
    String preferredLocale = 'fr',
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('aiLessons')
        .snapshots()
        .map((snap) {
      final out = <String, AiCountryLesson>{};
      for (final doc in snap.docs) {
        final parsed = AiCountryLesson.fromJson(
          doc.id,
          doc.data(),
          preferredLocale: preferredLocale,
        );
        if (parsed.isPlayable) out[parsed.slotId] = parsed;
      }
      return out;
    });
  }

  Stream<AiLessonsMeta> watchMeta(String uid) {
    return _firestore
        .doc('users/$uid/aiLessonsMeta/state')
        .snapshots()
        .map((doc) => AiLessonsMeta.fromJson(doc.data()));
  }

  /// Fills one awardable [slotId] (or the first country slot if omitted).
  ///
  /// [forceNew] true → always regenerate; false → reuse existing personalized doc.
  Future<Map<String, dynamic>> ensureGenerated({
    String? slotId,
    bool forceNew = false,
  }) async {
    final callable = _functions.httpsCallable('generateCountryLessons');
    final result = await callable.call(<String, dynamic>{
      if (slotId != null && slotId.isNotEmpty) 'slotId': slotId,
      'forceNew': forceNew,
    });
    return callableDataMap(result.data);
  }

  /// Generates content for the first [limit] empty slots of [countryCode].
  Future<void> ensureEmptySlotsFilled({
    required String? countryCode,
    required Set<String> filledSlotIds,
    int limit = 3,
  }) async {
    final ids = countrySlotIdsFor(countryCode)
        .where(isCountrySlotId)
        .where((id) => !filledSlotIds.contains(id))
        .take(limit);
    for (final id in ids) {
      await ensureGenerated(slotId: id, forceNew: false);
    }
  }
}
