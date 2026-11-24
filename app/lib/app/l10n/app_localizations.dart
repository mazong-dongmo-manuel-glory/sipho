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
    Locale('fr'),
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

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again in a moment.'**
  String get authErrorGeneric;

  /// No description provided for @authErrorAppleDisabled.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign-In isn’t enabled on this project. Try again later or use Google.'**
  String get authErrorAppleDisabled;

  /// No description provided for @authErrorInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'Invalid Apple credential. Try again or use another account.'**
  String get authErrorInvalidCredential;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your network and try again.'**
  String get authErrorNetwork;

  /// No description provided for @welcomeWordmark.
  ///
  /// In en, this message translates to:
  /// **'sipho'**
  String get welcomeWordmark;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your future self\nsays thank you.'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Two minutes to set the first foundations.'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeLegal.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you accept our terms and our privacy policy.'**
  String get welcomeLegal;

  /// No description provided for @loginExpertTitle.
  ///
  /// In en, this message translates to:
  /// **'You don’t need to be an expert.'**
  String get loginExpertTitle;

  /// No description provided for @loginExpertBody.
  ///
  /// In en, this message translates to:
  /// **'You’ll learn your money, at your pace. No judgment.'**
  String get loginExpertBody;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create my account'**
  String get loginCreateAccount;

  /// Settings row that opens the public privacy policy URL
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

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

  /// No description provided for @splashLead.
  ///
  /// In en, this message translates to:
  /// **'Money that grows.\nOne good habit at a time.'**
  String get splashLead;

  /// No description provided for @splashKicker.
  ///
  /// In en, this message translates to:
  /// **'SI-PO · “GIFT” IN ZULU'**
  String get splashKicker;

  /// No description provided for @splashCta.
  ///
  /// In en, this message translates to:
  /// **'Take the first step'**
  String get splashCta;

  /// No description provided for @splashFooter.
  ///
  /// In en, this message translates to:
  /// **'ONE SMALL STEP. A BIG FUTURE.'**
  String get splashFooter;

  /// No description provided for @onboardingNameHeading.
  ///
  /// In en, this message translates to:
  /// **'Shall we get acquainted?'**
  String get onboardingNameHeading;

  /// No description provided for @onboardingNameLead.
  ///
  /// In en, this message translates to:
  /// **'01 / 05 · About 2 minutes'**
  String get onboardingNameLead;

  /// No description provided for @onboardingNameBubbleTitle.
  ///
  /// In en, this message translates to:
  /// **'I\'m Sipho.'**
  String get onboardingNameBubbleTitle;

  /// No description provided for @onboardingNameBubble.
  ///
  /// In en, this message translates to:
  /// **'\"See-fo? No, See-po!\"\nAnd you, what\'s your name?'**
  String get onboardingNameBubble;

  /// No description provided for @onboardingNameLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR FIRST NAME'**
  String get onboardingNameLabel;

  /// No description provided for @onboardingNameHelper.
  ///
  /// In en, this message translates to:
  /// **'You can change it later.'**
  String get onboardingNameHelper;

  /// No description provided for @onboardingStepLead.
  ///
  /// In en, this message translates to:
  /// **'{step} / {total} · About 2 minutes'**
  String onboardingStepLead(String step, String total);

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

  /// No description provided for @onboardingLifeHeading.
  ///
  /// In en, this message translates to:
  /// **'Where are you in life?'**
  String get onboardingLifeHeading;

  /// No description provided for @onboardingLifeLead.
  ///
  /// In en, this message translates to:
  /// **'We adapt tips and lessons to your stage.'**
  String get onboardingLifeLead;

  /// No description provided for @onboardingLifeStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get onboardingLifeStudent;

  /// No description provided for @onboardingLifeFirstJob.
  ///
  /// In en, this message translates to:
  /// **'First job'**
  String get onboardingLifeFirstJob;

  /// No description provided for @onboardingLifeFamily.
  ///
  /// In en, this message translates to:
  /// **'Family life'**
  String get onboardingLifeFamily;

  /// No description provided for @onboardingLifePreRetirement.
  ///
  /// In en, this message translates to:
  /// **'Pre-retirement'**
  String get onboardingLifePreRetirement;

  /// No description provided for @onboardingLifeRetired.
  ///
  /// In en, this message translates to:
  /// **'Retired'**
  String get onboardingLifeRetired;

  /// No description provided for @onboardingIncomeHeading.
  ///
  /// In en, this message translates to:
  /// **'Your monthly income'**
  String get onboardingIncomeHeading;

  /// No description provided for @onboardingIncomeLead.
  ///
  /// In en, this message translates to:
  /// **'Optional — unlocks “left to spend” and under-budget quests.'**
  String get onboardingIncomeLead;

  /// No description provided for @onboardingIncomeBubble.
  ///
  /// In en, this message translates to:
  /// **'A rough number is enough. You can refine it later in your profile.'**
  String get onboardingIncomeBubble;

  /// No description provided for @onboardingIncomeHint.
  ///
  /// In en, this message translates to:
  /// **'Net income per month · you can skip'**
  String get onboardingIncomeHint;

  /// No description provided for @onboardingIncomeSkip.
  ///
  /// In en, this message translates to:
  /// **'I\'LL SET THIS LATER'**
  String get onboardingIncomeSkip;

  /// No description provided for @onboardingBuildNest.
  ///
  /// In en, this message translates to:
  /// **'BUILD MY NEST'**
  String get onboardingBuildNest;

  /// No description provided for @onboardingNestTitle.
  ///
  /// In en, this message translates to:
  /// **'One strand at a time.'**
  String get onboardingNestTitle;

  /// No description provided for @onboardingNestLead.
  ///
  /// In en, this message translates to:
  /// **'05 / 05 · Recurring expenses.'**
  String get onboardingNestLead;

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
  /// **'Right: yes. Left: no.'**
  String get onboardingNestHint;

  /// No description provided for @onboardingNestSwipe.
  ///
  /// In en, this message translates to:
  /// **'← No                            Yes →'**
  String get onboardingNestSwipe;

  /// No description provided for @onboardingNestYesRent.
  ///
  /// In en, this message translates to:
  /// **'Yes, add rent'**
  String get onboardingNestYesRent;

  /// No description provided for @onboardingNestSkip.
  ///
  /// In en, this message translates to:
  /// **'No, skip'**
  String get onboardingNestSkip;

  /// No description provided for @onboardingNestFooter.
  ///
  /// In en, this message translates to:
  /// **'Next: internet, phone…\nGroceries and transport become envelopes.'**
  String get onboardingNestFooter;

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
  /// **'Your nest is ready.'**
  String get nestReadyTitle;

  /// No description provided for @nestReadyLead.
  ///
  /// In en, this message translates to:
  /// **'It\'s only the beginning, and that already matters.'**
  String get nestReadyLead;

  /// No description provided for @nestReadyXp.
  ///
  /// In en, this message translates to:
  /// **'+50 XP'**
  String get nestReadyXp;

  /// No description provided for @nestReadyXpCardTitle.
  ///
  /// In en, this message translates to:
  /// **'+50 XP · First step'**
  String get nestReadyXpCardTitle;

  /// No description provided for @nestReadyXpCardBody.
  ///
  /// In en, this message translates to:
  /// **'For building your foundation.'**
  String get nestReadyXpCardBody;

  /// No description provided for @nestReadyBadge.
  ///
  /// In en, this message translates to:
  /// **'Builder'**
  String get nestReadyBadge;

  /// No description provided for @nestReadyBadgeRow.
  ///
  /// In en, this message translates to:
  /// **'Badge \"Nest built\"'**
  String get nestReadyBadgeRow;

  /// No description provided for @nestReadyDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Badges don\'t grant XP.\nYour money stays private.'**
  String get nestReadyDisclaimer;

  /// No description provided for @nestReadyCta.
  ///
  /// In en, this message translates to:
  /// **'Discover my home'**
  String get nestReadyCta;

  /// No description provided for @notifFlameTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay in touch?'**
  String get notifFlameTitle;

  /// No description provided for @notifFlameLead.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already done the important part.'**
  String get notifFlameLead;

  /// No description provided for @notifFlameCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Your nest is waiting.'**
  String get notifFlameCardTitle;

  /// No description provided for @notifFlameCardBody.
  ///
  /// In en, this message translates to:
  /// **'30 seconds to keep your flame.'**
  String get notifFlameCardBody;

  /// No description provided for @notifFlameBody.
  ///
  /// In en, this message translates to:
  /// **'Short, rare messages.\nYou choose which ones, and you can turn them all off.'**
  String get notifFlameBody;

  /// No description provided for @notifFlameYes.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get notifFlameYes;

  /// No description provided for @notifLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notifLater;

  /// No description provided for @homeHello.
  ///
  /// In en, this message translates to:
  /// **'Hello {name}'**
  String homeHello(String name);

  /// No description provided for @homeFutureLine.
  ///
  /// In en, this message translates to:
  /// **'Your future is taking shape.'**
  String get homeFutureLine;

  /// No description provided for @homeEveryStep.
  ///
  /// In en, this message translates to:
  /// **'Every small step counts.'**
  String get homeEveryStep;

  /// No description provided for @homeStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{count}-day streak'**
  String homeStreakDays(int count);

  /// No description provided for @homeSeedsLevel.
  ///
  /// In en, this message translates to:
  /// **'{seeds} seeds · Lvl {level}'**
  String homeSeedsLevel(String seeds, int level);

  /// No description provided for @homeComfortable.
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get homeComfortable;

  /// No description provided for @homeTight.
  ///
  /// In en, this message translates to:
  /// **'Tight'**
  String get homeTight;

  /// No description provided for @homeUnderZero.
  ///
  /// In en, this message translates to:
  /// **'Below zero'**
  String get homeUnderZero;

  /// No description provided for @homeQuestCount.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String homeQuestCount(int done, int total);

  /// No description provided for @homeOnTrackLine.
  ///
  /// In en, this message translates to:
  /// **'Your streak is holding. You’re on track.'**
  String get homeOnTrackLine;

  /// No description provided for @homeMonthRemainingKicker.
  ///
  /// In en, this message translates to:
  /// **'{month} · LEFT TO LIVE ON'**
  String homeMonthRemainingKicker(String month);

  /// No description provided for @homeComfortableCheck.
  ///
  /// In en, this message translates to:
  /// **'✓  Comfortable'**
  String get homeComfortableCheck;

  /// No description provided for @homeTightCheck.
  ///
  /// In en, this message translates to:
  /// **'✓  Tight'**
  String get homeTightCheck;

  /// No description provided for @homeUnderZeroCheck.
  ///
  /// In en, this message translates to:
  /// **'Below zero'**
  String get homeUnderZeroCheck;

  /// No description provided for @homeBreakdownEpure.
  ///
  /// In en, this message translates to:
  /// **'{income} income − {fixed} base − {spent}'**
  String homeBreakdownEpure(String income, String fixed, String spent);

  /// No description provided for @homeCheckOncePaid.
  ///
  /// In en, this message translates to:
  /// **'Check once paid'**
  String get homeCheckOncePaid;

  /// No description provided for @homeTakeLesson.
  ///
  /// In en, this message translates to:
  /// **'Take a lesson'**
  String get homeTakeLesson;

  /// No description provided for @homeReadEco.
  ///
  /// In en, this message translates to:
  /// **'Read the eco card'**
  String get homeReadEco;

  /// No description provided for @homeSpendWeekHeading.
  ///
  /// In en, this message translates to:
  /// **'Spending · 7 days'**
  String get homeSpendWeekHeading;

  /// No description provided for @homeSpendWeekEmpty.
  ///
  /// In en, this message translates to:
  /// **'No expenses this week yet.'**
  String get homeSpendWeekEmpty;

  /// No description provided for @homeFxHeading.
  ///
  /// In en, this message translates to:
  /// **'Today’s rate'**
  String get homeFxHeading;

  /// No description provided for @homeFxLine.
  ///
  /// In en, this message translates to:
  /// **'1 {base} ≈ {rate} {currency}'**
  String homeFxLine(String base, String rate, String currency);

  /// No description provided for @homeFxUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Rate unavailable right now.'**
  String get homeFxUnavailable;

  /// No description provided for @homeTipHeading.
  ///
  /// In en, this message translates to:
  /// **'Quick tip'**
  String get homeTipHeading;

  /// No description provided for @homeTipFallback.
  ///
  /// In en, this message translates to:
  /// **'Log one expense today — Sipho will help you see clearly.'**
  String get homeTipFallback;

  /// No description provided for @fabAddManual.
  ///
  /// In en, this message translates to:
  /// **'Log an expense'**
  String get fabAddManual;

  /// No description provided for @fabAddScan.
  ///
  /// In en, this message translates to:
  /// **'Scan a receipt (AI)'**
  String get fabAddScan;

  /// No description provided for @fabAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get fabAddTitle;

  /// No description provided for @expenseScanCta.
  ///
  /// In en, this message translates to:
  /// **'Scan with camera'**
  String get expenseScanCta;

  /// No description provided for @homeQuestNote3.
  ///
  /// In en, this message translates to:
  /// **'Log 3 expenses'**
  String get homeQuestNote3;

  /// No description provided for @homeQuestOneMore.
  ///
  /// In en, this message translates to:
  /// **'One more action for this quest.'**
  String get homeQuestOneMore;

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
    String income,
    String fixed,
    String spent,
  );

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

  /// No description provided for @homeGaugeSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Left to live on'**
  String get homeGaugeSheetTitle;

  /// No description provided for @homeGaugeSheetLead.
  ///
  /// In en, this message translates to:
  /// **'History, income and this month’s budget.'**
  String get homeGaugeSheetLead;

  /// No description provided for @homeGaugeIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget (income)'**
  String get homeGaugeIncomeLabel;

  /// No description provided for @homeGaugeIncomeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2800'**
  String get homeGaugeIncomeHint;

  /// No description provided for @homeGaugeIncomeSaved.
  ///
  /// In en, this message translates to:
  /// **'Income saved'**
  String get homeGaugeIncomeSaved;

  /// No description provided for @homeGaugeHistoryHeading.
  ///
  /// In en, this message translates to:
  /// **'Expense history'**
  String get homeGaugeHistoryHeading;

  /// No description provided for @homeGaugeHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month.'**
  String get homeGaugeHistoryEmpty;

  /// No description provided for @homeGaugeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all expenses'**
  String get homeGaugeSeeAll;

  /// No description provided for @homeGaugeBudgets.
  ///
  /// In en, this message translates to:
  /// **'Category limits'**
  String get homeGaugeBudgets;

  /// No description provided for @homeGaugeEditExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get homeGaugeEditExpense;

  /// No description provided for @homeGaugeMerchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get homeGaugeMerchant;

  /// No description provided for @homeGaugeAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get homeGaugeAmount;

  /// No description provided for @homeGaugeSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get homeGaugeSave;

  /// No description provided for @homeGaugeCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get homeGaugeCancel;

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

  /// No description provided for @homeQuestsProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String homeQuestsProgress(int done, int total);

  /// No description provided for @homeQuestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your quests for today are on their way. Check back in a moment!'**
  String get homeQuestsEmpty;

  /// No description provided for @homeBudgetDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Day under budget!'**
  String get homeBudgetDayTitle;

  /// No description provided for @homeBudgetDayBody.
  ///
  /// In en, this message translates to:
  /// **'You stayed within your budget yesterday. +{xp} XP for your consistency.'**
  String homeBudgetDayBody(int xp);

  /// No description provided for @homeNoSpendCta.
  ///
  /// In en, this message translates to:
  /// **'No spending today'**
  String get homeNoSpendCta;

  /// No description provided for @homeNoSpendDone.
  ///
  /// In en, this message translates to:
  /// **'Noted: your streak goes on.'**
  String get homeNoSpendDone;

  /// No description provided for @homeNoSpendError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t confirm right now. Please try again later.'**
  String get homeNoSpendError;

  /// No description provided for @friendsMyCode.
  ///
  /// In en, this message translates to:
  /// **'Your friend code'**
  String get friendsMyCode;

  /// No description provided for @friendsCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get friendsCopy;

  /// No description provided for @friendsCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get friendsCodeCopied;

  /// No description provided for @friendsShare.
  ///
  /// In en, this message translates to:
  /// **'Invite a friend'**
  String get friendsShare;

  /// No description provided for @friendsShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Join me on Sipho and make tracking your money fun! My friend code: {code}'**
  String friendsShareMessage(String code);

  /// No description provided for @friendsCodeError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your code right now.'**
  String get friendsCodeError;

  /// No description provided for @friendsAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a friend'**
  String get friendsAddTitle;

  /// No description provided for @friendsAddHint.
  ///
  /// In en, this message translates to:
  /// **'Your friend\'s code'**
  String get friendsAddHint;

  /// No description provided for @friendsAddCta.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get friendsAddCta;

  /// No description provided for @friendsRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent.'**
  String get friendsRequestSent;

  /// No description provided for @friendsNowFriends.
  ///
  /// In en, this message translates to:
  /// **'You are now friends!'**
  String get friendsNowFriends;

  /// No description provided for @friendsRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Requests received'**
  String get friendsRequestsTitle;

  /// No description provided for @friendsPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Requests sent'**
  String get friendsPendingTitle;

  /// No description provided for @friendsListTitle.
  ///
  /// In en, this message translates to:
  /// **'My friends'**
  String get friendsListTitle;

  /// No description provided for @friendsAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get friendsAccept;

  /// No description provided for @friendsDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get friendsDecline;

  /// No description provided for @friendsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get friendsRemove;

  /// No description provided for @friendsRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from your friends?'**
  String friendsRemoveConfirm(String name);

  /// No description provided for @friendsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Invite a friend to cheer each other on and follow your streaks together.'**
  String get friendsEmpty;

  /// No description provided for @friendsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Friends see your nickname, level, streak and league. Never your amounts.'**
  String get friendsPrivacy;

  /// No description provided for @friendsStats.
  ///
  /// In en, this message translates to:
  /// **'Level {level} · 🔥 {streak}'**
  String friendsStats(int level, int streak);

  /// No description provided for @friendsUnknownName.
  ///
  /// In en, this message translates to:
  /// **'Sipho friend'**
  String get friendsUnknownName;

  /// No description provided for @friendsRedeemTitle.
  ///
  /// In en, this message translates to:
  /// **'I have a referral code'**
  String get friendsRedeemTitle;

  /// No description provided for @friendsRedeemCta.
  ///
  /// In en, this message translates to:
  /// **'Redeem code'**
  String get friendsRedeemCta;

  /// No description provided for @friendsRedeemDone.
  ///
  /// In en, this message translates to:
  /// **'Welcome! +{xp} XP, and you are now friends.'**
  String friendsRedeemDone(int xp);

  /// No description provided for @friendsRedeemDonePending.
  ///
  /// In en, this message translates to:
  /// **'Welcome! You\'re friends now. Keep active for {days} days to unlock the referral XP (anti-abuse).'**
  String friendsRedeemDonePending(int days);

  /// No description provided for @friendsCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid code (letters and digits).'**
  String get friendsCodeInvalid;

  /// No description provided for @friendsErrCodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'This code doesn\'t exist. Check it with your friend.'**
  String get friendsErrCodeNotFound;

  /// No description provided for @friendsErrOwnCode.
  ///
  /// In en, this message translates to:
  /// **'That\'s your own code: share it with a friend.'**
  String get friendsErrOwnCode;

  /// No description provided for @friendsErrAlreadyDone.
  ///
  /// In en, this message translates to:
  /// **'Already done: request pending, already friends, or code already used.'**
  String get friendsErrAlreadyDone;

  /// No description provided for @friendsErrLimit.
  ///
  /// In en, this message translates to:
  /// **'Limit reached. Please try again later.'**
  String get friendsErrLimit;

  /// No description provided for @friendsErrNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Please try again in a moment.'**
  String get friendsErrNetwork;

  /// No description provided for @friendsErrNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This action is no longer possible.'**
  String get friendsErrNotAllowed;

  /// No description provided for @friendsErrGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get friendsErrGeneric;

  /// No description provided for @contactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Find your friends in your contacts'**
  String get contactsTitle;

  /// No description provided for @contactsIntro.
  ///
  /// In en, this message translates to:
  /// **'See which of your contacts are already on Sipho, and invite the others in one tap.'**
  String get contactsIntro;

  /// No description provided for @contactsFind.
  ///
  /// In en, this message translates to:
  /// **'Find my contacts'**
  String get contactsFind;

  /// No description provided for @contactsConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Use your contacts?'**
  String get contactsConsentTitle;

  /// No description provided for @contactsConsentBody.
  ///
  /// In en, this message translates to:
  /// **'Sipho compares your contacts\' e-mails and phone numbers with existing accounts as encrypted fingerprints: they are neither read nor kept by Sipho.\n\nIn return, people who have your verified e-mail or phone number in their contacts will be able to find you. You can opt out at any time.'**
  String get contactsConsentBody;

  /// No description provided for @contactsConsentAccept.
  ///
  /// In en, this message translates to:
  /// **'Agree and continue'**
  String get contactsConsentAccept;

  /// No description provided for @contactsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get contactsRefresh;

  /// No description provided for @contactsSuggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Already on Sipho'**
  String get contactsSuggestionsTitle;

  /// No description provided for @contactsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get contactsAdd;

  /// No description provided for @contactsMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get contactsMore;

  /// No description provided for @contactsNoneOnSipho.
  ///
  /// In en, this message translates to:
  /// **'None of your contacts is on Sipho yet. Invite them!'**
  String get contactsNoneOnSipho;

  /// No description provided for @contactsInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite your people'**
  String get contactsInviteTitle;

  /// No description provided for @contactsInviteSms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get contactsInviteSms;

  /// No description provided for @contactsInviteEmail.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get contactsInviteEmail;

  /// No description provided for @contactsInviteSubject.
  ///
  /// In en, this message translates to:
  /// **'Join me on Sipho'**
  String get contactsInviteSubject;

  /// No description provided for @contactsInviteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the messaging app.'**
  String get contactsInviteFailed;

  /// No description provided for @contactsDenied.
  ///
  /// In en, this message translates to:
  /// **'Sipho can\'t access your contacts.'**
  String get contactsDenied;

  /// No description provided for @contactsDeniedSettings.
  ///
  /// In en, this message translates to:
  /// **'Allow access in settings to continue.'**
  String get contactsDeniedSettings;

  /// No description provided for @contactsOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get contactsOpenSettings;

  /// No description provided for @contactsStop.
  ///
  /// In en, this message translates to:
  /// **'Stop being findable by my contacts'**
  String get contactsStop;

  /// No description provided for @contactsStopped.
  ///
  /// In en, this message translates to:
  /// **'You can no longer be found by your contacts.'**
  String get contactsStopped;

  /// No description provided for @contactsErrEmail.
  ///
  /// In en, this message translates to:
  /// **'A verified e-mail or phone number on your account is required to use contacts.'**
  String get contactsErrEmail;

  /// No description provided for @contactsAddPhone.
  ///
  /// In en, this message translates to:
  /// **'Add my number'**
  String get contactsAddPhone;

  /// No description provided for @contactsAddPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'So people who have your number can find you too (verified by SMS).'**
  String get contactsAddPhoneHint;

  /// No description provided for @contactsPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Your phone number'**
  String get contactsPhoneTitle;

  /// No description provided for @contactsPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get contactsPhoneLabel;

  /// No description provided for @contactsSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get contactsSendCode;

  /// No description provided for @contactsCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Code sent by SMS'**
  String get contactsCodeTitle;

  /// No description provided for @contactsCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get contactsCodeLabel;

  /// No description provided for @contactsVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get contactsVerify;

  /// No description provided for @contactsPhoneAdded.
  ///
  /// In en, this message translates to:
  /// **'Number verified and added.'**
  String get contactsPhoneAdded;

  /// No description provided for @contactsPhoneLinked.
  ///
  /// In en, this message translates to:
  /// **'Verified number: {phone}'**
  String contactsPhoneLinked(String phone);

  /// No description provided for @contactsErrPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'This number isn\'t valid. Add the country code (e.g. +225).'**
  String get contactsErrPhoneInvalid;

  /// No description provided for @contactsErrPhoneCode.
  ///
  /// In en, this message translates to:
  /// **'Wrong or expired code.'**
  String get contactsErrPhoneCode;

  /// No description provided for @contactsErrPhoneUsed.
  ///
  /// In en, this message translates to:
  /// **'This number is already used by another account.'**
  String get contactsErrPhoneUsed;

  /// No description provided for @contactsErrPhoneTooMany.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get contactsErrPhoneTooMany;

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

  /// No description provided for @homeCountryEconomyTitle.
  ///
  /// In en, this message translates to:
  /// **'Economy in {country}'**
  String homeCountryEconomyTitle(String country);

  /// No description provided for @homeEconomyInflationChip.
  ///
  /// In en, this message translates to:
  /// **'Inflation {value}'**
  String homeEconomyInflationChip(String value);

  /// No description provided for @homeEconomyRateChip.
  ///
  /// In en, this message translates to:
  /// **'Key rate {value}'**
  String homeEconomyRateChip(String value);

  /// No description provided for @homeFxChip.
  ///
  /// In en, this message translates to:
  /// **'1 {base} = {rate} {quote}'**
  String homeFxChip(String base, String rate, String quote);

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
  /// **'Personalised tips'**
  String get notifTipsTitle;

  /// No description provided for @notifTipsBody.
  ///
  /// In en, this message translates to:
  /// **'A tip from Sipho (AI) tailored to your lessons and budget, at most every 3 days. Only totals are analysed, never your name.'**
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

  /// No description provided for @addExpenseSteps.
  ///
  /// In en, this message translates to:
  /// **'1. Amount   →   2. Category   →   3. Confirm'**
  String get addExpenseSteps;

  /// No description provided for @addExpenseCta.
  ///
  /// In en, this message translates to:
  /// **'ADD'**
  String get addExpenseCta;

  /// No description provided for @addExpenseScan.
  ///
  /// In en, this message translates to:
  /// **'Scan a receipt'**
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

  /// No description provided for @catFamily.
  ///
  /// In en, this message translates to:
  /// **'Family / transfers'**
  String get catFamily;

  /// No description provided for @catInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get catInsurance;

  /// No description provided for @catWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get catWater;

  /// No description provided for @familyRecipientHint.
  ///
  /// In en, this message translates to:
  /// **'Who is this for?'**
  String get familyRecipientHint;

  /// No description provided for @familyFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Transfer fee (optional)'**
  String get familyFeeLabel;

  /// No description provided for @familyFeeHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get familyFeeHint;

  /// No description provided for @familyMonthTitle.
  ///
  /// In en, this message translates to:
  /// **'Sent to family'**
  String get familyMonthTitle;

  /// No description provided for @familyMonthBody.
  ///
  /// In en, this message translates to:
  /// **'{count} transfers · fees {fees}'**
  String familyMonthBody(int count, String fees);

  /// No description provided for @onTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re on the right track'**
  String get onTrackTitle;

  /// No description provided for @onTrackBody.
  ///
  /// In en, this message translates to:
  /// **'{days} days in a row, and this month still holds.'**
  String onTrackBody(int days);

  /// No description provided for @onTrackLogging.
  ///
  /// In en, this message translates to:
  /// **'You\'re logging expenses. That\'s the habit that counts.'**
  String get onTrackLogging;

  /// No description provided for @onTrackCatchUpTitle.
  ///
  /// In en, this message translates to:
  /// **'We can catch this up'**
  String get onTrackCatchUpTitle;

  /// No description provided for @onTrackCatchUpBody.
  ///
  /// In en, this message translates to:
  /// **'Living money went below zero. One small action is enough.'**
  String get onTrackCatchUpBody;

  /// No description provided for @onTrackStartTitle.
  ///
  /// In en, this message translates to:
  /// **'The first step counts'**
  String get onTrackStartTitle;

  /// No description provided for @onTrackStartBody.
  ///
  /// In en, this message translates to:
  /// **'Log an expense or finish a lesson. Sipho is with you.'**
  String get onTrackStartBody;

  /// No description provided for @recapKickerMonth.
  ///
  /// In en, this message translates to:
  /// **'YOUR {month} WITH SIPHO'**
  String recapKickerMonth(String month);

  /// No description provided for @recapSpentTitleMonth.
  ///
  /// In en, this message translates to:
  /// **'In {month},\nyou logged'**
  String recapSpentTitleMonth(String month);

  /// No description provided for @recapFocusDrop.
  ///
  /// In en, this message translates to:
  /// **'−{percent} %'**
  String recapFocusDrop(int percent);

  /// No description provided for @recapFocusShare.
  ///
  /// In en, this message translates to:
  /// **'{percent} % of the month'**
  String recapFocusShare(int percent);

  /// No description provided for @recapEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged this month yet'**
  String get recapEmptyTitle;

  /// No description provided for @recapEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your recap fills in from the expenses you actually enter.'**
  String get recapEmptyBody;

  /// No description provided for @recapShareReal.
  ///
  /// In en, this message translates to:
  /// **'My {month} with Sipho: {count} expenses logged, {saved} set aside versus last month.'**
  String recapShareReal(String month, int count, String saved);

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
  /// **'+2 XP'**
  String get rewardXp;

  /// No description provided for @rewardToast.
  ///
  /// In en, this message translates to:
  /// **'✓  Nice work! Your quest is moving forward.'**
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
  /// **'VARIABLE SPENDING THIS MONTH'**
  String get expensesSpentKicker;

  /// No description provided for @expensesFixedApart.
  ///
  /// In en, this message translates to:
  /// **'Fixed bills, kept apart'**
  String get expensesFixedApart;

  /// No description provided for @expensesSeeBills.
  ///
  /// In en, this message translates to:
  /// **'See the due dates →'**
  String get expensesSeeBills;

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

  /// No description provided for @expensesSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all transactions  →'**
  String get expensesSeeAll;

  /// No description provided for @expensesMonthPicker.
  ///
  /// In en, this message translates to:
  /// **'{month}  ↓'**
  String expensesMonthPicker(String month);

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

  /// No description provided for @expenseScannedBadge.
  ///
  /// In en, this message translates to:
  /// **'scanned'**
  String get expenseScannedBadge;

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
  /// **'Fixed on one side. Envelopes on the other.'**
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

  /// No description provided for @chartsFixedVsVariable.
  ///
  /// In en, this message translates to:
  /// **'Fixed vs variable'**
  String get chartsFixedVsVariable;

  /// No description provided for @chartsFixedLabel.
  ///
  /// In en, this message translates to:
  /// **'Fixed (nest)'**
  String get chartsFixedLabel;

  /// No description provided for @chartsVariableLabel.
  ///
  /// In en, this message translates to:
  /// **'Variable'**
  String get chartsVariableLabel;

  /// No description provided for @chartsSixMonths.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get chartsSixMonths;

  /// No description provided for @budgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetTitle;

  /// No description provided for @budgetIntro.
  ///
  /// In en, this message translates to:
  /// **'Here\'s how this month looks so far.'**
  String get budgetIntro;

  /// No description provided for @budgetStatusOk.
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get budgetStatusOk;

  /// No description provided for @budgetStatusWarn.
  ///
  /// In en, this message translates to:
  /// **'Watch out'**
  String get budgetStatusWarn;

  /// No description provided for @budgetStatusOver.
  ///
  /// In en, this message translates to:
  /// **'Slow down?'**
  String get budgetStatusOver;

  /// No description provided for @budgetSiphoAdviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Uh-oh. Slowing down?'**
  String get budgetSiphoAdviceTitle;

  /// No description provided for @budgetSiphoAdviceBody.
  ///
  /// In en, this message translates to:
  /// **'We can fix this this week.'**
  String get budgetSiphoAdviceBody;

  /// No description provided for @budgetGraphsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your charts'**
  String get budgetGraphsTitle;

  /// No description provided for @budgetGraphsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'4 simple views, no jargon'**
  String get budgetGraphsSubtitle;

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
  /// **'One small step\nto learn.'**
  String get learnTitle;

  /// No description provided for @learnPathLead.
  ///
  /// In en, this message translates to:
  /// **'Your path · 4 core units'**
  String get learnPathLead;

  /// No description provided for @learnYourTurn.
  ///
  /// In en, this message translates to:
  /// **'YOUR TURN'**
  String get learnYourTurn;

  /// No description provided for @learnSlotPending.
  ///
  /// In en, this message translates to:
  /// **'Not ready yet'**
  String get learnSlotPending;

  /// No description provided for @learnAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get learnAvailable;

  /// No description provided for @friendsChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge {name} ⚔️'**
  String friendsChallengeTitle(String name);

  /// No description provided for @friendsChallengeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a friendly challenge to motivate each other:'**
  String get friendsChallengeSubtitle;

  /// No description provided for @friendsChallengeSend.
  ///
  /// In en, this message translates to:
  /// **'Send challenge'**
  String get friendsChallengeSend;

  /// No description provided for @friendsChallengeSent.
  ///
  /// In en, this message translates to:
  /// **'Challenge \"{title}\" sent to {name}! ⚔️'**
  String friendsChallengeSent(String title, String name);

  /// No description provided for @friendsChallengeSendError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t send the challenge. Try again.'**
  String get friendsChallengeSendError;

  /// No description provided for @friendsChallengeYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get friendsChallengeYou;

  /// No description provided for @friendsChallengeAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept ⚔️'**
  String get friendsChallengeAccept;

  /// No description provided for @friendsChallengeWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name}…'**
  String friendsChallengeWaiting(String name);

  /// No description provided for @friendsChallengeWon.
  ///
  /// In en, this message translates to:
  /// **'🏆 Challenge won! Congrats!'**
  String get friendsChallengeWon;

  /// No description provided for @friendsChallengeFinishedBy.
  ///
  /// In en, this message translates to:
  /// **'🏁 Challenge finished by {name}'**
  String friendsChallengeFinishedBy(String name);

  /// No description provided for @friendsChallengesSection.
  ///
  /// In en, this message translates to:
  /// **'1v1 challenges ⚔️'**
  String get friendsChallengesSection;

  /// No description provided for @friendsChallengeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get friendsChallengeTooltip;

  /// No description provided for @friendsChallengeFriendFallback.
  ///
  /// In en, this message translates to:
  /// **'your friend'**
  String get friendsChallengeFriendFallback;

  /// No description provided for @learnUnit3.
  ///
  /// In en, this message translates to:
  /// **'03 · READ YOUR ACCOUNTS'**
  String get learnUnit3;

  /// No description provided for @learnUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'UNIT {number}'**
  String learnUnitLabel(int number);

  /// No description provided for @learnUnitProgress.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} lessons'**
  String learnUnitProgress(int done, int total);

  /// No description provided for @learnUnitBonus.
  ///
  /// In en, this message translates to:
  /// **'Finish it: +{xp} XP · +{seeds} seeds'**
  String learnUnitBonus(int xp, int seeds);

  /// No description provided for @learnUnitDone.
  ///
  /// In en, this message translates to:
  /// **'Unit complete ✓'**
  String get learnUnitDone;

  /// No description provided for @learnUnitLocked.
  ///
  /// In en, this message translates to:
  /// **'Finish the previous unit'**
  String get learnUnitLocked;

  /// No description provided for @lessonUnitCompleted.
  ///
  /// In en, this message translates to:
  /// **'Unit complete! Bonus: +{xp} XP · +{seeds} seeds'**
  String lessonUnitCompleted(int xp, int seeds);

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
  /// **'Check'**
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

  /// No description provided for @learnStart.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get learnStart;

  /// No description provided for @learnReplay.
  ///
  /// In en, this message translates to:
  /// **'REPLAY'**
  String get learnReplay;

  /// No description provided for @learnLessonMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String learnLessonMinutes(int minutes);

  /// No description provided for @learnLessonSteps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String learnLessonSteps(int count);

  /// No description provided for @learnLessonReward.
  ///
  /// In en, this message translates to:
  /// **'up to +{xp} XP'**
  String learnLessonReward(int xp);

  /// No description provided for @learnLessonObjective.
  ///
  /// In en, this message translates to:
  /// **'What you will learn'**
  String get learnLessonObjective;

  /// No description provided for @learnLessonDoneHint.
  ///
  /// In en, this message translates to:
  /// **'Already completed: replay to practice.'**
  String get learnLessonDoneHint;

  /// No description provided for @learnUnitGiftLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit-end gift'**
  String get learnUnitGiftLabel;

  /// No description provided for @learnYouAreHere.
  ///
  /// In en, this message translates to:
  /// **'You are here'**
  String get learnYouAreHere;

  /// No description provided for @lessonKickerRead.
  ///
  /// In en, this message translates to:
  /// **'DISCOVER'**
  String get lessonKickerRead;

  /// No description provided for @lessonKickerQuestion.
  ///
  /// In en, this message translates to:
  /// **'QUESTION'**
  String get lessonKickerQuestion;

  /// No description provided for @lessonKickerTrueFalse.
  ///
  /// In en, this message translates to:
  /// **'TRUE OR FALSE?'**
  String get lessonKickerTrueFalse;

  /// No description provided for @lessonTrue.
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get lessonTrue;

  /// No description provided for @lessonFalse.
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get lessonFalse;

  /// No description provided for @lessonRecapTitle.
  ///
  /// In en, this message translates to:
  /// **'To remember'**
  String get lessonRecapTitle;

  /// No description provided for @lessonRecapFinish.
  ///
  /// In en, this message translates to:
  /// **'FINISH'**
  String get lessonRecapFinish;

  /// No description provided for @lessonNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson not found'**
  String get lessonNotFoundTitle;

  /// No description provided for @lessonNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This lesson is no longer available. Pick another from your path.'**
  String get lessonNotFoundBody;

  /// No description provided for @lessonNotFoundCta.
  ///
  /// In en, this message translates to:
  /// **'Back to Learn'**
  String get lessonNotFoundCta;

  /// No description provided for @lessonLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave the lesson?'**
  String get lessonLeaveTitle;

  /// No description provided for @lessonLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress in this lesson will be lost.'**
  String get lessonLeaveBody;

  /// No description provided for @lessonLeaveStay.
  ///
  /// In en, this message translates to:
  /// **'STAY'**
  String get lessonLeaveStay;

  /// No description provided for @lessonLeaveQuit.
  ///
  /// In en, this message translates to:
  /// **'LEAVE'**
  String get lessonLeaveQuit;

  /// No description provided for @learnLockedHint.
  ///
  /// In en, this message translates to:
  /// **'Finish the previous lesson first to unlock this one.'**
  String get learnLockedHint;

  /// No description provided for @learnLessonPosition.
  ///
  /// In en, this message translates to:
  /// **'Lesson {number} of {total}'**
  String learnLessonPosition(int number, int total);

  /// No description provided for @learnClose.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get learnClose;

  /// No description provided for @lessonDoneBravoAnon.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get lessonDoneBravoAnon;

  /// No description provided for @lessonDoneLevelUp.
  ///
  /// In en, this message translates to:
  /// **'Level {level} reached!'**
  String lessonDoneLevelUp(int level);

  /// No description provided for @lessonDoneReplay.
  ///
  /// In en, this message translates to:
  /// **'Lesson already completed: a little more practice.'**
  String get lessonDoneReplay;

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

  /// No description provided for @giftSeedsAmount.
  ///
  /// In en, this message translates to:
  /// **'+{count} gold seeds'**
  String giftSeedsAmount(int count);

  /// No description provided for @giftXpAmount.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String giftXpAmount(int xp);

  /// No description provided for @giftLevelUp.
  ///
  /// In en, this message translates to:
  /// **'Level up!'**
  String get giftLevelUp;

  /// No description provided for @giftNothingNew.
  ///
  /// In en, this message translates to:
  /// **'This gift has already been opened.'**
  String get giftNothingNew;

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

  /// No description provided for @leagueTierBronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get leagueTierBronze;

  /// No description provided for @leagueTierSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get leagueTierSilver;

  /// No description provided for @leagueTierGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get leagueTierGold;

  /// No description provided for @leagueTierSapphire.
  ///
  /// In en, this message translates to:
  /// **'Sapphire'**
  String get leagueTierSapphire;

  /// No description provided for @leagueTierRuby.
  ///
  /// In en, this message translates to:
  /// **'Ruby'**
  String get leagueTierRuby;

  /// No description provided for @leagueTierEmerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get leagueTierEmerald;

  /// No description provided for @leagueTierAmethyst.
  ///
  /// In en, this message translates to:
  /// **'Amethyst'**
  String get leagueTierAmethyst;

  /// No description provided for @leagueTierPearl.
  ///
  /// In en, this message translates to:
  /// **'Pearl'**
  String get leagueTierPearl;

  /// No description provided for @leagueTierObsidian.
  ///
  /// In en, this message translates to:
  /// **'Obsidian'**
  String get leagueTierObsidian;

  /// No description provided for @leagueTierDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get leagueTierDiamond;

  /// No description provided for @leagueTitleNamed.
  ///
  /// In en, this message translates to:
  /// **'{tier} League'**
  String leagueTitleNamed(String tier);

  /// No description provided for @leagueTitleThe.
  ///
  /// In en, this message translates to:
  /// **'The {tier} League'**
  String leagueTitleThe(String tier);

  /// No description provided for @leagueGroupWeek.
  ///
  /// In en, this message translates to:
  /// **'This week’s group · Ends Sunday'**
  String get leagueGroupWeek;

  /// No description provided for @leagueXpOnly.
  ///
  /// In en, this message translates to:
  /// **'Ranking on XP only.'**
  String get leagueXpOnly;

  /// No description provided for @leagueNearLevel.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to go for level {level}'**
  String leagueNearLevel(int xp, int level);

  /// No description provided for @leaguePromoRules.
  ///
  /// In en, this message translates to:
  /// **'Top 7: promotion · Last 5: relegation'**
  String get leaguePromoRules;

  /// No description provided for @leagueSeeGroup.
  ///
  /// In en, this message translates to:
  /// **'{count} players · See the whole group →'**
  String leagueSeeGroup(int count);

  /// No description provided for @leaguePodiumSunday.
  ///
  /// In en, this message translates to:
  /// **'The podium lands on Sunday.'**
  String get leaguePodiumSunday;

  /// No description provided for @leagueCountryCity.
  ///
  /// In en, this message translates to:
  /// **'Country · City'**
  String get leagueCountryCity;

  /// No description provided for @leagueYouInline.
  ///
  /// In en, this message translates to:
  /// **'· you'**
  String get leagueYouInline;

  /// No description provided for @leagueEndsIn.
  ///
  /// In en, this message translates to:
  /// **'Ends in {duration}'**
  String leagueEndsIn(String duration);

  /// No description provided for @leagueEnded.
  ///
  /// In en, this message translates to:
  /// **'Week over · results coming up'**
  String get leagueEnded;

  /// No description provided for @leagueDurationDaysHours.
  ///
  /// In en, this message translates to:
  /// **'{days} d {hours} h'**
  String leagueDurationDaysHours(int days, int hours);

  /// No description provided for @leagueDurationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String leagueDurationHoursMinutes(int hours, int minutes);

  /// No description provided for @leagueXpValue.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String leagueXpValue(int xp);

  /// No description provided for @leagueYouSuffix.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get leagueYouSuffix;

  /// No description provided for @leagueAlone.
  ///
  /// In en, this message translates to:
  /// **'You\'re the only one in your group so far. Other players join as the week goes on.'**
  String get leagueAlone;

  /// No description provided for @leagueError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the league. Check your connection and try again.'**
  String get leagueError;

  /// No description provided for @leagueSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get leagueSoon;

  /// No description provided for @leagueResultPromoted.
  ///
  /// In en, this message translates to:
  /// **'Last week: #{rank}, promoted to {tier} League!'**
  String leagueResultPromoted(int rank, String tier);

  /// No description provided for @leagueResultRelegated.
  ///
  /// In en, this message translates to:
  /// **'Last week: #{rank}, moved down to {tier} League.'**
  String leagueResultRelegated(int rank, String tier);

  /// No description provided for @leagueResultStayed.
  ///
  /// In en, this message translates to:
  /// **'Last week: #{rank}, you stay in {tier} League.'**
  String leagueResultStayed(int rank, String tier);

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

  /// No description provided for @profileSpaceSince.
  ///
  /// In en, this message translates to:
  /// **'Your space · Since {date}'**
  String profileSpaceSince(String date);

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

  /// No description provided for @profileStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String profileStreakDays(int count);

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

  /// No description provided for @profileLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String profileLevelLabel(int level);

  /// No description provided for @profileXpValue.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String profileXpValue(String xp);

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
  /// **'Lessons completed'**
  String get profileLessonsLabel;

  /// No description provided for @profileBadges.
  ///
  /// In en, this message translates to:
  /// **'My badges'**
  String get profileBadges;

  /// No description provided for @profilePublic.
  ///
  /// In en, this message translates to:
  /// **'My public profile'**
  String get profilePublic;

  /// No description provided for @profilePublicHint.
  ///
  /// In en, this message translates to:
  /// **'Amounts are never shared'**
  String get profilePublicHint;

  /// No description provided for @profileSettingsRow.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettingsRow;

  /// No description provided for @badgeFirstLesson.
  ///
  /// In en, this message translates to:
  /// **'First lesson'**
  String get badgeFirstLesson;

  /// No description provided for @badgeFirstLessonHint.
  ///
  /// In en, this message translates to:
  /// **'Finish your first lesson.'**
  String get badgeFirstLessonHint;

  /// No description provided for @badgeUnit1.
  ///
  /// In en, this message translates to:
  /// **'Budget basics'**
  String get badgeUnit1;

  /// No description provided for @badgeUnit1Hint.
  ///
  /// In en, this message translates to:
  /// **'Finish unit 1.'**
  String get badgeUnit1Hint;

  /// No description provided for @badgeUnit2.
  ///
  /// In en, this message translates to:
  /// **'Saver'**
  String get badgeUnit2;

  /// No description provided for @badgeUnit2Hint.
  ///
  /// In en, this message translates to:
  /// **'Finish unit 2.'**
  String get badgeUnit2Hint;

  /// No description provided for @badgeStreak7.
  ///
  /// In en, this message translates to:
  /// **'7-day streak'**
  String get badgeStreak7;

  /// No description provided for @badgeStreak7Hint.
  ///
  /// In en, this message translates to:
  /// **'Reach a 7-day streak.'**
  String get badgeStreak7Hint;

  /// No description provided for @badgeStreak30.
  ///
  /// In en, this message translates to:
  /// **'30-day streak'**
  String get badgeStreak30;

  /// No description provided for @badgeStreak30Hint.
  ///
  /// In en, this message translates to:
  /// **'Reach a 30-day streak.'**
  String get badgeStreak30Hint;

  /// No description provided for @badgeLevel5.
  ///
  /// In en, this message translates to:
  /// **'Level 5'**
  String get badgeLevel5;

  /// No description provided for @badgeLevel5Hint.
  ///
  /// In en, this message translates to:
  /// **'Reach level 5.'**
  String get badgeLevel5Hint;

  /// No description provided for @badgeLevel10.
  ///
  /// In en, this message translates to:
  /// **'Level 10'**
  String get badgeLevel10;

  /// No description provided for @badgeLevel10Hint.
  ///
  /// In en, this message translates to:
  /// **'Reach level 10.'**
  String get badgeLevel10Hint;

  /// No description provided for @badgeLeagueSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver league'**
  String get badgeLeagueSilver;

  /// No description provided for @badgeLeagueSilverHint.
  ///
  /// In en, this message translates to:
  /// **'Move up to the Silver league.'**
  String get badgeLeagueSilverHint;

  /// No description provided for @badgeBuilder.
  ///
  /// In en, this message translates to:
  /// **'Nest builder'**
  String get badgeBuilder;

  /// No description provided for @badgeBuilderHint.
  ///
  /// In en, this message translates to:
  /// **'Finish building your nest (onboarding).'**
  String get badgeBuilderHint;

  /// No description provided for @badgeUnit3.
  ///
  /// In en, this message translates to:
  /// **'Money-smart'**
  String get badgeUnit3;

  /// No description provided for @badgeUnit3Hint.
  ///
  /// In en, this message translates to:
  /// **'Finish unit 3.'**
  String get badgeUnit3Hint;

  /// No description provided for @badgeUnit4.
  ///
  /// In en, this message translates to:
  /// **'Smart Investor'**
  String get badgeUnit4;

  /// No description provided for @badgeUnit4Hint.
  ///
  /// In en, this message translates to:
  /// **'Finish unit 4.'**
  String get badgeUnit4Hint;

  /// No description provided for @badgeEarnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get badgeEarnedLabel;

  /// No description provided for @badgeLockedLabel.
  ///
  /// In en, this message translates to:
  /// **'To earn'**
  String get badgeLockedLabel;

  /// No description provided for @learnQuestCompleteLesson.
  ///
  /// In en, this message translates to:
  /// **'Complete a lesson'**
  String get learnQuestCompleteLesson;

  /// No description provided for @learnQuestCompleteLessonSub.
  ///
  /// In en, this message translates to:
  /// **'Answer the quiz right to unlock the next step'**
  String get learnQuestCompleteLessonSub;

  /// No description provided for @learnQuestFinishUnit.
  ///
  /// In en, this message translates to:
  /// **'Finish the unit ({count} lessons)'**
  String learnQuestFinishUnit(int count);

  /// No description provided for @learnQuestFinishUnitSub.
  ///
  /// In en, this message translates to:
  /// **'{unitTitle} · {bonusXp} XP bonus at the end'**
  String learnQuestFinishUnitSub(String unitTitle, int bonusXp);

  /// No description provided for @learnQuestBuildFoundation.
  ///
  /// In en, this message translates to:
  /// **'Set up your monthly base'**
  String get learnQuestBuildFoundation;

  /// No description provided for @learnQuestBuildFoundationSub.
  ///
  /// In en, this message translates to:
  /// **'Set your income and at least 1 fixed bill'**
  String get learnQuestBuildFoundationSub;

  /// No description provided for @learnQuestTrackThree.
  ///
  /// In en, this message translates to:
  /// **'Log 3 expenses this month'**
  String get learnQuestTrackThree;

  /// No description provided for @learnQuestTrackThreeSub.
  ///
  /// In en, this message translates to:
  /// **'Put the spending tracking lesson into practice'**
  String get learnQuestTrackThreeSub;

  /// No description provided for @learnQuestLessonChallenge.
  ///
  /// In en, this message translates to:
  /// **'Lesson challenge'**
  String get learnQuestLessonChallenge;

  /// No description provided for @learnQuestTrackingChallenge.
  ///
  /// In en, this message translates to:
  /// **'Tracking challenge'**
  String get learnQuestTrackingChallenge;

  /// No description provided for @learnQuestPersonalized.
  ///
  /// In en, this message translates to:
  /// **'Personalized Sipho challenge'**
  String get learnQuestPersonalized;

  /// No description provided for @onboardingLocating.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get onboardingLocating;

  /// No description provided for @onboardingLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied. Pick your country instead.'**
  String get onboardingLocationDenied;

  /// No description provided for @onboardingLocationError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t read your location. Pick your country instead.'**
  String get onboardingLocationError;

  /// No description provided for @streakMilestonesTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak milestones'**
  String get streakMilestonesTitle;

  /// No description provided for @streakMilestoneReached.
  ///
  /// In en, this message translates to:
  /// **'Reached!'**
  String get streakMilestoneReached;

  /// No description provided for @streakRepairTitle.
  ///
  /// In en, this message translates to:
  /// **'Repair your streak?'**
  String get streakRepairTitle;

  /// No description provided for @streakRepairBody.
  ///
  /// In en, this message translates to:
  /// **'You missed yesterday. Repair within 24 h using 1 freeze.'**
  String get streakRepairBody;

  /// No description provided for @streakRepairCta.
  ///
  /// In en, this message translates to:
  /// **'REPAIR STREAK'**
  String get streakRepairCta;

  /// No description provided for @streakRepairDone.
  ///
  /// In en, this message translates to:
  /// **'Streak repaired!'**
  String get streakRepairDone;

  /// No description provided for @streakRepairError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t repair the streak.'**
  String get streakRepairError;

  /// No description provided for @streakRepairNoFreeze.
  ///
  /// In en, this message translates to:
  /// **'You need a streak freeze (shop).'**
  String get streakRepairNoFreeze;

  /// No description provided for @expenseCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get expenseCurrencyLabel;

  /// No description provided for @expenseFxUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Exchange rate unavailable for that currency. Try again later or use your main currency.'**
  String get expenseFxUnavailable;

  /// No description provided for @scanQuotaLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} scans left today'**
  String scanQuotaLeft(int count);

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

  /// No description provided for @addGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a goal'**
  String get addGoalTitle;

  /// No description provided for @addGoalBtn.
  ///
  /// In en, this message translates to:
  /// **'Create goal'**
  String get addGoalBtn;

  /// No description provided for @goalTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalTitleLabel;

  /// No description provided for @goalTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Vacation, Emergency fund...'**
  String get goalTitleHint;

  /// No description provided for @goalTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get goalTargetLabel;

  /// No description provided for @goalSavedLabel.
  ///
  /// In en, this message translates to:
  /// **'Already saved'**
  String get goalSavedLabel;

  /// No description provided for @goalDepositBtn.
  ///
  /// In en, this message translates to:
  /// **'Add savings'**
  String get goalDepositBtn;

  /// No description provided for @goalDepositTitle.
  ///
  /// In en, this message translates to:
  /// **'Add money to goal'**
  String get goalDepositTitle;

  /// No description provided for @goalDepositAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount to add'**
  String get goalDepositAmount;

  /// No description provided for @goalDepositConfirm.
  ///
  /// In en, this message translates to:
  /// **'Save deposit'**
  String get goalDepositConfirm;

  /// No description provided for @goalEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No savings goals yet'**
  String get goalEmptyTitle;

  /// No description provided for @goalEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a target (trip, project, buffer) and save step by step!'**
  String get goalEmptySubtitle;

  /// No description provided for @goalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Goal achieved 🎉'**
  String get goalCompleted;

  /// No description provided for @goalReachedBadge.
  ///
  /// In en, this message translates to:
  /// **'Done ✓'**
  String get goalReachedBadge;

  /// No description provided for @goalSaveQuick.
  ///
  /// In en, this message translates to:
  /// **'+ Save'**
  String get goalSaveQuick;

  /// No description provided for @goalTrackerCount.
  ///
  /// In en, this message translates to:
  /// **'{count} goals set'**
  String goalTrackerCount(int count);

  /// No description provided for @goalDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete goal'**
  String get goalDelete;

  /// No description provided for @goalDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this goal?'**
  String get goalDeleteConfirm;

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

  /// No description provided for @shopOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get shopOwned;

  /// No description provided for @shopStockFull.
  ///
  /// In en, this message translates to:
  /// **'Stock full'**
  String get shopStockFull;

  /// No description provided for @shopNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough seeds'**
  String get shopNotEnough;

  /// No description provided for @shopBought.
  ///
  /// In en, this message translates to:
  /// **'{item} is yours!'**
  String shopBought(String item);

  /// No description provided for @shopFreezeStock.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max} in stock'**
  String shopFreezeStock(int count, int max);

  /// No description provided for @shopRefusedOwned.
  ///
  /// In en, this message translates to:
  /// **'You already own this one.'**
  String get shopRefusedOwned;

  /// No description provided for @shopRefusedStock.
  ///
  /// In en, this message translates to:
  /// **'Your freeze stock is full.'**
  String get shopRefusedStock;

  /// No description provided for @shopRefusedSeeds.
  ///
  /// In en, this message translates to:
  /// **'You need more seeds for this.'**
  String get shopRefusedSeeds;

  /// No description provided for @shopError.
  ///
  /// In en, this message translates to:
  /// **'The purchase did not go through. Try again.'**
  String get shopError;

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
  /// **'At your pace'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re in control.'**
  String get settingsSubtitle;

  /// No description provided for @settingsEnabled.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settingsEnabled;

  /// No description provided for @settingsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsDisabled;

  /// No description provided for @settingsEnabledF.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settingsEnabledF;

  /// No description provided for @settingsDisabledF.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsDisabledF;

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
  /// **'News and rates'**
  String get settingsEconomy;

  /// No description provided for @settingsRecap.
  ///
  /// In en, this message translates to:
  /// **'Recaps'**
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
  /// **'Reminder time'**
  String get settingsReminder;

  /// No description provided for @settingsReminderTime.
  ///
  /// In en, this message translates to:
  /// **'7 PM'**
  String get settingsReminderTime;

  /// No description provided for @settingsSleep.
  ///
  /// In en, this message translates to:
  /// **'Each category can be turned off.\nPromise, I\'ll respect your sleep.'**
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

  /// No description provided for @coachHourlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Sipho coaching'**
  String get coachHourlyTitle;

  /// No description provided for @coachHourlyDismiss.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get coachHourlyDismiss;

  /// No description provided for @coachEducationLevel.
  ///
  /// In en, this message translates to:
  /// **'Level: {stage} · {score}/100'**
  String coachEducationLevel(String stage, int score);

  /// No description provided for @coachStageFoundation.
  ///
  /// In en, this message translates to:
  /// **'Foundations'**
  String get coachStageFoundation;

  /// No description provided for @coachStageHabits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get coachStageHabits;

  /// No description provided for @coachStageSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get coachStageSaving;

  /// No description provided for @coachStageProtect.
  ///
  /// In en, this message translates to:
  /// **'Protection'**
  String get coachStageProtect;

  /// No description provided for @coachStageGrow.
  ///
  /// In en, this message translates to:
  /// **'Growing'**
  String get coachStageGrow;

  /// No description provided for @coachEducationCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial education'**
  String get coachEducationCardTitle;

  /// No description provided for @coachEducationCardHint.
  ///
  /// In en, this message translates to:
  /// **'Progress from your lessons, streak and habits on Sipho.'**
  String get coachEducationCardHint;

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
  /// **'The server refused this device (App Check). Debug builds use the dev debug token registered in Firebase Console > App Check; release builds need Play Integrity / App Attest configured.'**
  String get aiErrorAppCheck;

  /// No description provided for @aiErrorQuota.
  ///
  /// In en, this message translates to:
  /// **'AI quota temporarily reached. Please try again in a few minutes.'**
  String get aiErrorQuota;

  /// No description provided for @aiErrorCredits.
  ///
  /// In en, this message translates to:
  /// **'The AI has no credit left on this Firebase project. Top up in AI Studio (ai.studio/projects), then try again.'**
  String get aiErrorCredits;

  /// No description provided for @aiErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network connection unavailable to reach Sipho AI.'**
  String get aiErrorNetwork;

  /// No description provided for @lessonSaveErrorAuth.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Sign in again, then try again.'**
  String get lessonSaveErrorAuth;

  /// No description provided for @lessonSaveErrorRefused.
  ///
  /// In en, this message translates to:
  /// **'This lesson could not be validated (it may still be locked).'**
  String get lessonSaveErrorRefused;

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

  /// No description provided for @ecoTipCatAll.
  ///
  /// In en, this message translates to:
  /// **'All 🌈'**
  String get ecoTipCatAll;

  /// No description provided for @ecoTipCatBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget 🛒'**
  String get ecoTipCatBudget;

  /// No description provided for @ecoTipCatSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving 🌱'**
  String get ecoTipCatSaving;

  /// No description provided for @ecoTipCatEconomy.
  ///
  /// In en, this message translates to:
  /// **'Economy 📉'**
  String get ecoTipCatEconomy;

  /// No description provided for @ecoTipCatSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security 🛡️'**
  String get ecoTipCatSecurity;

  /// No description provided for @ecoTipCatInvest.
  ///
  /// In en, this message translates to:
  /// **'Investing 🧺'**
  String get ecoTipCatInvest;

  /// No description provided for @ecoTipCatLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Daily Life 💡'**
  String get ecoTipCatLifestyle;

  /// No description provided for @ecoTipActionLabel.
  ///
  /// In en, this message translates to:
  /// **'ACTION STEP'**
  String get ecoTipActionLabel;

  /// No description provided for @ecoTipSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get ecoTipSource;

  /// No description provided for @ecoTipShuffle.
  ///
  /// In en, this message translates to:
  /// **'ANOTHER TIP 🎲'**
  String get ecoTipShuffle;

  /// No description provided for @ecoMetricInflation.
  ///
  /// In en, this message translates to:
  /// **'Annual Inflation'**
  String get ecoMetricInflation;

  /// No description provided for @ecoMetricPolicyRate.
  ///
  /// In en, this message translates to:
  /// **'Policy Rate'**
  String get ecoMetricPolicyRate;

  /// No description provided for @ecoMetricSavingsBenchmark.
  ///
  /// In en, this message translates to:
  /// **'Savings Benchmark'**
  String get ecoMetricSavingsBenchmark;

  /// No description provided for @ecoFxTitle.
  ///
  /// In en, this message translates to:
  /// **'Exchange rates'**
  String get ecoFxTitle;

  /// No description provided for @ecoFxBlurb.
  ///
  /// In en, this message translates to:
  /// **'European Central Bank reference, via Frankfurter. Sipho never invents a rate.'**
  String get ecoFxBlurb;

  /// No description provided for @ecoFxEmpty.
  ///
  /// In en, this message translates to:
  /// **'Rates are not in yet.'**
  String get ecoFxEmpty;

  /// No description provided for @ecoNewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sourced headlines'**
  String get ecoNewsTitle;

  /// No description provided for @ecoNewsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sourced archives · Not today’s news'**
  String get ecoNewsSubtitle;

  /// No description provided for @ecoIndicatorsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Official indicators unavailable.'**
  String get ecoIndicatorsUnavailable;

  /// No description provided for @ecoWhatItMeans.
  ///
  /// In en, this message translates to:
  /// **'What this means for you'**
  String get ecoWhatItMeans;

  /// No description provided for @ecoBenchmarkDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Official benchmark indicators dated {date}. Educational purposes.'**
  String ecoBenchmarkDisclaimer(String date);

  /// No description provided for @ecoNewsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No headlines for this country yet. They appear after the next server fetch.'**
  String get ecoNewsEmpty;

  /// No description provided for @ecoNewsFooter.
  ///
  /// In en, this message translates to:
  /// **'Older figures · Open the sources\nRefresh before you decide.'**
  String get ecoNewsFooter;

  /// No description provided for @ecoNewsRefresh.
  ///
  /// In en, this message translates to:
  /// **'See the latest figures'**
  String get ecoNewsRefresh;

  /// No description provided for @ecoNewsSiphoQuote.
  ///
  /// In en, this message translates to:
  /// **'Sipho: “{quote}”'**
  String ecoNewsSiphoQuote(String quote);

  /// No description provided for @expenseAmountHeading.
  ///
  /// In en, this message translates to:
  /// **'How much?'**
  String get expenseAmountHeading;

  /// No description provided for @expenseStepLead.
  ///
  /// In en, this message translates to:
  /// **'{step} / {total}'**
  String expenseStepLead(String step, String total);

  /// No description provided for @expenseCategoryHeading.
  ///
  /// In en, this message translates to:
  /// **'Where does it go?'**
  String get expenseCategoryHeading;

  /// No description provided for @expenseCategoryLead.
  ///
  /// In en, this message translates to:
  /// **'2 / 3 · Amount: {amount}'**
  String expenseCategoryLead(String amount);

  /// No description provided for @expenseConfirmHeading.
  ///
  /// In en, this message translates to:
  /// **'Before saving'**
  String get expenseConfirmHeading;

  /// No description provided for @expenseConfirmLead.
  ///
  /// In en, this message translates to:
  /// **'3 / 3 · You confirm.'**
  String get expenseConfirmLead;

  /// No description provided for @expenseConfirmCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseConfirmCategory;

  /// No description provided for @expenseConfirmDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get expenseConfirmDate;

  /// No description provided for @expenseConfirmMerchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get expenseConfirmMerchant;

  /// No description provided for @expenseConfirmEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit a detail  →'**
  String get expenseConfirmEdit;

  /// No description provided for @expenseConfirmPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing automatic.'**
  String get expenseConfirmPrivacyTitle;

  /// No description provided for @expenseConfirmPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Sipho never creates an expense without you.'**
  String get expenseConfirmPrivacyBody;

  /// No description provided for @lifeIncomeHeading.
  ///
  /// In en, this message translates to:
  /// **'And in your life?'**
  String get lifeIncomeHeading;

  /// No description provided for @lifeIncomeLead.
  ///
  /// In en, this message translates to:
  /// **'04 / 05 · Only what you want to share.'**
  String get lifeIncomeLead;

  /// No description provided for @lifeStageStudies.
  ///
  /// In en, this message translates to:
  /// **'Studies'**
  String get lifeStageStudies;

  /// No description provided for @lifeStageActive.
  ///
  /// In en, this message translates to:
  /// **'Working life'**
  String get lifeStageActive;

  /// No description provided for @lifeStageTransition.
  ///
  /// In en, this message translates to:
  /// **'Transition'**
  String get lifeStageTransition;

  /// No description provided for @lifeStageRetired.
  ///
  /// In en, this message translates to:
  /// **'Retirement'**
  String get lifeStageRetired;

  /// No description provided for @lifeIncomeOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly income · Optional'**
  String get lifeIncomeOptionalLabel;

  /// No description provided for @lifeIncomeHint.
  ///
  /// In en, this message translates to:
  /// **'2,800 CAD'**
  String get lifeIncomeHint;

  /// No description provided for @lifeIncomeNoIncomeHint.
  ///
  /// In en, this message translates to:
  /// **'Without income, we can’t compute remaining to live.'**
  String get lifeIncomeNoIncomeHint;

  /// No description provided for @lifeIncomeSkipIncome.
  ///
  /// In en, this message translates to:
  /// **'Continue without income'**
  String get lifeIncomeSkipIncome;

  /// No description provided for @goalsHeading.
  ///
  /// In en, this message translates to:
  /// **'My goals'**
  String get goalsHeading;

  /// No description provided for @goalsLead.
  ///
  /// In en, this message translates to:
  /// **'One project at a time. No pressure.'**
  String get goalsLead;

  /// No description provided for @goalsEmptyLead.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet — and that’s fine.'**
  String get goalsEmptyLead;

  /// No description provided for @goalsEmptyCardTitle.
  ///
  /// In en, this message translates to:
  /// **'A first goal'**
  String get goalsEmptyCardTitle;

  /// No description provided for @goalsEmptyCardBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a simple project. Sipho helps you move.'**
  String get goalsEmptyCardBody;

  /// No description provided for @goalsNewCta.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get goalsNewCta;

  /// No description provided for @goalsSampleTravel.
  ///
  /// In en, this message translates to:
  /// **'Trip to Cameroon'**
  String get goalsSampleTravel;

  /// No description provided for @goalsSampleEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency fund'**
  String get goalsSampleEmergency;

  /// No description provided for @goalsNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started yet'**
  String get goalsNotStarted;

  /// No description provided for @goalsSeeEmptyState.
  ///
  /// In en, this message translates to:
  /// **'See empty state'**
  String get goalsSeeEmptyState;

  /// No description provided for @milestoneHeading.
  ///
  /// In en, this message translates to:
  /// **'One month covered.'**
  String get milestoneHeading;

  /// No description provided for @milestoneLead.
  ///
  /// In en, this message translates to:
  /// **'Your emergency fund is growing.'**
  String get milestoneLead;

  /// No description provided for @milestoneKicker.
  ///
  /// In en, this message translates to:
  /// **'1 MONTH OF NEST · 1 / 3 OF TARGET'**
  String get milestoneKicker;

  /// No description provided for @milestoneCardTitle.
  ///
  /// In en, this message translates to:
  /// **'First milestone'**
  String get milestoneCardTitle;

  /// No description provided for @milestoneCardBody.
  ///
  /// In en, this message translates to:
  /// **'A badge for this step. No XP tied to the amount saved.'**
  String get milestoneCardBody;

  /// No description provided for @subTrimmedHeading.
  ///
  /// In en, this message translates to:
  /// **'Subscription trimmed'**
  String get subTrimmedHeading;

  /// No description provided for @subTrimmedLead.
  ///
  /// In en, this message translates to:
  /// **'You just freed a little air.'**
  String get subTrimmedLead;

  /// No description provided for @subTrimmedKicker.
  ///
  /// In en, this message translates to:
  /// **'PER MONTH · STREAMING REDUCED'**
  String get subTrimmedKicker;

  /// No description provided for @subTrimmedCard.
  ///
  /// In en, this message translates to:
  /// **'A lighter subscription = one more strand for your nest.'**
  String get subTrimmedCard;

  /// No description provided for @lessonCardHeading.
  ///
  /// In en, this message translates to:
  /// **'What’s an emergency fund?'**
  String get lessonCardHeading;

  /// No description provided for @lessonCardLead.
  ///
  /// In en, this message translates to:
  /// **'Saving · 1 / 4'**
  String get lessonCardLead;

  /// No description provided for @lessonCardBody.
  ///
  /// In en, this message translates to:
  /// **'A liquid reserve for surprises — without touching your daily budget.'**
  String get lessonCardBody;

  /// No description provided for @lessonCardSource.
  ///
  /// In en, this message translates to:
  /// **'Source: FCAC · Building an emergency fund'**
  String get lessonCardSource;

  /// No description provided for @lessonTfHeading.
  ///
  /// In en, this message translates to:
  /// **'An emergency fund\nmust be accessible.'**
  String get lessonTfHeading;

  /// No description provided for @lessonTfLead.
  ///
  /// In en, this message translates to:
  /// **'Saving · 3 / 4'**
  String get lessonTfLead;

  /// No description provided for @lessonTfTrue.
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get lessonTfTrue;

  /// No description provided for @lessonTfFalse.
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get lessonTfFalse;

  /// No description provided for @lessonTfCorrect.
  ///
  /// In en, this message translates to:
  /// **'Right. Accessible ≠ invested in stocks.'**
  String get lessonTfCorrect;

  /// No description provided for @lessonTfWrong.
  ///
  /// In en, this message translates to:
  /// **'Not quite — it should stay liquid.'**
  String get lessonTfWrong;

  /// No description provided for @lessonTfHint.
  ///
  /// In en, this message translates to:
  /// **'Take your time. No pressure here.'**
  String get lessonTfHint;

  /// No description provided for @lessonSimHeading.
  ///
  /// In en, this message translates to:
  /// **'You get a \$200 bonus.'**
  String get lessonSimHeading;

  /// No description provided for @lessonSimLead.
  ///
  /// In en, this message translates to:
  /// **'Mini-simulation · 4 / 4'**
  String get lessonSimLead;

  /// No description provided for @lessonSimOptA.
  ///
  /// In en, this message translates to:
  /// **'Spend it all now'**
  String get lessonSimOptA;

  /// No description provided for @lessonSimOptB.
  ///
  /// In en, this message translates to:
  /// **'Put \$150 in the cushion'**
  String get lessonSimOptB;

  /// No description provided for @lessonSimOptC.
  ///
  /// In en, this message translates to:
  /// **'Wait without deciding'**
  String get lessonSimOptC;

  /// No description provided for @lessonSimFeedbackGood.
  ///
  /// In en, this message translates to:
  /// **'Solid. Your cushion grows without total sacrifice.'**
  String get lessonSimFeedbackGood;

  /// No description provided for @lessonSimFeedbackOther.
  ///
  /// In en, this message translates to:
  /// **'Possible — see what your nest prefers.'**
  String get lessonSimFeedbackOther;

  /// No description provided for @badgeEarnedHeading.
  ///
  /// In en, this message translates to:
  /// **'New badge!'**
  String get badgeEarnedHeading;

  /// No description provided for @badgeEarnedLead.
  ///
  /// In en, this message translates to:
  /// **'A milestone, not a race.'**
  String get badgeEarnedLead;

  /// No description provided for @badgeEarnedName.
  ///
  /// In en, this message translates to:
  /// **'Nest built'**
  String get badgeEarnedName;

  /// No description provided for @badgeEarnedBody.
  ///
  /// In en, this message translates to:
  /// **'You set your base. No XP on this badge.'**
  String get badgeEarnedBody;

  /// No description provided for @badgeEarnedCta.
  ///
  /// In en, this message translates to:
  /// **'See my badges'**
  String get badgeEarnedCta;

  /// No description provided for @publicProfileHeading.
  ///
  /// In en, this message translates to:
  /// **'Public profile'**
  String get publicProfileHeading;

  /// No description provided for @publicProfileLead.
  ///
  /// In en, this message translates to:
  /// **'What friends see — never amounts.'**
  String get publicProfileLead;

  /// No description provided for @publicProfileLeague.
  ///
  /// In en, this message translates to:
  /// **'Gold league'**
  String get publicProfileLeague;

  /// No description provided for @publicProfileStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get publicProfileStreak;

  /// No description provided for @publicProfileLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get publicProfileLevel;

  /// No description provided for @publicProfileBadges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get publicProfileBadges;

  /// No description provided for @publicProfileLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get publicProfileLessons;

  /// No description provided for @publicProfilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Amounts, income and expenses stay private.'**
  String get publicProfilePrivacy;

  /// No description provided for @familySupportHeading.
  ///
  /// In en, this message translates to:
  /// **'Family support'**
  String get familySupportHeading;

  /// No description provided for @familySupportLead.
  ///
  /// In en, this message translates to:
  /// **'Plan without guilt.'**
  String get familySupportLead;

  /// No description provided for @familySupportKicker.
  ///
  /// In en, this message translates to:
  /// **'THIS MONTH · FAMILY ENVELOPES'**
  String get familySupportKicker;

  /// No description provided for @familySupportPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned transfer'**
  String get familySupportPlanned;

  /// No description provided for @familySupportExtra.
  ///
  /// In en, this message translates to:
  /// **'Extra help'**
  String get familySupportExtra;

  /// No description provided for @familySupportTip.
  ///
  /// In en, this message translates to:
  /// **'Set a soft ceiling. Your nest matters too.'**
  String get familySupportTip;

  /// No description provided for @travelModeHeading.
  ///
  /// In en, this message translates to:
  /// **'Travel mode'**
  String get travelModeHeading;

  /// No description provided for @travelModeLead.
  ///
  /// In en, this message translates to:
  /// **'Enter local currency; we convert.'**
  String get travelModeLead;

  /// No description provided for @travelModeToggle.
  ///
  /// In en, this message translates to:
  /// **'Enable travel mode'**
  String get travelModeToggle;

  /// No description provided for @travelModeCurrency.
  ///
  /// In en, this message translates to:
  /// **'Trip currency'**
  String get travelModeCurrency;

  /// No description provided for @travelModeFxHint.
  ///
  /// In en, this message translates to:
  /// **'Reference rate'**
  String get travelModeFxHint;

  /// No description provided for @travelModeFxBody.
  ///
  /// In en, this message translates to:
  /// **'Official source · never invented'**
  String get travelModeFxBody;

  /// No description provided for @travelModeCard.
  ///
  /// In en, this message translates to:
  /// **'Budgets stay in your home currency.'**
  String get travelModeCard;

  /// No description provided for @ecoHubHeading.
  ///
  /// In en, this message translates to:
  /// **'Eco info'**
  String get ecoHubHeading;

  /// No description provided for @ecoHubLead.
  ///
  /// In en, this message translates to:
  /// **'Always a source and a date. Never invented.'**
  String get ecoHubLead;

  /// No description provided for @ecoHubCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Food inflation · Canada'**
  String get ecoHubCardTitle;

  /// No description provided for @ecoHubCardBody.
  ///
  /// In en, this message translates to:
  /// **'3.4% · ≈ +\$11/mo on groceries'**
  String get ecoHubCardBody;

  /// No description provided for @ecoHubCardSource.
  ///
  /// In en, this message translates to:
  /// **'Source · StatCan · Nov 12, 2026'**
  String get ecoHubCardSource;

  /// No description provided for @ecoHistoryHeading.
  ///
  /// In en, this message translates to:
  /// **'Indicator history'**
  String get ecoHistoryHeading;

  /// No description provided for @ecoHistoryLead.
  ///
  /// In en, this message translates to:
  /// **'Sourced, dated archives.'**
  String get ecoHistoryLead;

  /// No description provided for @ecoHistoryItem1.
  ///
  /// In en, this message translates to:
  /// **'Food inflation'**
  String get ecoHistoryItem1;

  /// No description provided for @ecoHistoryItem2.
  ///
  /// In en, this message translates to:
  /// **'Policy rate'**
  String get ecoHistoryItem2;

  /// No description provided for @ecoHistoryItem3.
  ///
  /// In en, this message translates to:
  /// **'Overall CPI'**
  String get ecoHistoryItem3;

  /// No description provided for @ecoUnavailableHeading.
  ///
  /// In en, this message translates to:
  /// **'Indicators unavailable'**
  String get ecoUnavailableHeading;

  /// No description provided for @ecoUnavailableLead.
  ///
  /// In en, this message translates to:
  /// **'The server couldn’t refresh figures.'**
  String get ecoUnavailableLead;

  /// No description provided for @ecoUnavailableCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing invented'**
  String get ecoUnavailableCardTitle;

  /// No description provided for @ecoUnavailableCardBody.
  ///
  /// In en, this message translates to:
  /// **'Sipho prefers an empty screen to a fake number.'**
  String get ecoUnavailableCardBody;

  /// No description provided for @newsArchivesHeading.
  ///
  /// In en, this message translates to:
  /// **'News · Archives'**
  String get newsArchivesHeading;

  /// No description provided for @newsArchivesLead.
  ///
  /// In en, this message translates to:
  /// **'Not today’s feed — sourced archives.'**
  String get newsArchivesLead;

  /// No description provided for @newsArchivesItem1.
  ///
  /// In en, this message translates to:
  /// **'Cost of living and basket'**
  String get newsArchivesItem1;

  /// No description provided for @newsArchivesItem2.
  ///
  /// In en, this message translates to:
  /// **'Transfers and diaspora'**
  String get newsArchivesItem2;

  /// No description provided for @newsArchivesItem3.
  ///
  /// In en, this message translates to:
  /// **'Saving and rates'**
  String get newsArchivesItem3;

  /// No description provided for @ecoQuizHeading.
  ///
  /// In en, this message translates to:
  /// **'Economy quiz'**
  String get ecoQuizHeading;

  /// No description provided for @ecoQuizLead.
  ///
  /// In en, this message translates to:
  /// **'Weekly · 1 question, 1 source'**
  String get ecoQuizLead;

  /// No description provided for @ecoQuizQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is a policy rate for?'**
  String get ecoQuizQuestion;

  /// No description provided for @ecoQuizOptA.
  ///
  /// In en, this message translates to:
  /// **'Set the price of bread'**
  String get ecoQuizOptA;

  /// No description provided for @ecoQuizOptB.
  ///
  /// In en, this message translates to:
  /// **'Guide the cost of credit'**
  String get ecoQuizOptB;

  /// No description provided for @ecoQuizOptC.
  ///
  /// In en, this message translates to:
  /// **'Replace your budget'**
  String get ecoQuizOptC;

  /// No description provided for @ecoQuizCorrect.
  ///
  /// In en, this message translates to:
  /// **'Yes — it influences borrowing and saving.'**
  String get ecoQuizCorrect;

  /// No description provided for @ecoQuizWrong.
  ///
  /// In en, this message translates to:
  /// **'Not quite. Re-read the Eco card.'**
  String get ecoQuizWrong;

  /// No description provided for @ecoAlertsHeading.
  ///
  /// In en, this message translates to:
  /// **'Economy alerts'**
  String get ecoAlertsHeading;

  /// No description provided for @ecoAlertsLead.
  ///
  /// In en, this message translates to:
  /// **'Gentle, rare, always sourced.'**
  String get ecoAlertsLead;

  /// No description provided for @ecoAlertsRates.
  ///
  /// In en, this message translates to:
  /// **'Policy rate'**
  String get ecoAlertsRates;

  /// No description provided for @ecoAlertsFx.
  ///
  /// In en, this message translates to:
  /// **'FX'**
  String get ecoAlertsFx;

  /// No description provided for @ecoAlertsInflation.
  ///
  /// In en, this message translates to:
  /// **'Inflation'**
  String get ecoAlertsInflation;

  /// No description provided for @homeEmptyHeading.
  ///
  /// In en, this message translates to:
  /// **'Welcome Amina'**
  String get homeEmptyHeading;

  /// No description provided for @homeEmptyLead.
  ///
  /// In en, this message translates to:
  /// **'We start with what you know.'**
  String get homeEmptyLead;

  /// No description provided for @homeEmptyKicker.
  ///
  /// In en, this message translates to:
  /// **'REMAINING TO LIVE NOT CALCULATED'**
  String get homeEmptyKicker;

  /// No description provided for @homeEmptyCardTitle.
  ///
  /// In en, this message translates to:
  /// **'A first good habit'**
  String get homeEmptyCardTitle;

  /// No description provided for @homeEmptyCardBody.
  ///
  /// In en, this message translates to:
  /// **'Lay the first base of your budget.'**
  String get homeEmptyCardBody;

  /// No description provided for @homeEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Build my nest'**
  String get homeEmptyCta;

  /// No description provided for @homeLoadingHeading.
  ///
  /// In en, this message translates to:
  /// **'Loading your nest…'**
  String get homeLoadingHeading;

  /// No description provided for @homeLoadingLead.
  ///
  /// In en, this message translates to:
  /// **'One more second.'**
  String get homeLoadingLead;

  /// No description provided for @homeErrorHeading.
  ///
  /// In en, this message translates to:
  /// **'Home unavailable'**
  String get homeErrorHeading;

  /// No description provided for @homeErrorLead.
  ///
  /// In en, this message translates to:
  /// **'The connection slipped.'**
  String get homeErrorLead;

  /// No description provided for @homeErrorCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get homeErrorCardTitle;

  /// No description provided for @homeErrorCardBody.
  ///
  /// In en, this message translates to:
  /// **'Your data is safe on the server.'**
  String get homeErrorCardBody;

  /// No description provided for @homeTightHeading.
  ///
  /// In en, this message translates to:
  /// **'Getting tight'**
  String get homeTightHeading;

  /// No description provided for @homeTightLead.
  ///
  /// In en, this message translates to:
  /// **'Little left — no panic.'**
  String get homeTightLead;

  /// No description provided for @homeTightKicker.
  ///
  /// In en, this message translates to:
  /// **'REMAINING · END OF MONTH'**
  String get homeTightKicker;

  /// No description provided for @homeTightCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Gentle tip'**
  String get homeTightCardTitle;

  /// No description provided for @homeTightCardBody.
  ///
  /// In en, this message translates to:
  /// **'Postpone a non-urgent purchase.'**
  String get homeTightCardBody;

  /// No description provided for @homeTightCta.
  ///
  /// In en, this message translates to:
  /// **'See expenses'**
  String get homeTightCta;

  /// No description provided for @homeUnderHeading.
  ///
  /// In en, this message translates to:
  /// **'Below zero'**
  String get homeUnderHeading;

  /// No description provided for @homeUnderLead.
  ///
  /// In en, this message translates to:
  /// **'The nest is under strain.'**
  String get homeUnderLead;

  /// No description provided for @homeUnderKicker.
  ///
  /// In en, this message translates to:
  /// **'NEGATIVE REMAINING'**
  String get homeUnderKicker;

  /// No description provided for @homeUnderCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Let’s recalibrate'**
  String get homeUnderCardTitle;

  /// No description provided for @homeUnderCardBody.
  ///
  /// In en, this message translates to:
  /// **'Check envelopes and your base.'**
  String get homeUnderCardBody;

  /// No description provided for @homeUnderCta.
  ///
  /// In en, this message translates to:
  /// **'Open budgets'**
  String get homeUnderCta;

  /// No description provided for @homeBackHeading.
  ///
  /// In en, this message translates to:
  /// **'Glad you’re back'**
  String get homeBackHeading;

  /// No description provided for @homeBackLead.
  ///
  /// In en, this message translates to:
  /// **'Your streak can resume without pressure.'**
  String get homeBackLead;

  /// No description provided for @homeBackCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Back after a break'**
  String get homeBackCardTitle;

  /// No description provided for @homeBackCardBody.
  ///
  /// In en, this message translates to:
  /// **'One short lesson can relight the flame.'**
  String get homeBackCardBody;

  /// No description provided for @homeBackCta.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get homeBackCta;

  /// No description provided for @homeWellDoneHeading.
  ///
  /// In en, this message translates to:
  /// **'Well done'**
  String get homeWellDoneHeading;

  /// No description provided for @homeWellDoneLead.
  ///
  /// In en, this message translates to:
  /// **'One more good habit.'**
  String get homeWellDoneLead;

  /// No description provided for @homeWellDoneKicker.
  ///
  /// In en, this message translates to:
  /// **'SERVER REWARD'**
  String get homeWellDoneKicker;

  /// No description provided for @homeWellDoneCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily quest'**
  String get homeWellDoneCardTitle;

  /// No description provided for @homeWellDoneCardBody.
  ///
  /// In en, this message translates to:
  /// **'Log an expense · done'**
  String get homeWellDoneCardBody;

  /// No description provided for @homeWellDoneQuests.
  ///
  /// In en, this message translates to:
  /// **'Daily quests'**
  String get homeWellDoneQuests;

  /// No description provided for @homeWellDoneQuestsSub.
  ///
  /// In en, this message translates to:
  /// **'Log · Learn · Read'**
  String get homeWellDoneQuestsSub;

  /// No description provided for @expensesEmptyHeading.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesEmptyHeading;

  /// No description provided for @expensesEmptyLead.
  ///
  /// In en, this message translates to:
  /// **'This month is still empty.'**
  String get expensesEmptyLead;

  /// No description provided for @expensesEmptyKicker.
  ///
  /// In en, this message translates to:
  /// **'SPENT THIS MONTH'**
  String get expensesEmptyKicker;

  /// No description provided for @expensesEmptyCardTitle.
  ///
  /// In en, this message translates to:
  /// **'First trace'**
  String get expensesEmptyCardTitle;

  /// No description provided for @expensesEmptyCardBody.
  ///
  /// In en, this message translates to:
  /// **'Add an expense or scan a receipt.'**
  String get expensesEmptyCardBody;

  /// No description provided for @expensesEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get expensesEmptyCta;

  /// No description provided for @expensesErrorHeading.
  ///
  /// In en, this message translates to:
  /// **'Expenses unavailable'**
  String get expensesErrorHeading;

  /// No description provided for @expensesErrorLead.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load the list.'**
  String get expensesErrorLead;

  /// No description provided for @expensesErrorCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get expensesErrorCardTitle;

  /// No description provided for @expensesErrorCardBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing was lost.'**
  String get expensesErrorCardBody;

  /// No description provided for @expensesLoadingHeading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get expensesLoadingHeading;

  /// No description provided for @expensesLoadingLead.
  ///
  /// In en, this message translates to:
  /// **'Sorting your envelopes.'**
  String get expensesLoadingLead;

  /// No description provided for @notifExamplesHeading.
  ///
  /// In en, this message translates to:
  /// **'Notification examples'**
  String get notifExamplesHeading;

  /// No description provided for @notifExamplesLead.
  ///
  /// In en, this message translates to:
  /// **'Tone and frequency — no spam.'**
  String get notifExamplesLead;

  /// No description provided for @notifExamplesStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get notifExamplesStreakTitle;

  /// No description provided for @notifExamplesStreakBody.
  ///
  /// In en, this message translates to:
  /// **'Your flame holds 4 more hours. A micro-lesson?'**
  String get notifExamplesStreakBody;

  /// No description provided for @notifExamplesBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get notifExamplesBudgetTitle;

  /// No description provided for @notifExamplesBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'Groceries at 80% · \$42 left this week.'**
  String get notifExamplesBudgetBody;

  /// No description provided for @notifExamplesLeagueTitle.
  ///
  /// In en, this message translates to:
  /// **'League'**
  String get notifExamplesLeagueTitle;

  /// No description provided for @notifExamplesLeagueBody.
  ///
  /// In en, this message translates to:
  /// **'Sunday podium. You’re 4th — still in play.'**
  String get notifExamplesLeagueBody;

  /// No description provided for @tenLeaguesHeading.
  ///
  /// In en, this message translates to:
  /// **'The ten leagues'**
  String get tenLeaguesHeading;

  /// No description provided for @tenLeaguesLead.
  ///
  /// In en, this message translates to:
  /// **'Bronze to diamond — same pace for all.'**
  String get tenLeaguesLead;

  /// No description provided for @leagueBronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get leagueBronze;

  /// No description provided for @leagueSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get leagueSilver;

  /// No description provided for @leagueGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get leagueGold;

  /// No description provided for @leagueSapphire.
  ///
  /// In en, this message translates to:
  /// **'Sapphire'**
  String get leagueSapphire;

  /// No description provided for @leagueRuby.
  ///
  /// In en, this message translates to:
  /// **'Ruby'**
  String get leagueRuby;

  /// No description provided for @leagueEmerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get leagueEmerald;

  /// No description provided for @leagueAmethyst.
  ///
  /// In en, this message translates to:
  /// **'Amethyst'**
  String get leagueAmethyst;

  /// No description provided for @leaguePearl.
  ///
  /// In en, this message translates to:
  /// **'Pearl'**
  String get leaguePearl;

  /// No description provided for @leagueObsidian.
  ///
  /// In en, this message translates to:
  /// **'Obsidian'**
  String get leagueObsidian;

  /// No description provided for @leagueDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get leagueDiamond;

  /// No description provided for @podiumHeading.
  ///
  /// In en, this message translates to:
  /// **'Sunday podium'**
  String get podiumHeading;

  /// No description provided for @podiumLead.
  ///
  /// In en, this message translates to:
  /// **'The week closes — well done everyone.'**
  String get podiumLead;

  /// No description provided for @podiumFooter.
  ///
  /// In en, this message translates to:
  /// **'Amounts stay private. Only league XP counts.'**
  String get podiumFooter;

  /// No description provided for @chestsHeading.
  ///
  /// In en, this message translates to:
  /// **'Progress chests'**
  String get chestsHeading;

  /// No description provided for @chestsLead.
  ///
  /// In en, this message translates to:
  /// **'Unit rewards — via the server.'**
  String get chestsLead;

  /// No description provided for @chestsChest1.
  ///
  /// In en, this message translates to:
  /// **'Unit 1 chest'**
  String get chestsChest1;

  /// No description provided for @chestsChest1Sub.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get chestsChest1Sub;

  /// No description provided for @chestsChest2.
  ///
  /// In en, this message translates to:
  /// **'Unit 2 chest'**
  String get chestsChest2;

  /// No description provided for @chestsChest2Sub.
  ///
  /// In en, this message translates to:
  /// **'3 lessons left'**
  String get chestsChest2Sub;

  /// No description provided for @chestsChest3.
  ///
  /// In en, this message translates to:
  /// **'Unit 3 chest'**
  String get chestsChest3;

  /// No description provided for @chestsChest3Sub.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get chestsChest3Sub;

  /// No description provided for @androidErrorHeading.
  ///
  /// In en, this message translates to:
  /// **'Oops'**
  String get androidErrorHeading;

  /// No description provided for @androidErrorLead.
  ///
  /// In en, this message translates to:
  /// **'Android couldn’t open this screen.'**
  String get androidErrorLead;

  /// No description provided for @androidErrorCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Technical error'**
  String get androidErrorCardTitle;

  /// No description provided for @androidErrorCardBody.
  ///
  /// In en, this message translates to:
  /// **'Try again. If it persists, close and reopen Sipho.'**
  String get androidErrorCardBody;

  /// No description provided for @rewardHeading.
  ///
  /// In en, this message translates to:
  /// **'Logged.'**
  String get rewardHeading;

  /// No description provided for @rewardLead.
  ///
  /// In en, this message translates to:
  /// **'One more good habit.'**
  String get rewardLead;

  /// No description provided for @rewardSavedLine.
  ///
  /// In en, this message translates to:
  /// **'✓  {amount} saved'**
  String rewardSavedLine(String amount);

  /// No description provided for @rewardXpLine.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP for logging'**
  String rewardXpLine(int xp);

  /// No description provided for @rewardQuestProgress.
  ///
  /// In en, this message translates to:
  /// **'2 of 3 actions for your quest.'**
  String get rewardQuestProgress;

  /// No description provided for @rewardDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'You earn for logging.\nNot for spending.'**
  String get rewardDisclaimer;

  /// No description provided for @streakHelpHeading.
  ///
  /// In en, this message translates to:
  /// **'A helping hand'**
  String get streakHelpHeading;

  /// No description provided for @streakHelpLead.
  ///
  /// In en, this message translates to:
  /// **'Your flame can resume within 24h.'**
  String get streakHelpLead;

  /// No description provided for @streakHelpCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Repair with seeds'**
  String get streakHelpCardTitle;

  /// No description provided for @streakHelpCardBody.
  ///
  /// In en, this message translates to:
  /// **'The server decides. No client-side XP inventing.'**
  String get streakHelpCardBody;

  /// No description provided for @streakHelpCost.
  ///
  /// In en, this message translates to:
  /// **'Typical cost · 100 seeds (country pack)'**
  String get streakHelpCost;

  /// No description provided for @streakHelpCta.
  ///
  /// In en, this message translates to:
  /// **'Request repair'**
  String get streakHelpCta;

  /// No description provided for @streakHelpSkip.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get streakHelpSkip;

  /// No description provided for @recapHabitsKicker.
  ///
  /// In en, this message translates to:
  /// **'YOUR OCTOBER WITH SIPHO'**
  String get recapHabitsKicker;

  /// No description provided for @recapHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'In October you logged'**
  String get recapHabitsTitle;

  /// No description provided for @recapHabitsValue.
  ///
  /// In en, this message translates to:
  /// **'64 expenses'**
  String get recapHabitsValue;

  /// No description provided for @recapHabitsBody.
  ///
  /// In en, this message translates to:
  /// **'Every note is another strand for your nest.'**
  String get recapHabitsBody;

  /// No description provided for @recapCompareKicker.
  ///
  /// In en, this message translates to:
  /// **'YOUR OCTOBER WITH SIPHO'**
  String get recapCompareKicker;

  /// No description provided for @recapCompareTitle.
  ///
  /// In en, this message translates to:
  /// **'Compared to September'**
  String get recapCompareTitle;

  /// No description provided for @recapCompareValue.
  ///
  /// In en, this message translates to:
  /// **'−12%'**
  String get recapCompareValue;

  /// No description provided for @recapCompareBody.
  ///
  /// In en, this message translates to:
  /// **'You spent less while logging more often.'**
  String get recapCompareBody;

  /// No description provided for @recapGoalKicker.
  ///
  /// In en, this message translates to:
  /// **'YOUR OCTOBER WITH SIPHO'**
  String get recapGoalKicker;

  /// No description provided for @recapGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Your goal'**
  String get recapGoalTitle;

  /// No description provided for @recapGoalValue.
  ///
  /// In en, this message translates to:
  /// **'Understand my money'**
  String get recapGoalValue;

  /// No description provided for @recapGoalBody.
  ///
  /// In en, this message translates to:
  /// **'3 lessons done · keep going.'**
  String get recapGoalBody;

  /// No description provided for @recapStreakKicker.
  ///
  /// In en, this message translates to:
  /// **'YOUR STREAK'**
  String get recapStreakKicker;

  /// No description provided for @recapStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Active days this month'**
  String get recapStreakTitle;

  /// No description provided for @recapStreakValue.
  ///
  /// In en, this message translates to:
  /// **'18'**
  String get recapStreakValue;

  /// No description provided for @recapStreakBody.
  ///
  /// In en, this message translates to:
  /// **'Consistency beats intensity. Future you knows.'**
  String get recapStreakBody;

  /// No description provided for @recapBadgesKicker.
  ///
  /// In en, this message translates to:
  /// **'YOUR BADGES'**
  String get recapBadgesKicker;

  /// No description provided for @recapBadgesTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlocked this month'**
  String get recapBadgesTitle;

  /// No description provided for @recapBadgesValue.
  ///
  /// In en, this message translates to:
  /// **'2'**
  String get recapBadgesValue;

  /// No description provided for @recapBadgesBody.
  ///
  /// In en, this message translates to:
  /// **'No XP on a badge — just the milestone pride.'**
  String get recapBadgesBody;

  /// No description provided for @recapDecemberKicker.
  ///
  /// In en, this message translates to:
  /// **'DECEMBER RECAP'**
  String get recapDecemberKicker;

  /// No description provided for @recapDecemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Your year ends gently'**
  String get recapDecemberTitle;

  /// No description provided for @recapDecemberValue.
  ///
  /// In en, this message translates to:
  /// **'12 months'**
  String get recapDecemberValue;

  /// No description provided for @recapDecemberBody.
  ///
  /// In en, this message translates to:
  /// **'A clearer nest than in January. Onward.'**
  String get recapDecemberBody;

  /// No description provided for @recapBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to the nest'**
  String get recapBackHome;

  /// No description provided for @chartsHeading.
  ///
  /// In en, this message translates to:
  /// **'Your charts'**
  String get chartsHeading;

  /// No description provided for @chartsLead.
  ///
  /// In en, this message translates to:
  /// **'4 simple views, no jargon'**
  String get chartsLead;

  /// No description provided for @chartsDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'By day'**
  String get chartsDaysTitle;

  /// No description provided for @chartsDaysSub.
  ///
  /// In en, this message translates to:
  /// **'Week bars'**
  String get chartsDaysSub;

  /// No description provided for @chartsCatsTitle.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get chartsCatsTitle;

  /// No description provided for @chartsCatsSub.
  ///
  /// In en, this message translates to:
  /// **'Month ring'**
  String get chartsCatsSub;

  /// No description provided for @chartsSixTitle.
  ///
  /// In en, this message translates to:
  /// **'Six months'**
  String get chartsSixTitle;

  /// No description provided for @chartsSixSub.
  ///
  /// In en, this message translates to:
  /// **'Trend curve'**
  String get chartsSixSub;

  /// No description provided for @chartsStructureTitle.
  ///
  /// In en, this message translates to:
  /// **'Fixed vs variable'**
  String get chartsStructureTitle;

  /// No description provided for @chartsStructureSub.
  ///
  /// In en, this message translates to:
  /// **'Month structure'**
  String get chartsStructureSub;

  /// No description provided for @chartsInsight.
  ///
  /// In en, this message translates to:
  /// **'You spent 12% less than last month.'**
  String get chartsInsight;

  /// No description provided for @chartsDaysDetailLead.
  ///
  /// In en, this message translates to:
  /// **'Your week at a glance.'**
  String get chartsDaysDetailLead;

  /// No description provided for @chartsDaysPeak.
  ///
  /// In en, this message translates to:
  /// **'Busiest day'**
  String get chartsDaysPeak;

  /// No description provided for @chartsDaysCats.
  ///
  /// In en, this message translates to:
  /// **'Top category'**
  String get chartsDaysCats;

  /// No description provided for @chartsSixDetailLead.
  ///
  /// In en, this message translates to:
  /// **'Gentle trend over six months.'**
  String get chartsSixDetailLead;

  /// No description provided for @chartsSixInsight.
  ///
  /// In en, this message translates to:
  /// **'The line is down — your nest breathes easier.'**
  String get chartsSixInsight;

  /// No description provided for @chartsStructureFixed.
  ///
  /// In en, this message translates to:
  /// **'Nest (fixed)'**
  String get chartsStructureFixed;

  /// No description provided for @chartsStructureVar.
  ///
  /// In en, this message translates to:
  /// **'Variable'**
  String get chartsStructureVar;

  /// No description provided for @simHubHeading.
  ///
  /// In en, this message translates to:
  /// **'Simulators'**
  String get simHubHeading;

  /// No description provided for @simHubLead.
  ///
  /// In en, this message translates to:
  /// **'Educational · country pack rules, never regulated advice.'**
  String get simHubLead;

  /// No description provided for @simRetirementTitle.
  ///
  /// In en, this message translates to:
  /// **'Retirement'**
  String get simRetirementTitle;

  /// No description provided for @simRetirementSub.
  ///
  /// In en, this message translates to:
  /// **'Simple projection for your country'**
  String get simRetirementSub;

  /// No description provided for @simDebtTitle.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get simDebtTitle;

  /// No description provided for @simDebtSub.
  ///
  /// In en, this message translates to:
  /// **'Compare faster payoff'**
  String get simDebtSub;

  /// No description provided for @simCompoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Compound interest'**
  String get simCompoundTitle;

  /// No description provided for @simCompoundSub.
  ///
  /// In en, this message translates to:
  /// **'See time work for you'**
  String get simCompoundSub;

  /// No description provided for @simEduDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Educational only · not financial advice.'**
  String get simEduDisclaimer;

  /// No description provided for @simRetirementResult.
  ///
  /// In en, this message translates to:
  /// **'ILLUSTRATIVE PROJECTION'**
  String get simRetirementResult;

  /// No description provided for @simMonthlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly contribution · {amount}'**
  String simMonthlyLabel(String amount);

  /// No description provided for @simYearsLabel.
  ///
  /// In en, this message translates to:
  /// **'Horizon · {years} years'**
  String simYearsLabel(String years);

  /// No description provided for @simDebtBase.
  ///
  /// In en, this message translates to:
  /// **'Without extra'**
  String get simDebtBase;

  /// No description provided for @simDebtFaster.
  ///
  /// In en, this message translates to:
  /// **'With extra'**
  String get simDebtFaster;

  /// No description provided for @simMonths.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String simMonths(int count);

  /// No description provided for @simDebtBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance · {amount}'**
  String simDebtBalance(String amount);

  /// No description provided for @simDebtExtra.
  ///
  /// In en, this message translates to:
  /// **'Monthly extra · {amount}'**
  String simDebtExtra(String amount);

  /// No description provided for @simCompoundResult.
  ///
  /// In en, this message translates to:
  /// **'At ~5%/yr (illustrative)'**
  String get simCompoundResult;

  /// No description provided for @simCompoundSeed.
  ///
  /// In en, this message translates to:
  /// **'Starting amount · {amount}'**
  String simCompoundSeed(String amount);

  /// No description provided for @learnUnit1.
  ///
  /// In en, this message translates to:
  /// **'01 · BUDGET BASICS'**
  String get learnUnit1;

  /// No description provided for @learnUnit2.
  ///
  /// In en, this message translates to:
  /// **'02 · SAVING'**
  String get learnUnit2;

  /// No description provided for @learnUnit4.
  ///
  /// In en, this message translates to:
  /// **'04 · SMART CREDIT'**
  String get learnUnit4;

  /// No description provided for @learnUnit5.
  ///
  /// In en, this message translates to:
  /// **'05 · FAMILY AND TRAVEL'**
  String get learnUnit5;

  /// No description provided for @learnUnit5Ready.
  ///
  /// In en, this message translates to:
  /// **'One lesson ready soon'**
  String get learnUnit5Ready;

  /// No description provided for @learnUnit5Three.
  ///
  /// In en, this message translates to:
  /// **'Three lessons in the unit'**
  String get learnUnit5Three;

  /// No description provided for @learnUnit6.
  ///
  /// In en, this message translates to:
  /// **'06 · A FRESH START'**
  String get learnUnit6;

  /// No description provided for @learnUnit6Fresh.
  ///
  /// In en, this message translates to:
  /// **'When you come back after a break.'**
  String get learnUnit6Fresh;

  /// No description provided for @learnSeeChests.
  ///
  /// In en, this message translates to:
  /// **'See chests →'**
  String get learnSeeChests;

  /// No description provided for @learnJumpQuiz.
  ///
  /// In en, this message translates to:
  /// **'Jump to quiz →'**
  String get learnJumpQuiz;

  /// No description provided for @friendsChallengesHeading.
  ///
  /// In en, this message translates to:
  /// **'Friends and challenges'**
  String get friendsChallengesHeading;

  /// No description provided for @friendsTabFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendsTabFriends;

  /// No description provided for @friendsTabChallenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get friendsTabChallenges;

  /// No description provided for @friendsStreakTogether.
  ///
  /// In en, this message translates to:
  /// **'Shared streak'**
  String get friendsStreakTogether;

  /// No description provided for @friendsLevelPeer.
  ///
  /// In en, this message translates to:
  /// **'Same pace'**
  String get friendsLevelPeer;

  /// No description provided for @friendsPending.
  ///
  /// In en, this message translates to:
  /// **'Pending request'**
  String get friendsPending;

  /// No description provided for @friendsChallengeActive.
  ///
  /// In en, this message translates to:
  /// **'Challenge of the week'**
  String get friendsChallengeActive;

  /// No description provided for @friendsChallengeActiveBody.
  ///
  /// In en, this message translates to:
  /// **'Log 5 expenses before Sunday · with Nadia'**
  String get friendsChallengeActiveBody;

  /// No description provided for @friendsChallengeWeekly.
  ///
  /// In en, this message translates to:
  /// **'5 logs together'**
  String get friendsChallengeWeekly;

  /// No description provided for @friendsChallengeWeeklySub.
  ///
  /// In en, this message translates to:
  /// **'Never share amounts'**
  String get friendsChallengeWeeklySub;

  /// No description provided for @friendsChallengeInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite to a challenge'**
  String get friendsChallengeInvite;

  /// No description provided for @friendsChallengePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Challenges compare actions, not balances.'**
  String get friendsChallengePrivacy;

  /// No description provided for @quizCorrectHeading.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get quizCorrectHeading;

  /// No description provided for @quizCorrectLead.
  ///
  /// In en, this message translates to:
  /// **'Accessible and liquid — that’s the base.'**
  String get quizCorrectLead;

  /// No description provided for @quizCorrectExplain.
  ///
  /// In en, this message translates to:
  /// **'An emergency fund should be reachable quickly, without a forced sale.'**
  String get quizCorrectExplain;

  /// No description provided for @quizCorrectXp.
  ///
  /// In en, this message translates to:
  /// **'+10 accuracy XP (server)'**
  String get quizCorrectXp;

  /// No description provided for @quizWrongHint.
  ///
  /// In en, this message translates to:
  /// **'Not quite — accessible cash remains the base.'**
  String get quizWrongHint;
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
    'that was used.',
  );
}
