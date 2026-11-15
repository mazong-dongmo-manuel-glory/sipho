import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'Sipho'**
  String get appName;

  /// App tagline
  ///
  /// In en, this message translates to:
  /// **'Master your money'**
  String get tagline;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @skipBtn.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipBtn;

  /// No description provided for @doneBtn.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneBtn;

  /// No description provided for @saveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveBtn;

  /// No description provided for @cancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelBtn;

  /// No description provided for @deleteBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteBtn;

  /// No description provided for @editBtn.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editBtn;

  /// No description provided for @addBtn.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addBtn;

  /// No description provided for @confirmBtn.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmBtn;

  /// No description provided for @retryBtn.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryBtn;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get signInWithApple;

  /// No description provided for @welcomeWordmark.
  ///
  /// In en, this message translates to:
  /// **'SIPHO'**
  String get welcomeWordmark;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome\nto Sipho!'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The gamified guide to\nyour financial prosperity'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeLegal.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you accept our terms\nand our privacy policy.'**
  String get welcomeLegal;

  /// No description provided for @logoutBtn.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logoutBtn;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Give yourself a gift:\nyour future.'**
  String get splashTagline;

  /// No description provided for @splashFooter.
  ///
  /// In en, this message translates to:
  /// **'ONE SMALL STEP. A BIG FUTURE.'**
  String get splashFooter;

  /// No description provided for @onboardingNameHeading.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get acquainted'**
  String get onboardingNameHeading;

  /// No description provided for @onboardingNameLead.
  ///
  /// In en, this message translates to:
  /// **'Your adventure starts here.'**
  String get onboardingNameLead;

  /// No description provided for @onboardingNameBubble.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m Sipho. What\'s your name?'**
  String get onboardingNameBubble;

  /// No description provided for @onboardingNameLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR FIRST NAME'**
  String get onboardingNameLabel;

  /// No description provided for @onboardingNameHelper.
  ///
  /// In en, this message translates to:
  /// **'A lovely name for a fresh start.'**
  String get onboardingNameHelper;

  /// No description provided for @onboardingCountryHeading.
  ///
  /// In en, this message translates to:
  /// **'Where do you live?'**
  String get onboardingCountryHeading;

  /// No description provided for @onboardingCountryLead.
  ///
  /// In en, this message translates to:
  /// **'We adapt your nest to your life.'**
  String get onboardingCountryLead;

  /// No description provided for @onboardingUseLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get onboardingUseLocation;

  /// No description provided for @onboardingNestRoot.
  ///
  /// In en, this message translates to:
  /// **'Your nest is taking root in {country}!'**
  String onboardingNestRoot(String country);

  /// No description provided for @onboardingGoalHeading.
  ///
  /// In en, this message translates to:
  /// **'One goal,\na world of possibilities.'**
  String get onboardingGoalHeading;

  /// No description provided for @onboardingGoalLead.
  ///
  /// In en, this message translates to:
  /// **'What\'s your main goal?'**
  String get onboardingGoalLead;

  /// No description provided for @onboardingGoalOverdraft.
  ///
  /// In en, this message translates to:
  /// **'Stop living in the red'**
  String get onboardingGoalOverdraft;

  /// No description provided for @onboardingGoalProject.
  ///
  /// In en, this message translates to:
  /// **'Save for a project'**
  String get onboardingGoalProject;

  /// No description provided for @onboardingGoalUnderstand.
  ///
  /// In en, this message translates to:
  /// **'Understand my money'**
  String get onboardingGoalUnderstand;

  /// No description provided for @onboardingGoalRetire.
  ///
  /// In en, this message translates to:
  /// **'Prepare for retirement'**
  String get onboardingGoalRetire;

  /// No description provided for @onboardingGoalCheer.
  ///
  /// In en, this message translates to:
  /// **'We\'ll get there, one small step at a time!'**
  String get onboardingGoalCheer;

  /// No description provided for @onboardingBuildNest.
  ///
  /// In en, this message translates to:
  /// **'BUILD MY NEST'**
  String get onboardingBuildNest;

  /// No description provided for @onboardingNestTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s build your nest!'**
  String get onboardingNestTitle;

  /// No description provided for @onboardingNestStrands.
  ///
  /// In en, this message translates to:
  /// **'{count} strands woven'**
  String onboardingNestStrands(int count);

  /// No description provided for @onboardingNestQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you pay rent?'**
  String get onboardingNestQuestion;

  /// No description provided for @onboardingNestHint.
  ///
  /// In en, this message translates to:
  /// **'Let\'s add this strand to your base.'**
  String get onboardingNestHint;

  /// No description provided for @onboardingNestSwipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe right for yes →'**
  String get onboardingNestSwipe;

  /// No description provided for @fixedSocle.
  ///
  /// In en, this message translates to:
  /// **'My base'**
  String get fixedSocle;

  /// No description provided for @fixedRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get fixedRent;

  /// No description provided for @fixedPerMonth.
  ///
  /// In en, this message translates to:
  /// **'per month · CAD'**
  String get fixedPerMonth;

  /// No description provided for @fixedDue.
  ///
  /// In en, this message translates to:
  /// **'Charged on: the 1st'**
  String get fixedDue;

  /// No description provided for @fixedAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic payment'**
  String get fixedAuto;

  /// No description provided for @fixedAdd.
  ///
  /// In en, this message translates to:
  /// **'ADD TO MY NEST'**
  String get fixedAdd;

  /// No description provided for @nestReadyKicker.
  ///
  /// In en, this message translates to:
  /// **'A BEAUTIFUL FIRST STEP'**
  String get nestReadyKicker;

  /// No description provided for @nestReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your nest is ready!'**
  String get nestReadyTitle;

  /// No description provided for @nestReadyXp.
  ///
  /// In en, this message translates to:
  /// **'+50 XP'**
  String get nestReadyXp;

  /// No description provided for @nestReadyBadge.
  ///
  /// In en, this message translates to:
  /// **'Builder'**
  String get nestReadyBadge;

  /// No description provided for @notifFlameTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the flame going?'**
  String get notifFlameTitle;

  /// No description provided for @notifFlameBody.
  ///
  /// In en, this message translates to:
  /// **'Can I remind you to keep your flame? Two reminders a day, max. Promise.'**
  String get notifFlameBody;

  /// No description provided for @notifFlameYes.
  ///
  /// In en, this message translates to:
  /// **'YES, REMIND ME'**
  String get notifFlameYes;

  /// No description provided for @notifLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get notifLater;

  /// No description provided for @homeHello.
  ///
  /// In en, this message translates to:
  /// **'Hello {name}!'**
  String homeHello(String name);

  /// No description provided for @homeFutureLine.
  ///
  /// In en, this message translates to:
  /// **'Your future is taking shape.'**
  String get homeFutureLine;

  /// No description provided for @homeLevelPill.
  ///
  /// In en, this message translates to:
  /// **'LV. {level}'**
  String homeLevelPill(int level);

  /// No description provided for @homeRemainingKicker.
  ///
  /// In en, this message translates to:
  /// **'LEFT TO LIVE ON'**
  String get homeRemainingKicker;

  /// No description provided for @homeRemainingCaption.
  ///
  /// In en, this message translates to:
  /// **'left for November'**
  String get homeRemainingCaption;

  /// No description provided for @homeRemainingCaptionMonth.
  ///
  /// In en, this message translates to:
  /// **'left for {month}'**
  String homeRemainingCaptionMonth(String month);

  /// No description provided for @homeRemainingBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Income 2,800 \$ · Fixed 1,690 \$ · Spent 468 \$'**
  String get homeRemainingBreakdown;

  /// No description provided for @homeRemainingBreakdownValues.
  ///
  /// In en, this message translates to:
  /// **'Income {income} · Fixed {fixed} · Spent {spent}'**
  String homeRemainingBreakdownValues(
      String income, String fixed, String spent);

  /// No description provided for @homeSetIncome.
  ///
  /// In en, this message translates to:
  /// **'Tap the amount to set your income'**
  String get homeSetIncome;

  /// No description provided for @homeGuestName.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get homeGuestName;

  /// No description provided for @homeLatestExpense.
  ///
  /// In en, this message translates to:
  /// **'Latest expense'**
  String get homeLatestExpense;

  /// No description provided for @homeNoExpenseYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet'**
  String get homeNoExpenseYet;

  /// No description provided for @homeAddFirstExpense.
  ///
  /// In en, this message translates to:
  /// **'Add an expense with +'**
  String get homeAddFirstExpense;

  /// No description provided for @incomeSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly income'**
  String get incomeSheetTitle;

  /// No description provided for @incomeSheetCta.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get incomeSheetCta;

  /// No description provided for @incomeSaveError.
  ///
  /// In en, this message translates to:
  /// **'Income wasn\'t saved. Try again.'**
  String get incomeSaveError;

  /// No description provided for @expenseSaveError.
  ///
  /// In en, this message translates to:
  /// **'The expense wasn\'t saved. Try again.'**
  String get expenseSaveError;

  /// No description provided for @expensesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month.'**
  String get expensesEmpty;

  /// No description provided for @expensesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your expenses.'**
  String get expensesLoadError;

  /// No description provided for @homeNextExpense.
  ///
  /// In en, this message translates to:
  /// **'Next bill · tomorrow'**
  String get homeNextExpense;

  /// No description provided for @homePaid.
  ///
  /// In en, this message translates to:
  /// **'Paid ✓'**
  String get homePaid;

  /// No description provided for @homeQuests.
  ///
  /// In en, this message translates to:
  /// **'Today\'s quests'**
  String get homeQuests;

  /// No description provided for @homeQuestExpenses.
  ///
  /// In en, this message translates to:
  /// **'Log 3 expenses'**
  String get homeQuestExpenses;

  /// No description provided for @homeQuestLesson.
  ///
  /// In en, this message translates to:
  /// **'Do a lesson'**
  String get homeQuestLesson;

  /// No description provided for @homeQuestRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Stay under your restaurant budget'**
  String get homeQuestRestaurants;

  /// No description provided for @homeEconomyTitle.
  ///
  /// In en, this message translates to:
  /// **'Official figures are on the way'**
  String get homeEconomyTitle;

  /// No description provided for @homeEconomyImpact.
  ///
  /// In en, this message translates to:
  /// **'Sipho only shows a rate when it comes from a dated source.'**
  String get homeEconomyImpact;

  /// No description provided for @expenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense removed'**
  String get expenseDeleted;

  /// No description provided for @onboardingSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your profile. Try again.'**
  String get onboardingSaveError;

  /// No description provided for @notifSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifSettingsTitle;

  /// No description provided for @notifStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Evening reminder'**
  String get notifStreakTitle;

  /// No description provided for @notifStreakBody.
  ///
  /// In en, this message translates to:
  /// **'A reminder at 7 pm to log your day'**
  String get notifStreakBody;

  /// No description provided for @notifBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget alerts'**
  String get notifBudgetTitle;

  /// No description provided for @notifBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'When a category nears its limit'**
  String get notifBudgetBody;

  /// No description provided for @notifFixedTitle.
  ///
  /// In en, this message translates to:
  /// **'Due dates'**
  String get notifFixedTitle;

  /// No description provided for @notifFixedBody.
  ///
  /// In en, this message translates to:
  /// **'The day before a bill in your base'**
  String get notifFixedBody;

  /// No description provided for @notifTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get notifTipsTitle;

  /// No description provided for @notifTipsBody.
  ///
  /// In en, this message translates to:
  /// **'When an analysis of your totals is ready'**
  String get notifTipsBody;

  /// No description provided for @notifEconomyTitle.
  ///
  /// In en, this message translates to:
  /// **'Economy'**
  String get notifEconomyTitle;

  /// No description provided for @notifEconomyBody.
  ///
  /// In en, this message translates to:
  /// **'Only when a dated source is available'**
  String get notifEconomyBody;

  /// No description provided for @notifDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your nest is waiting'**
  String get notifDailyTitle;

  /// No description provided for @notifDailyBody.
  ///
  /// In en, this message translates to:
  /// **'30 seconds to log an expense.'**
  String get notifDailyBody;

  /// No description provided for @notifDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications stay off in your phone settings.'**
  String get notifDenied;

  /// No description provided for @homeEconomyRead.
  ///
  /// In en, this message translates to:
  /// **'Read (20 s) →'**
  String get homeEconomyRead;

  /// No description provided for @homeInsightAsk.
  ///
  /// In en, this message translates to:
  /// **'Look at my spending'**
  String get homeInsightAsk;

  /// No description provided for @homeInsightWorking.
  ///
  /// In en, this message translates to:
  /// **'Sipho is reading your totals…'**
  String get homeInsightWorking;

  /// No description provided for @homeInsightError.
  ///
  /// In en, this message translates to:
  /// **'The analysis didn\'t finish. Try again.'**
  String get homeInsightError;

  /// No description provided for @homeInsightEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log at least one expense before Sipho can talk about it.'**
  String get homeInsightEmpty;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get navExpenses;

  /// No description provided for @navLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// No description provided for @navRanking.
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get navRanking;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @addExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpenseTitle;

  /// No description provided for @addExpenseCta.
  ///
  /// In en, this message translates to:
  /// **'ADD'**
  String get addExpenseCta;

  /// No description provided for @addExpenseScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get addExpenseScan;

  /// No description provided for @catRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get catRent;

  /// No description provided for @catInternet.
  ///
  /// In en, this message translates to:
  /// **'Internet'**
  String get catInternet;

  /// No description provided for @catEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get catEnergy;

  /// No description provided for @catPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get catPhone;

  /// No description provided for @catGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get catGroceries;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get catRestaurants;

  /// No description provided for @catShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get catShopping;

  /// No description provided for @rewardAdded.
  ///
  /// In en, this message translates to:
  /// **'✓  {amount} added · {category}'**
  String rewardAdded(String amount, String category);

  /// No description provided for @rewardHabit.
  ///
  /// In en, this message translates to:
  /// **'One more good habit!'**
  String get rewardHabit;

  /// No description provided for @rewardXp.
  ///
  /// In en, this message translates to:
  /// **'+5 XP'**
  String get rewardXp;

  /// No description provided for @rewardToast.
  ///
  /// In en, this message translates to:
  /// **'✓  Nice work! 2/3 on your quest.'**
  String get rewardToast;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a receipt'**
  String get scanTitle;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Place your receipt in the frame'**
  String get scanHint;

  /// No description provided for @scanPrivacy.
  ///
  /// In en, this message translates to:
  /// **'The photo is used to read the total. No card number is stored.'**
  String get scanPrivacy;

  /// No description provided for @scanReading.
  ///
  /// In en, this message translates to:
  /// **'Reading the receipt…'**
  String get scanReading;

  /// No description provided for @scanReadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read this receipt. You can type the total.'**
  String get scanReadError;

  /// No description provided for @scanGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose a photo'**
  String get scanGallery;

  /// No description provided for @validateTitle.
  ///
  /// In en, this message translates to:
  /// **'Check the receipt'**
  String get validateTitle;

  /// No description provided for @validateBubble.
  ///
  /// In en, this message translates to:
  /// **'Check the total before saving.'**
  String get validateBubble;

  /// No description provided for @validateBubbleOk.
  ///
  /// In en, this message translates to:
  /// **'I read the receipt. Check it before saving.'**
  String get validateBubbleOk;

  /// No description provided for @validateDateOk.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get validateDateOk;

  /// No description provided for @validateMerchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get validateMerchant;

  /// No description provided for @validateDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date · Check this'**
  String get validateDateLabel;

  /// No description provided for @validateDate.
  ///
  /// In en, this message translates to:
  /// **'10 Nov 2026'**
  String get validateDate;

  /// No description provided for @validateTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get validateTotal;

  /// No description provided for @validateTaxes.
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get validateTaxes;

  /// No description provided for @validateTaxesValue.
  ///
  /// In en, this message translates to:
  /// **'GST 2.11 \$ · QST 4.21 \$'**
  String get validateTaxesValue;

  /// No description provided for @validateCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get validateCategory;

  /// No description provided for @validateCta.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get validateCta;

  /// No description provided for @expensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your expenses'**
  String get expensesTitle;

  /// No description provided for @expensesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get expensesThisMonth;

  /// No description provided for @expensesBase.
  ///
  /// In en, this message translates to:
  /// **'My base'**
  String get expensesBase;

  /// No description provided for @expensesCharts.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get expensesCharts;

  /// No description provided for @expensesMonth.
  ///
  /// In en, this message translates to:
  /// **'November 2026'**
  String get expensesMonth;

  /// No description provided for @expensesSpentKicker.
  ///
  /// In en, this message translates to:
  /// **'SPENT THIS MONTH'**
  String get expensesSpentKicker;

  /// No description provided for @expensesToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get expensesToday;

  /// No description provided for @expensesNov10.
  ///
  /// In en, this message translates to:
  /// **'10 NOVEMBER'**
  String get expensesNov10;

  /// No description provided for @expenseBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Restaurants · breakfast'**
  String get expenseBreakfast;

  /// No description provided for @expenseCommute.
  ///
  /// In en, this message translates to:
  /// **'Transport · commute'**
  String get expenseCommute;

  /// No description provided for @expenseScanned.
  ///
  /// In en, this message translates to:
  /// **'Groceries · 📷 scanned'**
  String get expenseScanned;

  /// No description provided for @expenseLeisure.
  ///
  /// In en, this message translates to:
  /// **'Leisure · 25.00 € → 36.80 \$'**
  String get expenseLeisure;

  /// No description provided for @socleTitle.
  ///
  /// In en, this message translates to:
  /// **'My base'**
  String get socleTitle;

  /// No description provided for @socleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your strands, neatly arranged.'**
  String get socleSubtitle;

  /// No description provided for @socleCalendar.
  ///
  /// In en, this message translates to:
  /// **'NOVEMBER 2026'**
  String get socleCalendar;

  /// No description provided for @socleWeekdays.
  ///
  /// In en, this message translates to:
  /// **'M    T    W    T    F    S    S'**
  String get socleWeekdays;

  /// No description provided for @soclePaidOn.
  ///
  /// In en, this message translates to:
  /// **'{day} · Paid ✓'**
  String soclePaidOn(String day);

  /// No description provided for @socleTomorrow.
  ///
  /// In en, this message translates to:
  /// **'15 · Tomorrow'**
  String get socleTomorrow;

  /// No description provided for @socleUpcoming.
  ///
  /// In en, this message translates to:
  /// **'{day} · Upcoming'**
  String socleUpcoming(String day);

  /// No description provided for @socleEnvelopeProgress.
  ///
  /// In en, this message translates to:
  /// **'Envelope · 62%'**
  String get socleEnvelopeProgress;

  /// No description provided for @socleEnvelope.
  ///
  /// In en, this message translates to:
  /// **'Envelope'**
  String get socleEnvelope;

  /// No description provided for @socleLater.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get socleLater;

  /// No description provided for @socleFamily.
  ///
  /// In en, this message translates to:
  /// **'Family / transfers'**
  String get socleFamily;

  /// No description provided for @socleElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get socleElectricity;

  /// No description provided for @socleTotal.
  ///
  /// In en, this message translates to:
  /// **'Base: 1,690 \$/month'**
  String get socleTotal;

  /// No description provided for @socleTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Base: {amount}/month'**
  String socleTotalAmount(String amount);

  /// No description provided for @socleEmpty.
  ///
  /// In en, this message translates to:
  /// **'No strands yet. Add rent, internet, groceries…'**
  String get socleEmpty;

  /// No description provided for @socleAdd.
  ///
  /// In en, this message translates to:
  /// **'ADD A STRAND'**
  String get socleAdd;

  /// No description provided for @soclePickTitle.
  ///
  /// In en, this message translates to:
  /// **'Which strand are you adding?'**
  String get soclePickTitle;

  /// No description provided for @socleSaveError.
  ///
  /// In en, this message translates to:
  /// **'The strand wasn\'t saved. Try again.'**
  String get socleSaveError;

  /// No description provided for @socleEnvelopePercent.
  ///
  /// In en, this message translates to:
  /// **'Envelope · {percent}%'**
  String socleEnvelopePercent(int percent);

  /// No description provided for @socleAsk.
  ///
  /// In en, this message translates to:
  /// **'Do you pay for {name}?'**
  String socleAsk(String name);

  /// No description provided for @socleYes.
  ///
  /// In en, this message translates to:
  /// **'YES ✓'**
  String get socleYes;

  /// No description provided for @socleNo.
  ///
  /// In en, this message translates to:
  /// **'NO ✕'**
  String get socleNo;

  /// No description provided for @socleProgress.
  ///
  /// In en, this message translates to:
  /// **'{current}/{total} nest strands'**
  String socleProgress(int current, int total);

  /// No description provided for @fixedDueValue.
  ///
  /// In en, this message translates to:
  /// **'Charged on day {day}'**
  String fixedDueValue(int day);

  /// No description provided for @fixedEachMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get fixedEachMonth;

  /// No description provided for @homeNextFixed.
  ///
  /// In en, this message translates to:
  /// **'Next fixed expense · day {day}'**
  String homeNextFixed(int day);

  /// No description provided for @chartsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your money, clearly'**
  String get chartsTitle;

  /// No description provided for @chartsWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get chartsWeek;

  /// No description provided for @chartsByWeekday.
  ///
  /// In en, this message translates to:
  /// **'By day of the week'**
  String get chartsByWeekday;

  /// No description provided for @chartsSlice.
  ///
  /// In en, this message translates to:
  /// **'{name}    {percent}%'**
  String chartsSlice(String name, int percent);

  /// No description provided for @chartsCategoryShare.
  ///
  /// In en, this message translates to:
  /// **'{name} · {percent}%'**
  String chartsCategoryShare(String name, int percent);

  /// No description provided for @chartsOtherName.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get chartsOtherName;

  /// No description provided for @chartsSummaryLess.
  ///
  /// In en, this message translates to:
  /// **'{percent}% less than last month'**
  String chartsSummaryLess(int percent);

  /// No description provided for @chartsSummaryMore.
  ///
  /// In en, this message translates to:
  /// **'{percent}% more than last month'**
  String chartsSummaryMore(int percent);

  /// No description provided for @chartsSummarySame.
  ///
  /// In en, this message translates to:
  /// **'Same as last month'**
  String get chartsSummarySame;

  /// No description provided for @chartsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month.'**
  String get chartsEmpty;

  /// No description provided for @budgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetTitle;

  /// No description provided for @budgetIntro.
  ///
  /// In en, this message translates to:
  /// **'Share of this month\'s spending'**
  String get budgetIntro;

  /// No description provided for @chartsGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries    42%'**
  String get chartsGroceries;

  /// No description provided for @chartsRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants    28%'**
  String get chartsRestaurants;

  /// No description provided for @chartsTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport    18%'**
  String get chartsTransport;

  /// No description provided for @chartsOther.
  ///
  /// In en, this message translates to:
  /// **'Other    12%'**
  String get chartsOther;

  /// No description provided for @chartsRestaurantsBudget.
  ///
  /// In en, this message translates to:
  /// **'Restaurants · 85% ⚠'**
  String get chartsRestaurantsBudget;

  /// No description provided for @chartsShoppingBudget.
  ///
  /// In en, this message translates to:
  /// **'Shopping · 40%'**
  String get chartsShoppingBudget;

  /// No description provided for @chartsLeisureBudget.
  ///
  /// In en, this message translates to:
  /// **'Leisure · 95%'**
  String get chartsLeisureBudget;

  /// No description provided for @chartsSlowDown.
  ///
  /// In en, this message translates to:
  /// **'Shall we slow down a bit?'**
  String get chartsSlowDown;

  /// No description provided for @chartsSummary.
  ///
  /// In en, this message translates to:
  /// **'12% less than last month 🎉'**
  String get chartsSummary;

  /// No description provided for @learnTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnTitle;

  /// No description provided for @learnUnit.
  ///
  /// In en, this message translates to:
  /// **'UNIT 1'**
  String get learnUnit;

  /// No description provided for @learnUnitTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget basics'**
  String get learnUnitTitle;

  /// No description provided for @learnYourTurn.
  ///
  /// In en, this message translates to:
  /// **'YOUR TURN'**
  String get learnYourTurn;

  /// No description provided for @learnUnit3.
  ///
  /// In en, this message translates to:
  /// **'Unit 3: The TFSA 🇨🇦'**
  String get learnUnit3;

  /// No description provided for @quizKicker.
  ///
  /// In en, this message translates to:
  /// **'THE EMERGENCY FUND'**
  String get quizKicker;

  /// No description provided for @quizQuestion.
  ///
  /// In en, this message translates to:
  /// **'Where should your emergency fund live?'**
  String get quizQuestion;

  /// No description provided for @quizHint.
  ///
  /// In en, this message translates to:
  /// **'Pick the best answer.'**
  String get quizHint;

  /// No description provided for @quizCheck.
  ///
  /// In en, this message translates to:
  /// **'CHECK'**
  String get quizCheck;

  /// No description provided for @quizTryAgain.
  ///
  /// In en, this message translates to:
  /// **'TRY AGAIN'**
  String get quizTryAgain;

  /// No description provided for @quizWrong.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get quizWrong;

  /// No description provided for @learnDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get learnDone;

  /// No description provided for @learnLocked.
  ///
  /// In en, this message translates to:
  /// **'Finish the previous lesson'**
  String get learnLocked;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @profileMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String profileMemberSince(String date);

  /// No description provided for @profileGuest.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get profileGuest;

  /// No description provided for @quizExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get quizExcellent;

  /// No description provided for @quizExplain.
  ///
  /// In en, this message translates to:
  /// **'Easy to reach, with no nasty surprise.'**
  String get quizExplain;

  /// No description provided for @quizA.
  ///
  /// In en, this message translates to:
  /// **'In an accessible savings account'**
  String get quizA;

  /// No description provided for @quizB.
  ///
  /// In en, this message translates to:
  /// **'In high-risk stocks'**
  String get quizB;

  /// No description provided for @quizC.
  ///
  /// In en, this message translates to:
  /// **'Under my mattress'**
  String get quizC;

  /// No description provided for @quizD.
  ///
  /// In en, this message translates to:
  /// **'In a 10-year locked investment'**
  String get quizD;

  /// No description provided for @lessonDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'One more lesson,\none giant step.'**
  String get lessonDoneTitle;

  /// No description provided for @lessonDoneBravo.
  ///
  /// In en, this message translates to:
  /// **'Well done, {name}!'**
  String lessonDoneBravo(String name);

  /// No description provided for @lessonXp.
  ///
  /// In en, this message translates to:
  /// **'XP earned'**
  String get lessonXp;

  /// No description provided for @lessonAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get lessonAccuracy;

  /// No description provided for @lessonTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get lessonTime;

  /// No description provided for @streakKicker.
  ///
  /// In en, this message translates to:
  /// **'CONSISTENCY GROWS'**
  String get streakKicker;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'day streak!'**
  String get streakDays;

  /// No description provided for @streakThanks.
  ///
  /// In en, this message translates to:
  /// **'Your future self thanks you.'**
  String get streakThanks;

  /// No description provided for @giftTitleClosed.
  ///
  /// In en, this message translates to:
  /// **'A surprise for you'**
  String get giftTitleClosed;

  /// No description provided for @giftFrom.
  ///
  /// In en, this message translates to:
  /// **'From your friend Sipho.'**
  String get giftFrom;

  /// No description provided for @giftTap.
  ///
  /// In en, this message translates to:
  /// **'Tap to open'**
  String get giftTap;

  /// No description provided for @giftMagic.
  ///
  /// In en, this message translates to:
  /// **'A little magic for your adventure.'**
  String get giftMagic;

  /// No description provided for @giftOpenCta.
  ///
  /// In en, this message translates to:
  /// **'OPEN MY GIFT'**
  String get giftOpenCta;

  /// No description provided for @giftTitleOpen.
  ///
  /// In en, this message translates to:
  /// **'A gift you earned!'**
  String get giftTitleOpen;

  /// No description provided for @giftEffort.
  ///
  /// In en, this message translates to:
  /// **'Every small effort counts.'**
  String get giftEffort;

  /// No description provided for @giftSeeds.
  ///
  /// In en, this message translates to:
  /// **'+50 gold seeds'**
  String get giftSeeds;

  /// No description provided for @giftFreeze.
  ///
  /// In en, this message translates to:
  /// **'Streak freeze ×1'**
  String get giftFreeze;

  /// No description provided for @giftThanks.
  ///
  /// In en, this message translates to:
  /// **'THANKS, SIPHO!'**
  String get giftThanks;

  /// No description provided for @leagueTab.
  ///
  /// In en, this message translates to:
  /// **'League'**
  String get leagueTab;

  /// No description provided for @leagueFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get leagueFriends;

  /// No description provided for @leagueCountry.
  ///
  /// In en, this message translates to:
  /// **'My country'**
  String get leagueCountry;

  /// No description provided for @leagueTitle.
  ///
  /// In en, this message translates to:
  /// **'Gold League'**
  String get leagueTitle;

  /// No description provided for @leagueEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends in 2 d 5 h'**
  String get leagueEnds;

  /// No description provided for @leaguePromotion.
  ///
  /// In en, this message translates to:
  /// **'↑  PROMOTION ZONE · TOP 7'**
  String get leaguePromotion;

  /// No description provided for @leagueRelegation.
  ///
  /// In en, this message translates to:
  /// **'↓  RELEGATION ZONE · LAST 5'**
  String get leagueRelegation;

  /// No description provided for @profileMember.
  ///
  /// In en, this message translates to:
  /// **'Member since Nov 2026'**
  String get profileMember;

  /// No description provided for @profileShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get profileShop;

  /// No description provided for @profileStreak.
  ///
  /// In en, this message translates to:
  /// **'18 days'**
  String get profileStreak;

  /// No description provided for @profileStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get profileStreakLabel;

  /// No description provided for @profileXp.
  ///
  /// In en, this message translates to:
  /// **'2,480'**
  String get profileXp;

  /// No description provided for @profileXpLabel.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get profileXpLabel;

  /// No description provided for @profileLeague.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get profileLeague;

  /// No description provided for @profileLeagueLabel.
  ///
  /// In en, this message translates to:
  /// **'League'**
  String get profileLeagueLabel;

  /// No description provided for @profileLessons.
  ///
  /// In en, this message translates to:
  /// **'24'**
  String get profileLessons;

  /// No description provided for @profileLessonsLabel.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get profileLessonsLabel;

  /// No description provided for @profileBadges.
  ///
  /// In en, this message translates to:
  /// **'My badges'**
  String get profileBadges;

  /// No description provided for @profileGoals.
  ///
  /// In en, this message translates to:
  /// **'My goals'**
  String get profileGoals;

  /// No description provided for @profileGoal.
  ///
  /// In en, this message translates to:
  /// **'Trip to Cameroon · 1,200 / 3,000 \$'**
  String get profileGoal;

  /// No description provided for @profileInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite friends  →'**
  String get profileInvite;

  /// No description provided for @shopTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopTitle;

  /// No description provided for @shopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A style as unique as your adventure.'**
  String get shopSubtitle;

  /// No description provided for @shopBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get shopBuy;

  /// No description provided for @shopHat.
  ///
  /// In en, this message translates to:
  /// **'Sun hat'**
  String get shopHat;

  /// No description provided for @shopGlasses.
  ///
  /// In en, this message translates to:
  /// **'Cool glasses'**
  String get shopGlasses;

  /// No description provided for @shopScarfGreen.
  ///
  /// In en, this message translates to:
  /// **'Green wax scarf'**
  String get shopScarfGreen;

  /// No description provided for @shopScarfClay.
  ///
  /// In en, this message translates to:
  /// **'Terracotta scarf'**
  String get shopScarfClay;

  /// No description provided for @shopNest.
  ///
  /// In en, this message translates to:
  /// **'Flowered nest'**
  String get shopNest;

  /// No description provided for @shopFreeze.
  ///
  /// In en, this message translates to:
  /// **'Streak freeze'**
  String get shopFreeze;

  /// No description provided for @shopNote.
  ///
  /// In en, this message translates to:
  /// **'Seeds are earned, never bought with money.'**
  String get shopNote;

  /// No description provided for @adviceKicker.
  ///
  /// In en, this message translates to:
  /// **'AN IDEA FOR YOU'**
  String get adviceKicker;

  /// No description provided for @adviceTitle.
  ///
  /// In en, this message translates to:
  /// **'What if we cooked?'**
  String get adviceTitle;

  /// No description provided for @adviceBody.
  ///
  /// In en, this message translates to:
  /// **'Your restaurant outings are up 38% this month.'**
  String get adviceBody;

  /// No description provided for @adviceQuest.
  ///
  /// In en, this message translates to:
  /// **'QUEST · +50 XP'**
  String get adviceQuest;

  /// No description provided for @adviceQuestBody.
  ///
  /// In en, this message translates to:
  /// **'Two more home-cooked meals\nthis week'**
  String get adviceQuestBody;

  /// No description provided for @adviceAccept.
  ///
  /// In en, this message translates to:
  /// **'ACCEPT THE QUEST'**
  String get adviceAccept;

  /// No description provided for @adviceLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get adviceLater;

  /// No description provided for @adviceDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Educational content, not personalized financial advice.'**
  String get adviceDisclaimer;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications and sounds'**
  String get settingsSubtitle;

  /// No description provided for @settingsStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak reminders'**
  String get settingsStreak;

  /// No description provided for @settingsBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget alerts'**
  String get settingsBudget;

  /// No description provided for @settingsFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends and league'**
  String get settingsFriends;

  /// No description provided for @settingsTips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get settingsTips;

  /// No description provided for @settingsEconomy.
  ///
  /// In en, this message translates to:
  /// **'Economy news'**
  String get settingsEconomy;

  /// No description provided for @settingsRecap.
  ///
  /// In en, this message translates to:
  /// **'Monthly recap'**
  String get settingsRecap;

  /// No description provided for @settingsSounds.
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get settingsSounds;

  /// No description provided for @settingsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsHaptics;

  /// No description provided for @settingsVoice.
  ///
  /// In en, this message translates to:
  /// **'Sipho\'s voice'**
  String get settingsVoice;

  /// No description provided for @settingsReminder.
  ///
  /// In en, this message translates to:
  /// **'Preferred reminder time'**
  String get settingsReminder;

  /// No description provided for @settingsReminderTime.
  ///
  /// In en, this message translates to:
  /// **'7 PM'**
  String get settingsReminderTime;

  /// No description provided for @settingsSleep.
  ///
  /// In en, this message translates to:
  /// **'Promise, I\'ll respect your sleep.'**
  String get settingsSleep;

  /// No description provided for @recapKicker.
  ///
  /// In en, this message translates to:
  /// **'YOUR OCTOBER WITH SIPHO'**
  String get recapKicker;

  /// No description provided for @recapSpentTitle.
  ///
  /// In en, this message translates to:
  /// **'In October,\nyou logged'**
  String get recapSpentTitle;

  /// No description provided for @recapSpentCount.
  ///
  /// In en, this message translates to:
  /// **'64'**
  String get recapSpentCount;

  /// No description provided for @recapSpentLabel.
  ///
  /// In en, this message translates to:
  /// **'expenses 📝'**
  String get recapSpentLabel;

  /// No description provided for @recapProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Your best\nprogress'**
  String get recapProgressTitle;

  /// No description provided for @recapProgressCategory.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get recapProgressCategory;

  /// No description provided for @recapProgressValue.
  ///
  /// In en, this message translates to:
  /// **'−22%'**
  String get recapProgressValue;

  /// No description provided for @recapProgressCaption.
  ///
  /// In en, this message translates to:
  /// **'More balance. Still plenty of fun.'**
  String get recapProgressCaption;

  /// No description provided for @recapSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'You gave yourself\na gift of'**
  String get recapSavedTitle;

  /// No description provided for @recapSavedValue.
  ///
  /// In en, this message translates to:
  /// **'\$142'**
  String get recapSavedValue;

  /// No description provided for @recapSavedLabel.
  ///
  /// In en, this message translates to:
  /// **'in savings 🎁'**
  String get recapSavedLabel;

  /// No description provided for @recapShare.
  ///
  /// In en, this message translates to:
  /// **'SHARE'**
  String get recapShare;

  /// No description provided for @recapShareText.
  ///
  /// In en, this message translates to:
  /// **'My October with Sipho: 64 expenses logged, and \$142 saved.'**
  String get recapShareText;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Hey, I\'m Sipho! 👋'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your money adventure'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should I call you?'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your first name'**
  String get onboardingNameHint;

  /// No description provided for @onboardingCountryTitle.
  ///
  /// In en, this message translates to:
  /// **'Where do you live?'**
  String get onboardingCountryTitle;

  /// No description provided for @onboardingGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your main goal?'**
  String get onboardingGoalTitle;

  /// No description provided for @onboardingGoalSave.
  ///
  /// In en, this message translates to:
  /// **'Save more money'**
  String get onboardingGoalSave;

  /// No description provided for @onboardingGoalBudget.
  ///
  /// In en, this message translates to:
  /// **'Stick to a budget'**
  String get onboardingGoalBudget;

  /// No description provided for @onboardingGoalDebt.
  ///
  /// In en, this message translates to:
  /// **'Get out of debt'**
  String get onboardingGoalDebt;

  /// No description provided for @onboardingGoalInvest.
  ///
  /// In en, this message translates to:
  /// **'Start investing'**
  String get onboardingGoalInvest;

  /// No description provided for @onboardingCelebrationTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set, {name}! 🎉'**
  String onboardingCelebrationTitle(String name);

  /// No description provided for @notifPrimingTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay on track 🔥'**
  String get notifPrimingTitle;

  /// No description provided for @notifPrimingBody.
  ///
  /// In en, this message translates to:
  /// **'Get daily reminders to log expenses'**
  String get notifPrimingBody;

  /// No description provided for @notifPrimingAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get notifPrimingAllow;

  /// No description provided for @notifPrimingSkip.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get notifPrimingSkip;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}! ☀️'**
  String homeGreetingMorning(String name);

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}!'**
  String homeGreetingAfternoon(String name);

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}! 🌙'**
  String homeGreetingEvening(String name);

  /// No description provided for @remainingBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining today'**
  String get remainingBudgetLabel;

  /// No description provided for @budgetMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get budgetMonth;

  /// No description provided for @budgetSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get budgetSpent;

  /// No description provided for @budgetRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get budgetRemaining;

  /// No description provided for @budgetOver.
  ///
  /// In en, this message translates to:
  /// **'Over budget!'**
  String get budgetOver;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **'{days} day streak'**
  String streakLabel(int days);

  /// No description provided for @seedsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} seeds'**
  String seedsLabel(int count);

  /// No description provided for @xpLabel.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String xpLabel(int xp);

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelLabel(int level);

  /// No description provided for @questTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Quest'**
  String get questTitle;

  /// No description provided for @questComplete.
  ///
  /// In en, this message translates to:
  /// **'Quest complete! 🎯'**
  String get questComplete;

  /// No description provided for @expenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenseAmount;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseCategory;

  /// No description provided for @expenseNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get expenseNote;

  /// No description provided for @expenseDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get expenseDate;

  /// No description provided for @scanReceiptBtn.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get scanReceiptBtn;

  /// No description provided for @fixedExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Fixed expenses'**
  String get fixedExpensesTitle;

  /// No description provided for @fixedExpenseMarkPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as paid'**
  String get fixedExpenseMarkPaid;

  /// No description provided for @fixedExpensePaid.
  ///
  /// In en, this message translates to:
  /// **'Paid ✓'**
  String get fixedExpensePaid;

  /// No description provided for @economyTitle.
  ///
  /// In en, this message translates to:
  /// **'Economy'**
  String get economyTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get errorNetwork;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again.'**
  String get errorUnauthorized;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food & Drinks'**
  String get categoryFood;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get categoryHousing;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categorySavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get categorySavings;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileBtn.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editProfileBtn;

  /// No description provided for @editProfileCountry.
  ///
  /// In en, this message translates to:
  /// **'Country & currency'**
  String get editProfileCountry;

  /// No description provided for @editProfileGoal.
  ///
  /// In en, this message translates to:
  /// **'Main goal'**
  String get editProfileGoal;

  /// No description provided for @editProfileIncome.
  ///
  /// In en, this message translates to:
  /// **'Monthly net income'**
  String get editProfileIncome;

  /// No description provided for @editProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get editProfileSaved;

  /// No description provided for @editExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get editExpenseTitle;

  /// No description provided for @editExpenseMerchantHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Grocery store, Cafe…'**
  String get editExpenseMerchantHint;

  /// No description provided for @editExpenseNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get editExpenseNoteHint;

  /// No description provided for @editExpenseSaved.
  ///
  /// In en, this message translates to:
  /// **'Expense updated'**
  String get editExpenseSaved;

  /// No description provided for @editFixedTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit this item'**
  String get editFixedTitle;

  /// No description provided for @editFixedName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get editFixedName;

  /// No description provided for @editFixedSaved.
  ///
  /// In en, this message translates to:
  /// **'Item updated'**
  String get editFixedSaved;

  /// No description provided for @editFixedDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item removed'**
  String get editFixedDeleted;

  /// No description provided for @coachTitle.
  ///
  /// In en, this message translates to:
  /// **'Sipho\'s Advice'**
  String get coachTitle;

  /// No description provided for @coachSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Based strictly on your real numbers this month.'**
  String get coachSubtitle;

  /// No description provided for @coachTopicGeneral.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get coachTopicGeneral;

  /// No description provided for @coachTopicSpending.
  ///
  /// In en, this message translates to:
  /// **'My spending'**
  String get coachTopicSpending;

  /// No description provided for @coachTopicFixed.
  ///
  /// In en, this message translates to:
  /// **'My base'**
  String get coachTopicFixed;

  /// No description provided for @coachTopicGoal.
  ///
  /// In en, this message translates to:
  /// **'My goal'**
  String get coachTopicGoal;

  /// No description provided for @coachGenerateCta.
  ///
  /// In en, this message translates to:
  /// **'ASK SIPHO FOR ADVICE'**
  String get coachGenerateCta;

  /// No description provided for @coachRefreshCta.
  ///
  /// In en, this message translates to:
  /// **'NEW ADVICE'**
  String get coachRefreshCta;

  /// No description provided for @coachEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your income, a base item, or an expense, then ask Sipho to review your month.'**
  String get coachEmptyBody;

  /// No description provided for @coachActionTitle.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK\'S HABIT'**
  String get coachActionTitle;

  /// No description provided for @coachQuestBadge.
  ///
  /// In en, this message translates to:
  /// **'SUGGESTED CHALLENGE'**
  String get coachQuestBadge;

  /// No description provided for @coachDoLessonCta.
  ///
  /// In en, this message translates to:
  /// **'START RELATED LESSON'**
  String get coachDoLessonCta;

  /// No description provided for @coachLogExpenseCta.
  ///
  /// In en, this message translates to:
  /// **'LOG AN EXPENSE'**
  String get coachLogExpenseCta;

  /// No description provided for @coachOpenCard.
  ///
  /// In en, this message translates to:
  /// **'View advice →'**
  String get coachOpenCard;

  /// No description provided for @coachPreviousTitle.
  ///
  /// In en, this message translates to:
  /// **'Previous advice'**
  String get coachPreviousTitle;

  /// No description provided for @learnQuestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning quests'**
  String get learnQuestsTitle;

  /// No description provided for @learnQuestsSummary.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} completed'**
  String learnQuestsSummary(int done, int total);

  /// No description provided for @learnQuestClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get learnQuestClaim;

  /// No description provided for @learnQuestGo.
  ///
  /// In en, this message translates to:
  /// **'Start →'**
  String get learnQuestGo;

  /// No description provided for @learnQuestDoneBadge.
  ///
  /// In en, this message translates to:
  /// **'Completed ✓'**
  String get learnQuestDoneBadge;

  /// No description provided for @learnQuestAiTag.
  ///
  /// In en, this message translates to:
  /// **'AI Challenge'**
  String get learnQuestAiTag;

  /// No description provided for @learnQuestClaimError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t claim the reward right now.'**
  String get learnQuestClaimError;

  /// No description provided for @learnGenerateAiQuest.
  ///
  /// In en, this message translates to:
  /// **'✨ Custom AI challenge'**
  String get learnGenerateAiQuest;

  /// No description provided for @learnGeneratingAiQuest.
  ///
  /// In en, this message translates to:
  /// **'Generating…'**
  String get learnGeneratingAiQuest;

  /// No description provided for @quizAskAiTutor.
  ///
  /// In en, this message translates to:
  /// **'✨ Example with my numbers (Sipho AI)'**
  String get quizAskAiTutor;

  /// No description provided for @quizAiTutorLoading.
  ///
  /// In en, this message translates to:
  /// **'Sipho is preparing your example…'**
  String get quizAiTutorLoading;

  /// No description provided for @quizAiTutorTitle.
  ///
  /// In en, this message translates to:
  /// **'Sipho connects this to your budget'**
  String get quizAiTutorTitle;

  /// No description provided for @quizAiTutorError.
  ///
  /// In en, this message translates to:
  /// **'Sipho couldn\'t generate an example right now.'**
  String get quizAiTutorError;

  /// No description provided for @aiErrorNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable Firebase AI Logic (Gemini Developer API) in Firebase Console to activate Sipho AI.'**
  String get aiErrorNotEnabled;

  /// No description provided for @aiErrorAppCheck.
  ///
  /// In en, this message translates to:
  /// **'App Check blocked this dev device: register its debug token in Firebase Console > App Check (or unenforce AI Logic).'**
  String get aiErrorAppCheck;

  /// No description provided for @aiErrorQuota.
  ///
  /// In en, this message translates to:
  /// **'AI quota temporarily reached. Please try again in a few minutes.'**
  String get aiErrorQuota;

  /// No description provided for @aiErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network connection unavailable to reach Sipho AI.'**
  String get aiErrorNetwork;

  /// No description provided for @lessonSaveError.
  ///
  /// In en, this message translates to:
  /// **'Your progress couldn\'t be saved. Check your connection and try again.'**
  String get lessonSaveError;

  /// No description provided for @fixedMarkPaidError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t mark this bill as paid. Try again.'**
  String get fixedMarkPaidError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
