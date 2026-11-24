import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'scaffold_with_nav_bar.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/presentation/life_income_screen.dart';
import '../features/onboarding/presentation/nest_swipe_screen.dart';
import '../features/onboarding/presentation/nest_amount_screen.dart';
import '../features/onboarding/presentation/ready_screen.dart';
import '../features/onboarding/presentation/notifications_permission_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/home/presentation/home_variant_screen.dart';
import '../features/home/presentation/home_variants_hub_screen.dart';
import '../features/expenses/presentation/expenses_screen.dart';
import '../features/expenses/presentation/expenses_variant_screen.dart';
import '../features/expenses/presentation/add_expense_sheet.dart';
import '../features/expenses/presentation/scan_screen.dart';
import '../features/expenses/presentation/validate_receipt_screen.dart';
import '../features/fixed_expenses/presentation/socle_screen.dart';
import '../features/budget/presentation/budgets_screen.dart';
import '../features/budget/presentation/charts_screen.dart';
import '../features/lessons/presentation/learn_screen.dart';
import '../features/lessons/presentation/quiz_screen.dart';
import '../features/lessons/presentation/lesson_done_screen.dart';
import '../features/lessons/presentation/lesson_steps_screen.dart';
import '../features/gamification/presentation/streak_screen.dart';
import '../features/gamification/presentation/chest_screen.dart';
import '../features/leaderboard/presentation/leaderboard_screen.dart';
import '../features/leaderboard/presentation/league_extra_screens.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/badges_screen.dart';
import '../features/profile/presentation/badge_earned_screen.dart';
import '../features/profile/presentation/goals_screen.dart';
import '../features/profile/presentation/milestone_screen.dart';
import '../features/profile/presentation/public_profile_screen.dart';
import '../features/shop/presentation/shop_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/insights/presentation/insights_screen.dart';
import '../features/recap/presentation/recap_screen.dart';
import '../features/social/presentation/contacts_screen.dart';
import '../features/social/presentation/friends_screen.dart';
import '../features/economy/presentation/economy_screen.dart';
import '../features/economy/presentation/economy_extra_screens.dart';
import '../features/tools/presentation/simulators_screen.dart';
import '../features/tools/presentation/family_support_screen.dart';
import '../features/tools/presentation/travel_mode_screen.dart';
import '../features/subscriptions/presentation/subscriptions_screen.dart';
import '../features/subscriptions/presentation/subscription_trimmed_screen.dart';
import '../features/expenses/presentation/expense_reward_screen.dart';
import '../features/gamification/presentation/streak_help_screen.dart';
import '../features/platform/presentation/android_chrome_screen.dart';
import '../features/platform/presentation/locale_preview_screen.dart';
import '../core/theme/sipho_theme.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter siphoRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(
      path: '/onboarding/life',
      builder: (_, __) => const LifeIncomeScreen(),
    ),
    GoRoute(path: '/onboarding/nest', builder: (_, __) => const NestSwipeScreen()),
    GoRoute(
      path: '/onboarding/nest/amount',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? const {};
        return NestAmountScreen(
          id: extra['id'] ?? 'rent',
          name: extra['name'] ?? 'Loyer',
          emoji: extra['emoji'] ?? '🏠',
        );
      },
    ),
    GoRoute(path: '/onboarding/ready', builder: (_, __) => const ReadyScreen()),
    GoRoute(
      path: '/onboarding/notifications',
      builder: (_, __) => const NotificationsPermissionScreen(),
    ),
    GoRoute(
      path: '/expenses/add',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (_, __) => const MaterialPage(
        fullscreenDialog: true,
        child: AddExpenseSheet(),
      ),
    ),
    GoRoute(
      path: '/expenses/scan',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ScanScreen(),
    ),
    GoRoute(
      path: '/expenses/validate',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? const {};
        return ValidateReceiptScreen(parsed: extra);
      },
    ),
    GoRoute(
      path: '/expenses/empty',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) =>
          const ExpensesVariantScreen(variant: ExpensesVariant.empty),
    ),
    GoRoute(
      path: '/expenses/error',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) =>
          const ExpensesVariantScreen(variant: ExpensesVariant.error),
    ),
    GoRoute(
      path: '/expenses/loading',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) =>
          const ExpensesVariantScreen(variant: ExpensesVariant.loading),
    ),
    GoRoute(
      path: '/fixed-expenses',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const SocleScreen(),
    ),
    GoRoute(
      path: '/budget',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const BudgetsScreen(),
    ),
    GoRoute(
      path: '/charts',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ChartsScreen(),
    ),
    GoRoute(
      path: '/charts/days',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ChartsScreen(view: ChartsView.days),
    ),
    GoRoute(
      path: '/charts/six-months',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ChartsScreen(view: ChartsView.sixMonths),
    ),
    GoRoute(
      path: '/quiz',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) {
        final extra = state.extra as Map<String, String>? ?? const {};
        return QuizScreen(
          lessonId: extra['id'] ?? 'emergency_fund',
          title: extra['title'] ?? 'Un coussin pour les imprévus',
        );
      },
    ),
    GoRoute(
      path: '/quiz/correct',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const QuizScreen(startCorrect: true),
    ),
    GoRoute(
      path: '/lesson/card',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? const {};
        return LessonStepsScreen(
          kind: LessonStepKind.card,
          lessonId: (extra['id'] as String?) ?? 'emergency_fund',
          title: (extra['title'] as String?) ?? 'Un coussin pour les imprévus',
        );
      },
    ),
    GoRoute(
      path: '/lesson/true-false',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? const {};
        return LessonStepsScreen(
          kind: LessonStepKind.trueFalse,
          lessonId: (extra['id'] as String?) ?? 'emergency_fund',
          title: (extra['title'] as String?) ?? 'Un coussin pour les imprévus',
        );
      },
    ),
    GoRoute(
      path: '/lesson/simulation',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? const {};
        return LessonStepsScreen(
          kind: LessonStepKind.simulation,
          lessonId: (extra['id'] as String?) ?? 'emergency_fund',
          title: (extra['title'] as String?) ?? 'Un coussin pour les imprévus',
        );
      },
    ),
    GoRoute(
      path: '/lesson-done',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? const {};
        return LessonDoneScreen(
          lessonId: (extra['lessonId'] as String?) ?? 'emergency_fund',
          xp: (extra['xp'] as int?) ?? 30,
          perfect: (extra['perfect'] as bool?) ?? true,
          durationSeconds: (extra['durationSeconds'] as int?) ?? 134,
        );
      },
    ),
    GoRoute(
      path: '/streak',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const StreakScreen(),
    ),
    GoRoute(
      path: '/chest',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) {
        final opened = state.uri.queryParameters['opened'] == '1';
        return ChestScreen(initialOpened: opened);
      },
    ),
    GoRoute(
      path: '/chest/opened',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ChestScreen(initialOpened: true),
    ),
    GoRoute(
      path: '/shop',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ShopScreen(),
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/insights',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const InsightsScreen(),
    ),
    GoRoute(
      path: '/recap',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) {
        final page = int.tryParse(state.uri.queryParameters['page'] ?? '') ?? 0;
        return RecapScreen(initialPage: page);
      },
    ),
    GoRoute(
      path: '/badges',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const BadgesScreen(),
    ),
    GoRoute(
      path: '/badges/earned',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const BadgeEarnedScreen(),
    ),
    GoRoute(
      path: '/goals',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const GoalsScreen(),
    ),
    GoRoute(
      path: '/goals/empty',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const GoalsScreen(empty: true),
    ),
    GoRoute(
      path: '/goals/milestone',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const MilestoneScreen(),
    ),
    GoRoute(
      path: '/profile/public',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const PublicProfileScreen(),
    ),
    GoRoute(
      path: '/friends',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const FriendsScreen(),
    ),
    GoRoute(
      path: '/friends/contacts',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ContactsScreen(),
    ),
    GoRoute(
      path: '/economy',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const EconomyScreen(),
    ),
    GoRoute(
      path: '/economy/history',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const EcoCardHistoryScreen(),
    ),
    GoRoute(
      path: '/economy/unavailable',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const EcoUnavailableScreen(),
    ),
    GoRoute(
      path: '/economy/news',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const NewsArchivesScreen(),
    ),
    GoRoute(
      path: '/economy/quiz',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const EcoQuizScreen(),
    ),
    GoRoute(
      path: '/economy/alerts',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const EcoAlertsScreen(),
    ),
    GoRoute(
      path: '/simulators',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const SimulatorsScreen(),
    ),
    GoRoute(
      path: '/simulators/retirement',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const SimulatorsScreen(kind: SimulatorKind.retirement),
    ),
    GoRoute(
      path: '/simulators/debt',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const SimulatorsScreen(kind: SimulatorKind.debt),
    ),
    GoRoute(
      path: '/simulators/compound',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const SimulatorsScreen(kind: SimulatorKind.compound),
    ),
    GoRoute(
      path: '/family-support',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const FamilySupportScreen(),
    ),
    GoRoute(
      path: '/travel-mode',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const TravelModeScreen(),
    ),
    GoRoute(
      path: '/subscriptions',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const SubscriptionsScreen(),
    ),
    GoRoute(
      path: '/subscriptions/trimmed',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? const {};
        return SubscriptionTrimmedScreen(
          merchant: extra['merchant']?.toString() ?? '',
          amountCents: (extra['amountCents'] as num?)?.toInt() ?? 0,
          currency: extra['currency']?.toString() ?? 'CAD',
        );
      },
    ),
    GoRoute(
      path: '/notifications/examples',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const NotificationExamplesScreen(),
    ),
    GoRoute(
      path: '/leagues',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const TenLeaguesScreen(),
    ),
    GoRoute(
      path: '/podium',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const SundayPodiumScreen(),
    ),
    GoRoute(
      path: '/chests',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ProgressChestsScreen(),
    ),
    GoRoute(
      path: '/android/error',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const AndroidErrorScreen(),
    ),
    GoRoute(
      path: '/home/states',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const HomeVariantsHubScreen(),
    ),
    GoRoute(
      path: '/home/empty',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) =>
          const HomeVariantScreen(variant: HomeVariant.empty),
    ),
    GoRoute(
      path: '/home/loading',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) =>
          const HomeVariantScreen(variant: HomeVariant.loading),
    ),
    GoRoute(
      path: '/home/error',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) =>
          const HomeVariantScreen(variant: HomeVariant.error),
    ),
    GoRoute(
      path: '/home/tight',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) =>
          const HomeVariantScreen(variant: HomeVariant.tight),
    ),
    GoRoute(
      path: '/home/under-zero',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) =>
          const HomeVariantScreen(variant: HomeVariant.underZero),
    ),
    GoRoute(
      path: '/home/welcome-back',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) =>
          const HomeVariantScreen(variant: HomeVariant.welcomeBack),
    ),
    GoRoute(
      path: '/home/well-done',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) =>
          const HomeVariantScreen(variant: HomeVariant.wellDone),
    ),

    GoRoute(
      path: '/expenses/reward',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? const {};
        return ExpenseRewardScreen(
          amountLabel: (extra['amount'] as String?) ?? '',
          category: (extra['category'] as String?) ?? '',
          merchant: (extra['merchant'] as String?) ?? '',
          xp: (extra['xp'] as num?)?.toInt() ?? kTransactionAddXp,
        );
      },
    ),
    GoRoute(
      path: '/streak/help',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const StreakHelpScreen(),
    ),
    GoRoute(
      path: '/home/dark',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => Theme(
        data: SiphoTheme.darkTheme,
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/expenses/dark',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => Theme(
        data: SiphoTheme.darkTheme,
        child: const ExpensesScreen(),
      ),
    ),
    GoRoute(
      path: '/android/home',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const AndroidChromeScreen(tab: AndroidChromeTab.home),
    ),
    GoRoute(
      path: '/android/expenses',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const AndroidChromeScreen(tab: AndroidChromeTab.expenses),
    ),
    GoRoute(
      path: '/android/learn',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const AndroidChromeScreen(tab: AndroidChromeTab.learn),
    ),
    GoRoute(
      path: '/en/home',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const LocalePreviewScreen(tab: LocalePreviewTab.home),
    ),
    GoRoute(
      path: '/en/expenses',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const LocalePreviewScreen(tab: LocalePreviewTab.expenses),
    ),
    GoRoute(
      path: '/en/learn',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const LocalePreviewScreen(tab: LocalePreviewTab.learn),
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/home', builder: (_, __) => const HomeScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/expenses', builder: (_, __) => const ExpensesScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/learn', builder: (_, __) => const LearnScreen())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/leaderboard',
              builder: (_, __) => const LeaderboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ],
        ),
      ],
    ),
  ],
);
