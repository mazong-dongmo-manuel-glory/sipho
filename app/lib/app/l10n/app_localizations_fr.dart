// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Sipho';

  @override
  String get tagline => 'Maîtrise ton argent';

  @override
  String get continueBtn => 'Continuer';

  @override
  String get skipBtn => 'Passer';

  @override
  String get doneBtn => 'Terminer';

  @override
  String get saveBtn => 'Enregistrer';

  @override
  String get cancelBtn => 'Annuler';

  @override
  String get deleteBtn => 'Supprimer';

  @override
  String get editBtn => 'Modifier';

  @override
  String get addBtn => 'Ajouter';

  @override
  String get confirmBtn => 'Confirmer';

  @override
  String get retryBtn => 'Réessayer';

  @override
  String get loginTitle => 'Content de te revoir !';

  @override
  String get loginSubtitle => 'Connecte-toi pour continuer';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get signInWithApple => 'Se connecter avec Apple';

  @override
  String get logoutBtn => 'Se déconnecter';

  @override
  String get onboardingWelcomeTitle => 'Salut, je suis Sipho ! 👋';

  @override
  String get onboardingWelcomeSubtitle => 'Prépare ton aventure financière';

  @override
  String get onboardingNameTitle => 'Comment je t\'appelle ?';

  @override
  String get onboardingNameHint => 'Ton prénom';

  @override
  String get onboardingCountryTitle => 'Où habites-tu ?';

  @override
  String get onboardingGoalTitle => 'Quel est ton objectif principal ?';

  @override
  String get onboardingGoalSave => 'Économiser plus';

  @override
  String get onboardingGoalBudget => 'Respecter un budget';

  @override
  String get onboardingGoalDebt => 'Sortir des dettes';

  @override
  String get onboardingGoalInvest => 'Commencer à investir';

  @override
  String onboardingCelebrationTitle(String name) {
    return 'Tu es prêt·e, $name ! 🎉';
  }

  @override
  String get notifPrimingTitle => 'Reste sur la bonne voie 🔥';

  @override
  String get notifPrimingBody =>
      'Reçois des rappels quotidiens pour noter tes dépenses';

  @override
  String get notifPrimingAllow => 'Autoriser les notifications';

  @override
  String get notifPrimingSkip => 'Peut-être plus tard';

  @override
  String get homeTitle => 'Accueil';

  @override
  String homeGreetingMorning(String name) {
    return 'Bonjour, $name ! ☀️';
  }

  @override
  String homeGreetingAfternoon(String name) {
    return 'Bon après-midi, $name !';
  }

  @override
  String homeGreetingEvening(String name) {
    return 'Bonsoir, $name ! 🌙';
  }

  @override
  String get remainingBudgetLabel => 'Reste aujourd\'hui';

  @override
  String get budgetTitle => 'Budget';

  @override
  String get budgetMonth => 'Ce mois-ci';

  @override
  String get budgetSpent => 'Dépensé';

  @override
  String get budgetRemaining => 'Restant';

  @override
  String get budgetOver => 'Budget dépassé !';

  @override
  String get learnTitle => 'Apprendre';

  @override
  String get leaderboardTitle => 'Classement';

  @override
  String get profileTitle => 'Profil';

  @override
  String streakLabel(int days) {
    return '$days jours de suite';
  }

  @override
  String seedsLabel(int count) {
    return '$count graines';
  }

  @override
  String xpLabel(int xp) {
    return '$xp XP';
  }

  @override
  String levelLabel(int level) {
    return 'Niveau $level';
  }

  @override
  String get questTitle => 'Quête du jour';

  @override
  String get questComplete => 'Quête terminée ! 🎯';

  @override
  String get addExpenseTitle => 'Ajouter une dépense';

  @override
  String get expenseAmount => 'Montant';

  @override
  String get expenseCategory => 'Catégorie';

  @override
  String get expenseNote => 'Note (optionnel)';

  @override
  String get expenseDate => 'Date';

  @override
  String get scanReceiptBtn => 'Scanner un reçu';

  @override
  String get fixedExpensesTitle => 'Dépenses fixes';

  @override
  String get fixedExpenseMarkPaid => 'Marquer comme payé';

  @override
  String get fixedExpensePaid => 'Payé ✓';

  @override
  String get economyTitle => 'Économie';

  @override
  String get shopTitle => 'Boutique';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsDeleteAccount => 'Supprimer le compte';

  @override
  String get errorGeneric => 'Une erreur est survenue. Réessaie.';

  @override
  String get errorNetwork => 'Pas de connexion internet.';

  @override
  String get errorUnauthorized => 'Reconnecte-toi s\'il te plaît.';

  @override
  String get categoryFood => 'Alimentation';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryHousing => 'Logement';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryEntertainment => 'Loisirs';

  @override
  String get categoryHealth => 'Santé';

  @override
  String get categorySavings => 'Épargne';

  @override
  String get categoryOther => 'Autre';
}
