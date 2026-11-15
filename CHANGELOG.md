# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Versionnage Sémantique](https://semver.org/lang/fr/).

---

## [Unreleased] - 2026-11-12

### Ajouté — Boutique de graines (achats réels)
- Callable `buyShopItem` (ADR-013) : le serveur fixe le prix, vérifie le solde dans une transaction, applique « un seul exemplaire » aux objets et le **plafond de 2 gels de série** ; refus expliqués (`already-owned`, `max-stock`, `insufficient-seeds`). Premier usage des graines, qui ne se dépensaient nulle part.
- Écran Boutique : solde, série et niveau **réels** (avant : 12 / 340 / niveau 7 écrits en dur), états Acheter / Possédé / Pas assez de graines / Stock plein, stock de gels affiché, un achat à la fois, son à l'achat.
- Les objets achetés sont enregistrés dans `game/state.ownedItems` ; le gel acheté augmente `streak.freezes`, consommé par `dailyRollover`.
- Tests : `shop.test.ts`, 4 tests d'émulateur, tests Flutter (états, écran, parité app/serveur).

### Ajouté — Badges
- Le serveur attribue maintenant les badges (ADR-012) : première leçon, un par unité terminée, série de 7 et 30 jours (meilleure série), niveau 5 et 10, ligue Argent. Déclencheur `onGameBadgeCheck` sur l'état de jeu, ajout par `arrayUnion`, aucun XP, copie dans `publicProfiles`.
- Profil : tout le catalogue de badges, verrouillé tant que non attribué ; toucher un badge affiche son nom et comment l'obtenir (FR / EN). Avant : icônes en dur calculées à partir du nombre de leçons.
- Son et vibration quand un nouveau badge arrive (`SiphoCue.badgeUnlocked`).
- Tests : `badges.test.ts`, trois tests d'émulateur (`syncBadges`), tests Flutter (cue, textes, parité avec le serveur).

### Ajouté — Chemin de leçons par unités
- Le serveur devient l'autorité du chemin (`shared/lessonPath.ts`) : une leçon verrouillée est **refusée par `completeLesson`** (`failed-precondition`), plus seulement grisée dans l'app. Rejouer une leçon déjà faite reste permis.
- **Bonus de fin d'unité** : 30 XP + 10 graines, une seule fois, à la première validation de la dernière leçon manquante de l'unité ; `completeLesson` renvoie `unitCompleted`, `unitBonusXp`, `unitBonusSeeds`.
- Unité 2 « Épargner, un pas après l'autre » (3 leçons : objectif d'épargne, se payer en premier, petits montants) ; l'unité 2 s'ouvre quand l'unité 1 est finie.
- Onglet Apprendre : une section par unité (progression `x/y`, barre, bonus à gagner, état verrouillé) ; l'écran de leçon annonce le bonus de fin d'unité et sa barre suit l'unité de la leçon ; la quête « Terminer l'unité » suit l'unité en cours.
- Tests : `lessonPath.test.ts`, deux tests d'émulateur (leçon verrouillée, bonus une seule fois), tests Flutter des unités et de la parité app/serveur. Décision : ADR-011.

### Ajouté — Animations Lottie
- `SiphoLotties` (registre des animations, plus de chemins en dur), préchargement au démarrage (`preloadSiphoLotties`), `LottieWidget` protégé : un fichier absent ou corrompu laisse une zone vide au lieu d'une erreur ; masqué aux lecteurs d'écran ; « réduire les animations » respecté.
- Deux nouvelles animations générées par `app/tool/lottie/generate.py` : `trophy_shine` (bannière de promotion de ligue) et `gift_sparkles` (ouverture du cadeau). Les 6 fichiers sont vérifiés par test (JSON valide, lisible par le lecteur, tous listés dans le registre).
- Les 6 animations sont des créations simples faites à la main : pour une version de designer, remplacer le fichier du même nom dans `assets/animations/`.

