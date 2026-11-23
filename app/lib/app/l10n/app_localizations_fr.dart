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
  String get signInWithGoogle => 'Continuer avec Google';

  @override
  String get signInWithApple => 'Continuer avec Apple';

  @override
  String get authErrorGeneric =>
      'Connexion impossible. Réessaie dans un instant.';

  @override
  String get authErrorAppleDisabled =>
      'Connexion Apple non activée sur ce projet. Réessaie plus tard ou utilise Google.';

  @override
  String get authErrorInvalidCredential =>
      'Identifiant Apple invalide. Réessaie ou utilise un autre compte.';

  @override
  String get authErrorNetwork =>
      'Pas de connexion. Vérifie ton réseau et réessaie.';

  @override
  String get welcomeWordmark => 'sipho';

  @override
  String get welcomeTitle => 'Ton futur toi\nte dit merci.';

  @override
  String get welcomeSubtitle => 'Deux minutes pour poser les premières bases.';

  @override
  String get welcomeLegal =>
      'En continuant, tu acceptes nos conditions et notre politique de confidentialité.';

  @override
  String get loginExpertTitle => 'Pas besoin d’être expert.';

  @override
  String get loginExpertBody =>
      'On apprend à comprendre son argent, à son rythme. Sans jugement.';

  @override
  String get loginCreateAccount => 'Créer mon compte';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get logoutBtn => 'Se déconnecter';

  @override
  String get splashTagline => 'Fais-toi un cadeau :\nton avenir.';

  @override
  String get splashLead =>
      'L’argent qui grandit.\nUne bonne habitude à la fois.';

  @override
  String get splashKicker => 'SI-PO · « CADEAU » EN ZOULOU';

  @override
  String get splashCta => 'Faire le premier pas';

  @override
  String get splashFooter => 'UN PETIT PAS. UN GRAND AVENIR.';

  @override
  String get onboardingNameHeading => 'On fait connaissance ?';

  @override
  String get onboardingNameLead => '01 / 05 · Environ 2 minutes';

  @override
  String get onboardingNameBubbleTitle => 'Moi, c’est Sipho.';

  @override
  String get onboardingNameBubble =>
      '« Sifo ? Non, Si-po ! »\nEt toi, comment tu t’appelles ?';

  @override
  String get onboardingNameLabel => 'TON PRÉNOM';

  @override
  String get onboardingNameHelper => 'Tu pourras le changer plus tard.';

  @override
  String onboardingStepLead(String step, String total) {
    return '$step / $total · Environ 2 minutes';
  }

  @override
  String get onboardingCountryHeading => 'Tu vis où ?';

  @override
  String get onboardingCountryLead => 'On adapte ton nid à ta réalité.';

  @override
  String get onboardingUseLocation => 'Utiliser ma position';

  @override
  String onboardingNestRoot(String country) {
    return 'Ton nid prend racine au $country !';
  }

  @override
  String get onboardingGoalHeading => 'Un objectif,\nplein de possibilités.';

  @override
  String get onboardingGoalLead => 'Quel est ton objectif principal ?';

  @override
  String get onboardingGoalOverdraft => 'Arrêter d’être à découvert';

  @override
  String get onboardingGoalProject => 'Épargner pour un projet';

  @override
  String get onboardingGoalUnderstand => 'Comprendre mon argent';

  @override
  String get onboardingGoalRetire => 'Préparer ma retraite';

  @override
  String get onboardingGoalCheer => 'On y va, un petit pas à la fois !';

  @override
  String get onboardingLifeHeading => 'Où en es-tu dans la vie ?';

  @override
  String get onboardingLifeLead => 'On adapte conseils et leçons à ton étape.';

  @override
  String get onboardingLifeStudent => 'Étudiant·e';

  @override
  String get onboardingLifeFirstJob => 'Premier emploi';

  @override
  String get onboardingLifeFamily => 'Vie de famille';

  @override
  String get onboardingLifePreRetirement => 'Avant la retraite';

  @override
  String get onboardingLifeRetired => 'À la retraite';

  @override
  String get onboardingIncomeHeading => 'Ton revenu mensuel';

  @override
  String get onboardingIncomeLead =>
      'Optionnel — débloque le « reste à vivre » et les quêtes sous budget.';

  @override
  String get onboardingIncomeBubble =>
      'Un ordre de grandeur suffit. Tu pourras l’ajuster plus tard dans ton profil.';

  @override
  String get onboardingIncomeHint => 'Revenu net par mois · tu peux passer';

  @override
  String get onboardingIncomeSkip => 'JE LE FERAI PLUS TARD';

  @override
  String get onboardingBuildNest => 'CONSTRUIRE MON NID';

  @override
  String get onboardingNestTitle => 'Un brin après l’autre.';

  @override
  String get onboardingNestLead => '05 / 05 · Les dépenses qui reviennent.';

  @override
  String onboardingNestStrands(int count) {
    return '$count brins tissés';
  }

  @override
  String get onboardingNestQuestion => 'Tu paies un loyer ?';

  @override
  String get onboardingNestHint => 'À droite : oui. À gauche : non.';

  @override
  String get onboardingNestSwipe => '← Non                            Oui →';

  @override
  String get onboardingNestYesRent => 'Oui, ajouter le loyer';

  @override
  String get onboardingNestSkip => 'Non, passer';

  @override
  String get onboardingNestFooter =>
      'Ensuite : Internet, téléphone…\nÉpicerie et transport seront des enveloppes.';

  @override
  String get fixedSocle => 'Mon socle';

  @override
  String get fixedRent => 'Loyer';

  @override
  String get fixedPerMonth => 'par mois · CAD';

  @override
  String get fixedDue => 'Prélevé le : 1er du mois';

  @override
  String get fixedAuto => 'Paiement automatique';

  @override
  String get fixedAdd => 'AJOUTER AU NID';

  @override
  String get nestReadyKicker => 'UNE BELLE PREMIÈRE ÉTAPE';

  @override
  String get nestReadyTitle => 'Ton nid est prêt.';

  @override
  String get nestReadyLead => 'C’est le début, et c’est déjà quelque chose.';

  @override
  String get nestReadyXp => '+50 XP';

  @override
  String get nestReadyXpCardTitle => '+50 XP · Premier pas';

  @override
  String get nestReadyXpCardBody => 'Pour avoir construit ton socle.';

  @override
  String get nestReadyBadge => 'Bâtisseur';

  @override
  String get nestReadyBadgeRow => 'Badge « Nid construit »';

  @override
  String get nestReadyDisclaimer =>
      'Les badges ne donnent pas d’XP.\nTon argent reste privé.';

  @override
  String get nestReadyCta => 'Découvrir mon accueil';

  @override
  String get notifFlameTitle => 'On garde le lien ?';

  @override
  String get notifFlameLead => 'Tu as déjà fait le plus important.';

  @override
  String get notifFlameCardTitle => 'Ton nid t’attend.';

  @override
  String get notifFlameCardBody => '30 secondes pour garder ta flamme.';

  @override
  String get notifFlameBody =>
      'Des messages courts et rares.\nTu choisis lesquels, et tu peux tout couper.';

  @override
  String get notifFlameYes => 'Autoriser les notifications';

  @override
  String get notifLater => 'Pas maintenant';

  @override
  String homeHello(String name) {
    return 'Bonjour $name';
  }

  @override
  String get homeFutureLine => 'Ton avenir prend forme.';

  @override
  String get homeEveryStep => 'Chaque petit pas compte.';

  @override
  String homeStreakDays(int count) {
    return '$count jours de série';
  }

  @override
  String homeSeedsLevel(String seeds, int level) {
    return '$seeds graines · Niv. $level';
  }

  @override
  String get homeComfortable => 'Confortable';

  @override
  String get homeTight => 'Juste';

  @override
  String get homeUnderZero => 'En dessous de zéro';

  @override
  String homeQuestCount(int done, int total) {
    return '$done sur $total';
  }

  @override
  String get homeOnTrackLine => 'Ta série tient. Tu es sur la bonne voie.';

  @override
  String homeLevelPill(int level) {
    return 'NIV. $level';
  }

  @override
  String get homeRemainingKicker => 'RESTE À VIVRE';

  @override
  String get homeRemainingCaption => 'reste pour novembre';

  @override
  String homeRemainingCaptionMonth(String month) {
    return 'reste pour $month';
  }

  @override
  String get homeRemainingBreakdown =>
      'Revenu 2 800 \$ · Fixes 1 690 \$ · Dépensé 468 \$';

  @override
  String homeRemainingBreakdownValues(
      String income, String fixed, String spent) {
    return 'Revenu $income · Fixes $fixed · Dépensé $spent';
  }

  @override
  String get homeSetIncome => 'Touche le montant pour indiquer ton revenu';

  @override
  String get homeGuestName => 'toi';

  @override
  String get homeLatestExpense => 'Dernière dépense';

  @override
  String get homeNoExpenseYet => 'Rien pour l\'instant';

  @override
  String get homeAddFirstExpense => 'Ajoute une dépense avec +';

  @override
  String get incomeSheetTitle => 'Revenu mensuel';

  @override
  String get incomeSheetCta => 'ENREGISTRER';

  @override
  String get incomeSaveError => 'Le revenu n\'a pas été enregistré. Réessaie.';

  @override
  String get expenseSaveError =>
      'La dépense n\'a pas été enregistrée. Réessaie.';

  @override
  String get expensesEmpty => 'Aucune dépense ce mois-ci.';

  @override
  String get expensesLoadError => 'Impossible de charger tes dépenses.';

  @override
  String get homeNextExpense => 'Prochaine dépense · demain';

  @override
  String get homePaid => 'Payé ✓';

  @override
  String get homeQuests => 'Quêtes du jour';

  @override
  String homeQuestsProgress(int done, int total) {
    return '$done sur $total';
  }

  @override
  String get homeQuestsEmpty =>
      'Tes quêtes du jour arrivent. Reviens dans un instant !';

  @override
  String get homeBudgetDayTitle => 'Journée sous budget !';

  @override
  String homeBudgetDayBody(int xp) {
    return 'Tu as tenu ton budget hier. +$xp XP pour ta régularité.';
  }

  @override
  String get homeNoSpendCta => 'Aucune dépense aujourd\'hui';

  @override
  String get homeNoSpendDone => 'C\'est noté : ta série continue.';

  @override
  String get homeNoSpendError =>
      'Impossible de confirmer pour le moment. Réessaie plus tard.';

  @override
  String get friendsMyCode => 'Ton code ami';

  @override
  String get friendsCopy => 'Copier';

  @override
  String get friendsCodeCopied => 'Code copié';

  @override
  String get friendsShare => 'Inviter un ami';

  @override
  String friendsShareMessage(String code) {
    return 'Rejoins-moi sur Sipho pour suivre ton argent en t\'amusant ! Mon code ami : $code';
  }

  @override
  String get friendsCodeError =>
      'Impossible de charger ton code pour le moment.';

  @override
  String get friendsAddTitle => 'Ajouter un ami';

  @override
  String get friendsAddHint => 'Code de ton ami';

  @override
  String get friendsAddCta => 'Envoyer la demande';

  @override
  String get friendsRequestSent => 'Demande envoyée.';

  @override
  String get friendsNowFriends => 'Vous êtes maintenant amis !';

  @override
  String get friendsRequestsTitle => 'Demandes reçues';

  @override
  String get friendsPendingTitle => 'Demandes envoyées';

  @override
  String get friendsListTitle => 'Mes amis';

  @override
  String get friendsAccept => 'Accepter';

  @override
  String get friendsDecline => 'Refuser';

  @override
  String get friendsRemove => 'Retirer';

  @override
  String friendsRemoveConfirm(String name) {
    return 'Retirer $name de tes amis ?';
  }

  @override
  String get friendsEmpty =>
      'Invite un ami pour vous encourager et suivre vos séries ensemble.';

  @override
  String get friendsPrivacy =>
      'Tes amis voient ton pseudo, ton niveau, ta série et ta ligue. Jamais tes montants.';

  @override
  String friendsStats(int level, int streak) {
    return 'Niveau $level · 🔥 $streak';
  }

  @override
  String get friendsUnknownName => 'Ami Sipho';

  @override
  String get friendsRedeemTitle => 'J\'ai un code de parrainage';

  @override
  String get friendsRedeemCta => 'Valider le code';

  @override
  String friendsRedeemDone(int xp) {
    return 'Bienvenue ! +$xp XP, et vous voilà amis.';
  }

  @override
  String friendsRedeemDonePending(int days) {
    return 'Bienvenue ! Vous êtes amis. Reste actif $days jours pour débloquer l\'XP de parrainage (anti-abus).';
  }

  @override
  String get friendsCodeInvalid =>
      'Entre un code valide (lettres et chiffres).';

  @override
  String get friendsErrCodeNotFound =>
      'Ce code n\'existe pas. Vérifie-le avec ton ami.';

  @override
  String get friendsErrOwnCode =>
      'C\'est ton propre code : partage-le à un ami.';

  @override
  String get friendsErrAlreadyDone =>
      'Déjà fait : demande en attente, amitié existante ou code déjà utilisé.';

  @override
  String get friendsErrLimit => 'Limite atteinte. Réessaie plus tard.';

  @override
  String get friendsErrNetwork => 'Pas de connexion. Réessaie dans un instant.';

  @override
  String get friendsErrNotAllowed => 'Cette action n\'est plus possible.';

  @override
  String get friendsErrGeneric => 'Une erreur est survenue. Réessaie.';

  @override
  String get contactsTitle => 'Retrouve tes amis dans tes contacts';

  @override
  String get contactsIntro =>
      'Vois qui, parmi tes contacts, est déjà sur Sipho, et invite les autres en un geste.';

  @override
  String get contactsFind => 'Trouver mes contacts';

  @override
  String get contactsConsentTitle => 'Utiliser tes contacts ?';

  @override
  String get contactsConsentBody =>
      'Sipho compare les e-mails et les numéros de tes contacts avec les comptes existants, sous forme d\'empreintes chiffrées : ils ne sont ni lus par Sipho ni conservés.\n\nEn échange, les personnes qui ont ton e-mail ou ton numéro vérifié dans leurs contacts pourront te trouver. Tu peux t\'en retirer à tout moment.';

  @override
  String get contactsConsentAccept => 'Accepter et continuer';

  @override
  String get contactsRefresh => 'Actualiser';

  @override
  String get contactsSuggestionsTitle => 'Déjà sur Sipho';

  @override
  String get contactsAdd => 'Ajouter';

  @override
  String get contactsMore => 'Voir plus';

  @override
  String get contactsNoneOnSipho =>
      'Aucun de tes contacts n\'est encore sur Sipho. Invite-les !';

  @override
  String get contactsInviteTitle => 'Invite tes proches';

  @override
  String get contactsInviteSms => 'SMS';

  @override
  String get contactsInviteEmail => 'E-mail';

  @override
  String get contactsInviteSubject => 'Rejoins-moi sur Sipho';

  @override
  String get contactsInviteFailed =>
      'Impossible d\'ouvrir l\'application de messagerie.';

  @override
  String get contactsDenied => 'Sipho n\'a pas accès à tes contacts.';

  @override
  String get contactsDeniedSettings =>
      'Autorise l\'accès dans les réglages pour continuer.';

  @override
  String get contactsOpenSettings => 'Ouvrir les réglages';

  @override
  String get contactsStop => 'Ne plus être trouvable par mes contacts';

  @override
  String get contactsStopped => 'Tu n\'es plus trouvable par tes contacts.';

  @override
  String get contactsErrEmail =>
      'Il faut un e-mail ou un numéro de téléphone vérifié sur ton compte pour utiliser les contacts.';

  @override
  String get contactsAddPhone => 'Ajouter mon numéro';

  @override
  String get contactsAddPhoneHint =>
      'Pour que les gens qui ont ton numéro te retrouvent aussi (vérifié par SMS).';

  @override
  String get contactsPhoneTitle => 'Ton numéro de téléphone';

  @override
  String get contactsPhoneLabel => 'Numéro';

  @override
  String get contactsSendCode => 'Envoyer le code';

  @override
  String get contactsCodeTitle => 'Code reçu par SMS';

  @override
  String get contactsCodeLabel => 'Code à 6 chiffres';

  @override
  String get contactsVerify => 'Valider';

  @override
  String get contactsPhoneAdded => 'Numéro vérifié et ajouté.';

  @override
  String contactsPhoneLinked(String phone) {
    return 'Numéro vérifié : $phone';
  }

  @override
  String get contactsErrPhoneInvalid =>
      'Ce numéro n\'est pas valide. Ajoute l\'indicatif du pays (par ex. +225).';

  @override
  String get contactsErrPhoneCode => 'Code incorrect ou expiré.';

  @override
  String get contactsErrPhoneUsed =>
      'Ce numéro est déjà utilisé par un autre compte.';

  @override
  String get contactsErrPhoneTooMany => 'Trop d\'essais. Réessaie plus tard.';

  @override
  String get homeEconomyTitle => 'Les indicateurs officiels arrivent';

  @override
  String get homeEconomyImpact =>
      'Sipho n\'affiche un taux que s\'il vient d\'une source datée.';

  @override
  String homeCountryEconomyTitle(String country) {
    return 'Économie · $country';
  }

  @override
  String homeEconomyInflationChip(String value) {
    return 'Inflation $value';
  }

  @override
  String homeEconomyRateChip(String value) {
    return 'Taux directeur $value';
  }

  @override
  String homeFxChip(String base, String rate, String quote) {
    return '1 $base = $rate $quote';
  }

  @override
  String get expenseDeleted => 'Dépense retirée';

  @override
  String get onboardingSaveError =>
      'Impossible d\'enregistrer ton profil. Réessaie.';

  @override
  String get notifSettingsTitle => 'Notifications';

  @override
  String get notifStreakTitle => 'Rappel du soir';

  @override
  String get notifStreakBody => 'Un rappel à 19 h pour noter ta journée';

  @override
  String get notifBudgetTitle => 'Alertes budget';

  @override
  String get notifBudgetBody => 'Quand une catégorie approche sa limite';

  @override
  String get notifFixedTitle => 'Échéances';

  @override
  String get notifFixedBody => 'La veille d\'une facture du socle';

  @override
  String get notifTipsTitle => 'Conseils personnalisés';

  @override
  String get notifTipsBody =>
      'Un conseil de Sipho (IA) adapté à tes leçons et à ton budget, au plus tous les 3 jours. Seuls des totaux sont analysés, jamais ton nom.';

  @override
  String get notifEconomyTitle => 'Économie';

  @override
  String get notifEconomyBody => 'Seulement si une source datée est disponible';

  @override
  String get notifDailyTitle => 'Ton nid t\'attend';

  @override
  String get notifDailyBody => '30 secondes pour noter une dépense.';

  @override
  String get notifDenied =>
      'Les notifications restent désactivées dans les réglages du téléphone.';

  @override
  String get homeEconomyRead => 'Lire (20 s) →';

  @override
  String get homeInsightAsk => 'Analyser mes dépenses';

  @override
  String get homeInsightWorking => 'Sipho lit tes totaux…';

  @override
  String get homeInsightError => 'L\'analyse n\'a pas abouti. Réessaie.';

  @override
  String get homeInsightEmpty =>
      'Note au moins une dépense pour que Sipho puisse en parler.';

  @override
  String get navHome => 'Accueil';

  @override
  String get navExpenses => 'Dépenses';

  @override
  String get navLearn => 'Apprendre';

  @override
  String get navRanking => 'Classement';

  @override
  String get navProfile => 'Profil';

  @override
  String get addExpenseTitle => 'Ajouter une dépense';

  @override
  String get addExpenseSteps =>
      '1. Montant   →   2. Catégorie   →   3. Valider';

  @override
  String get addExpenseCta => 'AJOUTER';

  @override
  String get addExpenseScan => 'Scanner une facture';

  @override
  String get catRent => 'Loyer';

  @override
  String get catInternet => 'Internet';

  @override
  String get catEnergy => 'Énergie';

  @override
  String get catPhone => 'Téléphone';

  @override
  String get catGroceries => 'Épicerie';

  @override
  String get catTransport => 'Transport';

  @override
  String get catRestaurants => 'Restos';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catFamily => 'Famille / transferts';

  @override
  String get catInsurance => 'Assurance';

  @override
  String get catWater => 'Eau';

  @override
  String get familyRecipientHint => 'Pour qui ?';

  @override
  String get familyFeeLabel => 'Frais d\'envoi (optionnel)';

  @override
  String get familyFeeHint => '0,00';

  @override
  String get familyMonthTitle => 'Envoyé à la famille';

  @override
  String familyMonthBody(int count, String fees) {
    return '$count envois · frais $fees';
  }

  @override
  String get onTrackTitle => 'Tu es sur la bonne voie';

  @override
  String onTrackBody(int days) {
    return '$days jours de suite, et le mois tient encore.';
  }

  @override
  String get onTrackLogging =>
      'Tu notes tes dépenses. C’est l’habitude qui compte.';

  @override
  String get onTrackCatchUpTitle => 'On peut rattraper ça';

  @override
  String get onTrackCatchUpBody =>
      'Le reste à vivre est passé sous zéro. Une petite action suffit.';

  @override
  String get onTrackStartTitle => 'Le premier pas compte';

  @override
  String get onTrackStartBody =>
      'Note une dépense ou finis une leçon. Sipho avance avec toi.';

  @override
  String recapKickerMonth(String month) {
    return 'TON $month AVEC SIPHO';
  }

  @override
  String recapSpentTitleMonth(String month) {
    return 'En $month,\ntu as noté';
  }

  @override
  String recapFocusDrop(int percent) {
    return '−$percent %';
  }

  @override
  String recapFocusShare(int percent) {
    return '$percent % du mois';
  }

  @override
  String get recapEmptyTitle => 'Rien de noté ce mois-ci';

  @override
  String get recapEmptyBody =>
      'Le récap se remplit avec les dépenses que tu entres vraiment.';

  @override
  String recapShareReal(String month, int count, String saved) {
    return 'Mon $month avec Sipho : $count dépenses notées, $saved de moins que le mois d’avant.';
  }

  @override
  String rewardAdded(String amount, String category) {
    return '✓  $amount ajoutés · $category';
  }

  @override
  String get rewardHabit => 'Une bonne habitude de plus !';

  @override
  String get rewardXp => '+2 XP';

  @override
  String get rewardToast => '✓  Bien joué ! Ta quête avance.';

  @override
  String get scanTitle => 'Scanner une facture';

  @override
  String get scanHint => 'Place ta facture dans le cadre';

  @override
  String get scanPrivacy =>
      'La photo sert à lire le total. Aucun numéro de carte n\'est enregistré.';

  @override
  String get scanReading => 'Lecture du ticket…';

  @override
  String get scanReadError =>
      'Impossible de lire ce ticket. Tu peux saisir le total à la main.';

  @override
  String get scanGallery => 'Choisir une photo';

  @override
  String get validateTitle => 'Vérifier le ticket';

  @override
  String get validateBubble => 'Vérifie le total avant d\'enregistrer.';

  @override
  String get validateBubbleOk =>
      'J\'ai lu le ticket. Vérifie avant d\'enregistrer.';

  @override
  String get validateDateOk => 'Date';

  @override
  String get validateMerchant => 'Marchand';

  @override
  String get validateDateLabel => 'Date · À vérifier';

  @override
  String get validateDate => '10 nov. 2026';

  @override
  String get validateTotal => 'Total';

  @override
  String get validateTaxes => 'Taxes';

  @override
  String get validateTaxesValue => 'TPS 2,11 \$ · TVQ 4,21 \$';

  @override
  String get validateCategory => 'Catégorie';

  @override
  String get validateCta => 'ENREGISTRER';

  @override
  String get expensesTitle => 'Tes dépenses';

  @override
  String get expensesThisMonth => 'Ce mois';

  @override
  String get expensesBase => 'Mon socle';

  @override
  String get expensesCharts => 'Graphiques';

  @override
  String get expensesMonth => 'Novembre 2026';

  @override
  String get expensesSpentKicker => 'DÉPENSES VARIABLES DU MOIS';

  @override
  String get expensesFixedApart => 'Socle fixe, à part';

  @override
  String get expensesSeeBills => 'Voir les échéances →';

  @override
  String get expensesToday => 'AUJOURD\'HUI';

  @override
  String get expensesNov10 => '10 NOVEMBRE';

  @override
  String get expenseBreakfast => 'Restos · déjeuner';

  @override
  String get expenseCommute => 'Transport · trajet boulot';

  @override
  String get expenseScanned => 'Épicerie · 📷 scanné';

  @override
  String get expenseScannedBadge => 'scanné';

  @override
  String get expenseLeisure => 'Loisirs · 25,00 € → 36,80 \$';

  @override
  String get socleTitle => 'Mon socle';

  @override
  String get socleSubtitle =>
      'Les fixes d\'un côté. Les enveloppes de l\'autre.';

  @override
  String get socleCalendar => 'NOVEMBRE 2026';

  @override
  String get socleWeekdays => 'L    M    M    J    V    S    D';

  @override
  String soclePaidOn(String day) {
    return '$day · Payé ✓';
  }

  @override
  String get socleTomorrow => '15 · Demain';

  @override
  String socleUpcoming(String day) {
    return '$day · À venir';
  }

  @override
  String get socleEnvelopeProgress => 'Enveloppe · 62 %';

  @override
  String get socleEnvelope => 'Enveloppe';

  @override
  String get socleLater => 'À venir';

  @override
  String get socleFamily => 'Famille / transferts';

  @override
  String get socleElectricity => 'Électricité';

  @override
  String get socleTotal => 'Socle : 1 690 \$/mois';

  @override
  String socleTotalAmount(String amount) {
    return 'Socle : $amount/mois';
  }

  @override
  String get socleEmpty =>
      'Aucun brin pour l\'instant. Ajoute ton loyer, internet, l\'épicerie…';

  @override
  String get socleAdd => 'AJOUTER UN BRIN';

  @override
  String get soclePickTitle => 'Quel brin ajoutes-tu ?';

  @override
  String get socleSaveError => 'Le brin n\'a pas été enregistré. Réessaie.';

  @override
  String socleEnvelopePercent(int percent) {
    return 'Enveloppe · $percent %';
  }

  @override
  String socleAsk(String name) {
    return 'Tu paies « $name » ?';
  }

  @override
  String get socleYes => 'OUI ✓';

  @override
  String get socleNo => 'NON ✕';

  @override
  String socleProgress(int current, int total) {
    return '$current/$total brins du nid';
  }

  @override
  String fixedDueValue(int day) {
    return 'Prélevé le $day';
  }

  @override
  String get fixedEachMonth => 'par mois';

  @override
  String homeNextFixed(int day) {
    return 'Prochaine dépense fixe · le $day';
  }

  @override
  String get chartsTitle => 'Ton argent, en clair';

  @override
  String get chartsWeek => 'Cette semaine';

  @override
  String get chartsByWeekday => 'Par jour de la semaine';

  @override
  String chartsSlice(String name, int percent) {
    return '$name    $percent %';
  }

  @override
  String chartsCategoryShare(String name, int percent) {
    return '$name · $percent %';
  }

  @override
  String get chartsOtherName => 'Autres';

  @override
  String chartsSummaryLess(int percent) {
    return '$percent % de moins que le mois dernier';
  }

  @override
  String chartsSummaryMore(int percent) {
    return '$percent % de plus que le mois dernier';
  }

  @override
  String get chartsSummarySame => 'Autant que le mois dernier';

  @override
  String get chartsEmpty => 'Aucune dépense ce mois-ci.';

  @override
  String get chartsFixedVsVariable => 'Fixes vs variables';

  @override
  String get chartsFixedLabel => 'Fixes (socle)';

  @override
  String get chartsVariableLabel => 'Variables';

  @override
  String get chartsSixMonths => '6 derniers mois';

  @override
  String get budgetTitle => 'Budget';

  @override
  String get budgetIntro => 'Voici où en est ton mois.';

  @override
  String get budgetStatusOk => 'À l\'aise';

  @override
  String get budgetStatusWarn => 'À surveiller';

  @override
  String get budgetStatusOver => 'On ralentit ?';

  @override
  String get budgetSiphoAdviceTitle => 'Oh-oh. On ralentit ?';

  @override
  String get budgetSiphoAdviceBody => 'On peut rattraper ça cette semaine.';

  @override
  String get budgetGraphsTitle => 'Tes graphiques';

  @override
  String get budgetGraphsSubtitle => '4 vues simples, sans jargon';

  @override
  String get chartsGroceries => 'Épicerie    42 %';

  @override
  String get chartsRestaurants => 'Restos        28 %';

  @override
  String get chartsTransport => 'Transport   18 %';

  @override
  String get chartsOther => 'Autres         12 %';

  @override
  String get chartsRestaurantsBudget => 'Restos · 85 % ⚠';

  @override
  String get chartsShoppingBudget => 'Shopping · 40 %';

  @override
  String get chartsLeisureBudget => 'Loisirs · 95 %';

  @override
  String get chartsSlowDown => 'On ralentit un peu ?';

  @override
  String get chartsSummary => '12 % de moins que le mois dernier 🎉';

  @override
  String get learnTitle => 'Un petit pas\nà apprendre.';

  @override
  String get learnPathLead => 'Ton parcours · 4 unités de base';

  @override
  String get learnYourTurn => 'À TOI DE JOUER';

  @override
  String get learnSlotPending => 'Pas encore prête';

  @override
  String get learnAvailable => 'Disponible';

  @override
  String friendsChallengeTitle(String name) {
    return 'Défier $name ⚔️';
  }

  @override
  String get friendsChallengeSubtitle =>
      'Choisis un défi amical pour vous motiver à progresser ensemble :';

  @override
  String get friendsChallengeSend => 'Envoyer le défi';

  @override
  String friendsChallengeSent(String title, String name) {
    return 'Défi \"$title\" envoyé à $name ! ⚔️';
  }

  @override
  String get friendsChallengeSendError =>
      'Erreur lors de l’envoi du défi. Réessaie.';

  @override
  String get friendsChallengeYou => 'Toi';

  @override
  String get friendsChallengeAccept => 'Relever ⚔️';

  @override
  String friendsChallengeWaiting(String name) {
    return 'En attente de $name…';
  }

  @override
  String get friendsChallengeWon => '🏆 Défi remporté ! Félicitations !';

  @override
  String friendsChallengeFinishedBy(String name) {
    return '🏁 Défi terminé par $name';
  }

  @override
  String get friendsChallengesSection => 'Défis 1v1 ⚔️';

  @override
  String get friendsChallengeTooltip => 'Défier';

  @override
  String get friendsChallengeFriendFallback => 'ton ami';

  @override
  String get learnUnit3 => 'Unité 3 : Le CELI 🇨🇦';

  @override
  String learnUnitLabel(int number) {
    return 'UNITÉ $number';
  }

  @override
  String learnUnitProgress(int done, int total) {
    return '$done/$total leçons';
  }

  @override
  String learnUnitBonus(int xp, int seeds) {
    return 'Termine-la : +$xp XP · +$seeds graines';
  }

  @override
  String get learnUnitDone => 'Unité terminée ✓';

  @override
  String get learnUnitLocked => 'Termine l\'unité d\'avant';

  @override
  String lessonUnitCompleted(int xp, int seeds) {
    return 'Unité terminée ! Bonus : +$xp XP · +$seeds graines';
  }

  @override
  String get quizKicker => 'LE FONDS D\'URGENCE';

  @override
  String get quizQuestion => 'Où placer ton fonds d\'urgence ?';

  @override
  String get quizHint => 'Choisis la meilleure réponse.';

  @override
  String get quizCheck => 'VÉRIFIER';

  @override
  String get quizTryAgain => 'RÉESSAYER';

  @override
  String get quizWrong => 'Pas encore';

  @override
  String get learnDone => 'Terminée';

  @override
  String get learnLocked => 'Termine la leçon d\'avant';

  @override
  String get profileSignOut => 'Se déconnecter';

  @override
  String profileMemberSince(String date) {
    return 'Membre depuis $date';
  }

  @override
  String get profileGuest => 'Toi';

  @override
  String get quizExcellent => 'Excellent !';

  @override
  String get quizExplain => 'Disponible vite, sans mauvaise surprise.';

  @override
  String get quizA => 'Dans un compte d\'épargne accessible';

  @override
  String get quizB => 'En actions à haut risque';

  @override
  String get quizC => 'Sous mon matelas';

  @override
  String get quizD => 'Dans un placement bloqué 10 ans';

  @override
  String get lessonDoneTitle => 'Une leçon de plus,\nun pas de géant.';

  @override
  String lessonDoneBravo(String name) {
    return 'Bravo $name !';
  }

  @override
  String get learnStart => 'COMMENCER';

  @override
  String get learnReplay => 'REFAIRE';

  @override
  String learnLessonMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String learnLessonSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes',
      one: '1 étape',
    );
    return '$_temp0';
  }

  @override
  String learnLessonReward(int xp) {
    return 'jusqu\'à +$xp XP';
  }

  @override
  String get learnLessonObjective => 'Ce que tu vas apprendre';

  @override
  String get learnLessonDoneHint => 'Déjà validée : rejoue pour t\'entraîner.';

  @override
  String get learnUnitGiftLabel => 'Cadeau de fin d\'unité';

  @override
  String get learnYouAreHere => 'Tu en es là';

  @override
  String get lessonKickerRead => 'DÉCOUVRE';

  @override
  String get lessonKickerQuestion => 'QUESTION';

  @override
  String get lessonKickerTrueFalse => 'VRAI OU FAUX ?';

  @override
  String get lessonTrue => 'Vrai';

  @override
  String get lessonFalse => 'Faux';

  @override
  String get lessonRecapTitle => 'À retenir';

  @override
  String get lessonRecapFinish => 'TERMINER';

  @override
  String get lessonNotFoundTitle => 'Leçon introuvable';

  @override
  String get lessonNotFoundBody =>
      'Cette leçon n\'est plus disponible. Choisis-en une autre sur ton parcours.';

  @override
  String get lessonNotFoundCta => 'Retour à Apprendre';

  @override
  String get lessonLeaveTitle => 'Quitter la leçon ?';

  @override
  String get lessonLeaveBody => 'Ta progression dans cette leçon sera perdue.';

  @override
  String get lessonLeaveStay => 'RESTER';

  @override
  String get lessonLeaveQuit => 'QUITTER';

  @override
  String get learnLockedHint =>
      'Termine d\'abord la leçon précédente pour débloquer celle-ci.';

  @override
  String learnLessonPosition(int number, int total) {
    return 'Leçon $number sur $total';
  }

  @override
  String get learnClose => 'FERMER';

  @override
  String get lessonDoneBravoAnon => 'Bravo !';

  @override
  String lessonDoneLevelUp(int level) {
    return 'Niveau $level atteint !';
  }

  @override
  String get lessonDoneReplay =>
      'Leçon déjà validée : un petit entraînement de plus.';

  @override
  String get lessonXp => 'XP gagnés';

  @override
  String get lessonAccuracy => 'Précision';

  @override
  String get lessonTime => 'Temps';

  @override
  String get streakKicker => 'LA CONSTANCE, ÇA SE CULTIVE';

  @override
  String get streakDays => 'jours de série !';

  @override
  String get streakThanks => 'Ton futur toi te remercie.';

  @override
  String get giftTitleClosed => 'Une surprise pour toi';

  @override
  String get giftFrom => 'De la part de ton ami Sipho.';

  @override
  String get giftTap => 'Touche pour ouvrir';

  @override
  String get giftMagic => 'Un peu de magie pour ton aventure.';

  @override
  String get giftOpenCta => 'OUVRIR MON CADEAU';

  @override
  String get giftTitleOpen => 'Un cadeau bien mérité !';

  @override
  String get giftEffort => 'Chaque petit effort compte.';

  @override
  String giftSeedsAmount(int count) {
    return '+$count graines d\'or';
  }

  @override
  String giftXpAmount(int xp) {
    return '+$xp XP';
  }

  @override
  String get giftLevelUp => 'Niveau supérieur !';

  @override
  String get giftNothingNew => 'Ce cadeau a déjà été ouvert.';

  @override
  String get giftThanks => 'SUPER, MERCI SIPHO !';

  @override
  String get leagueTab => 'Ligue';

  @override
  String get leagueFriends => 'Amis';

  @override
  String get leagueCountry => 'Mon pays';

  @override
  String get leagueTierBronze => 'Bronze';

  @override
  String get leagueTierSilver => 'Argent';

  @override
  String get leagueTierGold => 'Or';

  @override
  String get leagueTierSapphire => 'Saphir';

  @override
  String get leagueTierRuby => 'Rubis';

  @override
  String get leagueTierEmerald => 'Émeraude';

  @override
  String get leagueTierAmethyst => 'Améthyste';

  @override
  String get leagueTierPearl => 'Perle';

  @override
  String get leagueTierObsidian => 'Obsidienne';

  @override
  String get leagueTierDiamond => 'Diamant';

  @override
  String leagueTitleNamed(String tier) {
    return 'Ligue $tier';
  }

  @override
  String leagueEndsIn(String duration) {
    return 'Se termine dans $duration';
  }

  @override
  String get leagueEnded => 'Semaine terminée · résultats en cours';

  @override
  String leagueDurationDaysHours(int days, int hours) {
    return '$days j $hours h';
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
  String get leagueYouSuffix => 'Toi';

  @override
  String get leagueAlone =>
      'Tu es seul·e dans ton groupe pour l\'instant. Les autres joueurs te rejoignent au fil de la semaine.';

  @override
  String get leagueError =>
      'Impossible de charger la ligue. Vérifie ta connexion et réessaie.';

  @override
  String get leagueSoon => 'Bientôt disponible';

  @override
  String leagueResultPromoted(int rank, String tier) {
    return 'Semaine dernière : $rankᵉ place, promotion en ligue $tier !';
  }

  @override
  String leagueResultRelegated(int rank, String tier) {
    return 'Semaine dernière : $rankᵉ place, retour en ligue $tier.';
  }

  @override
  String leagueResultStayed(int rank, String tier) {
    return 'Semaine dernière : $rankᵉ place, tu restes en ligue $tier.';
  }

  @override
  String get leaguePromotion => '↑  ZONE DE PROMOTION · TOP 7';

  @override
  String get leagueRelegation => '↓  ZONE DE RELÉGATION · 5 DERNIERS';

  @override
  String get profileMember => 'Membre depuis nov. 2026';

  @override
  String profileSpaceSince(String date) {
    return 'Ton espace à toi · Depuis $date';
  }

  @override
  String get profileShop => 'Boutique';

  @override
  String get profileStreak => '18 jours';

  @override
  String get profileStreakLabel => 'Série record';

  @override
  String profileStreakDays(int count) {
    return '$count jours';
  }

  @override
  String get profileXp => '2 480';

  @override
  String get profileXpLabel => 'XP total';

  @override
  String profileLevelLabel(int level) {
    return 'Niveau $level';
  }

  @override
  String profileXpValue(String xp) {
    return '$xp XP';
  }

  @override
  String get profileLeague => 'Or';

  @override
  String get profileLeagueLabel => 'Ligue';

  @override
  String get profileLessons => '24';

  @override
  String get profileLessonsLabel => 'Leçons terminées';

  @override
  String get profileBadges => 'Mes badges';

  @override
  String get profilePublic => 'Mon profil public';

  @override
  String get profilePublicHint => 'Jamais de montant partagé';

  @override
  String get profileSettingsRow => 'Réglages';

  @override
  String get badgeFirstLesson => 'Première leçon';

  @override
  String get badgeFirstLessonHint => 'Termine ta première leçon.';

  @override
  String get badgeUnit1 => 'Bases du budget';

  @override
  String get badgeUnit1Hint => 'Termine l\'unité 1.';

  @override
  String get badgeUnit2 => 'Épargnant';

  @override
  String get badgeUnit2Hint => 'Termine l\'unité 2.';

  @override
  String get badgeStreak7 => 'Série de 7 jours';

  @override
  String get badgeStreak7Hint => 'Atteins une série de 7 jours.';

  @override
  String get badgeStreak30 => 'Série de 30 jours';

  @override
  String get badgeStreak30Hint => 'Atteins une série de 30 jours.';

  @override
  String get badgeLevel5 => 'Niveau 5';

  @override
  String get badgeLevel5Hint => 'Atteins le niveau 5.';

  @override
  String get badgeLevel10 => 'Niveau 10';

  @override
  String get badgeLevel10Hint => 'Atteins le niveau 10.';

  @override
  String get badgeLeagueSilver => 'Ligue Argent';

  @override
  String get badgeLeagueSilverHint => 'Monte en ligue Argent.';

  @override
  String get badgeBuilder => 'Bâtisseur';

  @override
  String get badgeBuilderHint =>
      'Termine la construction de ton nid (onboarding).';

  @override
  String get badgeUnit3 => 'Malin de l\'argent';

  @override
  String get badgeUnit3Hint => 'Termine l\'unité 3.';

  @override
  String get badgeUnit4 => 'Investisseur avisé';

  @override
  String get badgeUnit4Hint => 'Termine l\'unité 4.';

  @override
  String get badgeEarnedLabel => 'Obtenu';

  @override
  String get badgeLockedLabel => 'À gagner';

  @override
  String get learnQuestCompleteLesson => 'Valider une leçon';

  @override
  String get learnQuestCompleteLessonSub =>
      'Réponds juste au quiz pour débloquer la suite';

  @override
  String learnQuestFinishUnit(int count) {
    return 'Terminer l\'unité ($count leçons)';
  }

  @override
  String learnQuestFinishUnitSub(String unitTitle, int bonusXp) {
    return '$unitTitle · bonus de $bonusXp XP à la fin';
  }

  @override
  String get learnQuestBuildFoundation => 'Poser ton socle du mois';

  @override
  String get learnQuestBuildFoundationSub =>
      'Indique ton revenu et au moins 1 charge fixe';

  @override
  String get learnQuestTrackThree => 'Noter 3 dépenses ce mois-ci';

  @override
  String get learnQuestTrackThreeSub =>
      'Mets en pratique la leçon sur le suivi';

  @override
  String get learnQuestLessonChallenge => 'Défi leçon';

  @override
  String get learnQuestTrackingChallenge => 'Défi suivi';

  @override
  String get learnQuestPersonalized => 'Défi personnalisé Sipho';

  @override
  String get onboardingLocating => 'Recherche de ta position…';

  @override
  String get onboardingLocationDenied =>
      'Permission refusée. Choisis ton pays à la place.';

  @override
  String get onboardingLocationError =>
      'Impossible de lire ta position. Choisis ton pays.';

  @override
  String get streakMilestonesTitle => 'Paliers de série';

  @override
  String get streakMilestoneReached => 'Atteint !';

  @override
  String get streakRepairTitle => 'Réparer ta série ?';

  @override
  String get streakRepairBody =>
      'Tu as manqué hier. Répare sous 24 h avec 1 gel.';

  @override
  String get streakRepairCta => 'RÉPARER LA SÉRIE';

  @override
  String get streakRepairDone => 'Série réparée !';

  @override
  String get streakRepairError => 'Impossible de réparer la série.';

  @override
  String get streakRepairNoFreeze => 'Il te faut un gel de série (boutique).';

  @override
  String get expenseCurrencyLabel => 'Devise';

  @override
  String get expenseFxUnavailable =>
      'Taux de change indisponible pour cette devise. Réessaie plus tard ou utilise ta devise principale.';

  @override
  String scanQuotaLeft(int count) {
    return '$count scans restants aujourd\'hui';
  }

  @override
  String get profileGoals => 'Mes objectifs';

  @override
  String get profileGoal => 'Voyage au Cameroun · 1 200 / 3 000 \$';

  @override
  String get addGoalTitle => 'Ajouter un objectif';

  @override
  String get addGoalBtn => 'Créer l\'objectif';

  @override
  String get goalTitleLabel => 'Nom de l\'objectif';

  @override
  String get goalTitleHint => 'ex. Voyage, Fonds d\'urgence...';

  @override
  String get goalTargetLabel => 'Montant cible';

  @override
  String get goalSavedLabel => 'Déjà épargné';

  @override
  String get goalDepositBtn => 'Ajouter une épargne';

  @override
  String get goalDepositTitle => 'Verser vers l\'objectif';

  @override
  String get goalDepositAmount => 'Montant à ajouter';

  @override
  String get goalDepositConfirm => 'Enregistrer le versement';

  @override
  String get goalEmptyTitle => 'Aucun objectif d\'épargne';

  @override
  String get goalEmptySubtitle =>
      'Fixe-toi un but (voyage, projet, réserve) et avance pas à pas !';

  @override
  String get goalCompleted => 'Objectif atteint 🎉';

  @override
  String get goalReachedBadge => 'Atteint ✓';

  @override
  String get goalSaveQuick => '+ Épargner';

  @override
  String goalTrackerCount(int count) {
    return '$count objectifs configurés';
  }

  @override
  String get goalDelete => 'Supprimer l\'objectif';

  @override
  String get goalDeleteConfirm => 'Veux-tu supprimer cet objectif ?';

  @override
  String get profileInvite => 'Inviter des amis  →';

  @override
  String get shopTitle => 'Boutique';

  @override
  String get shopSubtitle => 'Un style unique, comme ton aventure.';

  @override
  String get shopBuy => 'Acheter';

  @override
  String get shopHat => 'Chapeau soleil';

  @override
  String get shopGlasses => 'Lunettes cool';

  @override
  String get shopScarfGreen => 'Écharpe wax verte';

  @override
  String get shopScarfClay => 'Écharpe terre cuite';

  @override
  String get shopNest => 'Nid fleuri';

  @override
  String get shopFreeze => 'Gel de série';

  @override
  String get shopNote => 'Les graines se gagnent, pas besoin de payer.';

  @override
  String get shopOwned => 'Possédé';

  @override
  String get shopStockFull => 'Stock plein';

  @override
  String get shopNotEnough => 'Pas assez de graines';

  @override
  String shopBought(String item) {
    return '$item est à toi !';
  }

  @override
  String shopFreezeStock(int count, int max) {
    return '$count/$max en stock';
  }

  @override
  String get shopRefusedOwned => 'Tu as déjà cet objet.';

  @override
  String get shopRefusedStock => 'Ton stock de gels est plein.';

  @override
  String get shopRefusedSeeds => 'Il te faut plus de graines.';

  @override
  String get shopError => 'L\'achat n\'a pas abouti. Réessaie.';

  @override
  String get adviceKicker => 'UNE IDÉE POUR TOI';

  @override
  String get adviceTitle => 'Et si on cuisinait ?';

  @override
  String get adviceBody =>
      'Tes sorties au resto ont augmenté de 38 % ce mois-ci.';

  @override
  String get adviceQuest => 'QUÊTE · +50 XP';

  @override
  String get adviceQuestBody => '2 repas maison de plus\ncette semaine';

  @override
  String get adviceAccept => 'ACCEPTER LA QUÊTE';

  @override
  String get adviceLater => 'Plus tard';

  @override
  String get adviceDisclaimer =>
      'Contenu éducatif, pas un conseil financier personnalisé.';

  @override
  String get settingsTitle => 'À ton rythme';

  @override
  String get settingsSubtitle => 'Tu gardes le contrôle.';

  @override
  String get settingsEnabled => 'Activés';

  @override
  String get settingsDisabled => 'Désactivés';

  @override
  String get settingsEnabledF => 'Activées';

  @override
  String get settingsDisabledF => 'Désactivées';

  @override
  String get settingsStreak => 'Rappels de série';

  @override
  String get settingsBudget => 'Alertes budget';

  @override
  String get settingsFriends => 'Amis et ligue';

  @override
  String get settingsTips => 'Conseils';

  @override
  String get settingsEconomy => 'Actualité et taux';

  @override
  String get settingsRecap => 'Récaps';

  @override
  String get settingsSounds => 'Sons';

  @override
  String get settingsHaptics => 'Vibrations';

  @override
  String get settingsVoice => 'Voix de Sipho';

  @override
  String get settingsReminder => 'Heure du rappel';

  @override
  String get settingsReminderTime => '19 h';

  @override
  String get settingsSleep =>
      'Chaque catégorie peut être coupée.\nPromis, je respecte ton sommeil.';

  @override
  String get recapKicker => 'TON OCTOBRE AVEC SIPHO';

  @override
  String get recapSpentTitle => 'En octobre,\ntu as noté';

  @override
  String get recapSpentCount => '64';

  @override
  String get recapSpentLabel => 'dépenses 📝';

  @override
  String get recapProgressTitle => 'Ta plus belle\nprogression';

  @override
  String get recapProgressCategory => 'Restos';

  @override
  String get recapProgressValue => '−22 %';

  @override
  String get recapProgressCaption => 'Plus d’équilibre. Toujours du plaisir.';

  @override
  String get recapSavedTitle => 'Tu t’es fait\nun cadeau de';

  @override
  String get recapSavedValue => '142 \$';

  @override
  String get recapSavedLabel => 'd’économies 🎁';

  @override
  String get recapShare => 'PARTAGER';

  @override
  String get recapShareText =>
      'Mon octobre avec Sipho : 64 dépenses notées, et 142 \$ d’économies.';

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
  String get budgetMonth => 'Ce mois-ci';

  @override
  String get budgetSpent => 'Dépensé';

  @override
  String get budgetRemaining => 'Restant';

  @override
  String get budgetOver => 'Budget dépassé !';

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

  @override
  String get editProfileTitle => 'Modifier mon profil';

  @override
  String get editProfileBtn => 'Modifier';

  @override
  String get editProfileCountry => 'Pays et devise';

  @override
  String get editProfileGoal => 'Objectif principal';

  @override
  String get editProfileIncome => 'Revenu mensuel net';

  @override
  String get editProfileSaved => 'Profil mis à jour';

  @override
  String get editExpenseTitle => 'Modifier la dépense';

  @override
  String get editExpenseMerchantHint => ' Ex. : IGA, Métro, Café…';

  @override
  String get editExpenseNoteHint => 'Ajouter une note';

  @override
  String get editExpenseSaved => 'Dépense mise à jour';

  @override
  String get editFixedTitle => 'Modifier ce brin';

  @override
  String get editFixedName => 'Nom';

  @override
  String get editFixedSaved => 'Brin mis à jour';

  @override
  String get editFixedDeleted => 'Brin retiré du socle';

  @override
  String get coachTitle => 'Conseils de Sipho';

  @override
  String get coachSubtitle =>
      'Basés uniquement sur tes vrais chiffres du mois.';

  @override
  String get coachTopicGeneral => 'Vue d\'ensemble';

  @override
  String get coachTopicSpending => 'Mes dépenses';

  @override
  String get coachTopicFixed => 'Mon socle';

  @override
  String get coachTopicGoal => 'Mon objectif';

  @override
  String get coachGenerateCta => 'DEMANDER UN CONSEIL À SIPHO';

  @override
  String get coachRefreshCta => 'NOUVEAU CONSEIL';

  @override
  String get coachEmptyBody =>
      'Ajoute ton revenu, un brin du socle ou une dépense, puis demande à Sipho d\'analyser ton mois.';

  @override
  String get coachActionTitle => 'HABITUDE DE LA SEMAINE';

  @override
  String get coachQuestBadge => 'DÉFI SUGGÉRÉ';

  @override
  String get coachDoLessonCta => 'FAIRE LA LEÇON LIÉE';

  @override
  String get coachLogExpenseCta => 'NOTER UNE DÉPENSE';

  @override
  String get coachOpenCard => 'Voir le conseil →';

  @override
  String get coachPreviousTitle => 'Conseils précédents';

  @override
  String get coachHourlyTitle => 'Accompagnement Sipho';

  @override
  String get coachHourlyDismiss => 'Compris';

  @override
  String coachEducationLevel(String stage, int score) {
    return 'Niveau : $stage · $score/100';
  }

  @override
  String get coachStageFoundation => 'Fondations';

  @override
  String get coachStageHabits => 'Habitudes';

  @override
  String get coachStageSaving => 'Épargne';

  @override
  String get coachStageProtect => 'Protection';

  @override
  String get coachStageGrow => 'Faire grandir';

  @override
  String get coachEducationCardTitle => 'Éducation financière';

  @override
  String get coachEducationCardHint =>
      'Progression d’après tes leçons, ta série et tes habitudes sur Sipho.';

  @override
  String get learnQuestsTitle => 'Quêtes d\'apprentissage';

  @override
  String learnQuestsSummary(int done, int total) {
    return '$done/$total terminées';
  }

  @override
  String get learnQuestClaim => 'Réclamer';

  @override
  String get learnQuestGo => 'Faire →';

  @override
  String get learnQuestDoneBadge => 'Terminée ✓';

  @override
  String get learnQuestAiTag => 'Défi IA';

  @override
  String get learnQuestClaimError =>
      'Impossible de réclamer la récompense pour l\'instant.';

  @override
  String get learnGenerateAiQuest => '✨ Défi IA sur mesure';

  @override
  String get learnGeneratingAiQuest => 'Création…';

  @override
  String get quizAskAiTutor => '✨ Exemple avec mes chiffres (Sipho IA)';

  @override
  String get quizAiTutorLoading => 'Sipho prépare ton exemple…';

  @override
  String get quizAiTutorTitle => 'Sipho relie ça à ton budget';

  @override
  String get quizAiTutorError =>
      'Sipho n\'a pas pu générer d\'exemple maintenant.';

  @override
  String get aiErrorNotEnabled =>
      'Active Firebase AI Logic (Gemini Developer API) dans la console Firebase pour activer Sipho IA.';

  @override
  String get aiErrorAppCheck =>
      'Le serveur a refusé cet appareil (App Check). Les builds debug utilisent le jeton debug dev enregistré dans Firebase Console > App Check ; les builds release demandent Play Integrity / App Attest configurés.';

  @override
  String get aiErrorQuota =>
      'Quota IA temporairement atteint. Réessaie dans quelques minutes.';

  @override
  String get aiErrorCredits =>
      'L\'IA n\'a plus de crédit sur ce projet Firebase. Recharge-le dans AI Studio (ai.studio/projects), puis réessaie.';

  @override
  String get aiErrorNetwork =>
      'Connexion réseau indisponible pour contacter Sipho IA.';

  @override
  String get lessonSaveErrorAuth =>
      'Ta session a expiré. Reconnecte-toi, puis réessaie.';

  @override
  String get lessonSaveErrorRefused =>
      'Cette leçon n\'a pas pu être validée (elle est peut-être encore verrouillée).';

  @override
  String get lessonSaveError =>
      'Ta progression n\'a pas pu être enregistrée. Vérifie ta connexion et réessaie.';

  @override
  String get fixedMarkPaidError =>
      'Impossible de marquer cette charge comme payée. Réessaie.';

  @override
  String get ecoTipCatAll => 'Tous 🌈';

  @override
  String get ecoTipCatBudget => 'Budget 🛒';

  @override
  String get ecoTipCatSaving => 'Épargne 🌱';

  @override
  String get ecoTipCatEconomy => 'Économie 📉';

  @override
  String get ecoTipCatSecurity => 'Sécurité 🛡️';

  @override
  String get ecoTipCatInvest => 'Investir 🧺';

  @override
  String get ecoTipCatLifestyle => 'Quotidien 💡';

  @override
  String get ecoTipActionLabel => 'ACTION CONCRÈTE';

  @override
  String get ecoTipSource => 'Source';

  @override
  String get ecoTipShuffle => 'AUTRE CONSEIL 🎲';

  @override
  String get ecoMetricInflation => 'Inflation annuelle';

  @override
  String get ecoMetricPolicyRate => 'Taux directeur';

  @override
  String get ecoMetricSavingsBenchmark => 'Rendement épargne sans risque';

  @override
  String get ecoFxTitle => 'Taux de change';

  @override
  String get ecoFxBlurb =>
      'Référence Banque centrale européenne, via Frankfurter. Sipho n’invente aucun taux.';

  @override
  String get ecoFxEmpty => 'Taux pas encore disponibles.';

  @override
  String get ecoNewsTitle => 'Actus sourcées';

  @override
  String get ecoNewsSubtitle => 'Archives sourcées · Pas l’actualité du jour';

  @override
  String get ecoIndicatorsUnavailable => 'Indicateurs officiels indisponibles.';

  @override
  String get ecoWhatItMeans => 'Ce que ça change pour toi';

  @override
  String ecoBenchmarkDisclaimer(String date) {
    return 'Données de référence officielles datées de $date. À des fins éducatives.';
  }

  @override
  String get ecoNewsEmpty =>
      'Pas encore d’actus pour ce pays. Elles arrivent après le prochain passage du serveur.';

  @override
  String get ecoNewsFooter =>
      'Données anciennes · Ouvrir les sources\nActualiser avant une décision.';

  @override
  String get ecoNewsRefresh => 'Voir les informations récentes';

  @override
  String ecoNewsSiphoQuote(String quote) {
    return 'Sipho : « $quote »';
  }
}
