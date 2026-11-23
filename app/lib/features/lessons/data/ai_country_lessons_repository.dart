import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// UI language (`fr`|`en`) aligned with MaterialApp / device locale.
final appUiLanguageProvider = Provider<String>((ref) {
  return normalizeAppLanguage(
    WidgetsBinding.instance.platformDispatcher.locale.languageCode,
  );
});

/// Live map of AI lessons keyed by **slotId** for the signed-in user.
final aiCountryLessonsProvider =
    StreamProvider<Map<String, AiCountryLesson>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null || uid.isEmpty) {
    return Stream.value(const {});
  }
  final locale = ref.watch(appUiLanguageProvider);
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
  final uiLanguage = ref.watch(appUiLanguageProvider);
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
            resolveCountryLesson(
              lesson,
              ai[lesson.id],
              uiLanguage: uiLanguage,
            ),
        ],
      ),
  ];
});

/// Prefer AI content for a slot; fall back to path/catalog lessons.
CatalogLesson? playableLessonById(
  String id,
  Map<String, AiCountryLesson> ai, {
  String? uiLanguage,
}) {
  final onlyAi = ai[id];
  if (onlyAi != null &&
      onlyAi.isPlayable &&
      (uiLanguage == null ||
          uiLanguage.isEmpty ||
          appLanguagesMatch(onlyAi.locale, uiLanguage))) {
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

  /// Asks the server for the next lesson after the static path.
  /// Reuses the unfinished `gen_00N` document when one already exists.
  Future<Map<String, dynamic>> ensureNextGenerated({String? locale}) async {
    final callable = _functions.httpsCallable('generateNextLesson');
    final lang = locale == null || locale.isEmpty
        ? null
        : normalizeAppLanguage(locale);
    final result = await callable.call(<String, dynamic>{
      if (lang != null) 'locale': lang,
    });
    final data = result.data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return const {};
  }

  /// Fills one awardable [slotId] (or the first country slot if omitted).
  Future<Map<String, dynamic>> ensureGenerated({
    String? slotId,
    bool forceNew = false,
    String? locale,
  }) async {
    final callable = _functions.httpsCallable('generateCountryLessons');
    final lang = locale == null || locale.isEmpty
        ? null
        : normalizeAppLanguage(locale);
    final result = await callable.call(<String, dynamic>{
      if (slotId != null && slotId.isNotEmpty) 'slotId': slotId,
      'forceNew': forceNew,
      if (lang != null) 'locale': lang,
    });
    final data = result.data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return const {};
  }

  /// Generates content for the first [limit] empty / wrong-locale slots.
  Future<void> ensureEmptySlotsFilled({
    required String? countryCode,
    required Set<String> filledSlotIds,
    required Map<String, AiCountryLesson> lessonsBySlot,
    required String uiLanguage,
    int limit = 3,
  }) async {
    final lang = normalizeAppLanguage(uiLanguage);
    final ids = countrySlotIdsFor(countryCode).where(isCountrySlotId).where((id) {
      if (!filledSlotIds.contains(id)) return true;
      final existing = lessonsBySlot[id];
      if (existing == null || !existing.isPlayable) return true;
      return !appLanguagesMatch(existing.locale, lang);
    }).take(limit);
    for (final id in ids) {
      final mismatch = filledSlotIds.contains(id) &&
          !appLanguagesMatch(lessonsBySlot[id]?.locale, lang);
      await ensureGenerated(
        slotId: id,
        forceNew: mismatch,
        locale: lang,
      );
    }
  }
}