### Modifié — App Check intégré de façon définitive
- `activateAppCheck()` (`core/firebase/app_check_setup.dart`) s'exécute juste après `Firebase.initializeApp` : Play Integrity (Android) et App Attest avec repli DeviceCheck (iOS) en release, fournisseur debug en debug. Le client IA joint le jeton à ses requêtes AI Logic.
- Jeton debug **fixe** pour le projet dev, **fourni au lancement** par `--dart-define=APP_CHECK_DEBUG_TOKEN=<uuid>` (jamais écrit dans le code : le dépôt est public ; la valeur vit dans `.vscode/launch.json`, ignoré par git ; sans elle, jeton aléatoire par installation), imposé par les ponts natifs (`AppDelegate.swift`, `MainActivity.kt`, builds debug uniquement) : enregistré une seule fois dans la console, valable sur tous les émulateurs, simulateurs et après réinstallation. `--dart-define=APP_CHECK_REAL=true` teste les vrais fournisseurs sur un appareil physique.
- Condition de compilation `DEBUG` ajoutée à la configuration Debug de `Runner` (elle n'existait que pour `RunnerTests`).
- Entitlement App Attest dans `Runner.entitlements`. Enforcement serveur : à réactiver à l'étape 5 (après vérification des jetons).

### Modifié — Plus de flavors pour lancer l'app
- `flutter run` suffit sur Android et iOS : `main.dart` vise dev en debug et prod en release (`resolveFlavor`). Flavors Gradle retirés, `google-services.json` déplacé dans `android/app/`. Détails dans ADR-005.

### Ajouté — Quêtes du jour
- Nouvelle quête quotidienne `daily_lesson` (« Fais une micro-leçon », 1 leçon, 20 XP, 5 graines), avancée par `completeLesson`.
- Callable `refreshDailyQuests` (idempotent, limité à 20 appels/h) : crée les quêtes du jour manquantes ; l'accueil l'appelle une fois par session. Un nouveau modèle de quête apparaît donc le jour même, sans attendre le prochain rollover.
- Les lignes de quête de l'accueil sont cliquables : quête dépenses → formulaire d'ajout, quête leçon ou quête terminée → onglet Apprendre (réclamation).
- Tests : `quests.test.ts` (modèles, plafonds de récompense, décision de réclamation), test d'émulateur de progression de la quête leçon, tests de `homeQuestRoute`.

### Ajouté — Amis et invitations
- Onglet « Amis » du classement : mon code ami (copier, partager), ajout d'un ami par code, demandes reçues (accepter / refuser) et envoyées (annuler), liste triée par série avec niveau, série et ligue, retrait avec confirmation, et saisie d'un code de parrainage.
- Callables `getInviteCode`, `sendFriendRequest`, `respondFriendRequest`, `removeFriend` ; une demande croisée est acceptée d'office ; 100 liens maximum ; l'usage d'un code de parrainage crée l'amitié.
- Les amis ne voient que le profil public (pseudo, niveau, série, ligue), jamais de montant. Pas de recherche d'utilisateurs : on ajoute quelqu'un avec son code.
- Suppression de compte : les amitiés et demandes de l'utilisateur sont supprimées.
- Tests : `friends.test.ts` (code, identifiants, règles de réponse), tests d'émulateur des appels et des règles, 18 tests Flutter (logique et écran).

### Corrigé — Firebase AI Logic : jeton App Check et appels serveur inutiles
- Diagnostic sur `sipho-f5a01` : l'API AI Logic est activée et **App Check y est imposé** (`401 Firebase App Check token is invalid` sans jeton valide). Un appareil dont le jeton n'est pas accepté (jeton debug non enregistré, Play Integrity / App Attest non configuré) voit donc toutes les fonctions IA échouer.
- `SiphoAiClient` : sur un 401, il redemande un jeton App Check frais (`getToken(true)`) et rejoue la requête **une seule fois** (un jeton en cache peut être périmé). Trois tests.
- Coach : si le serveur répond « AI coach is not configured » (pas de `GEMINI_API_KEY`, l'app s'appuie sur AI Logic), l'app ne le rappelle plus pendant la session et passe directement par AI Logic. Test de reconnaissance de l'erreur.

### Ajouté — Amis depuis les contacts et invitations
- Carte « Retrouve tes amis dans tes contacts » dans l'onglet Amis : après un consentement explicite, l'app demande l'accès aux contacts, compare l'e-mail de chaque contact avec les comptes Sipho sous forme d'empreintes SHA-256 (le serveur ne voit jamais l'adresse d'un contact qui n'est pas utilisateur, rien n'est conservé) et propose d'ajouter ceux qui sont déjà sur Sipho.
- Invitation des autres contacts par SMS ou e-mail, message prérempli avec mon code ami (l'utilisateur envoie lui-même).
- Réciproque et révocable : il faut être soi-même trouvable (e-mail vérifié) pour chercher ; « Ne plus être trouvable » retire l'empreinte ; la suppression de compte aussi.
- Callables `setContactDiscovery`, `findContacts`, `sendContactFriendRequest` (limites : 1000 empreintes par appel, 10 recherches et 20 demandes par jour) ; collection `contactIndex` fermée à tout client ; `users/{uid}/social/contacts` lisible par son propriétaire.
- Numéros de téléphone : les contacts sont aussi comparés par numéro (E.164, SHA-256). Les numéros locaux sont complétés avec l'indicatif du pays de l'utilisateur (FR, BE, MA, CA, US, CI, SN, CM, ML, BF, TG, BJ ; le `0` ivoirien est conservé, le `0` français retiré). Les contacts qui n'ont qu'un numéro sont donc trouvés, plus seulement invités.
- « Ajouter mon numéro » : vérification par SMS (Firebase Phone Auth, numéro lié au compte existant), puis réindexation pour que les gens qui ont ce numéro te trouvent. Suffit à utiliser les contacts avec un e-mail masqué (Apple). Nécessite d'activer Phone Auth dans la console Firebase.
- `setContactDiscovery` indexe l'e-mail vérifié et le numéro vérifié ; la désactivation et la suppression de compte retirent toutes les empreintes.
- Permissions : `READ_CONTACTS` (Android), `NSContactsUsageDescription` (iOS) ; dépendances `flutter_contacts`, `crypto`.
- Tests : `contacts.test.ts` (normalisation, empreintes e-mail et numéro, identités indexées), test des règles, 40 tests Flutter (empreintes identiques au serveur, lecture des numéros par pays, suggestions, invitations, vérification du numéro, écran).

### Corrigé — Codes de parrainage lisibles par tous
- `referrals/{code}` n'est plus lisible que par son propriétaire : le document liste les `uid` des invités. L'app passe par les callables et n'en avait pas besoin.

### Ajouté — Journée sous budget
- Règle 9 de l'ADR-009 : à la fin de chaque journée locale, `dailyRollover` compare les dépenses du jour au budget quotidien (revenu − charges fixes actives, divisé par les jours du mois) et attribue **15 XP** une seule fois si l'utilisateur est resté sous budget **avec au moins une dépense notée** (ne rien noter n'est jamais récompensé). Sans revenu renseigné, la règle ne s'applique pas.
- Retour visuel : l'accueil affiche « Journée sous budget ! +15 XP » le jour qui suit, avec un son discret (le serveur écrit `lastBudgetDay` dans `game/state`).
- Callable `confirmNoSpend` + bouton « Aucune dépense aujourd'hui » sur l'accueil : prolonge la série, rend la journée éligible à la récompense « sous budget », sans XP par elle-même ; refusé si une dépense est déjà notée ce jour-là ; idempotent.
- Règles des quêtes consolidées dans `DECISIONS.md` (ADR-009).

### Corrigé — Quêtes expirées réclamables
- `claimQuest` refuse désormais une quête `expired` (`failed-precondition`). Avant, une quête terminée puis expirée restait réclamable par appel direct jusqu'à sa purge, 14 jours plus tard. La décision est extraite dans `shared/questClaim.ts` et testée.

### Ajouté
- Spécification complète du projet (README.md)
- Brief design Figma (FIGMA.md)
- Création du projet Flutter (app/)
- Structure initiale des dossiers
- Fichiers de configuration (pubspec.yaml, firebase.json, etc.)
- Fichiers de suivi et documentation : TRACKER.md, CHANGELOG.md, DECISIONS.md, FIGMA_TRACKER.md
- Workflows GitHub Actions : CI et déploiement dev
- `.gitignore` complet Flutter + Firebase + Node

### Corrigé (revue avant bêta)
- **Environnements** : un projet Firebase par flavor (`firebase_options_{dev,staging,prod}.dart`), garde au démarrage qui refuse une config non remplie ou un flavor non-dev pointant vers le projet de dev ; flavors Android `dev` / `staging` / `prod` avec `google-services.json` par flavor.
- **CI** : Flutter 3.47, Node 22, tests unitaires séparés des tests d'émulateur (job dédié avec Java + Firebase CLI) ; déploiement dev avec `--flavor dev`, sans l'étape hosting inexistante.
- **XP** : plafonds par jour **serveur** (plus par date de transaction fournie par le client) ; `lessonId` limité au catalogue + rejouer une leçon donne un XP d'entraînement plafonné ; « Payé ✓ » limité au mois courant, aux dépenses actives de type facture et plafonné par jour ; `redeemedReferralCode` & co. en écriture serveur uniquement + marqueur de parrainage côté serveur.
- **Série** : noter une dépense prolonge la série ; le gel ne peut plus être consommé deux fois.
- **Dépenses fixes** : bouton « Payé ✓ » branché (liste et accueil) sur `markFixedPaid` ; écrans morts supprimés ; état payé lu depuis `months/{yyyy-MM}.fixedPaid` ; correction de l'écriture (map imbriquée, pas de clé pointée).
- **Quêtes du jour** : renouvelées chaque jour local (`dailyRollover`, trigger de création de profil), expirées à minuit local, purgées après 14 jours ; index collection group `quests` et `alerts` ajoutés ; le client lit les quêtes les plus récentes.
- **Tâches planifiées** : pagination par curseur + concurrence bornée + garde de durée pour `dailyRollover`, notifications, `generateMonth`, `weeklyInsights`.
- **Fuseaux horaires** : id IANA + décalage en minutes (demi-heures, heure d'été) côté client, règles, rollover, notifications et rappel local de 19 h.

### Ajouté — Classement (ligues)
- L'écran de classement affichait une liste de joueurs écrite en dur. Il lit maintenant de vraies données : groupe de la semaine, XP de chaque joueur en direct, compte à rebours, zones de promotion / relégation, résultat de la semaine précédente, états chargement / erreur avec bouton Réessayer.
- Functions : `joinLeague` (callable), `onGameXpChange` (trigger sur `game/state`), `leagueWeekly` (clôture horaire des groupes terminés) ; règles Firestore (lecture seule pour `leagues/{id}/members`) et index `leagues(processed, endsAt)`.
- Les onglets Amis et Mon pays affichent « Bientôt disponible » (V2).
- Le profil affiche la vraie ligue, localisée.

### Corrigé — Accueil et série affichaient de fausses données
- **Accueil** : la série (🔥 12), les graines (🌾 340) et le niveau (7) étaient écrits en dur. Ils lisent maintenant `users/{uid}/game/state` (tirets « — » tant que l'état n'est pas chargé).
- **Quêtes du jour (accueil)** : la carte affichait trois quêtes inventées (dont « Reste sous ton budget restos » toujours cochée) et comptait les dépenses du **mois** pour une quête « du jour ». Elle affiche maintenant les vraies quêtes quotidiennes du serveur (`period == 'daily'`, 3 max, non terminées d'abord) avec leur progression réelle, ou un message si elles ne sont pas encore créées.
- **Écran de série** : affichait toujours 13 jours et 5 jours cochés. Il affiche la vraie série et les jours de la semaine courante qui en font partie (calcul pur `streakWeekMarks`, sans effet de l'heure d'été). Les initiales des jours suivent la langue de l'app.
- Le toast après une dépense n'affiche plus un « 2/3 » en dur.

### Ajouté — Sons et vibrations
- Nouveau module `core/feedback/` : `FeedbackService` (point d'entrée unique), table des événements (`SiphoCue` → son + vibration + voix), réglages lus depuis les interrupteurs existants (Sons, Vibrations, Voix).
- Déclencheurs : dépense ajoutée (saisie et scan validé), « Payé ✓ », scan terminé, bonne / mauvaise réponse, quête réclamée, cadeau ouvert, et, côté serveur, passage de niveau, promotion de ligue et série prolongée (détectés en comparant l'ancien et le nouvel état de jeu ; jamais au premier chargement ni au changement de compte).
- Les erreurs restent douces : un son, aucune vibration. Les voix de Sipho (`sipho_*`) ne jouent que si l'option est activée.
- `SoundService` réécrit : sons alignés sur le README (10 effets + 3 emplacements de voix, format OGG), ne plante jamais (fichier absent, moteur audio indisponible : ignoré et loggé une fois), nettoyage sûr.
- Session audio iOS configurée par l'app (`flutter_soloud` ne le fait pas) : catégorie *ambient* + *mix with others*, donc respect du mode silencieux et musique de l'utilisateur non coupée. Android : aucun focus audio demandé.
- Les interrupteurs Sons / Vibrations prennent effet immédiatement et jouent un aperçu quand on les active.
- **10 sons provisoires** ajoutés dans `app/assets/sounds/` (OGG mono, 93 Ko au total) : packs CC0 de Kenney (Interface Sounds, Music Jingles, RPG Sounds) retenus d'après leur durée et leur contour mélodique (montant pour les réussites, descendant pour l'alerte), jingles de steel drum pour les moments forts (timbre proche du kalimba). Convertis, rognés et mis au même volume par `app/tool/build_sounds.py` ; licences dans `app/assets/sounds/CREDITS.txt`. Remplaçables en déposant un fichier du même nom.
- Les voix de Sipho (`sipho_*`) n'ont pas de fichier : ignorées sans erreur.
- Test : chaque son existe, est un OGG valide, est déclaré dans le `pubspec.yaml` et respecte le budget de taille.

### Corrigé — Écran cadeau
- Les pastilles 🔥 12 / 🌾 340 / niveau 7 de l'écran d'ouverture du cadeau étaient écrites en dur ; elles lisent l'état de jeu réel. (Le contenu du cadeau lui-même reste écrit en dur.)

### Ajouté — Tests
- `Money`, `MoneyFormatter`, `LocalDay` (tâche de la phase 1 qui n'avait pas de tests), `streakWeekMarks`, `dailyQuestsForHome`, `StreakScreen`, réglages / événements / service de feedback, détection des événements de jeu. 62 → 124 tests Flutter.

### Notes de migration
- Les utilisateurs existants reçoivent `timezone` / `utcOffsetMinutes` au prochain lancement de l'app ; les tâches planifiées ne traitent plus les profils qui n'ont que l'ancien `timezoneOffset` avant cela.
- Déployer règles **et** index (`firebase deploy --only firestore,functions`) ; les nouveaux index mettent quelques minutes à se construire.

---

<!-- Template pour les prochaines entrées :

## [0.1.0] - YYYY-MM-DD

### Ajouté
- Nouvelle fonctionnalité

### Modifié
- Changement d'une fonctionnalité existante

### Corrigé
- Correction d'un bug

### Supprimé
- Fonctionnalité retirée

### Sécurité
- Correction d'une vulnérabilité

-->
