import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sipho/core/firebase/firebase_providers.dart';

part 'analytics_service.g.dart';

@riverpod
AnalyticsService analyticsService(AnalyticsServiceRef ref) =>
    AnalyticsService(ref.watch(firebaseAnalyticsProvider));

class AnalyticsService {
  AnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  Future<void> logLogin(String method) =>
      _analytics.logLogin(loginMethod: method);

  Future<void> logSignUp(String method) =>
      _analytics.logSignUp(signUpMethod: method);

  Future<void> logOnboardingComplete() =>
      _analytics.logTutorialComplete();

  Future<void> logExpenseAdded({
    required String category,
    required int amountCents,
    required String currency,
    required String source,
  }) =>
      _analytics.logEvent(
        name: 'expense_added',
        parameters: {
          'category': category,
          'amount_cents': amountCents,
          'currency': currency,
          'source': source,
        },
      );

  Future<void> logBudgetViewed() =>
      _analytics.logEvent(name: 'budget_viewed');

  Future<void> logLessonStarted(String lessonId) =>
      _analytics.logEvent(
        name: 'lesson_started',
        parameters: {'lesson_id': lessonId},
      );

  Future<void> logLessonCompleted({
    required String lessonId,
    required int score,
    required int xpEarned,
  }) =>
      _analytics.logEvent(
        name: 'lesson_completed',
        parameters: {
          'lesson_id': lessonId,
          'score': score,
          'xp_earned': xpEarned,
        },
      );

  Future<void> logStreakUpdated(int streakDays) =>
      _analytics.logEvent(
        name: 'streak_updated',
        parameters: {'streak_days': streakDays},
      );

  Future<void> logStreakLost() =>
      _analytics.logEvent(name: 'streak_lost');

  Future<void> logQuestCompleted(String questId) =>
      _analytics.logEvent(
        name: 'quest_completed',
        parameters: {'quest_id': questId},
      );

  Future<void> logChestOpened(String tier) =>
      _analytics.logEvent(
        name: 'chest_opened',
        parameters: {'tier': tier},
      );

  Future<void> logReceiptScanned({required bool success}) =>
      _analytics.logEvent(
        name: 'receipt_scanned',
        parameters: {'success': success},
      );

  Future<void> logFixedExpensePaid(String id) =>
      _analytics.logEvent(
        name: 'fixed_expense_paid',
        parameters: {'id': id},
      );

  Future<void> logShopPurchase({
    required String itemId,
    required int priceSeedsOrCents,
    required String currency,
  }) =>
      _analytics.logPurchase(
        currency: currency,
        value: priceSeedsOrCents / 100.0,
        items: [AnalyticsEventItem(itemId: itemId)],
      );

  Future<void> logScreenView(String screenName) =>
      _analytics.logScreenView(screenName: screenName);
}
