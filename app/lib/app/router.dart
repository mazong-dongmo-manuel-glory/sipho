import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sipho/core/widgets/bottom_nav.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/auth/presentation/login_screen.dart';
import 'package:sipho/features/budget/presentation/budget_screen.dart';
import 'package:sipho/features/budget/presentation/charts_screen.dart';
import 'package:sipho/features/economy/presentation/economy_detail_screen.dart';
import 'package:sipho/features/expenses/domain/parsed_receipt.dart';
import 'package:sipho/features/expenses/presentation/add_expense_sheet.dart';
import 'package:sipho/features/expenses/presentation/expenses_list_screen.dart';
import 'package:sipho/features/expenses/presentation/receipt_scan_screen.dart';
import 'package:sipho/features/expenses/presentation/receipt_validation_screen.dart';
import 'package:sipho/features/finance/presentation/finance_providers.dart';
import 'package:sipho/features/fixed_expenses/domain/fixed_expense_draft.dart';
import 'package:sipho/features/fixed_expenses/presentation/fixed_amount_screen.dart';
import 'package:sipho/features/fixed_expenses/presentation/fixed_expense_swipe_screen.dart';
import 'package:sipho/features/fixed_expenses/presentation/fixed_expenses_list_screen.dart';
import 'package:sipho/features/gamification/domain/quest_reward.dart';
import 'package:sipho/features/gamification/presentation/chest_open_screen.dart';
import 'package:sipho/features/gamification/presentation/streak_screen.dart';
import 'package:sipho/features/home/presentation/home_screen.dart';
import 'package:sipho/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:sipho/features/lessons/domain/lesson_result.dart';
import 'package:sipho/features/lessons/presentation/learn_screen.dart';
import 'package:sipho/features/lessons/presentation/lesson_done_screen.dart';
import 'package:sipho/features/lessons/presentation/lesson_player_screen.dart';
import 'package:sipho/features/notifications/presentation/notification_settings_screen.dart';
import 'package:sipho/features/onboarding/presentation/nest_ready_screen.dart';
import 'package:sipho/features/onboarding/presentation/nest_screen.dart';
import 'package:sipho/features/onboarding/presentation/notification_priming_screen.dart';
import 'package:sipho/features/onboarding/presentation/onboarding_screen.dart';
import 'package:sipho/features/onboarding/presentation/splash_screen.dart';
import 'package:sipho/features/profile/presentation/profile_screen.dart';
import 'package:sipho/features/profile/presentation/shop_screen.dart';
import 'package:sipho/features/recap/presentation/monthly_recap_screen.dart';
import 'package:sipho/features/settings/presentation/settings_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  // Recreating GoRouter resets the stack. Auth and profile updates only
  // re-run the redirect, so the name and country step stay on screen.
  final refresh = ValueNotifier<int>(0);
  ref.onDispose(refresh.dispose);
  ref.listen(authStateProvider, (_, __) => refresh.value++);
  ref.listen(onboardingGateProvider, (_, __) => refresh.value++);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = ref.read(authStateProvider).valueOrNull != null;
      final onboardingDone = ref.read(onboardingGateProvider);
      final location = state.matchedLocation;
      final onboarding = location.startsWith('/onboarding');
      final onboardingFlow = onboarding ||
          location.startsWith('/fixed-expenses/amount') ||
          location.startsWith('/fixed-expenses/swipe');
      final splash = location.startsWith('/splash');
      final login = location.startsWith('/login');
      if (!loggedIn && !onboarding && !splash && !login) return '/splash';
      if (!loggedIn) return null;
      if (onboardingDone == null) return null;
      if (!onboardingDone && !onboardingFlow) return '/onboarding';
      if (onboardingDone && (onboarding || splash || login)) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: '/onboarding/nest', builder: (_, __) => const NestScreen()),
      GoRoute(
        path: '/onboarding/ready',
        builder: (_, __) => const NestReadyScreen(),
      ),
      GoRoute(
        path: '/onboarding/notifications',
        builder: (_, __) => const NotificationPrimingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => SiphoBottomNav(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(
              path: '/expenses',
              builder: (_, __) => const ExpensesListScreen()),
          GoRoute(path: '/budget', builder: (_, __) => const BudgetScreen()),
          GoRoute(path: '/learn', builder: (_, __) => const LearnScreen()),
          GoRoute(
            path: '/leaderboard',
            builder: (_, __) => const LeaderboardScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
          GoRoute(path: '/shop', builder: (_, __) => const ShopScreen()),
          GoRoute(path: '/charts', builder: (_, __) => const ChartsScreen()),
        ],
      ),
      GoRoute(
        path: '/expenses/add',
        builder: (_, __) => const AddExpenseSheet(),
      ),
      GoRoute(
        path: '/expenses/scan',
        builder: (_, __) => const ReceiptScanScreen(),
      ),
      GoRoute(
        path: '/expenses/validate',
        builder: (_, state) => ReceiptValidationScreen(
          draft: state.extra is ParsedReceipt
              ? state.extra! as ParsedReceipt
              : ParsedReceipt.empty,
        ),
      ),
      GoRoute(
        path: '/fixed-expenses',
        builder: (_, __) => const FixedExpensesListScreen(),
      ),
      GoRoute(
        path: '/fixed-expenses/amount',
        builder: (_, state) => FixedAmountScreen(
          draft: state.extra is FixedExpenseDraft
              ? state.extra! as FixedExpenseDraft
              : null,
        ),
      ),
      GoRoute(
        path: '/fixed-expenses/swipe',
        builder: (_, __) => const FixedExpenseSwipeScreen(),
      ),
      GoRoute(
        path: '/economy',
        builder: (_, __) => const EconomyDetailScreen(),
      ),
      GoRoute(
        path: '/lesson/:id',
        builder: (_, state) =>
            LessonPlayerScreen(lessonId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/lesson-done',
        // The screen has nothing to show without the server's result (passed as `extra`).
        redirect: (_, state) => state.extra is LessonResult ? null : '/learn',
        builder: (_, state) =>
            LessonDoneScreen(result: state.extra! as LessonResult),
      ),
      GoRoute(path: '/streak', builder: (_, __) => const StreakScreen()),
      GoRoute(
        path: '/chest',
        // Opened from a quest claim (`extra` = its reward). Without it the gift still opens but
        // announces no amount, rather than inventing one.
        builder: (_, state) => ChestOpenScreen(
          reward:
              state.extra is QuestReward ? state.extra! as QuestReward : null,
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/recap',
        builder: (_, __) => const MonthlyRecapScreen(),
      ),
      GoRoute(
        path: '/notification-settings',
        builder: (_, __) => const NotificationSettingsScreen(),
      ),
    ],
  );
}
