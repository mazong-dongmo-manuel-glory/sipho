import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/auth/presentation/login_screen.dart';
import 'package:sipho/features/budget/presentation/budget_screen.dart';
import 'package:sipho/features/budget/presentation/charts_screen.dart';
import 'package:sipho/features/country_pack/domain/country_pack.dart';
import 'package:sipho/features/economy/presentation/economy_detail_screen.dart';
import 'package:sipho/features/expenses/presentation/add_expense_sheet.dart';
import 'package:sipho/features/expenses/presentation/expenses_list_screen.dart';
import 'package:sipho/features/expenses/presentation/receipt_scan_screen.dart';
import 'package:sipho/features/expenses/presentation/receipt_validation_screen.dart';
import 'package:sipho/features/fixed_expenses/presentation/fixed_expense_detail_screen.dart';
import 'package:sipho/features/fixed_expenses/presentation/fixed_expense_swipe_screen.dart';
import 'package:sipho/features/fixed_expenses/presentation/fixed_expenses_list_screen.dart';
import 'package:sipho/features/gamification/presentation/chest_open_screen.dart';
import 'package:sipho/features/gamification/presentation/streak_screen.dart';
import 'package:sipho/features/home/presentation/home_screen.dart';
import 'package:sipho/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:sipho/features/lessons/presentation/learn_screen.dart';
import 'package:sipho/features/lessons/presentation/lesson_done_screen.dart';
import 'package:sipho/features/lessons/presentation/lesson_quiz_screen.dart';
import 'package:sipho/features/notifications/presentation/notification_settings_screen.dart';
import 'package:sipho/features/onboarding/presentation/onboarding_screen.dart';
import 'package:sipho/features/profile/presentation/profile_screen.dart';
import 'package:sipho/features/profile/presentation/shop_screen.dart';
import 'package:sipho/features/settings/presentation/settings_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/onboarding');
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => child,
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
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
        ],
      ),
      GoRoute(
        path: '/expenses',
        builder: (_, __) => const ExpensesListScreen(),
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
        builder: (_, __) => const ReceiptValidationScreen(),
      ),
      GoRoute(
        path: '/fixed-expenses',
        builder: (_, __) => const FixedExpensesListScreen(),
      ),
      GoRoute(
        path: '/fixed-expenses/swipe',
        builder: (_, __) => const FixedExpenseSwipeScreen(),
      ),
      GoRoute(
        path: '/fixed-expenses/:id',
        builder: (_, state) =>
            FixedExpenseDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(path: '/charts', builder: (_, __) => const ChartsScreen()),
      GoRoute(
        path: '/economy',
        builder: (_, __) => const EconomyDetailScreen(),
      ),
      GoRoute(
        path: '/lesson/:id',
        builder: (_, state) =>
            LessonQuizScreen(lessonId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/lesson-done',
        builder: (_, __) => const LessonDoneScreen(),
      ),
      GoRoute(path: '/streak', builder: (_, __) => const StreakScreen()),
      GoRoute(
        path: '/chest',
        builder: (_, __) => const ChestOpenScreen(),
      ),
      GoRoute(path: '/shop', builder: (_, __) => const ShopScreen()),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notification-settings',
        builder: (_, __) => const NotificationSettingsScreen(),
      ),
    ],
  );
}
