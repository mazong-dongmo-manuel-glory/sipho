# Sipho — le « Duolingo de l'argent »

> **Sipho** (zoulou : « cadeau ») est une application mobile gamifiée qui aide chacun, partout dans le monde, à suivre ses dépenses, maîtriser ses dépenses fixes, apprendre la finance personnelle et construire sa prospérité sur le long terme.
> *Slogan : « Fais-toi un cadeau : ton avenir. » / « Your future is a gift. »*

Ce README est la **source de vérité** du projet. Il est écrit pour deux lecteurs :
1. les développeurs humains ;
2. **les assistants IA de code** (Claude, Copilot, Cursor…), qui doivent lire en priorité la section [Instructions pour l'IA](#15-instructions-pour-lia-qui-code-ce-projet).

Auteur : Manuel Glory Mazong Dongmo — CargoNomade · Version 1.2 · 12 novembre 2026

---

## Sommaire

1. [Vision et principes](#1-vision-et-principes)
2. [Identité de marque](#2-identité-de-marque)
3. [Fonctionnalités](#3-fonctionnalités)
4. [International, économie et localisation](#4-international-économie-et-localisation)
5. [Gamification](#5-gamification)
6. [Notifications FCM](#6-notifications-fcm)
7. [UX, animations et sons](#7-ux-animations-et-sons)
8. [Stack technique](#8-stack-technique)
9. [Structure du dépôt](#9-structure-du-dépôt)
10. [Modèle de données Firestore](#10-modèle-de-données-firestore)
11. [Cloud Functions](#11-cloud-functions)
12. [Intégration IA (Gemini)](#12-intégration-ia-gemini)
13. [Sécurité et conformité](#13-sécurité-et-conformité)
14. [Installation et commandes](#14-installation-et-commandes)
15. [Instructions pour l'IA qui code ce projet](#15-instructions-pour-lia-qui-code-ce-projet)
16. [Tests et qualité](#16-tests-et-qualité)
17. [Feuille de route](#17-feuille-de-route)
18. [Décisions ouvertes](#18-décisions-ouvertes)

---

## 1. Vision et principes

Les applications de budget sont utiles mais ennuyeuses : on les abandonne en une semaine. Sipho transforme la gestion de l'argent en **habitude quotidienne ludique** (séries, quêtes, ligues, mascotte, sons, animations), adaptée au **pays et à la situation** de chaque utilisateur.

| Principe | Règle concrète |
|---|---|
| Simple | Toute action principale en **3 taps max**. Une journée « validée » en **< 60 s**. |
| Ludique | Chaque action = animation + son + vibration + XP. |
| Addictif aux **bonnes** habitudes | On récompense le suivi, la régularité, le respect du budget. **Jamais** le fait de dépenser. |
| Bienveillant | Aucune culpabilisation. Un dépassement déclenche un conseil + une quête de rattrapage. |
| Privé | Aucun montant n'est visible par les autres joueurs. Classements sur XP / pourcentages. |
| Éducatif | Éducation financière, **pas** de conseil financier personnalisé réglementé. |
| International | Aucun pays codé en dur : tout passe par les **packs pays**. |

**Public :** 18–35 ans, étudiants, jeunes travailleurs, nouveaux arrivants, diaspora qui soutient sa famille, expatriés.
**Langues :** FR + EN au lancement, i18n prête pour d'autres langues (y compris RTL).
**Pays prioritaires (proposition) :** Canada, France, Belgique, Suisse, Cameroun, Côte d'Ivoire, Sénégal, États-Unis, Royaume-Uni. Les autres pays utilisent le pack générique.

---

## 2. Identité de marque

| Élément | Définition |
|---|---|
| Nom | **Sipho** — prononcé « SI-po » (pas « Sifo ») |
| Promesse | Chaque bonne habitude est un cadeau à ton futur toi |
| Mascotte | **Sipho le tisserin** : petit oiseau jaune vif qui tisse son nid brin par brin |
| Personnalité | Enthousiaste, drôle, un peu dramatique, jamais moralisateur |
| Monnaie de jeu | **Graines d'or** (appelées `gems` dans le code) |
| Récompenses | « Cadeaux de Sipho » (coffres emballés dans un tissu africain), `chests` dans le code |
| Couleurs | Vert profond `#14342B`, vert Sipho `#1F9D55`, jaune tisserin `#F2B705`, terre cuite `#C8553D`, crème `#FFF8EC` |
| Son | Signature de 3–4 notes inspirée kalimba / kora |

**Métaphore produit :** le **nid = le socle** (dépenses fixes). Le nid évolue avec le niveau (nid simple → nid décoré → colonie de nids pour les amis et les ligues).

---

## 3. Fonctionnalités

Phases : **MVP** (lancement), **V2**, **V3**.

| Module | Résumé | Phase |
|---|---|---|
| Auth & onboarding | Google + Apple, onboarding conversationnel avec Sipho | MVP |
| **Mon socle** (dépenses fixes) | Loyer, internet, électricité, téléphone, épicerie, transport… configurés une fois, suivis chaque mois | MVP |
| Dépenses variables | Saisie express en 3 taps | MVP |
| Scan de factures IA | Photo → extraction Gemini → validation | MVP |
| Budgets & graphiques | Budgets par catégorie, **reste à vivre**, tendances | MVP |
| Gamification de base | XP, niveaux, séries, graines d'or, cadeaux, quêtes du jour | MVP |
| Micro-leçons | Tronc commun universel + modules par pays | MVP → V2 |
| Économie & contexte local | Indicateurs du pays + « ce que ça change pour toi » | MVP → V2 |
| Packs pays & localisation | Conseils, leçons, fiscalité selon pays / région | MVP |
| Notifications FCM | Rappels intelligents, alertes budget | MVP → V2 |
| Social | Amis, ligues, défis, parrainage | V2 |
| Conseils IA | Recommandations hebdo contextualisées | V2 |
| Objectifs d'épargne | Fonds d'urgence, voyage, mise de fonds… | V2 |
| Premium | Freemium (abonnement) | V2 |
| Planification long terme | Simulateurs retraite / dettes / intérêts composés par pays | V3 |
| Connexion bancaire | Agrégateurs + mobile money par région | V3 |

### 3.1 Onboarding (~2 min)
- Conversation avec Sipho : prénom → pays (pré-rempli depuis la locale) → région → devise → étape de vie (`student | first_job | family | pre_retirement | retired`) → objectif principal → revenu mensuel (fourchette, optionnel).
- Configuration du socle (voir 3.2).
- **Première victoire** : animation plein écran + badge + 50 XP.
- **Ensuite seulement** : pré-écran puis demande de permission des notifications.

### 3.2 Mon socle — dépenses fixes
- **Cartes à glisser** : « Loyer ? » droite = oui / gauche = non. Pour chaque oui : montant (clavier géant), jour de prélèvement, mode `auto | manual`, type `bill | envelope` (épicerie et transport = enveloppes mensuelles).
- Chaque dépense ajoutée = Sipho tresse un brin de son nid (Rive).
- **Calendrier du mois** : le jour J, carte « Loyer payé ? » → 1 tap → +10 XP.
- **Reste à vivre** = revenu − fixes − variables du mois. Chiffre central de l'accueil (jauge animée).
- Rappel FCM la veille d'une échéance manuelle.
- Détection de variation de montant → quête « Renégocie ton forfait ».
- **Chasseur d'abonnements** trimestriel.
- Le 1er du mois (fuseau de l'utilisateur), une Cloud Function génère le mois et reporte les fixes.

### 3.3 Dépenses variables
- Bouton « + » flottant → clavier numérique géant → grille de 8 catégories → valider.
- Catégories par défaut : `restaurants, groceries, transport, shopping, leisure, health, home, other` (personnalisables).
- Hors ligne OK (cache Firestore). +5 XP (max 10/jour).

### 3.4 Scan de factures
- Photo / import → compression (~1600 px, JPEG 80 %) → Gemini (sortie JSON imposée) → **écran de validation obligatoire** → enregistrement.
- Quota gratuit : 5 scans/jour (Remote Config). +15 XP.

### 3.5 Budgets & graphiques
- Budget proposé à partir du revenu et du socle (règle 50/30/20 ajustable), ajusté avec l'inflation du pays.
- Jauges : vert < 70 %, jaune 70–90 %, rouge > 90 % (toujours avec icône + texte, jamais la couleur seule).
- Graphiques `fl_chart` : barres par jour, anneau par catégorie, courbe 6 mois, fixes vs variables.
- Lecture du document agrégé `months/{yyyy-MM}` (1 lecture), pas de toutes les transactions.

### 3.6 Leçons
- Chemin vertical d'unités, leçons de 2–3 min : cartes animées, QCM, glisser-déposer, vrai/faux, mini-simulations.
- **Tronc commun** (`countries: ['*']`) : budget, fonds d'urgence, dettes et crédit, inflation, investir 101, arnaques.
- **Modules pays** : CA (CELI, REER, CELIAPP, RRQ/RPC), FR (Livret A, PEA, PER, assurance-vie), UK (ISA, pension), US (401k, IRA, credit score), CM/CI/SN (tontines, mobile money, CNPS/CNSS, change FCFA).

---

## 4. International, économie et localisation

### 4.1 Localisation
| Niveau | Source | Consentement |
|---|---|---|
| Pays | Onboarding (pré-rempli par la locale) | Obligatoire, modifiable |
| Région | Choix utilisateur ou géoloc | Optionnel |
| Ville | Géoloc **approximative, à la demande** | Optionnel, explicite |
| Pays d'origine / transferts | Déclaratif | Optionnel |

- `geolocator` en précision réduite, **jamais en arrière-plan**. `geocoding` côté appareil.
- **On stocke uniquement les libellés** (pays, région, ville), **jamais les coordonnées GPS**.
- L'app fonctionne entièrement sans localisation.

### 4.2 Packs pays — `countries/{countryCode}`
Contiennent : devise, régions et taxes, comptes d'épargne, retraite, crédit, catégories typiques, régulateur et mention légale, sources économiques, leçons locales, `verifiedAt`, `version`, `packLevel: full | partial | generic`.
**Règle absolue : aucun plafond, taux ou règle fiscale codé en dur dans l'app.** Tout vient du pack.

```json
{
  "code": "CA", "currency": "CAD", "packLevel": "full", "version": 3, "verifiedAt": "2026-11-01",
  "regions": { "QC": { "salesTax": [{"code":"GST","rate":0.05},{"code":"QST","rate":0.09975}] } },
  "savingsAccounts": [{ "id": "tfsa", "name": {"fr":"CELI","en":"TFSA"}, "lessonId": "ca_tfsa_101" }],
  "retirement": { "publicPlans": ["CPP_QPP","OAS"], "accounts": ["rrsp"] },
  "regulatorNotice": { "fr": "Contenu éducatif, pas un conseil financier personnalisé.", "en": "Educational content, not personalized financial advice." },
  "economySources": ["boc_valet","statcan","worldbank"],
  "defaultFixedExpenses": ["rent","internet","electricity","phone","groceries","transport","insurance"]
}
```

### 4.3 Économie intégrée au budget
- Indicateurs : inflation (globale + alimentation, logement, énergie, transport), taux directeur, change, chômage, salaire minimum, énergie, coût de la vie local (si dispo).
- **Carte économique du jour** (20 s, +5 XP), **impact personnalisé** calculé côté client (« inflation alimentaire 4 % → ~16 $/mois de plus sur ton budget épicerie »), ajustement des budgets et simulateurs, alertes (taux directeur, change), quiz hebdo.
- Toujours afficher **source + date** ; signaler les données anciennes.
- Pipeline : `economyFetch` (quotidien, connecteurs `EconomySource`, repli Banque mondiale / FMI) → `economy/{code}` → `economySummaries` (Gemini résume **sans inventer de chiffres**) ; `fxRates` → `fx/latest`.

### 4.4 Multi-devises
- Chaque transaction a sa `currency` ; `amountMainCents` = conversion dans la devise principale au taux du jour.
- Catégorie **« Soutien à la famille / transferts »** (montants, frais, taux).
- Mode voyage.

---

## 5. Gamification

### 5.1 Boucle quotidienne
Déclencheur (notification Sipho) → action courte (≤ 90 s) → récompense (animation, son, XP, série) → investissement (niveau, ligue, nid, objectif).

### 5.2 Barème XP (Remote Config, attribué **côté serveur uniquement**)
| Action | XP | Limite / jour |
|---|---|---|
| Dépense variable notée | 5 | 10 |
| Facture scannée | 15 | 5 |
| Dépense fixe cochée | 10 | réel |
| Leçon (parfaite = +10) | 20 | — |
| Carte économique | 5 | 1 |
| Quête du jour | 20–50 | 3 |
| Journée sous budget | 15 | 1 |
| Semaine sous budget | 100 | 1/sem |
| Filleul actif 7 jours | 200 + cadeau rare | — |

### 5.3 Mécaniques
- **Séries** : 1 action utile/jour (ou « aucune dépense aujourd'hui » confirmé). Paliers 3, 7, 14, 30, 50, 100, 200, 365. **Gel** (max 2 en stock), **réparation** sous 24 h, séries entre amis (V2). Jour calculé dans le `timezone` de l'utilisateur.
- **Graines d'or** (non achetables en argent réel au MVP) + **boutique** (accessoires de Sipho, décorations du nid, thèmes, gels).
- **Cadeaux de Sipho** (bronze/argent/or) au contenu aléatoire. **Jamais achetables en argent réel.**
- **Ligues** : 10 niveaux (bronze → diamant), groupes de 30, classement sur l'XP gagnée pendant la semaine **uniquement**, top 7 promus (avec de l'XP), 5 derniers relégués (groupes ≥ 15 joueurs). Semaine **commune à tous** : dimanche 20 h UTC → dimanche 20 h UTC. Ligues mondiales + filtres pays/ville.
- **Quêtes** : quotidiennes (3), hebdo, mensuelles (badge animé), IA, entre amis, rattrapage.
- **Social** (V2) : profil public sans montants, encouragements, défis 1v1, parrainage via App Links / Universal Links + code (**Firebase Dynamic Links est arrêté : ne pas l'utiliser**).
- **Récap mensuel** style « Wrapped », partageable sans montants sensibles par défaut.

---

## 6. Notifications FCM

| Type | Déclencheur | Exemple | Phase |
|---|---|---|---|
| `streak_reminder` | Pas d'activité, heure habituelle | « Ton nid t'attend ! 30 s pour garder ta flamme. » | MVP |
| `streak_last_chance` | 22 h | « Il reste 2 h pour sauver ta flamme… » | MVP |
| `fixed_due` | Veille d'échéance manuelle | « Demain c'est le loyer. Tout est prêt ? » | MVP |
| `budget_alert` | Catégorie 80 % / 100 % | « Restos : 80 % du budget. On ralentit ? » | MVP |
| `quest_almost` | 1 action restante | « Plus qu'une dépense et le cadeau est à toi ! » | MVP |
| `comeback` | Absent J+1/3/7/14 | « Je ne t'ai pas vu hier… ton budget non plus. » | MVP |
| `recap` | 1er du mois | « Ton récap d'octobre est prêt. » | MVP |
| `social` | Ami te dépasse, défi | « Amina vient de te dépasser en ligue Or. » | V2 |
| `league_end` | Dimanche 18 h | « Tu es 8e, la promotion est à 1 place ! » | V2 |
| `insight` | Conseil hebdo | « J'ai repéré un truc qui peut te faire économiser 30 $. » | V2 |
| `economy` | Taux / change | « La banque centrale a baissé son taux : voici ce que ça change. » | V2 |

**Règles :** max **2 notifications d'engagement/jour** ; heure personnalisée (~30 min avant l'ouverture habituelle) ; heures calmes 21 h 30 – 8 h ; escalade puis **pause** (J+1 → J+3 → J+7 → J+14 « je mets les rappels en pause » → 1/mois) ; 10–20 variantes bilingues par type, pas de répétition en 7 jours ; A/B tests via Remote Config ; préférences par type ; deep link `data.route`.
**Canaux Android :** `streak, budget, social, tips, recap, economy`.

---

## 7. UX, animations et sons

### 7.1 Navigation (5 onglets)
| Onglet | Contenu |
|---|---|
| Accueil | Reste à vivre (jauge), série, quêtes du jour, prochaine dépense fixe, Sipho, bouton « + » |
| Dépenses | Liste du mois, Mon socle, scan, filtres, graphiques |
| Apprendre | Chemin de leçons, carte économique du jour, simulateurs |
| Classement | Ligue, amis, défis (MVP : progression perso) |
| Profil | Sipho & boutique, badges, objectifs, réglages, Premium |

### 7.2 Animations
- **Rive** : Sipho (machine à états, ≥ 8 émotions : `idle, happy, proud, dance, worried, sad, sleepy, party`) et tissage du nid.
- **Lottie** : pièces/confettis, flamme, laser de scan, ouverture de cadeau, podium.
- **Flutter natif** : jauges, transitions de cartes, boutons « 3D » qui s'enfoncent.
- Préchargement ; animations lourdes téléchargées depuis Storage ; respect de « réduire les animations ».

### 7.3 Sons
| Son | Moment | Durée |
|---|---|---|
| `ding` | Validation, bonne réponse | < 0,4 s |
| `soft_error` | Mauvaise réponse | < 0,4 s |
| `coins` | XP, graines | 0,5–1 s |
| `flame` | Série prolongée | ~1 s |
| `scan_loop` / `scan_done` | Scan | 0,5–1,5 s |
| `gift_open` | Cadeau | 1,5–2 s |
| `level_up` | Niveau / palier (signature) | 2–3 s |
| `league_up` | Promotion | 2–3 s |
| `lesson_done` | Fin de leçon | ~2 s |
| `sipho_*` | Voix (onomatopées) | 0,3–1 s |
| `uh_oh` | Alerte budget | ~0,6 s |
| `notif` | Push | ~1 s |

- `flutter_soloud` (ou `audioplayers` + pool), **sons préchargés** ; `audio_session` en **ambient / mix with others** (ne coupe jamais la musique, respecte le mode silencieux iOS).
- `SoundService` unique (Riverpod) ; les événements Rive peuvent déclencher les sons.
- OGG (Android) / AAC ou CAF (iOS), < 50 Ko/son, < 1 Mo au total. Réglages séparés : sons, vibrations, voix.

### 7.4 Accessibilité
Contraste AA, texte dynamique, `Semantics` partout, couleur jamais seule porteuse de sens, TalkBack/VoiceOver testés.

---

## 8. Stack technique

| Couche | Choix |
|---|---|
| App | **Flutter** (Dart 3, Material 3), iOS + Android |
| État | **Riverpod** (`flutter_riverpod`, générateurs `riverpod_annotation`) |
| Navigation | **go_router** |
| Modèles | **freezed** + **json_serializable** |
| Auth | Firebase Auth — Google + Apple |
| BDD | Cloud Firestore (persistance hors ligne) |
| Backend | Cloud Functions 2e gén. — **TypeScript**, Node LTS |
| IA | **Firebase AI Logic** (`firebase_ai`) + Gemini (famille Flash, nom du modèle dans Remote Config) |
| Fichiers | Cloud Storage |
| Push | FCM + `flutter_local_notifications` |
| Sécurité | App Check (Play Integrity / App Attest), Firebase Auth, limites par utilisateur, règles Firestore |
| Config | Remote Config + A/B Testing |
| Qualité | Crashlytics, Performance, Analytics |
| Web | Firebase Hosting (vitrine, parrainage, fichiers App Links / AASA) |
| Secrets | Secret Manager |
| CI/CD | GitHub Actions + Codemagic ou Fastlane |

### 8.1 Dépendances Flutter
```yaml
dependencies:
  firebase_core, firebase_auth, google_sign_in, sign_in_with_apple
  cloud_firestore, firebase_storage, cloud_functions
  firebase_messaging, flutter_local_notifications
  firebase_ai
  firebase_remote_config
  firebase_analytics, firebase_crashlytics, firebase_performance
  flutter_riverpod, riverpod_annotation, go_router
  freezed_annotation, json_annotation
  lottie, rive, fl_chart
  flutter_soloud, audio_session
  image_picker, image, app_links, share_plus
  geolocator, geocoding
  intl, flutter_localizations
  in_app_purchase
dev_dependencies:
  build_runner, freezed, json_serializable, riverpod_generator
  flutter_test, mocktail, integration_test, flutter_lints
```

---

## 9. Structure du dépôt

```
sipho/
├── README.md                     # ce document
├── app/                          # application Flutter
│   ├── lib/
│   │   ├── main.dart / bootstrap.dart
│   │   ├── app/                  # router.dart, theme/ (tokens), l10n/ (ARB)
│   │   ├── core/
│   │   │   ├── firebase/         # init, App Check, providers Firebase
│   │   │   ├── money/            # Money (cents + devise), formatage
│   │   │   ├── time/             # fuseaux, "jour local"
│   │   │   ├── analytics/
│   │   │   ├── sound/            # SoundService
│   │   │   ├── animations/       # wrappers Lottie / Rive
│   │   │   └── widgets/          # SiphoButton3D, Gauge, AmountKeypad, Card…
│   │   └── features/
│   │       ├── auth/  onboarding/  fixed_expenses/  expenses/
│   │       ├── receipt_scan/  budget/  gamification/  lessons/
│   │       ├── economy/  country_pack/  notifications/  settings/
│   │       ├── leagues/  friends/  insights/  goals/      # V2
│   │       └── planning/  banking/                       # V3
│   │           └── <feature>/{data, domain, presentation}
│   ├── assets/ (animations/, rive/, sounds/, images/)
│   └── test/ · integration_test/
├── functions/                    # Cloud Functions TypeScript
│   └── src/ (index.ts, gamification/, notifications/, ai/, stats/,
│             economy/, countries/, referrals/, account/, banking/)
├── content/                      # packs pays, leçons, templates (JSON) + scripts d'import
├── firestore.rules · storage.rules · firestore.indexes.json · firebase.json
└── .github/workflows/
```

Chaque feature : **data** (repositories Firestore, DTO), **domain** (modèles `freezed`, logique pure testée), **presentation** (écrans, widgets, providers).

---

## 10. Modèle de données Firestore

**Montants en cents (entiers).** Données perso sous `users/{uid}`.

| Chemin | Champs principaux | Écrit par |
|---|---|---|
| `users/{uid}` | displayName, photoUrl, countryCode, regionCode?, city?, locationConsent, homeCountry?, remittanceCountries[], lifeStage, currency, locale, timezone (id IANA), utcOffsetMinutes, onboardingDone, mainGoal, incomeMonthlyCents?, createdAt, plan | Client (sauf `plan`) |
| `users/{uid}/game/state` | xp, level, gems, streak{current,best,lastActiveDay,freezes}, leagueId, weeklyXp, badges[] | **Functions** |
| `users/{uid}/fixedExpenses/{id}` | name, category, icon, amountCents, dueDay, payMode, type, active, createdAt | Client |
| `users/{uid}/months/{yyyy-MM}` | incomeCents, fixedPaid{}, totals{}, remainingCents | Functions |
| `users/{uid}/transactions/{id}` | amountCents, currency, amountMainCents, fxRate?, category, merchant, note, date, source(`manual\|receipt\|bank`), receiptPath?, fixedExpenseId?, createdAt | Client (`bank` = serveur) |
| `users/{uid}/receipts/{id}` | storagePath, status, extracted{}, model, createdAt | Client + Functions |
| `users/{uid}/budgets/{yyyy-MM}` | categories{cat: limitCents}, rule | Client |
| `users/{uid}/goals/{id}` | title, targetCents, savedCents, deadline, emoji, completedAt | Client |
| `users/{uid}/quests/{id}` | templateId, type, progress, target, rewardXp, rewardChest, expiresAt, status | Functions |
| `users/{uid}/lessonProgress/{id}` | completed, score, perfect, completedAt | Functions |
| `users/{uid}/insights/{id}` | text, suggestedQuest, createdAt, dismissed | Functions |
| `users/{uid}/devices/{id}` | fcmToken, platform, appVersion, updatedAt | Client |
| `users/{uid}/notifState/state` | prefs{}, preferredHour, sentToday, lastSentAt, inactivityStage | Client (prefs) / Functions |
| `publicProfiles/{uid}` | pseudo, avatar, level, streak, league, badges — **aucun montant** | Functions |
| `friendships/{pairId}` | users[], status, sharedStreak | Functions |
| `leagues/{id}` | week (`yyyy-MM-dd` du dimanche 20 h UTC), tier, memberCount (≤ 30), open, processed, endsAt | Functions |
| `leagues/{id}/members/{uid}` | pseudo, avatar, level, weeklyXp (XP gagnée dans ce groupe), rank/result (à la clôture) — **aucun montant** | Functions |
| `users/{uid}/league/current` · `lastResult` | groupe de la semaine · résultat de la semaine précédente (rang, promotion/relégation) | Functions |
| `referrals/{code}` | ownerUid, uses[], rewardsGranted | Functions |
| `countries/{code}` | pack pays | Admin |
| `economy/{code}` | indicators{… avec source et date}, summary{fr,en}, dailyCards[], updatedAt | Functions |
| `fx/latest` | base, rates{}, asOf | Functions |
| `lessons/{id}` | unit, order, title{fr,en}, steps[], version, countries[] | Admin |
| `questTemplates/{id}` · `notifTemplates/{id}` | templates | Admin |

Index composites : transactions(date desc, category), quests(status, expiresAt) (les index à un seul champ, comme `devices.updatedAt`, sont automatiques et ne doivent pas être déclarés) ; collection group : quests(status, expireWarningSent, expiresAt), alerts(pushed, type, createdAt) ; leagues(processed, endsAt).

Fuseau horaire : le client écrit l'id IANA (`timezone`, ex. `Asia/Kolkata`) et le décalage courant en **minutes** (`utcOffsetMinutes`, ex. 330) à chaque lancement. Le serveur résout le jour local avec l'id IANA (heure d'été exacte) et n'utilise `utcOffsetMinutes` que pour présélectionner les utilisateurs d'un créneau local. L'ancien champ `timezoneOffset` (heures entières) n'est plus lu que comme dernier recours.

Quêtes du jour : `daily_{templateId}_{yyyy-MM-dd}` (jour local), créées par `dailyRollover` (00:00–03:00 local), à la création du profil et à la demande par `refreshDailyQuests`, expirées au prochain minuit local, supprimées 14 jours après expiration.

---

## 11. Cloud Functions

| Fonction | Type | Rôle |
|---|---|---|
| `onUserCreate` | Auth trigger | Crée game/state, notifState, profil public, quêtes initiales |
| `onTransactionWrite` | Firestore trigger | Agrégats du mois, quêtes, alertes budget, XP (avec limites) |
| `markFixedPaid` | Callable | Coche une dépense fixe + XP |
| `buyShopItem` | Callable | Dépense des graines : prix, un seul exemplaire des objets, stock de gels plafonné (ADR-013) |
| `onGameBadgeCheck` | Trigger Firestore | Attribue les badges dès que l'état de jeu change (ADR-012) |
| `completeLesson` | Callable | Valide le score, XP, graines, série ; refuse une leçon verrouillée ; bonus de fin d'unité une fois (ADR-011) |
| `parseReceipt` | Callable (option) | Scan côté serveur si besoin de contrôle |
| `generateMonth` | Scheduler | Crée le mois, reporte les fixes, prépare le récap |
| `dailyRollover` | Scheduler (horaire) | Fin de journée locale : séries, gels, quêtes |
| `refreshDailyQuests` | Callable | Crée les quêtes du jour manquantes (idempotent) |
| `confirmNoSpend` | Callable | « Aucune dépense aujourd'hui » : série + éligibilité « journée sous budget » |
| `getInviteCode` | Callable | Code d'invitation / code ami de l'utilisateur (créé à la demande, stable) |
| `sendFriendRequest` · `respondFriendRequest` · `removeFriend` | Callable | Demandes d'ami par code ; accepter / refuser ; retirer (écritures serveur uniquement) |
| `setContactDiscovery` · `findContacts` · `sendContactFriendRequest` | Callable | Retrouver ses amis dans ses contacts (empreintes SHA-256 d'e-mails et de numéros vérifiés, opt-in réciproque) et leur envoyer une demande (ADR-010) |
| `notifyScheduler` | Scheduler (15 min) | Rappels personnalisés, plafond, escalade |
| `joinLeague` | Callable | Inscrit le joueur dans le groupe de sa ligue pour la semaine (idempotent) |
| `onGameXpChange` | Trigger `users/{uid}/game/state` | Convertit tout gain d'XP en points de ligue (un seul point d'entrée pour toutes les sources d'XP) |
| `leagueWeekly` | Scheduler (toutes les heures) | Clôt les groupes terminés : classement, top 7 promus, 5 derniers relégués (groupes ≥ 15), remise à zéro |
| `weeklyInsights` | Scheduler | Contexte agrégé → Gemini → conseils + quêtes |
| `economyFetch` · `economySummaries` · `fxRates` · `economyAlerts` | Scheduler / trigger | Données économiques et change |
| `referralRedeem` | Callable + trigger | Parrainage validé après 7 jours |
| `deleteAccount` | Callable | Suppression totale (Firestore, Storage, Auth) |
| `bankWebhook` | HTTPS (V3) | Transactions des agrégateurs |

---

## 12. Intégration IA (Gemini)

### 12.1 Scan de factures (client, Firebase AI Logic + App Check)
```dart
final model = FirebaseAI.googleAI().generativeModel(
  model: remoteConfig.getString('receipt_model'),
  generationConfig: GenerationConfig(
    responseMimeType: 'application/json',
    responseSchema: receiptSchema,
    temperature: 0.1,
  ),
  systemInstruction: Content.system(receiptPrompt),
);
final res = await model.generateContent([
  Content.multi([InlineDataPart('image/jpeg', bytes), TextPart('Extract this receipt.')]),
]);
```
Sortie attendue :
```json
{ "isReceipt": true, "merchant": "…", "date": "2026-11-10", "currency": "CAD",
  "subtotal": 42.17, "taxes": [{"code":"GST","amount":2.11},{"code":"QST","amount":4.21}],
  "total": 48.49, "paymentMethod": "card",
  "items": [{"label":"Lait 2L","qty":1,"amount":5.29}],
  "suggestedCategory": "groceries", "confidence": 0.92 }
```
Règles du prompt : n'extraire que le visible, `null` si illisible, dates ISO, catégories de la liste fournie, `isReceipt=false` sinon. Si `confidence < 0.7` ou total incohérent → champs surlignés. **Jamais** de numéro de carte extrait ou stocké.

### 12.2 Conseils (serveur, `weeklyInsights`)
Contexte envoyé (agrégé, sans identité) : pays, région, ville, devise, langue, étape de vie, pack pays, indicateurs économiques, dépenses par catégorie, tendances, objectifs.
Garde-fous : citer uniquement les produits/règles du pack pays ; sinon principe général ; aucun produit financier nommé ; pas de conseil fiscal/placement individualisé ; ton bienveillant ; mention légale du pays.
Sortie : `[{ title, body, suggestedQuest: { type, target, rewardXp } }]`.

### 12.3 Coûts
Quotas par utilisateur/jour vérifiés avant appel, compression d'image, alertes de facturation GCP.

---

## 13. Sécurité et conformité

- Authentification obligatoire ; **App Check** sur Functions et AI Logic ; limites par utilisateur et règles Firestore.
- Le client ne peut **jamais** écrire : XP, niveau, séries, graines, quêtes, ligues, `plan`, transactions `source: bank`.
- Storage : `receipts/{uid}/{id}.jpg`, propriétaire seulement, ≤ 5 Mo, `image/*` ou `application/pdf`.
- Jetons bancaires uniquement côté serveur (Secret Manager).
- 3 projets Firebase : `sipho-f5a01` (dev), `sipho-staging`, `sipho-prod` (ces deux derniers restent à créer).
- Aucune donnée personnelle (montant, marchand, nom) dans les logs/Crashlytics.
- Conformité : RGPD, UK GDPR, Loi 25 + LPRPDE, lois US par État (CCPA…), lois africaines de protection des données ; régulateurs financiers par pays (positionnement **éducatif**) ; Sign in with Apple ; suppression de compte in-app ; Data safety (Play) et Privacy labels (Apple) ; âge minimum recommandé 16 ans (à valider).

Extrait de règles :
```
match /users/{uid}/transactions/{id} {
  allow read, delete: if isOwner(uid);
  allow create, update: if isOwner(uid)
    && request.resource.data.amountCents is int
    && request.resource.data.amountCents > 0
    && request.resource.data.amountCents < 10000000
    && request.resource.data.source in ['manual', 'receipt'];
}
match /users/{uid}/{sub=**} { allow read: if isOwner(uid); }   // jeu : lecture seule
```

---

## 14. Installation et commandes

Prérequis : Flutter stable, Dart 3, Node LTS, Firebase CLI, FlutterFire CLI, Xcode (iOS), Android Studio.

```bash
# Configuration Firebase (une fois par environnement) — écrit lib/core/firebase/firebase_options_<env>.dart
cd app
flutterfire configure --project=sipho-f5a01 --out=lib/core/firebase/firebase_options_dev.dart      # dev
flutterfire configure --project=sipho-staging --out=lib/core/firebase/firebase_options_staging.dart # staging
flutterfire configure --project=sipho-prod --out=lib/core/firebase/firebase_options_prod.dart       # prod
# Android : télécharger le google-services.json du projet dev dans android/app/ (pas de flavors)

# App
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define=APP_CHECK_DEBUG_TOKEN=<uuid-du-jeton-debug>   # Android et iOS, sans flavor : un build debug vise dev, un build release vise prod. Le jeton debug App Check est un secret (dépôt public) : ne jamais l'écrire dans le code (voir ADR-005)
flutter run -t lib/main_staging.dart   # staging (explicite)
flutter build appbundle           # release : prod
flutter run --dart-define=APP_CHECK_REAL=true   # appareil physique : teste Play Integrity / App Attest en debug

# Functions
cd functions && npm ci && npm run build

# Tests
cd app && flutter analyze && flutter test
cd functions && npm test               # tests unitaires (sans émulateur)
cd functions && npm run test:emulator  # règles Firestore + gamification (démarre l'émulateur Firestore, Java requis)
cd functions && npm run test:all

# Contenus (packs pays, leçons, templates)
cd content && npm run import -- --project=sipho-f5a01
```

Environnements : `dev` (`sipho-f5a01`), `staging` (`sipho-staging`), `prod` (`sipho-prod`) — un projet Firebase chacun, choisis côté Dart (`main.dart` / `main_dev.dart` / `main_staging.dart`). Il n'y a plus de flavors Android ni de schémas Xcode (ADR-005). Les fichiers `firebase_options_staging.dart` / `firebase_options_prod.dart` contiennent des valeurs `REPLACE_ME` tant que `flutterfire configure` n'a pas été lancé : l'app refuse alors de démarrer (`assertFirebaseConfigured`) au lieu d'écrire dans le projet de dev. Déploiement : `firebase deploy --project <alias>` (`.firebaserc` : `dev`, `staging`, `prod`).

---

## 15. Instructions pour l'IA qui code ce projet

> **À lire avant toute génération de code.** Ces règles priment sur les habitudes par défaut.

### 15.1 Règles non négociables
1. **Montants = entiers en cents** + code devise (`Money(int cents, String currency)`). Jamais de `double` pour de l'argent.
2. **Aucune règle financière, fiscale ou nationale codée en dur.** Taux, plafonds, comptes, taxes viennent du **pack pays** Firestore.
3. **XP, séries, graines, quêtes, ligues, plan Premium = serveur uniquement** (Cloud Functions). Le client affiche et appelle des callables.
4. **Aucun montant d'un utilisateur visible par un autre.** Classements sur XP et pourcentages.
5. **Jamais récompenser une dépense.** On récompense le suivi, la régularité, le respect du budget.
6. **Toute chaîne visible passe par l'i18n** (ARB, FR + EN). Aucun texte en dur dans les widgets.
7. **Le « jour » d'un utilisateur se calcule dans son `timezone`**, jamais en UTC.
8. **Localisation** : précision réduite, à la demande, coordonnées jamais stockées ni envoyées.
9. **L'IA ne crée jamais de données sans validation utilisateur** (scan → écran de validation).
10. **Prompts Gemini** : sortie JSON avec schéma, garde-fous éducatifs, n'utiliser que les chiffres et règles fournis.
11. **Pas de Firebase Dynamic Links** (service arrêté) → App Links / Universal Links.
12. **Sons et animations** : toujours via `SoundService` et les wrappers `core/animations`, préchargés, désactivables.
13. **Accessibilité** : `Semantics` sur tout élément interactif, couleur jamais seule porteuse de sens.
14. **Pas de secrets dans le code client.** Clés externes dans Secret Manager côté Functions.

### 15.2 Conventions de code
- Architecture **feature-first** : `data / domain / presentation`. Le `domain` ne dépend ni de Flutter ni de Firebase.
- **Riverpod** avec générateurs (`@riverpod`). Pas de `setState` pour l'état métier.
- Modèles **immuables** `freezed` ; (dé)sérialisation `json_serializable` ; `Timestamp` converti via converter.
- Navigation **go_router**, routes déclarées dans `app/router.dart`, deep links supportés.
- Repositories exposent des `Stream`/`Future` typés ; gestion d'erreur avec un type `Result`/`AsyncValue`, jamais d'exception silencieuse.
- Nommage : fichiers `snake_case.dart`, classes `PascalCase`, providers `xxxProvider`, clés ARB `feature_element_action`.
- Design : utiliser **uniquement les tokens** de `app/theme` (couleurs, rayons, espacements, typographie).
- Functions : TypeScript strict, une fonction par fichier, validation des entrées (zod), idempotence (clé d'événement), logs structurés sans données perso.
- `flutter analyze` et `eslint` sans avertissement.

### 15.3 Définition de « terminé »
- [ ] Code + tests unitaires (logique domain) + tests de widget si UI.
- [ ] Textes FR + EN ajoutés.
- [ ] Règles Firestore/Storage mises à jour **et testées** si nouveau chemin.
- [ ] Événement Analytics ajouté si action utilisateur clé.
- [ ] États vide / chargement / erreur / hors ligne gérés.
- [ ] Animation + son + haptique sur les validations importantes.
- [ ] Accessibilité vérifiée (Semantics, contraste, grand texte).
- [ ] Aucun nombre magique : constantes ou Remote Config.

### 15.4 Ordre de construction recommandé
1. Fondations : flavors, Firebase, thème/tokens, i18n, router, `Money`, `LocalDay`.
2. Auth (Google + Apple) + `onUserCreate`.
3. Packs pays (lecture + cache) + onboarding.
4. Mon socle + dépenses + agrégats (`onTransactionWrite`, `generateMonth`).
5. Budget, reste à vivre, graphiques.
6. Scan IA.
7. Gamification serveur (XP, séries, quêtes, cadeaux) + Sipho Rive + sons.
8. Notifications (`notifyScheduler`, préférences).
9. Économie (`economyFetch`, cartes du jour, impact perso).
10. Leçons.

### 15.5 Événements Analytics
`sign_up, onboarding_step, fixed_expense_added, expense_added, receipt_scanned, receipt_corrected, lesson_completed, quest_completed, streak_extended, streak_lost, streak_frozen, chest_opened, league_promoted, notif_opened, friend_invited, economy_card_viewed, location_consent, paywall_viewed, purchase`.

---

## 16. Tests et qualité
- Unitaires : reste à vivre, budgets, séries et fuseaux, conversion de devises, simulateurs.
- Widgets : saisie express, carte de dépense fixe, validation de scan.
- Intégration sur émulateurs Firebase.
- Règles de sécurité : `@firebase/rules-unit-testing` en CI.
- Jeu de **≥ 30 factures réelles par pays prioritaire** pour mesurer la précision du scan à chaque changement de modèle/prompt.
- Bêta : TestFlight + Play Internal Testing (30–50 testeurs).

**KPI MVP (3 mois) :** rétention J1/J7/J30 ≥ 45/25/12 % · DAU/MAU ≥ 30 % · onboarding terminé ≥ 70 % · série ≥ 7 j chez ≥ 20 % des actifs · scans sans correction ≥ 75 %.

---

## 17. Feuille de route

| Phase | Durée | Contenu |
|---|---|---|
| 0. Cadrage & design | 3 sem. | Maquettes Figma, Sipho (illustration + Rive), sons, 10 leçons |
| 1. Fondations | 3 sem. | Firebase ×3, auth, archi, thème, i18n, CI/CD, règles + tests |
| 2. Cœur finances | 4 sem. | Onboarding, socle, dépenses, budgets, reste à vivre, graphiques |
| 2b. International & économie | 3 sem. | Packs pays (3–5), multi-devises, localisation, indicateurs, cartes du jour |
| 3. Scan IA | 2 sem. | Caméra, Gemini, validation, quotas |
| 4. Gamification | 3 sem. | XP serveur, séries, graines, cadeaux, quêtes, Sipho Rive, sons, récap |
| 5. Notifications | 2 sem. | FCM, scheduler, plafond, escalade, préférences |
| 6. Bêta & lancement | 3 sem. | Bêta, stores, confidentialité, lancement pays prioritaires |
| V2 | 8–10 sem. | Amis, ligues, défis, parrainage, conseils IA, objectifs, Premium, alertes économiques |
| V3 | 10–12 sem. | Simulateurs par pays, banque + mobile money, nouveaux pays et langues |

**MVP ≈ 23 semaines.**

---

## 18. Décisions ouvertes
1. Vérification et dépôt de la marque **Sipho** (OPIC, USPTO, EUIPO, OAPI), domaines, stores.
2. Validation de la mascotte (tisserin) avec l'illustrateur.
3. Ordre des packs pays.
4. Âge minimum (16 ans recommandé).
5. Prix Premium.
6. Agrégateurs bancaires / mobile money par région (V3).
7. Projet personnel ou produit CargoNomade.
8. Scan Gemini côté client (recommandé au MVP) ou serveur.

---

*Sipho — Fais-toi un cadeau : ton avenir.*