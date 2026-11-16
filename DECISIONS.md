# DECISIONS.md — Journal des décisions architecturales (ADR)

> Format inspiré de [Michael Nygard's ADR template](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions).

---

## ADR-001 — Architecture Flutter : feature-first, Riverpod, go_router

**Date :** 2026-11-12  
**Statut :** ✅ ACCEPTÉE

### Contexte
Il faut choisir une architecture scalable pour une app Flutter complexe (gamification, finances, IA, notifications).

### Décision
- Structure **feature-first** : `lib/features/<feature>/data|domain|presentation/`
- State management : **Riverpod 2** avec `riverpod_generator` (annotations)
- Navigation : **go_router 14** (déclaratif, deep linking natif)
- Modèles : **freezed** + **json_serializable** (immuabilité, copywith, pattern matching)

### Conséquences
- Code bien isolé par domaine métier, facile à tester
- Courbe d'apprentissage Riverpod pour les nouveaux contributeurs
- Code generation (`build_runner`) nécessaire à chaque modification de modèle

---

## ADR-002 — Montants en cents (jamais de `double`)

**Date :** 2026-11-12  
**Statut :** ✅ ACCEPTÉE

### Contexte
Les calculs financiers avec `double` induisent des erreurs d'arrondi (ex: `0.1 + 0.2 ≠ 0.3`).

### Décision
- Tous les montants sont stockés et manipulés en **centimes (`int`)**
- La classe `Money(int cents, String currency)` encapsule la valeur
- L'affichage est géré par `MoneyFormatter` (avec `intl`)
- Firestore stocke le champ `amountCents: int`

### Conséquences
- Aucune erreur d'arrondi possible
- Conversion nécessaire à l'affichage uniquement
- Arithmétique simple et testable

---

## ADR-003 — XP, séries et ligues côté serveur uniquement

**Date :** 2026-11-12  
**Statut :** ✅ ACCEPTÉE

### Contexte
La logique de gamification (XP, streaks, ligues) doit être infalsifiable pour maintenir l'intégrité du classement.

### Décision
- Toute attribution d'XP est effectuée par **Cloud Functions** uniquement
- Le client envoie des événements (action réalisée) ; le serveur calcule et crédite
- Les limites journalières d'XP sont configurées via **Remote Config**
- Firestore Security Rules interdisent l'écriture directe des champs `xp`, `streak`, `league`

### Conséquences
- Résistance à la triche / manipulation côté client
- Latence légèrement plus élevée (appel réseau pour chaque gain XP)
- Cloud Functions à tester rigoureusement

---

## ADR-004 — Scan Gemini côté client (Firebase AI Logic) au MVP

**Date :** 2026-11-12  
**Statut :** 🟡 IMPLÉMENTÉE (option A, client) — à confirmer après mesure du coût réel par scan (mise à jour du 2026-11-15)

### Contexte
L'extraction d'informations depuis une photo de ticket de caisse peut se faire côté client (Firebase AI Logic / Gemini on-device ou API directe) ou via une Cloud Function serveur.

### Options

| Option | Avantages | Inconvénients |
|---|---|---|
| **A — Client direct (Firebase AI Logic)** | Simple, latence faible, moins de code serveur | Coût API visible côté client, quotas par utilisateur moins contrôlables |
| **B — Cloud Function serveur** | Contrôle total des quotas et coûts, logs centralisés | Latence aller-retour supplémentaire, plus de code à maintenir |

### Décision provisoire
Option A au MVP pour la simplicité, avec quotas contrôlés via Remote Config.

### À trancher
- Coût réel par scan en production
- Acceptabilité de la latence option B

---

## ADR-005 — 3 projets Firebase (dev / staging / prod)

**Date :** 2026-11-12  
**Statut :** ✅ ACCEPTÉE

### Contexte
Un seul projet Firebase mélangerait données de test et de production, risquant la corruption de données réelles.

### Décision
- **`sipho-dev`** : développement local + émulateurs Firebase
- **`sipho-staging`** : QA, beta interne, tests d'intégration
- **`sipho-prod`** : utilisateurs finaux uniquement

**App Check (2026-11-15)** : Play Integrity / App Attest en release, jeton debug fixe en debug (le même sur tous les appareils de dev, révocable dans la console, jamais lu par un build release). **Le jeton est un secret** : le dépôt GitHub est public, il est donc passé par `--dart-define=APP_CHECK_DEBUG_TOKEN=<uuid>` (`.vscode/launch.json`, ignoré par git) et jamais écrit dans le code. S'il fuite : le supprimer dans la console et en générer un nouveau (`uuidgen`). L'enforcement serveur (`enforceAppCheck`) est activé une fois les jetons valides observés.

Chaque environnement pointe vers le bon projet via `firebase_options_<env>.dart`. Il n'y a **plus de flavors Android** (retirés le 2026-11-14 : un seul projet réel, dev, et `--flavor` gênait le quotidien, surtout sur iOS qui n'a qu'un schéma). L'environnement se choisit côté Dart : `main.dart` prend dev en debug et prod en release, `main_dev.dart` / `main_staging.dart` forcent un environnement. À rétablir (flavors Android + schémas Xcode) quand staging et prod existeront pour de bon.

### Conséquences
- Isolation totale dev / prod
- 3 déploiements à maintenir (CI/CD automatise ça)
- Coûts Firebase multipliés par 3 (acceptables au stade MVP)

---

## ADR-006 — App Links / Universal Links (pas Firebase Dynamic Links)

**Date :** 2026-11-12  
**Statut :** ✅ ACCEPTÉE

### Contexte
Firebase Dynamic Links a été **officiellement arrêté** (sunset août 2025). Il ne peut plus être utilisé.

### Décision
- **Android** : App Links (`.well-known/assetlinks.json` sur le domaine)
- **iOS** : Universal Links (`.well-known/apple-app-site-association`)
- Package Flutter : `app_links ^6.3.3`
- Deep links gérés par go_router

### Conséquences
- Plus de dépendance à un service tiers déprécié
- Configuration initiale plus manuelle sur chaque plateforme
- Comportement natif, plus fiable à long terme

---

## ADR-007 — SoundService via flutter_soloud

**Date :** 2026-11-12  
**Statut :** ✅ ACCEPTÉE

### Contexte
L'app nécessite ~10 sons (succès, erreur, XP, série, pièce...) avec faible latence et contrôle du volume.

### Décision
- Package : **`flutter_soloud ^3.2.1`** (binding natif SoLoud, faible latence)
- `SoundService` Riverpod précharge les sons au démarrage
- Respect du mode silencieux système via `audio_session`
- Sons désactivables par l'utilisateur (Remote Config + Prefs)

### Conséquences
- Latence audio < 50 ms (vs. 200+ ms avec audioplayers)
- Dépendance native (binaires SoLoud compilés par plateforme)
- Taille de l'app légèrement augmentée

---

## ADR-008 — Packs pays Firestore (zéro règle fiscale codée en dur)

**Date :** 2026-11-12  
**Statut :** ✅ ACCEPTÉE

### Contexte
Sipho cible plusieurs pays (CA, FR, CM, CI, SN) avec des taxes, devises et catégories différentes. Coder ces règles en dur rendrait les mises à jour impossibles sans release.

### Décision
- Les configurations pays (taxes TVA/TPS/TVQ, devise par défaut, catégories suggérées) sont stockées dans **Firestore** (`/countries/{countryCode}`, avec un pack `countries/generic` en repli ; corrigé le 2026-11-15, l'ADR citait à tort `/countryPacks`)
- Chargées au démarrage et mises en cache localement
- Mises à jour sans release via Firestore
- Aucune règle fiscale en dur dans le code Dart

### Conséquences
- Ajout d'un nouveau pays = simple document Firestore (pas de release)
- Risque : si Firestore indisponible au premier lancement, fallback sur le pack CA intégré en assets
- Tests d'intégration nécessaires pour chaque pack pays

---

## ADR-009 — Règles des quêtes

**Date :** 2026-11-14  
**Statut :** ✅ ACCEPTÉE et implémentée (règles 1 à 9)

### Contexte
Les quêtes sont le levier d'habitude quotidienne de Sipho. Leurs règles étaient dispersées entre le README, le code et les tests. Une quête mal définie peut récompenser de la triche (progression envoyée par le client), de la dépense, ou de la culpabilisation.

### Décision

**Principes**
1. **Serveur uniquement** : création, progression, expiration et récompense des quêtes sont faites par Cloud Functions. Le client lit `users/{uid}/quests` et appelle `claimQuest` ; les règles Firestore interdisent toute écriture client.
2. **Seulement des actions vérifiables par le serveur** : types autorisés `ADD_TRANSACTION` et `COMPLETE_LESSON`, avancés par `onTransactionWrite` et `completeLesson`. Pas de quête « j'ai ouvert l'écran X » dont la progression viendrait du client. Un nouveau type exige d'abord son déclencheur serveur.
3. **Ne jamais récompenser la dépense** : on récompense noter, apprendre, tenir son budget. Aucune quête ne demande de dépenser un montant ou d'atteindre un nombre d'achats.
4. **Bienveillance** : pas de quête punitive ni de message de culpabilisation ; un dépassement propose une quête de rattrapage, jamais un reproche.

**Quêtes du jour**
5. **Catalogue** : au plus **3** modèles quotidiens (`MAX_DAILY_QUESTS`). Aujourd'hui : `log_expenses` (noter 3 dépenses, 15 XP, 5 graines) et `daily_lesson` (1 micro-leçon, 20 XP, 5 graines). Chaque modèle a un texte FR et EN, un `target` entier positif et une récompense de 50 XP maximum.
6. **Cycle de vie** : id déterministe `daily_{templateId}_{yyyy-MM-dd}` (jour **local** de l'utilisateur) ; créée par `onUserProfileCreate`, `dailyRollover` ou `refreshDailyQuests` (idempotent) ; une quête non terminée expire au prochain minuit local ; une quête terminée reste réclamable 24 h après la fin de son jour, puis expire ; supprimée 14 jours après expiration.
7. **Progression** : `ADD_TRANSACTION` +1 par dépense créée ; `COMPLETE_LESSON` +1 par leçon validée, y compris une leçon rejouée (la pratique compte, le gain reste plafonné à une quête par jour). La progression ne dépasse jamais `target`.
8. **Réclamation** (`claimQuest`) : une seule fois, dans une transaction. Refusée si la quête n'est pas terminée ou si elle est `expired`. XP borné à 5–100 et graines à 1–25, quoi que dise le document. Les récompenses sont réellement attribuées côté serveur (XP, niveau, ligue).

**Quêtes IA** (hebdomadaires et à la demande) : mêmes types autorisés (énumération zod), `target` de 1 à 14, 20 XP, expiration à 7 jours, créées par le serveur uniquement.

**Ajouter un modèle quotidien** (liste de contrôle) : l'ajouter à `DAILY_QUEST_TEMPLATES` ; vérifier que `quests.test.ts` passe (plafonds, ids, types, FR/EN) ; adapter le test d'émulateur du changement de jour si besoin ; si c'est un nouveau type, écrire son déclencheur serveur et son test ; mettre à jour le README (§5.2) et le TRACKER. Il apparaît le jour même grâce à `refreshDailyQuests`.

**Règle 9 — Journée sous budget (implémentée : `shared/budgetDay.ts`, `gamification/budgetDay.ts`)**
- **Budget du jour** = `max(0, revenu mensuel − dépenses fixes actives) ÷ nombre de jours du mois`, en cents entiers (arrondi inférieur). Le revenu (`monthlyIncomeCents`) et les dépenses fixes sont ceux que voit l'utilisateur dans son « reste à vivre ». Un budget stable plutôt que « reste ÷ jours restants », qui bouge à chaque dépense et se prête aux calculs d'optimisation.
- **Évaluation** : par le serveur, dans `dailyRollover`, pour la journée locale qui vient de se terminer, sur les dépenses datées de ce jour (montant principal de l'utilisateur). Dépenser exactement le budget compte comme « sous budget ».
- **Condition d'éligibilité** : au moins **une dépense notée ce jour-là**. Sans cela, ne rien noter suffirait à « tenir son budget », ce qui récompenserait l'absence de suivi. Les jours sans dépense ne comptent qu'avec une confirmation explicite « aucune dépense aujourd'hui » (callable `confirmNoSpend`) : elle prolonge la série (README §5.3), n'attribue aucun XP à elle seule, est refusée si une dépense est déjà notée ce jour-là, et ne peut jamais excuser un dépassement (une dépense ajoutée ensuite est comptée normalement).
- **Récompense** : 15 XP (`XP_CONFIG.budgetDayUnder`), attribués automatiquement, une fois par jour (marqueur `dailyXp/{jour}.fromBudgetDay`, donc sans doublon en cas de rejeu). Sans revenu renseigné, ou si les charges fixes absorbent tout le revenu, la règle ne s'applique pas. Un échec de cette évaluation est journalisé et ne bloque jamais le traitement de la série.
- **Retour à l'utilisateur** : le serveur écrit `lastBudgetDay { dayKey, xp }` dans `game/state` (déjà lu en direct par l'app). L'accueil affiche une carte « Journée sous budget ! +15 XP » pendant le jour qui suit, et l'app joue un son discret (jamais au premier chargement ni au changement de compte). De même, `noSpendDay` masque le bouton « Aucune dépense aujourd'hui » une fois confirmé.
- **Limite connue** : les montants étant déclarés par l'utilisateur, la règle ne peut pas empêcher de sous-déclarer une dépense, comme pour tout le suivi.

### Conséquences
- Les règles 5 à 8 sont verrouillées par des tests Jest (`quests.test.ts`) ; la règle de réclamation est une fonction pure (`shared/questClaim.ts`).
- La règle 2 limite volontairement la variété des quêtes tant que d'autres déclencheurs serveur n'existent pas (scan, carte économique, charge fixe payée).
- La règle 9 est verrouillée par des tests Jest (`budgetDay.test.ts`) et des tests d'émulateur (rollover, rejeu, jour voisin, sans revenu).

---

## ADR-010 — Amis et invitations

**Date :** 2026-11-14  
**Statut :** ✅ ACCEPTÉE (partage par lien : ⏳ en attente d'un domaine)

### Contexte
Le README prévoit amis, parrainage et séries entre amis. Le serveur savait échanger un code (`referralRedeem`) mais aucun code n'était créé et l'app n'avait aucun écran. La confidentialité prime : un ami ne doit jamais voir de montant.

### Décision
- **Un seul code par utilisateur** : code d'invitation = code ami, 8 caractères sans `0/O/1/I`, dérivé du `uid` (stable, sans table de correspondance), créé à la demande par `getInviteCode` avec son document `referrals/{code}`. Pas de recherche d'utilisateurs : on ne devient ami qu'en connaissant le code, ce qui évite l'annuaire public.
- **Écritures serveur uniquement** : `sendFriendRequest`, `respondFriendRequest`, `removeFriend` (les règles interdisent toute écriture sur `friendships`). Une demande croisée est acceptée d'office ; seul le destinataire peut répondre ; chacun des deux peut retirer l'amitié ; 100 liens (en attente + acceptés) au maximum ; limites de fréquence par action.
- **Parrainage = amitié** : `referralRedeem` crée l'amitié acceptée entre parrain et filleul.
- **Ce qu'un ami voit** : `publicProfiles` uniquement (pseudo, niveau, série, ligue). Jamais de montant ni de revenu.
- **Lecture** : `friendships` lisible par ses deux membres ; `referrals/{code}` lisible par son seul propriétaire (le document liste les invités). Le client passe par les callables pour résoudre un code.
- **Suppression de compte** : amitiés et demandes supprimées avec le compte.
- **Interface** : onglet « Amis » du classement : mon code (copier / partager), ajouter par code, demandes reçues et envoyées, liste triée par série, code de parrainage.
- **Contacts (ajouté le 2026-11-14, ouvre une exception à « pas d'annuaire »)** : retrouver ses amis dans le carnet d'adresses et inviter les autres.
  - **Clés = e-mail et numéro de téléphone** (choix de Manuel, le numéro ajouté le même jour) : le client envoie le **SHA-256** de chaque e-mail (trim + minuscules) et de chaque numéro (E.164) de contact ; le serveur répond avec les comptes dont l'empreinte est dans `contactIndex/{hash}` (collection **serveur uniquement**, aucune règle de lecture). Les deux espaces ne peuvent pas se confondre (un e-mail contient `@`, un numéro commence par `+`).
  - **Un compte est trouvable par ses identités vérifiées** : e-mail vérifié et/ou numéro vérifié par SMS (Firebase Phone Auth, `linkWithCredential` sur le compte existant). Un e-mail non vérifié n'est jamais indexé. `setContactDiscovery(true)` réindexe toutes les identités ; l'état `users/{uid}/social/contacts` garde la liste `hashes` (l'ancien champ `emailHash` est encore lu). Ajouter un numéro rappelle `setContactDiscovery(true)` ; pour un compte sans e-mail utilisable (Apple masqué), ajouter un numéro suffit à s'inscrire à la découverte.
  - **Lecture d'un numéro de contact** : international (`+…`, `00…`) tel quel ; local complété avec l'indicatif du **pays de l'utilisateur** (FR, BE, MA, CA, US, CI, SN, CM, ML, BF, TG, BJ). Le `0` initial est retiré en France/Belgique/Maroc (préfixe de ligne) mais conservé en Côte d'Ivoire (il fait partie du numéro depuis 2021). Un numéro ambigu (pays inconnu, trop court) n'est pas deviné : il reste utilisable pour l'invitation par SMS, pas pour la recherche. Les anciens numéros ivoiriens à 8 chiffres ne correspondent donc jamais.
  - **Consentement explicite et réciproque** : rien n'est lu avant un clic ; une fenêtre explique la comparaison par empreintes et que les gens qui ont mon e-mail pourront me trouver. `setContactDiscovery(true)` publie l'empreinte de **mon e-mail vérifié** ; `findContacts` refuse un appelant qui n'est pas lui-même trouvable (un scraper doit donc être trouvable aussi). Retrait possible à tout moment ; la suppression de compte retire l'empreinte.
  - **Rien du carnet n'est conservé** : les contacts qui ne sont pas utilisateurs ne sont jamais vus par le serveur (seulement une empreinte), rien n'est stocké côté serveur ni sur l'appareil. La permission (`READ_CONTACTS` / `NSContactsUsageDescription`) n'est demandée qu'après le clic de consentement ; refusée, l'utilisateur reste non trouvable.
  - **Demandes** : `sendContactFriendRequest {targetUid}` n'accepte que des comptes trouvables, depuis un appelant trouvable, et passe par la même logique que les codes (`createFriendRequest` : limites, demande croisée, 100 liens). Quota partagé de 20 demandes/jour avec `sendFriendRequest`.
  - **Bornes** : 1000 empreintes par appel, 5000 par analyse, 10 appels/jour, 200 correspondances. L'analyse est manuelle (pas à chaque ouverture) pour ne pas épuiser le quota.
  - **Invitations** : pour les contacts qui ne sont pas sur Sipho, boutons SMS (`sms:`) et e-mail (`mailto:`) qui ouvrent l'application de messagerie avec le message et mon code ami ; l'envoi est fait par l'utilisateur, Sipho n'envoie rien.
  - **Limites connues** : un e-mail se devine (SHA-256 sans secret) : quelqu'un qui devine l'adresse de quelqu'un peut vérifier qu'il est sur Sipho s'il est lui-même trouvable (quota et réciprocité limitent l'énumération). Les e-mails masqués d'Apple (relais privé) ne correspondent jamais : seul un numéro vérifié rend ces comptes trouvables. Un numéro se devine encore plus facilement qu'un e-mail (espace de recherche réduit) : même parade (réciprocité, quotas), mais le risque d'énumération est plus fort ; à surveiller avant l'ouverture publique (un secret serveur de type HMAC n'aiderait que si le client n'envoyait pas lui-même des empreintes calculables).
  - **Coût et configuration** : chaque vérification envoie un SMS (facturé sur le plan Blaze ; protection anti-abus : activer la région d'envoi et les quotas dans la console). Phone Auth doit être activé dans Firebase Authentication ; Android demande les empreintes SHA-1/SHA-256 de l'application et Play Integrity (ou reCAPTCHA), iOS les notifications APNs ou le schéma d'URL reCAPTCHA (déjà présent pour Google). Non vérifié sur appareil au moment de l'écriture ; des numéros de test peuvent être déclarés dans la console.

### À trancher / limites connues
- **Partage par lien** : le partage envoie un message avec le code. Les App Links / Universal Links (README §5.3) demandent un domaine et `assetlinks.json` / `apple-app-site-association` sur Firebase Hosting, qui n'existent pas encore.
- **Récompense de parrainage immédiate** : le code accorde 50 XP + 10 graines au parrain dès l'usage (25 XP + 5 graines au filleul), alors que le README parle d'un « filleul actif 7 jours » (200 XP + cadeau rare). Avec jusqu'à 50 usages par code, des comptes jetables peuvent gonfler l'XP, et l'XP de parrainage compte dans `weeklyXp` (classement des ligues). À corriger avant l'ouverture publique : récompense différée à l'activité du filleul et XP hors classement.
- **Encouragements, défis 1v1, séries entre amis** (V2) : non faits.

### Conséquences
- Aucune donnée financière n'est exposée par le social.
- La limite de 100 liens et les limites de fréquence bornent le spam de demandes.

---

*Dernière mise à jour : 2026-11-14*

---

## ADR-011 — Chemin de leçons par unités

**Date :** 2026-11-15  
**Statut :** ✅ ACCEPTÉE

### Contexte
Le chemin de leçons n'était qu'une liste de 3 leçons : le verrouillage n'existait que dans l'app (un appel direct à `completeLesson` pouvait valider n'importe quelle leçon) et aucune récompense ne marquait la fin d'une série de leçons.

### Décision
- **Le serveur est l'autorité du chemin** : `functions/src/shared/lessonPath.ts` (`LESSON_UNITS`) liste les unités et leurs leçons dans l'ordre. `ALLOWED_LESSON_IDS` en est dérivé, l'app en garde un miroir (`kCatalogUnits`), et un test Flutter compare les deux (unités, ordre, bonus).
- **Verrouillage serveur** : une leçon s'ouvre quand la leçon juste avant elle (d'une unité à l'autre) est faite. `completeLesson` refuse sinon (`failed-precondition`) ; rejouer une leçon déjà validée reste permis.
- **Bonus de fin d'unité, une seule fois** : terminer la dernière leçon manquante d'une unité, pour la première fois, donne `unitComplete` (30 XP) + `unitCompleteSeeds` (10 graines), en plus de la récompense de la leçon. Rejouer ne le redonne jamais. La réponse de `completeLesson` ajoute `unitCompleted`, `unitBonusXp`, `unitBonusSeeds`.
- **Interface** : l'onglet Apprendre affiche une section par unité (numéro, titre, `x/y leçons`, barre, bonus à gagner, verrouillée tant que l'unité d'avant n'est pas finie). La quête « Terminer l'unité » suit l'unité en cours. L'écran de leçon annonce le bonus.
- **Contenu** : unité 1 « Les bases du budget » (3 leçons), unité 2 « Épargner, un pas après l'autre » (3 leçons, nouvelles). L'unité 3 (CELI) reste annoncée « verrouillée ».

### À trancher / limites connues
- ~~Les leçons n'ont qu'une question chacune~~ — levé le 2026-11-15 : une leçon est une suite d'étapes (`InfoStep`, `QuizStep`, `TrueFalseStep`) + 3 points à retenir. Le serveur ne voit toujours que `{lessonId, score, durationSeconds}` : le contenu pédagogique reste côté app, la parité ne porte que sur les ids, l'ordre des unités et les bonus. Le score est `100 × questions / (questions + erreurs)`.
- Le bonus est le même pour toutes les unités ; il peut devenir un champ par unité.
- Ajouter une leçon à une unité déjà terminée par un joueur ne redonne pas de bonus (la leçon suivante s'ouvre seulement après elle).

### Conséquences
- Ajouter une unité demande de modifier `lessonPath.ts`, `lesson_catalog.dart` et le contenu ; le test de parité échoue sinon.

---

## ADR-014 — Conseils financiers personnalisés par notification (IA encadrée)

**Date :** 2026-11-15  
**Statut :** ✅ ACCEPTÉE

### Contexte
Les notifications étaient des modèles fixes (série, échéance, budget). Les conseils IA existaient (`weeklyInsights`, `generateInsight`) mais restaient dans l'app, sans notification, et ne tenaient pas compte des résultats des leçons.

### Décision
- **Les règles décident, l'IA rédige.** `shared/advice.ts` (pur, testé) choisit le sujet à partir des données réelles : budget dépassé > leçon mal réussie > catégorie dominante (≥ 40 %) > aucune dépense notée depuis 7 jours > prochaine leçon > objectif > général. Chaque sujet a un délai avant de revenir (3 à 14 jours) ; si tout a été dit récemment, rien n'est envoyé.
- **S'adapter aux anciennes réponses** : `completeLesson` enregistre `lastScore` à côté de `bestScore` dans `lessonProgress`. Une leçon dont le dernier score est < 80 est « à revoir » ; la rejouer avec un bon score la retire de la liste.
- **Garde-fous sur l'IA** : le prompt ne contient que des faits agrégés (centimes arrondis en unités, pourcentages, sujet de la leçon, objectif parmi 4 valeurs connues) : jamais de nom, d'uid ni de texte libre. La réponse est refusée si le JSON est invalide, si elle dépasse 45 / 140 caractères, si elle cite un nombre absent des faits, ou si elle parle de placement, crédit, impôt ou crypto. Dans ces cas (ou si l'IA est indisponible, sans clé ou hors quota) un **modèle FR/EN construit avec les mêmes faits** est envoyé : l'apprenant reçoit toujours un message juste.
- **Cadence et consentement** : uniquement si `notifPrefs.tips` est activé (opt-in), onboarding terminé, fenêtre 12 h–14 h locale, hors heures calmes, au plus 1 conseil tous les 3 jours, et le plafond de 2 notifications d'engagement par jour s'applique.
- **Traçabilité** : `users/{uid}/adviceHistory` (sujet, texte, source `ai`/`template`, jour) sert aux délais et à varier la formulation ; le même texte est écrit dans `insights/advice_{jour}` pour que la carte coach de l'app affiche ce que la notification annonce.
- Les utilitaires d'envoi (heures calmes, fenêtre locale, plafond, FCM) sont sortis de `notifyScheduler.ts` vers `notifications/delivery.ts`.

### À trancher / limites connues
- Le score d'une leçon indique qu'elle est mal comprise, pas quelle question a posé problème (le serveur ne reçoit pas le détail des réponses).
- Pas de test A/B de formulation ni de mesure d'ouverture (`notif_opened`) encore.
- Le conseil `budget_over` suppose un revenu mensuel renseigné ; sans revenu, il n'est jamais choisi (l'étape revenu de l'onboarding reste à faire).
- Un appel IA par utilisateur éligible et par envoi : à surveiller côté quota.

### Conséquences
- Ajouter une leçon demande aussi d'ajouter son sujet dans `LESSON_TOPICS` (le compilateur l'impose).

---

## ADR-012 — Badges attribués par le serveur

**Date :** 2026-11-15  
**Statut :** ✅ ACCEPTÉE

### Contexte
Le champ `badges` existait dans l'état de jeu mais aucune règle ne l'alimentait ; le profil affichait des icônes calculées à la volée (nombre de leçons) avec des emplacements verrouillés en dur.

### Décision
- **Règles pures** dans `functions/src/shared/badges.ts` (`BADGE_RULES`). Un badge ne dépend que d'un état qui ne fait que croître (leçons faites, meilleure série, niveau, palier de ligue) : il ne se perd jamais et réévaluer est toujours sans danger.
- **Catalogue (8)** : `first_lesson`, un badge par unité (`unit_1`, `unit_2`… généré depuis `LESSON_UNITS`), `streak_7`, `streak_30` (meilleure série), `level_5`, `level_10`, `league_silver`.
- **Un seul déclencheur** `onGameBadgeCheck` sur `users/{uid}/game/state` : tous les chemins d'attribution (leçons, séries, XP, ligues) écrivent cet état, aucun ne peut oublier de vérifier. Les badges sont ajoutés avec `arrayUnion` (jamais de remplacement du tableau) ; l'écriture relance le déclencheur une fois, qui ne trouve rien à ajouter et s'arrête.
- **Aucun XP** : un badge est purement honorifique, il ne peut pas alimenter l'XP ni le classement des ligues.
- **Copie publique** : les badges sont aussi écrits dans `publicProfiles/{uid}` (README §5 : ni montant ni donnée financière).
- **App** : le profil affiche tout le catalogue (`kBadges`), verrouillé tant que le serveur n'a pas attribué le badge ; toucher un badge affiche son nom et comment l'obtenir. Un nouveau badge dans l'état de jeu joue un son (`SiphoCue.badgeUnlocked`), derrière niveau et ligue, devant la série. Un identifiant inconnu (serveur plus récent que l'app) s'affiche tel quel.
- **Parité** : un test Flutter compare les identifiants et l'ordre avec `shared/badges.ts`.

### À trancher / limites connues
- Aucun badge de « première victoire / Bâtisseur » : l'écran d'onboarding l'annonce encore en texte, mais le serveur ne l'attribue pas.
- Pas de badge lié aux quêtes, aux amis ou au budget (« sous budget »).
- Le son de déblocage réutilise celui du cadeau (aucun son dédié).
- Un utilisateur existant reçoit ses badges au prochain changement de son état de jeu, pas rétroactivement d'un coup.

### Conséquences
- Ajouter un badge = une règle dans `badges.ts`, une entrée dans `kBadges`, deux chaînes ; le test de parité échoue sinon.

---

## ADR-013 — Boutique de graines : achats côté serveur

**Date :** 2026-11-15  
**Statut :** ✅ ACCEPTÉE

### Contexte
Les graines (`gems`) étaient gagnées partout (leçons, quêtes, bonus d'unité, parrainage) mais ne pouvaient être dépensées nulle part : l'écran « Boutique » était une maquette (série 12, 340 graines et niveau 7 écrits en dur, bouton « Acheter » sans effet). Les gels de série (2 au départ) ne se rechargeaient jamais.

### Décision
- **Le serveur fixe tout** : catalogue et prix dans `functions/src/shared/shop.ts` ; callable `buyShopItem {itemId}` qui ne fait confiance qu'à l'identifiant. Achat dans une transaction sur `game/state` (solde relu, jamais celui du client). Limite 30 achats/heure.
- **Catalogue (6)** : chapeau (120), lunettes (80), écharpe verte (150), écharpe terracotta (150), nid fleuri (200) = objets cosmétiques, achetés **une seule fois** ; gel de série (60) = consommable, **stock de 2 maximum** (README 5.3).
- **Refus** : `failed-precondition` avec `details.reason` ∈ `already-owned`, `max-stock`, `insufficient-seeds`. Le plafond de stock est signalé avant le prix.
- **Inventaire** : `game/state.ownedItems` (liste, `arrayUnion`) pour les objets ; les gels vivent déjà dans `streak.freezes`, remplacé en entier (sûr même avec l'ancien champ numérique). Aucune règle Firestore à ajouter : l'état de jeu reste lisible par son propriétaire, écrit par les Functions.
- **App** : l'écran lit le vrai solde, la vraie série et le vrai niveau ; chaque carte indique Acheter / Possédé / Pas assez de graines / Stock plein ; un achat à la fois (double tap sans effet) ; les refus du serveur sont expliqués. Le client calcule l'état du bouton pour l'affichage, le serveur redécide à l'achat. Un test compare le catalogue (ids, prix, types, plafond) avec `shop.ts`.
- **Graines non achetables en argent** : inchangé, aucune voie d'achat en monnaie réelle.

### À trancher / limites connues
- Les objets cosmétiques sont **possédés mais pas encore portés** : Sipho n'a que des illustrations SVG fixes, sans accessoires ni équipement. L'achat est réel, l'effet visuel dépend d'assets créatifs (Rive).
- Pas de journal des achats ni de remboursement.
- Le gel ne se « répare » pas encore après une série brisée (README 5.3 : réparation sous 24 h).
- Les prix ne sont pas dans Remote Config (constantes serveur).

### Conséquences
- Ajouter un article = `shop.ts`, `shop_catalog.dart`, une chaîne FR/EN ; le test de parité échoue sinon.
