// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sipho';

  @override
  String get tagline => 'Master your money';

  @override
  String get continueBtn => 'Continue';

  @override
  String get skipBtn => 'Skip';

  @override
  String get doneBtn => 'Done';

  @override
  String get saveBtn => 'Save';

  @override
  String get cancelBtn => 'Cancel';

  @override
  String get deleteBtn => 'Delete';

  @override
  String get editBtn => 'Edit';

  @override
  String get addBtn => 'Add';

  @override
  String get confirmBtn => 'Confirm';

  @override
  String get retryBtn => 'Retry';

  @override
  String get loginTitle => 'Welcome back!';

  @override
  String get loginSubtitle => 'Sign in to continue';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get logoutBtn => 'Sign out';

  @override
  String get onboardingWelcomeTitle => 'Hey, I\'m Sipho! 👋';

  @override
  String get onboardingWelcomeSubtitle => 'Let\'s set up your money adventure';

  @override
  String get onboardingNameTitle => 'What should I call you?';

  @override
  String get onboardingNameHint => 'Your first name';

  @override
  String get onboardingCountryTitle => 'Where do you live?';

  @override
  String get onboardingGoalTitle => 'What\'s your main goal?';

  @override
  String get onboardingGoalSave => 'Save more money';

  @override
  String get onboardingGoalBudget => 'Stick to a budget';

  @override
  String get onboardingGoalDebt => 'Get out of debt';

  @override
  String get onboardingGoalInvest => 'Start investing';

  @override
  String onboardingCelebrationTitle(String name) {
    return 'You\'re all set, $name! 🎉';
  }

  @override
  String get notifPrimingTitle => 'Stay on track 🔥';

  @override
  String get notifPrimingBody => 'Get daily reminders to log expenses';

  @override
  String get notifPrimingAllow => 'Allow notifications';

  @override
  String get notifPrimingSkip => 'Maybe later';

  @override
  String get homeTitle => 'Home';

  @override
  String homeGreetingMorning(String name) {
    return 'Good morning, $name! ☀️';
  }

  @override
  String homeGreetingAfternoon(String name) {
    return 'Good afternoon, $name!';
  }

  @override
  String homeGreetingEvening(String name) {
    return 'Good evening, $name! 🌙';
  }

  @override
  String get remainingBudgetLabel => 'Remaining today';

  @override
  String get budgetTitle => 'Budget';

  @override
  String get budgetMonth => 'This month';

  @override
  String get budgetSpent => 'Spent';

  @override
  String get budgetRemaining => 'Remaining';

  @override
  String get budgetOver => 'Over budget!';

  @override
  String get learnTitle => 'Learn';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get profileTitle => 'Profile';

  @override
  String streakLabel(int days) {
    return '$days day streak';
  }

  @override
  String seedsLabel(int count) {
    return '$count seeds';
  }

  @override
  String xpLabel(int xp) {
    return '$xp XP';
  }

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String get questTitle => 'Daily Quest';

  @override
  String get questComplete => 'Quest complete! 🎯';

  @override
  String get addExpenseTitle => 'Add expense';

  @override
  String get expenseAmount => 'Amount';

  @override
  String get expenseCategory => 'Category';

  @override
  String get expenseNote => 'Note (optional)';

  @override
  String get expenseDate => 'Date';

  @override
  String get scanReceiptBtn => 'Scan receipt';

  @override
  String get fixedExpensesTitle => 'Fixed expenses';

  @override
  String get fixedExpenseMarkPaid => 'Mark as paid';

  @override
  String get fixedExpensePaid => 'Paid ✓';

  @override
  String get economyTitle => 'Economy';

  @override
  String get shopTitle => 'Shop';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'No internet connection.';

  @override
  String get errorUnauthorized => 'Please sign in again.';

  @override
  String get categoryFood => 'Food & Drinks';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryHousing => 'Housing';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categorySavings => 'Savings';

  @override
  String get categoryOther => 'Other';
}
