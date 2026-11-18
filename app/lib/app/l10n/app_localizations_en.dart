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
  String get settingsPrivacyPolicy => 'Privacy policy';

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
  String get onboardingLifeHeading => 'Where are you in life?';

  @override
  String get onboardingLifeLead => 'We adapt tips and lessons to your stage.';

  @override
  String get onboardingLifeStudent => 'Student';

  @override
  String get onboardingLifeFirstJob => 'First job';

  @override
  String get onboardingLifeFamily => 'Family life';

  @override
  String get onboardingLifePreRetirement => 'Pre-retirement';

  @override
  String get onboardingLifeRetired => 'Retired';

  @override
  String get onboardingIncomeHeading => 'Your monthly income';

  @override
  String get onboardingIncomeLead =>
      'Optional — unlocks “left to spend” and under-budget quests.';

  @override
  String get onboardingIncomeBubble =>
      'A rough number is enough. You can refine it later in your profile.';

  @override
  String get onboardingIncomeHint => 'Net income per month · you can skip';

  @override
  String get onboardingIncomeSkip => 'I\'LL SET THIS LATER';

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
  String get homeQuestsEmpty =>
      'Your quests for today are on their way. Check back in a moment!';

  @override
  String get homeBudgetDayTitle => 'Day under budget!';

  @override
  String homeBudgetDayBody(int xp) {
    return 'You stayed within your budget yesterday. +$xp XP for your consistency.';
  }

  @override
  String get homeNoSpendCta => 'No spending today';

  @override
  String get homeNoSpendDone => 'Noted: your streak goes on.';

  @override
  String get homeNoSpendError =>
      'Couldn\'t confirm right now. Please try again later.';

  @override
  String get friendsMyCode => 'Your friend code';

  @override
  String get friendsCopy => 'Copy';

  @override
  String get friendsCodeCopied => 'Code copied';

  @override
  String get friendsShare => 'Invite a friend';

  @override
  String friendsShareMessage(String code) {
    return 'Join me on Sipho and make tracking your money fun! My friend code: $code';
  }

  @override
  String get friendsCodeError => 'Couldn\'t load your code right now.';

  @override
  String get friendsAddTitle => 'Add a friend';

  @override
  String get friendsAddHint => 'Your friend\'s code';

  @override
  String get friendsAddCta => 'Send request';

  @override
  String get friendsRequestSent => 'Request sent.';

  @override
  String get friendsNowFriends => 'You are now friends!';

  @override
  String get friendsRequestsTitle => 'Requests received';

  @override
  String get friendsPendingTitle => 'Requests sent';

  @override
  String get friendsListTitle => 'My friends';

  @override
  String get friendsAccept => 'Accept';

  @override
  String get friendsDecline => 'Decline';

  @override
  String get friendsRemove => 'Remove';

  @override
  String friendsRemoveConfirm(String name) {
    return 'Remove $name from your friends?';
  }

  @override
  String get friendsEmpty =>
      'Invite a friend to cheer each other on and follow your streaks together.';

  @override
  String get friendsPrivacy =>
      'Friends see your nickname, level, streak and league. Never your amounts.';

  @override
  String friendsStats(int level, int streak) {
    return 'Level $level · 🔥 $streak';
  }

  @override
  String get friendsUnknownName => 'Sipho friend';

  @override
  String get friendsRedeemTitle => 'I have a referral code';

  @override
  String get friendsRedeemCta => 'Redeem code';

  @override
  String friendsRedeemDone(int xp) {
    return 'Welcome! +$xp XP, and you are now friends.';
  }

  @override
  String get friendsCodeInvalid => 'Enter a valid code (letters and digits).';

  @override
  String get friendsErrCodeNotFound =>
      'This code doesn\'t exist. Check it with your friend.';

  @override
  String get friendsErrOwnCode =>
      'That\'s your own code: share it with a friend.';

  @override
  String get friendsErrAlreadyDone =>
      'Already done: request pending, already friends, or code already used.';

  @override
  String get friendsErrLimit => 'Limit reached. Please try again later.';

  @override
  String get friendsErrNetwork =>
      'No connection. Please try again in a moment.';

  @override
  String get friendsErrNotAllowed => 'This action is no longer possible.';

  @override
  String get friendsErrGeneric => 'Something went wrong. Please try again.';

  @override
  String get contactsTitle => 'Find your friends in your contacts';

  @override
  String get contactsIntro =>
      'See which of your contacts are already on Sipho, and invite the others in one tap.';

  @override
  String get contactsFind => 'Find my contacts';

  @override
  String get contactsConsentTitle => 'Use your contacts?';

  @override
  String get contactsConsentBody =>
      'Sipho compares your contacts\' e-mails and phone numbers with existing accounts as encrypted fingerprints: they are neither read nor kept by Sipho.\n\nIn return, people who have your verified e-mail or phone number in their contacts will be able to find you. You can opt out at any time.';

  @override
  String get contactsConsentAccept => 'Agree and continue';

  @override
  String get contactsRefresh => 'Refresh';

  @override
  String get contactsSuggestionsTitle => 'Already on Sipho';

  @override
  String get contactsAdd => 'Add';

  @override
  String get contactsMore => 'Show more';

  @override
  String get contactsNoneOnSipho =>
      'None of your contacts is on Sipho yet. Invite them!';

  @override
  String get contactsInviteTitle => 'Invite your people';

  @override
  String get contactsInviteSms => 'SMS';

  @override
  String get contactsInviteEmail => 'E-mail';

  @override
  String get contactsInviteSubject => 'Join me on Sipho';

  @override
  String get contactsInviteFailed => 'Couldn\'t open the messaging app.';

  @override
  String get contactsDenied => 'Sipho can\'t access your contacts.';

  @override
  String get contactsDeniedSettings => 'Allow access in settings to continue.';

  @override
  String get contactsOpenSettings => 'Open settings';

  @override
  String get contactsStop => 'Stop being findable by my contacts';

  @override
  String get contactsStopped => 'You can no longer be found by your contacts.';

  @override
  String get contactsErrEmail =>
      'A verified e-mail or phone number on your account is required to use contacts.';

  @override
  String get contactsAddPhone => 'Add my number';

  @override
  String get contactsAddPhoneHint =>
      'So people who have your number can find you too (verified by SMS).';

  @override
  String get contactsPhoneTitle => 'Your phone number';

  @override
  String get contactsPhoneLabel => 'Number';

  @override
  String get contactsSendCode => 'Send code';

  @override
  String get contactsCodeTitle => 'Code sent by SMS';

  @override
  String get contactsCodeLabel => '6-digit code';

  @override
  String get contactsVerify => 'Verify';

  @override
  String get contactsPhoneAdded => 'Number verified and added.';

  @override
  String contactsPhoneLinked(String phone) {
    return 'Verified number: $phone';
  }

  @override
  String get contactsErrPhoneInvalid =>
      'This number isn\'t valid. Add the country code (e.g. +225).';

  @override
  String get contactsErrPhoneCode => 'Wrong or expired code.';

  @override
  String get contactsErrPhoneUsed =>
      'This number is already used by another account.';

  @override
  String get contactsErrPhoneTooMany =>
      'Too many attempts. Please try again later.';

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
  String get notifTipsTitle => 'Personalised tips';

  @override
  String get notifTipsBody =>
      'A tip from Sipho (AI) tailored to your lessons and budget, at most every 3 days. Only totals are analysed, never your name.';

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
  String get rewardToast => '✓  Nice work! Your quest is moving forward.';

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
  String get learnTitle => 'Learn, one small step at a time';

  @override
  String get learnYourTurn => 'YOUR TURN';

  @override
  String get learnUnit3 => 'Unit 3: The TFSA 🇨🇦';

  @override
  String learnUnitLabel(int number) {
    return 'UNIT $number';
  }

  @override
  String learnUnitProgress(int done, int total) {
    return '$done/$total lessons';
  }

  @override
  String learnUnitBonus(int xp, int seeds) {
    return 'Finish it: +$xp XP · +$seeds seeds';
  }

  @override
  String get learnUnitDone => 'Unit complete ✓';

  @override
  String get learnUnitLocked => 'Finish the previous unit';

  @override
  String lessonUnitCompleted(int xp, int seeds) {
    return 'Unit complete! Bonus: +$xp XP · +$seeds seeds';
  }

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
  String get learnStart => 'START';

  @override
  String get learnReplay => 'REPLAY';

  @override
  String learnLessonMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String learnLessonSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String learnLessonReward(int xp) {
    return 'up to +$xp XP';
  }

  @override
  String get learnLessonObjective => 'What you will learn';

  @override
  String get learnLessonDoneHint => 'Already completed: replay to practice.';

  @override
  String get learnUnitGiftLabel => 'Unit-end gift';

  @override
  String get learnYouAreHere => 'You are here';

  @override
  String get lessonKickerRead => 'DISCOVER';

  @override
  String get lessonKickerQuestion => 'QUESTION';

  @override
  String get lessonKickerTrueFalse => 'TRUE OR FALSE?';

  @override
  String get lessonTrue => 'True';

  @override
  String get lessonFalse => 'False';

  @override
  String get lessonRecapTitle => 'To remember';

  @override
  String get lessonRecapFinish => 'FINISH';

  @override
  String get lessonLeaveTitle => 'Leave the lesson?';

  @override
  String get lessonLeaveBody => 'Your progress in this lesson will be lost.';

  @override
  String get lessonLeaveStay => 'STAY';

  @override
  String get lessonLeaveQuit => 'LEAVE';

  @override
  String get learnLockedHint =>
      'Finish the previous lesson first to unlock this one.';

  @override
  String learnLessonPosition(int number, int total) {
    return 'Lesson $number of $total';
  }

  @override
  String get learnClose => 'CLOSE';

  @override
  String get lessonDoneBravoAnon => 'Well done!';

  @override
  String lessonDoneLevelUp(int level) {
    return 'Level $level reached!';
  }

  @override
  String get lessonDoneReplay =>
      'Lesson already completed: a little more practice.';

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
  String giftSeedsAmount(int count) {
    return '+$count gold seeds';
  }

  @override
  String giftXpAmount(int xp) {
    return '+$xp XP';
  }

  @override
  String get giftLevelUp => 'Level up!';

  @override
  String get giftNothingNew => 'This gift has already been opened.';

  @override
  String get giftThanks => 'THANKS, SIPHO!';

  @override
  String get leagueTab => 'League';

  @override
  String get leagueFriends => 'Friends';

  @override
  String get leagueCountry => 'My country';

  @override
  String get leagueTierBronze => 'Bronze';

  @override
  String get leagueTierSilver => 'Silver';

  @override
  String get leagueTierGold => 'Gold';

  @override
  String get leagueTierSapphire => 'Sapphire';

  @override
  String get leagueTierRuby => 'Ruby';

  @override
  String get leagueTierEmerald => 'Emerald';

  @override
  String get leagueTierAmethyst => 'Amethyst';

  @override
  String get leagueTierPearl => 'Pearl';

  @override
  String get leagueTierObsidian => 'Obsidian';

  @override
  String get leagueTierDiamond => 'Diamond';

  @override
  String leagueTitleNamed(String tier) {
    return '$tier League';
  }

  @override
  String leagueEndsIn(String duration) {
    return 'Ends in $duration';
  }

  @override
  String get leagueEnded => 'Week over · results coming up';

  @override
  String leagueDurationDaysHours(int days, int hours) {
    return '$days d $hours h';
  }

  @override
  String leagueDurationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String leagueXpValue(int xp) {
    return '$xp XP';
  }

  @override
  String get leagueYouSuffix => 'You';

  @override
  String get leagueAlone =>
      'You\'re the only one in your group so far. Other players join as the week goes on.';

  @override
  String get leagueError =>
      'Couldn\'t load the league. Check your connection and try again.';

  @override
  String get leagueSoon => 'Coming soon';

  @override
  String leagueResultPromoted(int rank, String tier) {
    return 'Last week: #$rank, promoted to $tier League!';
  }

  @override
  String leagueResultRelegated(int rank, String tier) {
    return 'Last week: #$rank, moved down to $tier League.';
  }

  @override
  String leagueResultStayed(int rank, String tier) {
    return 'Last week: #$rank, you stay in $tier League.';
  }

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
  String get badgeFirstLesson => 'First lesson';

  @override
  String get badgeFirstLessonHint => 'Finish your first lesson.';

  @override
  String get badgeUnit1 => 'Budget basics';

  @override
  String get badgeUnit1Hint => 'Finish unit 1.';

  @override
  String get badgeUnit2 => 'Saver';

  @override
  String get badgeUnit2Hint => 'Finish unit 2.';

  @override
  String get badgeStreak7 => '7-day streak';

  @override
  String get badgeStreak7Hint => 'Reach a 7-day streak.';

  @override
  String get badgeStreak30 => '30-day streak';

  @override
  String get badgeStreak30Hint => 'Reach a 30-day streak.';

  @override
  String get badgeLevel5 => 'Level 5';

  @override
  String get badgeLevel5Hint => 'Reach level 5.';

  @override
  String get badgeLevel10 => 'Level 10';

  @override
  String get badgeLevel10Hint => 'Reach level 10.';

  @override
  String get badgeLeagueSilver => 'Silver league';

  @override
  String get badgeLeagueSilverHint => 'Move up to the Silver league.';

  @override
  String get badgeBuilder => 'Nest builder';

  @override
  String get badgeBuilderHint => 'Finish building your nest (onboarding).';

  @override
  String get badgeUnit3 => 'Money-smart';

  @override
  String get badgeUnit3Hint => 'Finish unit 3.';

  @override
  String get badgeEarnedLabel => 'Earned';

  @override
  String get badgeLockedLabel => 'To earn';

  @override
  String get learnQuestCompleteLesson => 'Complete a lesson';

  @override
  String get learnQuestCompleteLessonSub =>
      'Answer the quiz right to unlock the next step';

  @override
  String learnQuestFinishUnit(int count) {
    return 'Finish the unit ($count lessons)';
  }

  @override
  String learnQuestFinishUnitSub(String unitTitle, int bonusXp) {
    return '$unitTitle · $bonusXp XP bonus at the end';
  }

  @override
  String get learnQuestBuildFoundation => 'Set up your monthly base';

  @override
  String get learnQuestBuildFoundationSub =>
      'Set your income and at least 1 fixed bill';

  @override
  String get learnQuestTrackThree => 'Log 3 expenses this month';

  @override
  String get learnQuestTrackThreeSub =>
      'Put the spending tracking lesson into practice';

  @override
  String get learnQuestLessonChallenge => 'Lesson challenge';

  @override
  String get learnQuestTrackingChallenge => 'Tracking challenge';

  @override
  String get learnQuestPersonalized => 'Personalized Sipho challenge';

  @override
  String get onboardingLocating => 'Finding your location…';

  @override
  String get onboardingLocationDenied =>
      'Location permission denied. Pick your country instead.';

  @override
  String get onboardingLocationError =>
      'Couldn’t read your location. Pick your country instead.';

  @override
  String get streakMilestonesTitle => 'Streak milestones';

  @override
  String get streakMilestoneReached => 'Reached!';

  @override
  String get streakRepairTitle => 'Repair your streak?';

  @override
  String get streakRepairBody =>
      'You missed yesterday. Repair within 24 h using 1 freeze.';

  @override
  String get streakRepairCta => 'REPAIR STREAK';

  @override
  String get streakRepairDone => 'Streak repaired!';

  @override
  String get streakRepairError => 'Couldn’t repair the streak.';

  @override
  String get streakRepairNoFreeze => 'You need a streak freeze (shop).';

  @override
  String get expenseCurrencyLabel => 'Currency';

  @override
  String get expenseFxUnavailable =>
      'Exchange rate unavailable for that currency. Try again later or use your main currency.';

  @override
  String scanQuotaLeft(int count) {
    return '$count scans left today';
  }

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
  String get shopOwned => 'Owned';

  @override
  String get shopStockFull => 'Stock full';

  @override
  String get shopNotEnough => 'Not enough seeds';

  @override
  String shopBought(String item) {
    return '$item is yours!';
  }

  @override
  String shopFreezeStock(int count, int max) {
    return '$count/$max in stock';
  }

  @override
  String get shopRefusedOwned => 'You already own this one.';

  @override
  String get shopRefusedStock => 'Your freeze stock is full.';

  @override
  String get shopRefusedSeeds => 'You need more seeds for this.';

  @override
  String get shopError => 'The purchase did not go through. Try again.';

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
      'The server refused this device (App Check). Debug builds use the dev debug token registered in Firebase Console > App Check; release builds need Play Integrity / App Attest configured.';

  @override
  String get aiErrorQuota =>
      'AI quota temporarily reached. Please try again in a few minutes.';

  @override
  String get aiErrorCredits =>
      'The AI has no credit left on this Firebase project. Top up in AI Studio (ai.studio/projects), then try again.';

  @override
  String get aiErrorNetwork =>
      'Network connection unavailable to reach Sipho AI.';

  @override
  String get lessonSaveErrorAuth =>
      'Your session expired. Sign in again, then try again.';

  @override
  String get lessonSaveErrorRefused =>
      'This lesson could not be validated (it may still be locked).';

  @override
  String get lessonSaveError =>
      'Your progress couldn\'t be saved. Check your connection and try again.';

  @override
  String get fixedMarkPaidError =>
      'Couldn\'t mark this bill as paid. Try again.';
}
