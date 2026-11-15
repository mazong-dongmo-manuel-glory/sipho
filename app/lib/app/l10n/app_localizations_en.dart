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
  String get signInWithGoogle => 'Continue with Google';

  @override
  String get signInWithApple => 'Continue with Apple';

  @override
  String get welcomeWordmark => 'SIPHO';

  @override
  String get welcomeTitle => 'Welcome\nto Sipho!';

  @override
  String get welcomeSubtitle =>
      'The gamified guide to\nyour financial prosperity';

  @override
  String get welcomeLegal =>
      'By continuing, you accept our terms\nand our privacy policy.';

  @override
  String get logoutBtn => 'Sign out';

  @override
  String get splashTagline => 'Give yourself a gift:\nyour future.';

  @override
  String get splashFooter => 'ONE SMALL STEP. A BIG FUTURE.';

  @override
  String get onboardingNameHeading => 'Let\'s get acquainted';

  @override
  String get onboardingNameLead => 'Your adventure starts here.';

  @override
  String get onboardingNameBubble => 'Hi! I\'m Sipho. What\'s your name?';

  @override
  String get onboardingNameLabel => 'YOUR FIRST NAME';

  @override
  String get onboardingNameHelper => 'A lovely name for a fresh start.';

  @override
  String get onboardingCountryHeading => 'Where do you live?';

  @override
  String get onboardingCountryLead => 'We adapt your nest to your life.';

  @override
  String get onboardingUseLocation => 'Use my location';

  @override
  String onboardingNestRoot(String country) {
    return 'Your nest is taking root in $country!';
  }

  @override
  String get onboardingGoalHeading => 'One goal,\na world of possibilities.';

  @override
  String get onboardingGoalLead => 'What\'s your main goal?';

  @override
  String get onboardingGoalOverdraft => 'Stop living in the red';

  @override
  String get onboardingGoalProject => 'Save for a project';

  @override
  String get onboardingGoalUnderstand => 'Understand my money';

  @override
  String get onboardingGoalRetire => 'Prepare for retirement';

  @override
  String get onboardingGoalCheer =>
      'We\'ll get there, one small step at a time!';

  @override
  String get onboardingBuildNest => 'BUILD MY NEST';

  @override
  String get onboardingNestTitle => 'Let\'s build your nest!';

  @override
  String onboardingNestStrands(int count) {
    return '$count strands woven';
  }

  @override
  String get onboardingNestQuestion => 'Do you pay rent?';

  @override
  String get onboardingNestHint => 'Let\'s add this strand to your base.';

  @override
  String get onboardingNestSwipe => 'Swipe right for yes →';

  @override
  String get fixedSocle => 'My base';

  @override
  String get fixedRent => 'Rent';

  @override
  String get fixedPerMonth => 'per month · CAD';

  @override
  String get fixedDue => 'Charged on: the 1st';

  @override
  String get fixedAuto => 'Automatic payment';

  @override
  String get fixedAdd => 'ADD TO MY NEST';

  @override
  String get nestReadyKicker => 'A BEAUTIFUL FIRST STEP';

  @override
  String get nestReadyTitle => 'Your nest is ready!';

  @override
  String get nestReadyXp => '+50 XP';

  @override
  String get nestReadyBadge => 'Builder';

  @override
  String get notifFlameTitle => 'Keep the flame going?';

  @override
  String get notifFlameBody =>
      'Can I remind you to keep your flame? Two reminders a day, max. Promise.';

  @override
  String get notifFlameYes => 'YES, REMIND ME';

  @override
  String get notifLater => 'Later';

  @override
  String homeHello(String name) {
    return 'Hello $name!';
  }

  @override
  String get homeFutureLine => 'Your future is taking shape.';

  @override
  String homeLevelPill(int level) {
    return 'LV. $level';
  }

  @override
  String get homeRemainingKicker => 'LEFT TO LIVE ON';

  @override
  String get homeRemainingCaption => 'left for November';

  @override
  String homeRemainingCaptionMonth(String month) {
    return 'left for $month';
  }

  @override
  String get homeRemainingBreakdown =>
      'Income 2,800 \$ · Fixed 1,690 \$ · Spent 468 \$';

  @override
  String homeRemainingBreakdownValues(
      String income, String fixed, String spent) {
    return 'Income $income · Fixed $fixed · Spent $spent';
  }

  @override
  String get homeSetIncome => 'Tap the amount to set your income';

  @override
  String get homeGuestName => 'there';

  @override
  String get homeLatestExpense => 'Latest expense';

  @override
  String get homeNoExpenseYet => 'Nothing yet';

  @override
  String get homeAddFirstExpense => 'Add an expense with +';

  @override
  String get incomeSheetTitle => 'Monthly income';

  @override
  String get incomeSheetCta => 'SAVE';

  @override
  String get incomeSaveError => 'Income wasn\'t saved. Try again.';

  @override
  String get expenseSaveError => 'The expense wasn\'t saved. Try again.';

  @override
  String get expensesEmpty => 'No expenses this month.';

  @override
  String get expensesLoadError => 'Couldn\'t load your expenses.';

  @override
  String get homeNextExpense => 'Next bill · tomorrow';

  @override
  String get homePaid => 'Paid ✓';

  @override
  String get homeQuests => 'Today\'s quests';

  @override
  String get homeQuestExpenses => 'Log 3 expenses';

  @override
  String get homeQuestLesson => 'Do a lesson';

  @override
  String get homeQuestRestaurants => 'Stay under your restaurant budget';

  @override
  String get homeEconomyTitle => 'Official figures are on the way';

  @override
  String get homeEconomyImpact =>
      'Sipho only shows a rate when it comes from a dated source.';

  @override
  String get expenseDeleted => 'Expense removed';

  @override
  String get onboardingSaveError => 'Couldn\'t save your profile. Try again.';

  @override
  String get notifSettingsTitle => 'Notifications';

  @override
  String get notifStreakTitle => 'Evening reminder';

  @override
  String get notifStreakBody => 'A reminder at 7 pm to log your day';

  @override
  String get notifBudgetTitle => 'Budget alerts';

  @override
  String get notifBudgetBody => 'When a category nears its limit';

  @override
  String get notifFixedTitle => 'Due dates';

  @override
  String get notifFixedBody => 'The day before a bill in your base';

  @override
  String get notifTipsTitle => 'Tips';

  @override
  String get notifTipsBody => 'When an analysis of your totals is ready';

  @override
  String get notifEconomyTitle => 'Economy';

  @override
  String get notifEconomyBody => 'Only when a dated source is available';

  @override
  String get notifDailyTitle => 'Your nest is waiting';

  @override
  String get notifDailyBody => '30 seconds to log an expense.';

  @override
  String get notifDenied => 'Notifications stay off in your phone settings.';

  @override
  String get homeEconomyRead => 'Read (20 s) →';

  @override
  String get homeInsightAsk => 'Look at my spending';

  @override
  String get homeInsightWorking => 'Sipho is reading your totals…';

  @override
  String get homeInsightError => 'The analysis didn\'t finish. Try again.';

  @override
  String get homeInsightEmpty =>
      'Log at least one expense before Sipho can talk about it.';

  @override
  String get navHome => 'Home';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get navLearn => 'Learn';

  @override
  String get navRanking => 'Ranking';

  @override
  String get navProfile => 'Profile';

  @override
  String get addExpenseTitle => 'Add expense';

  @override
  String get addExpenseCta => 'ADD';

  @override
  String get addExpenseScan => 'Scan';

  @override
  String get catRent => 'Rent';

  @override
  String get catInternet => 'Internet';

  @override
  String get catEnergy => 'Energy';

  @override
  String get catPhone => 'Phone';

  @override
  String get catGroceries => 'Groceries';

  @override
  String get catTransport => 'Transport';

  @override
  String get catRestaurants => 'Restaurants';

  @override
  String get catShopping => 'Shopping';

  @override
  String rewardAdded(String amount, String category) {
    return '✓  $amount added · $category';
  }

  @override
  String get rewardHabit => 'One more good habit!';

  @override
  String get rewardXp => '+5 XP';

  @override
  String get rewardToast => '✓  Nice work! 2/3 on your quest.';

  @override
  String get scanTitle => 'Scan a receipt';

  @override
  String get scanHint => 'Place your receipt in the frame';

  @override
  String get scanPrivacy =>
      'The photo is used to read the total. No card number is stored.';

  @override
  String get scanReading => 'Reading the receipt…';

  @override
  String get scanReadError =>
      'Couldn\'t read this receipt. You can type the total.';

  @override
  String get scanGallery => 'Choose a photo';

  @override
  String get validateTitle => 'Check the receipt';

  @override
  String get validateBubble => 'Check the total before saving.';

  @override
  String get validateBubbleOk => 'I read the receipt. Check it before saving.';

  @override
  String get validateDateOk => 'Date';

  @override
  String get validateMerchant => 'Merchant';

  @override
  String get validateDateLabel => 'Date · Check this';

  @override
  String get validateDate => '10 Nov 2026';

  @override
  String get validateTotal => 'Total';

  @override
  String get validateTaxes => 'Taxes';

  @override
  String get validateTaxesValue => 'GST 2.11 \$ · QST 4.21 \$';

  @override
  String get validateCategory => 'Category';

  @override
  String get validateCta => 'SAVE';

  @override
  String get expensesTitle => 'Your expenses';

  @override
  String get expensesThisMonth => 'This month';

  @override
  String get expensesBase => 'My base';

  @override
  String get expensesCharts => 'Charts';

  @override
  String get expensesMonth => 'November 2026';

  @override
  String get expensesSpentKicker => 'SPENT THIS MONTH';

  @override
  String get expensesToday => 'TODAY';

  @override
  String get expensesNov10 => '10 NOVEMBER';

  @override
  String get expenseBreakfast => 'Restaurants · breakfast';

  @override
  String get expenseCommute => 'Transport · commute';

  @override
  String get expenseScanned => 'Groceries · 📷 scanned';

  @override
  String get expenseLeisure => 'Leisure · 25.00 € → 36.80 \$';

  @override
  String get socleTitle => 'My base';

  @override
  String get socleSubtitle => 'Your strands, neatly arranged.';

  @override
  String get socleCalendar => 'NOVEMBER 2026';

  @override
  String get socleWeekdays => 'M    T    W    T    F    S    S';

  @override
  String soclePaidOn(String day) {
    return '$day · Paid ✓';
  }

  @override
  String get socleTomorrow => '15 · Tomorrow';

  @override
  String socleUpcoming(String day) {
    return '$day · Upcoming';
  }

  @override
  String get socleEnvelopeProgress => 'Envelope · 62%';

  @override
  String get socleEnvelope => 'Envelope';

  @override
  String get socleLater => 'Upcoming';

  @override
  String get socleFamily => 'Family / transfers';

  @override
  String get socleElectricity => 'Electricity';

  @override
  String get socleTotal => 'Base: 1,690 \$/month';

  @override
  String socleTotalAmount(String amount) {
    return 'Base: $amount/month';
  }

  @override
  String get socleEmpty => 'No strands yet. Add rent, internet, groceries…';

  @override
  String get socleAdd => 'ADD A STRAND';

  @override
  String get soclePickTitle => 'Which strand are you adding?';

  @override
  String get socleSaveError => 'The strand wasn\'t saved. Try again.';

  @override
  String socleEnvelopePercent(int percent) {
    return 'Envelope · $percent%';
  }

  @override
  String socleAsk(String name) {
    return 'Do you pay for $name?';
  }

  @override
  String get socleYes => 'YES ✓';

  @override
  String get socleNo => 'NO ✕';

  @override
  String socleProgress(int current, int total) {
    return '$current/$total nest strands';
  }

  @override
  String fixedDueValue(int day) {
    return 'Charged on day $day';
  }

  @override
  String get fixedEachMonth => 'per month';

  @override
  String homeNextFixed(int day) {
    return 'Next fixed expense · day $day';
  }

  @override
  String get chartsTitle => 'Your money, clearly';

  @override
  String get chartsWeek => 'This week';

  @override
  String get chartsByWeekday => 'By day of the week';

  @override
  String chartsSlice(String name, int percent) {
    return '$name    $percent%';
  }

  @override
  String chartsCategoryShare(String name, int percent) {
    return '$name · $percent%';
  }

  @override
  String get chartsOtherName => 'Other';

  @override
  String chartsSummaryLess(int percent) {
    return '$percent% less than last month';
  }

  @override
  String chartsSummaryMore(int percent) {
    return '$percent% more than last month';
  }

  @override
  String get chartsSummarySame => 'Same as last month';

  @override
  String get chartsEmpty => 'No expenses this month.';

  @override
  String get budgetTitle => 'Budget';

  @override
  String get budgetIntro => 'Share of this month\'s spending';

  @override
  String get chartsGroceries => 'Groceries    42%';

  @override
  String get chartsRestaurants => 'Restaurants    28%';

  @override
  String get chartsTransport => 'Transport    18%';

  @override
  String get chartsOther => 'Other    12%';

  @override
  String get chartsRestaurantsBudget => 'Restaurants · 85% ⚠';

  @override
  String get chartsShoppingBudget => 'Shopping · 40%';

  @override
  String get chartsLeisureBudget => 'Leisure · 95%';

  @override
  String get chartsSlowDown => 'Shall we slow down a bit?';

  @override
  String get chartsSummary => '12% less than last month 🎉';

  @override
  String get learnTitle => 'Learn';

  @override
  String get learnUnit => 'UNIT 1';

  @override
  String get learnUnitTitle => 'Budget basics';

  @override
  String get learnYourTurn => 'YOUR TURN';

  @override
  String get learnUnit3 => 'Unit 3: The TFSA 🇨🇦';

  @override
  String get quizKicker => 'THE EMERGENCY FUND';

  @override
  String get quizQuestion => 'Where should your emergency fund live?';

  @override
  String get quizHint => 'Pick the best answer.';

  @override
  String get quizCheck => 'CHECK';

  @override
  String get quizTryAgain => 'TRY AGAIN';

  @override
  String get quizWrong => 'Not yet';

  @override
  String get learnDone => 'Done';

  @override
  String get learnLocked => 'Finish the previous lesson';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String profileMemberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get profileGuest => 'You';

  @override
  String get quizExcellent => 'Excellent!';

  @override
  String get quizExplain => 'Easy to reach, with no nasty surprise.';

  @override
  String get quizA => 'In an accessible savings account';

  @override
  String get quizB => 'In high-risk stocks';

  @override
  String get quizC => 'Under my mattress';

  @override
  String get quizD => 'In a 10-year locked investment';

  @override
  String get lessonDoneTitle => 'One more lesson,\none giant step.';

  @override
  String lessonDoneBravo(String name) {
    return 'Well done, $name!';
  }

  @override
  String get lessonXp => 'XP earned';

  @override
  String get lessonAccuracy => 'Accuracy';

  @override
  String get lessonTime => 'Time';

  @override
  String get streakKicker => 'CONSISTENCY GROWS';

  @override
  String get streakDays => 'day streak!';

  @override
  String get streakThanks => 'Your future self thanks you.';

  @override
  String get giftTitleClosed => 'A surprise for you';

  @override
  String get giftFrom => 'From your friend Sipho.';

  @override
  String get giftTap => 'Tap to open';

  @override
  String get giftMagic => 'A little magic for your adventure.';

  @override
  String get giftOpenCta => 'OPEN MY GIFT';

  @override
  String get giftTitleOpen => 'A gift you earned!';

  @override
  String get giftEffort => 'Every small effort counts.';

  @override
  String get giftSeeds => '+50 gold seeds';

  @override
  String get giftFreeze => 'Streak freeze ×1';

  @override
  String get giftThanks => 'THANKS, SIPHO!';

  @override
  String get leagueTab => 'League';

  @override
  String get leagueFriends => 'Friends';

  @override
  String get leagueCountry => 'My country';

  @override
  String get leagueTitle => 'Gold League';

  @override
  String get leagueEnds => 'Ends in 2 d 5 h';

  @override
  String get leaguePromotion => '↑  PROMOTION ZONE · TOP 7';

  @override
  String get leagueRelegation => '↓  RELEGATION ZONE · LAST 5';

  @override
  String get profileMember => 'Member since Nov 2026';

  @override
  String get profileShop => 'Shop';

  @override
  String get profileStreak => '18 days';

  @override
  String get profileStreakLabel => 'Best streak';

  @override
  String get profileXp => '2,480';

  @override
  String get profileXpLabel => 'Total XP';

  @override
  String get profileLeague => 'Gold';

  @override
  String get profileLeagueLabel => 'League';

  @override
  String get profileLessons => '24';

  @override
  String get profileLessonsLabel => 'Lessons';

  @override
  String get profileBadges => 'My badges';

  @override
  String get profileGoals => 'My goals';

  @override
  String get profileGoal => 'Trip to Cameroon · 1,200 / 3,000 \$';

  @override
  String get profileInvite => 'Invite friends  →';

  @override
  String get shopTitle => 'Shop';

  @override
  String get shopSubtitle => 'A style as unique as your adventure.';

  @override
  String get shopBuy => 'Buy';

  @override
  String get shopHat => 'Sun hat';

  @override
  String get shopGlasses => 'Cool glasses';

  @override
  String get shopScarfGreen => 'Green wax scarf';

  @override
  String get shopScarfClay => 'Terracotta scarf';

  @override
  String get shopNest => 'Flowered nest';

  @override
  String get shopFreeze => 'Streak freeze';

  @override
  String get shopNote => 'Seeds are earned, never bought with money.';

  @override
  String get adviceKicker => 'AN IDEA FOR YOU';

  @override
  String get adviceTitle => 'What if we cooked?';

  @override
  String get adviceBody => 'Your restaurant outings are up 38% this month.';

  @override
  String get adviceQuest => 'QUEST · +50 XP';

  @override
  String get adviceQuestBody => 'Two more home-cooked meals\nthis week';

  @override
  String get adviceAccept => 'ACCEPT THE QUEST';

  @override
  String get adviceLater => 'Later';

  @override
  String get adviceDisclaimer =>
      'Educational content, not personalized financial advice.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Notifications and sounds';

  @override
  String get settingsStreak => 'Streak reminders';

  @override
  String get settingsBudget => 'Budget alerts';

  @override
  String get settingsFriends => 'Friends and league';

  @override
  String get settingsTips => 'Tips';

  @override
  String get settingsEconomy => 'Economy news';

  @override
  String get settingsRecap => 'Monthly recap';

  @override
  String get settingsSounds => 'Sounds';

  @override
  String get settingsHaptics => 'Vibration';

  @override
  String get settingsVoice => 'Sipho\'s voice';

  @override
  String get settingsReminder => 'Preferred reminder time';

  @override
  String get settingsReminderTime => '7 PM';

  @override
  String get settingsSleep => 'Promise, I\'ll respect your sleep.';

  @override
  String get recapKicker => 'YOUR OCTOBER WITH SIPHO';

  @override
  String get recapSpentTitle => 'In October,\nyou logged';

  @override
  String get recapSpentCount => '64';

  @override
  String get recapSpentLabel => 'expenses 📝';

  @override
  String get recapProgressTitle => 'Your best\nprogress';

  @override
  String get recapProgressCategory => 'Restaurants';

  @override
  String get recapProgressValue => '−22%';

  @override
  String get recapProgressCaption => 'More balance. Still plenty of fun.';

  @override
  String get recapSavedTitle => 'You gave yourself\na gift of';

  @override
  String get recapSavedValue => '\$142';

  @override
  String get recapSavedLabel => 'in savings 🎁';

  @override
  String get recapShare => 'SHARE';

  @override
  String get recapShareText =>
      'My October with Sipho: 64 expenses logged, and \$142 saved.';

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
  String get budgetMonth => 'This month';

  @override
  String get budgetSpent => 'Spent';

  @override
  String get budgetRemaining => 'Remaining';

  @override
  String get budgetOver => 'Over budget!';

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

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get editProfileBtn => 'Edit';

  @override
  String get editProfileCountry => 'Country & currency';

  @override
  String get editProfileGoal => 'Main goal';

  @override
  String get editProfileIncome => 'Monthly net income';

  @override
  String get editProfileSaved => 'Profile updated';

  @override
  String get editExpenseTitle => 'Edit expense';

  @override
  String get editExpenseMerchantHint => 'e.g. Grocery store, Cafe…';

  @override
  String get editExpenseNoteHint => 'Add a note';

  @override
  String get editExpenseSaved => 'Expense updated';

  @override
  String get editFixedTitle => 'Edit this item';

  @override
  String get editFixedName => 'Name';

  @override
  String get editFixedSaved => 'Item updated';

  @override
  String get editFixedDeleted => 'Item removed';

  @override
  String get coachTitle => 'Sipho\'s Advice';

  @override
  String get coachSubtitle => 'Based strictly on your real numbers this month.';

  @override
  String get coachTopicGeneral => 'Overview';

  @override
  String get coachTopicSpending => 'My spending';

  @override
  String get coachTopicFixed => 'My base';

  @override
  String get coachTopicGoal => 'My goal';

  @override
  String get coachGenerateCta => 'ASK SIPHO FOR ADVICE';

  @override
  String get coachRefreshCta => 'NEW ADVICE';

  @override
  String get coachEmptyBody =>
      'Add your income, a base item, or an expense, then ask Sipho to review your month.';

  @override
  String get coachActionTitle => 'THIS WEEK\'S HABIT';

  @override
  String get coachQuestBadge => 'SUGGESTED CHALLENGE';

  @override
  String get coachDoLessonCta => 'START RELATED LESSON';

  @override
  String get coachLogExpenseCta => 'LOG AN EXPENSE';

  @override
  String get coachOpenCard => 'View advice →';

  @override
  String get coachPreviousTitle => 'Previous advice';

  @override
  String get learnQuestsTitle => 'Learning quests';

  @override
  String learnQuestsSummary(int done, int total) {
    return '$done/$total completed';
  }

  @override
  String get learnQuestClaim => 'Claim';

  @override
  String get learnQuestGo => 'Start →';

  @override
  String get learnQuestDoneBadge => 'Completed ✓';

  @override
  String get learnQuestAiTag => 'AI Challenge';

  @override
  String get learnQuestClaimError => 'Couldn\'t claim the reward right now.';

  @override
  String get learnGenerateAiQuest => '✨ Custom AI challenge';

  @override
  String get learnGeneratingAiQuest => 'Generating…';

  @override
  String get quizAskAiTutor => '✨ Example with my numbers (Sipho AI)';

  @override
  String get quizAiTutorLoading => 'Sipho is preparing your example…';

  @override
  String get quizAiTutorTitle => 'Sipho connects this to your budget';

  @override
  String get quizAiTutorError =>
      'Sipho couldn\'t generate an example right now.';

  @override
  String get aiErrorNotEnabled =>
      'Enable Firebase AI Logic (Gemini Developer API) in Firebase Console to activate Sipho AI.';

  @override
  String get aiErrorAppCheck =>
      'App Check blocked this dev device: register its debug token in Firebase Console > App Check (or unenforce AI Logic).';

  @override
  String get aiErrorQuota =>
      'AI quota temporarily reached. Please try again in a few minutes.';

  @override
  String get aiErrorNetwork =>
      'Network connection unavailable to reach Sipho AI.';

  @override
  String get lessonSaveError =>
      'Your progress couldn\'t be saved. Check your connection and try again.';

  @override
  String get fixedMarkPaidError =>
      'Couldn\'t mark this bill as paid. Try again.';
}
