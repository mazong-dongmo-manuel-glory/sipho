# 📊 TRACKER — Sipho

> **"Le Duolingo de l'argent"** — App mobile Flutter gamifiée de finance personnelle

| Champ | Valeur |
|---|---|
| **Statut** | 🔄 MVP fonctionnel — finitions (sons, Rive, contenu, staging/prod) puis bêta |
| **Démarrage** | 12 novembre 2026 |
| **Dernière mise à jour** | 20 novembre 2026 |
| **Santé du code** | `flutter analyze` propre · 328 tests Flutter · 164 tests Functions (hors émulateur) — mesuré le 19 novembre |

> Ce suivi a été remis à jour d'après l'état réel du code (il indiquait encore « Phase 1 à venir »).
> Légende : ✅ fait · 🟡 partiel · ⬜ à faire · 🎨 dépend d'assets créatifs (hors code)

---

## 🏗️ Stack validée

| Couche | Technologie |
|---|---|
| Mobile | Flutter 3.47+ / Dart 3.3+ |
| State management | Riverpod 2 |
| Navigation | go_router 14 |
| Modèles | Dart plain (freezed / riverpod_generator temporairement désactivés — mismatch analyzer SDK 3.13) |
| Backend | Firebase (Auth, Firestore, Functions TypeScript, Storage, Messaging, Remote Config) |
| IA | Firebase AI Logic (Gemini) |
| Animations | Rive 0.13, Lottie 3 |
| Graphiques | fl_chart 0.69 |
| Audio | flutter_soloud 3.2 |
| CI/CD | GitHub Actions (`ci.yml`, `deploy_dev.yml`) |
| Déploiement | Flavors dev / staging / prod |

---

## 📅 Phases du projet

| Phase | Nom | Statut | Reste à faire |
|---|---|---|---|
| 0 | Cadrage & Design | 🟡 | Maquettes validées, mascotte Rive, sons, leçons 🎨 |
| 1 | Fondations | 🟡 | Storage Get Started + Auth IdP + FCM sur `sipho-staging` (options Dart ✅) |
| 2 | Cœur finances | ✅ | — |
| 2b | International & économie | 🟡 | Contenu CI/SN à enrichir (niveau `full`) ; FX déjà Frankfurter en staging |
| 3 | Scan IA | ✅ | Jeu de factures de test ; quotas serveur + RC en place |
| 4 | Gamification | 🟡 | Rive, quête « sous budget », sons définitifs |
| 5 | Notifications | 🟡 | Vérifier les 10 types et le plafond/escalade sur appareil |
| 6 | Bêta & Lancement | ⬜ | TestFlight / Play, stores, conformité |
| V2 | — | 🟡 | Ligues et amis / invitations faits ; classement pays « Bientôt disponible » ; défis et conseils IA à faire |
| V3 | — | 🔮 | — |

---

## ✅ Tâches par phase

### Phase 0 — Cadrage & Design
- [x] README / spec complète
- [x] Brief Figma (FIGMA.md)
- [x] Maquettes Figma **réalisées** : 33 frames (25 écrans du brief + variantes) et une bibliothèque de composants ; reste leur **validation** et la mise à niveau pour les écrans ajoutés depuis (amis/contacts, multi-devises, objectifs) — voir FIGMA_TRACKER.md
- [x] ✨ Lottie : registre + préchargement + tests ; trophée, éclats, **podium** (IconScout), **quête** (IconScout check), **montée de niveau** (générée) ; crédits dans `assets/animations/CREDITS.txt`
- [ ] 🎨 Mascotte Sipho — illustration finale + animations Rive (8 émotions). État : illustrations **SVG** en place, `app/assets/rive/` vide
- [ ] 🎨 Sons (10 sons). État : `app/assets/sounds/` vide
- [x] 12 leçons en 4 unités complètes dans l'app (`lesson_catalog.dart` ↔ `shared/lessonPath.ts` : unit_1 = bases, unit_2 = épargne, unit_3 = dettes/inflation/arnaques, unit_4 = faire grandir son argent / investissement / intérêts composés / règle 50-30-20) ; bonus de fin d'unité synchronisés serveur/client
- [x] Badge « Investisseur avisé » (`unit_4`) synchronisé serveur et client avec icône et libellés i18n

### Phase 1 — Fondations
- [x] Flavors Dart `dev`/`staging`/`prod` (`main.dart`, `main_dev.dart`, `main_staging.dart`) ; **plus de flavors Android** (ADR-005)
- [x] Mapping Firebase : **prod = `sipho-f5a01`**, **dev/QA = `sipho-staging`** (console « sipho-dev ») — jamais l’ID nu `staging`
- [x] Options Firebase Flutter `firebase_options_dev/staging.dart` générées pour `sipho-staging` (`com.cargonomade.sipho.staging`)
- [ ] Storage « Get Started » + `firebase deploy --only storage --project sipho-staging`
- [x] Thème / tokens (couleurs, typo, espacements, radius)
- [x] i18n FR + EN (ARB + `l10n.yaml`)
- [x] go_router avec routes nommées
- [x] `Money` (cents) + `LocalDay` + tests unitaires (`test/core/money`, `test/core/time`)
- [x] CI GitHub Actions (lint, test, build)
- [x] Règles Firestore + tests émulateur (`functions/src/__tests__/*.emulator.test.ts`)
- [ ] App Check : code intégré, jeton debug dev fourni par `--dart-define=APP_CHECK_DEBUG_TOKEN` (secret, dépôt public) et à enregistrer dans la console ; Play Integrity / App Attest à configurer avant la release ; enforcement serveur à activer

### Phase 2 — Cœur finances
- [x] Onboarding conversationnel (nom, pays, objectif, nid)
- [x] Onboarding : étape de vie (`lifeStage`) + revenu mensuel optionnel (`monthlyIncomeCents`, skip possible) — débloque reste à vivre / sous budget dès le nid
- [x] Mon socle — dépenses fixes (cartes à glisser, montant, liste, « Payé ✓ »)
- [x] Dépenses variables — saisie express
- [x] Agrégats Cloud Functions (`onTransactionWrite`, `generateMonth`)
- [x] Budget & reste à vivre (jauge, carte d'accueil)
- [x] Graphiques fl_chart (anneau, barres)

### Phase 2b — International & économie
- [x] Packs pays Firestore (CA, FR, CM, CI, SN, générique) — import via `content/scripts/import.ts`
- [x] Multi-devises : saisie express (sélecteur) + `amountMainCents` / `fxRate` + lecture `fx/latest` ; `fxRates` écrit le doc seulement si `FX_FEED_URL` répond
- [x] Formats montants / dates localisés
- [x] Indicateurs économiques (`economyFetch`, `economyAlerts`, `economySummaries`) + benchmarks officiels de repli (CA, FR, CM, CI, SN, monde)
- [x] Écran économie & Hub financier enrichi : cartes d'indicateurs macro (inflation, taux directeurs, épargne sans risque), sélecteur de pays avec drapeaux, explication « Ce que ça change pour toi » et moteur de conseils aléatoires et variés
- [x] Conseils financiers variés et aléatoires (`EconomyTip`, tirage déterministe par jour + bouton dé 🎲 pour renouveler à volonté sur l'accueil et le détail, filtres par catégorie : budget, épargne, éco, sécurité, investissement, quotidien)
- [x] Localisation à la demande (onboarding « Utiliser ma position » → labels pays/région uniquement, pas de GPS stocké)
- [x] **Actus éco locales** (ADR-016) : scheduler `economyNewsFetch` (1×/jour) → `economyNews/{CA|FR|CM|CI|SN|WORLD}` via **Google News RSS gratuit** (pas de clé) ; option `GNEWS_API_KEY` pour CA/FR/WORLD ; titres simplifiés + takeaway éducatif ; section dans l’onglet Info Éco de l’app

### Phase 3 — Scan IA
- [x] Caméra + compression image
- [x] Gemini — extraction ticket (`receipt_parser`, `parseReceipt`)
- [x] Écran de validation
- [x] Quotas scan : serveur `SCAN_QUOTA_PER_DAY` (défaut 5) + Remote Config `scan_quota_per_day` affiché sur l'écran scan

### Phase 4 — Gamification
- [x] XP serveur + limites par jour (Cloud Functions)
- [x] Séries + gels (consommation automatique, achat en boutique, plafond 2) + réparation sous 24 h (`repairStreak`) + paliers (3, 7, 14, 30…)
- [x] Graines d'or ; boutique à achats réels côté serveur (`buyShopItem`, ADR-013). Reste : les objets achetés ne sont pas encore portés par Sipho 🎨
- [x] Cadeaux de Sipho (écran d'ouverture)
- [x] Quêtes du jour serveur, réclamation (`claimQuest`), quêtes IA
- [x] Accueil et écran de série lus depuis le **vrai** état serveur (plus de valeurs en dur)
- [ ] 🎨 Sipho Rive — 8 émotions animées
- [x] Vibrations + sons **branchés** (`core/feedback/`) : dépense, « Payé ✓ », scan, quiz, quête réclamée, cadeau, niveau, ligue, série ; réglages Sons / Vibrations / Voix actifs
- [x] 10 sons **provisoires** CC0 (Kenney) dans `app/assets/sounds/` (93 Ko au total), régénérables avec `app/tool/build_sounds.py`, crédits dans `CREDITS.txt`. À écouter sur appareil ; pour un son final, déposer un fichier du même nom
- [ ] 🎨 Sons finaux à l'identité kalimba / kora (signature `level_up`) et voix de Sipho (`sipho_happy`, `sipho_proud`, `sipho_worried`, absentes : ignorées sans erreur)
- [x] `uh_oh` (alerte budget) : `SiphoCue.budgetAlert` joué une fois par session quand le reste à vivre passe sous 0
- [ ] Vérifier sur appareil : mode silencieux iOS, musique en cours non coupée, vibrations
- [x] Chemin de leçons par unités : verrouillage **serveur** + bonus de fin d'unité (30 XP, 10 graines, une fois) + unité 2 (ADR-011)
- [x] Badges attribués par le serveur + affichage profil + son (ADR-012), dont badge « Bâtisseur » à la fin d'onboarding. Reste : badges quêtes / amis / budget, son dédié
- [x] Récap mensuel
- [x] Quêtes du jour : `log_expenses` (3 dépenses) + `daily_lesson` (1 micro-leçon, 20 XP) ; `refreshDailyQuests` comble les trous (rollover pas encore passé, nouveau modèle déployé en cours de journée) ; les lignes de l'accueil mènent à l'action
- [x] Règles des quêtes écrites : `DECISIONS.md` ADR-009
- [x] « Journée sous budget » (15 XP, ADR-009 règle 9) : évaluée par `dailyRollover`, une fois par jour
- [x] Retour visuel « sous budget » (carte sur l'accueil + son) et bouton « Aucune dépense aujourd'hui » (`confirmNoSpend`) : à vérifier sur appareil

### Phase 5 — Notifications
- [x] FCM + notifications locales
- [x] `notifyScheduler` + gabarits
- [x] Préférences utilisateur
- [ ] Vérification sur appareil des 10 types, plafond + escalade

### Phase 6 — Bêta & Lancement
- [ ] TestFlight (iOS) + Play Internal Testing (Android)
- [ ] Data safety (Play Store) + Privacy Nutrition Labels (App Store)
- [ ] Conformité RGPD / Loi 25 (Québec) — suppression de compte : `deleteAccount` présent
- [ ] Lancement pays prioritaires (CA, FR, CM)

### V2
- [x] Ligues hebdomadaires (`joinLeague`, `onGameXpChange`, `leagueWeekly`)
- [x] Amis et invitations par code (ADR-010) : à vérifier sur appareil
- [x] Amis depuis les contacts (e-mail, opt-in réciproque) + invitation SMS / e-mail : à vérifier sur appareil (permission, vrais contacts)
- [x] Contacts par numéro de téléphone (vérification SMS, Firebase Phone Auth) : code fait ; **à activer dans la console Firebase** (Authentication → Phone) puis à tester sur appareil
- [x] Défis 1v1 serveur (`createFriendChallenge` / `respondFriendChallenge`, progression métriques serveur, XP au vainqueur) ; flamme partagée encore affichage seul
- [x] Parrainage différé 7 jours actifs + XP hors `weeklyXp` (ADR-010 corrigé)
- [x] Modules pays (CA/FR/CM/CI/SN/générique) + courbe 6 mois / fixes vs variables
- [x] Fichiers deep link Hosting (SHA-256 Play + Team ID Apple à remplir)
- [x] Écran Conseils IA Sipho (Frame 23 Figma, navigation `/insights`, historique des conseils, quêtes associées)
- [x] Objectifs d'épargne `goals` : création, versements rapides, jauge de progression, célébration audio
- [x] Traqueur d'objectifs intégré sur l'écran d'accueil (`HomeGoalTrackerSection` : aperçu de l'objectif actif, jauge visuelle de progression, montant restant, bouton direct « + Épargner », carte d'incitation si aucun objectif)
- [x] Préparation des environnements Staging & Production (points d'entrée `main_dev.dart`, `main_staging.dart`, `main_prod.dart`, workflows CI/CD `deploy_staging.yml` & `deploy_prod.yml`, guide `ENVIRONMENTS.md`)
- [ ] Phone Auth : empreintes SHA Android + Play Integrity, APNs / reCAPTCHA iOS, quotas et régions SMS (coût, abus)
- [ ] Partage par lien (App Links / Universal Links) : il manque un domaine + `assetlinks.json` / AASA sur Firebase Hosting
- [ ] Parrainage : récompense différée au filleul actif 7 jours + XP hors classement (anti comptes jetables, voir ADR-010)

### V3
> Intégration bancaire, agrégateur de comptes, investissements basiques

---

## 🔥 Prochaines actions

1. **Sons** : écouter les 10 sons provisoires sur appareil (iOS silencieux, musique, vibrations) et signaler ceux à remplacer 🎨
1c. ✅ **Conseils financiers personnalisés par notification** (`adviceNotifier`, ADR-014) : sujet choisi par règles selon budget, dépenses, objectif et leçons mal réussies ; IA qui rédige avec garde-fous et modèle de repli ; à déployer avec `GEMINI_API_KEY` (sinon modèles de texte)
1d. ✅ **Coach horaire progressif** (`coachHourly`, ADR-015) : tip + pop-up chaque heure, niveau d’éducation stocké, anti-répétition ; à déployer `coachHourly` + règles `coach/*`
1b. ✅ **Leçons et parcours « à la Duolingo »** : chaque leçon est une suite d'étapes (à lire → question → à lire → vrai/faux → question) puis une page « À retenir » ; le parcours serpente avec nœuds 3D (étoile / jouer / cadenas), bulle « À toi de jouer », Sipho à côté, bannière d'unité (sous-titre, progression), cadeau de fin d'unité, fiche de leçon (objectif, durée, étapes, récompense), quêtes repliables
1a. ✅ **Écran de fin de leçon** branché sur `completeLesson` (XP, précision, temps, bonus d'unité, niveau) ; précision réelle : une réponse juste après une erreur n'est plus une leçon « parfaite » (score 100 / 50 / 33…)
1b. ✅ **Écran cadeau** : affiche la vraie récompense de `claimQuest` (graines, XP, niveau) ; plus de « gel de série » inventé
1c. ✅ **Revenu mensuel + étape de vie à l'onboarding** ; écarts Figma restants : voir `FIGMA_TRACKER.md`
2. **Quêtes** : vérifier sur appareil la carte « sous budget » et le bouton « Aucune dépense » ; lancer `npm run test:emulator` (Java requis) pour valider les nouveaux tests de quêtes
3. **Environnements (manuel console `sipho-staging`)** : Storage « Get Started » puis `firebase deploy --only storage --project sipho-staging` ; Auth Google/Apple/Phone (+ SHA / APNs) ; FCM. Déjà fait : apps `.staging`, options Dart, RC, App Check debug, Functions + env, seed packs, schedulers actifs. **Prod `sipho-f5a01` non modifiée.**
4. ✅ **FX** : `FX_FEED_URL` Frankfurter déjà dans `.env.sipho-staging`
5. **Vérifier** sur appareil : localisation onboarding, scan quotas, réparation de série, notifications
6. **Contenu** : enrichir packs CI/SN (niveau `full`) et éventuellement lire `content/lessons/` au lieu du catalogue embarqué
7. **Parrainage** : récompense différée 7 jours (ADR-010) toujours ouverte

---

## 🏢 Firebase Projects

| Environnement | Project ID | Usage |
|---|---|---|
| Dev / QA | `sipho-staging` (console « sipho-dev », alias `.firebaserc` `dev`/`staging`) | Dev local, QA — **ne jamais utiliser l’ID `staging`** |
| Production | `sipho-f5a01` (alias `prod` / `default`) | Utilisateurs finaux / stores — **ne pas y déployer le quotidien** |

### État de réplication `sipho-staging` (2026-11-20, 3e passe) — prod **non touchée**

| Service | Prod `sipho-f5a01` | Staging `sipho-staging` |
|---|---|---|
| Firestore DB | ✅ | ✅ |
| Firestore rules + indexes | ✅ | ✅ |
| Cloud Functions | ✅ | ✅ toutes + env `.env.sipho-staging` (GEMINI, SCAN_QUOTA=20, FX_FEED Frankfurter) |
| Schedulers (cron) | ✅ | ✅ vérifiés `firebase functions:list` : `economyNewsFetch`, `adviceNotifier`, `coachHourly`, `fxRates`, `dailyRollover`, `notifyScheduler`, `weeklyInsights`, `economyFetch`, `economySummaries`, `generateMonth`, `leagueWeekly` |
| Remote Config | vide CLI | ✅ publié (`scan_quota_per_day=20`, `ai_model`) via API REST |
| Apps Android/iOS | ✅ | ✅ `com.cargonomade.sipho.staging` + `firebase_options_dev/staging.dart` |
| App Check debug tokens | — | ✅ Android + iOS (`cursor-qa` / `cursor-qa-ios`) — secrets locaux CLI |
| Storage (Firebase) | ✅ | ⬜ **bloqué sans console** : « Get Started » obligatoire ; bucket GCS `sipho-staging-receipts` créé mais **pas** reconnu comme Firebase Storage |
| Auth Google / Apple / Phone | (prod) | ⬜ **aucun IdP activé** — OAuth/SHA/APNs console requis |
| FCM / APNs | ✅ | ⬜ après Auth + clés APNs / google-services en build |
| Seed `countries/*` + `lessons/*` | — | ✅ **2026-11-20** : CA, CI, CM, FR, SN, generic + `unit_1_budget_basics` (Firestore REST / token Firebase CLI ; `import.ts` Admin SDK exige encore ADC) |

---

## 🔡 Conventions de nommage

| Élément | Convention | Exemple |
|---|---|---|
| Fichiers Dart | `snake_case.dart` | `auth_repository.dart` |
| Classes | `PascalCase` | `AuthRepository` |
| Variables / fonctions | `camelCase` | `currentUser` |
| Constantes | `camelCase` | `kMaxScanPerMonth` |
| Routes go_router | `kebab-case` | `/home`, `/expenses/add` |
| Collections Firestore | `camelCase` pluriel | `users`, `expenses`, `fixedExpenses` |
| Documents Firestore | `uid` ou `ULID` | `users/{uid}` |
| Providers Riverpod | `camelCase + Provider` | `authRepositoryProvider` |
| Dossiers features | `snake_case` | `features/expenses/` |
| ARB keys | `camelCase` | `homeWelcomeTitle` |
| Assets | `snake_case` | `sipho_happy.riv` |
| Montants | **Toujours en cents** `int` | `int amountCents = 4849` |

---

## 🎯 KPI MVP cibles

| KPI | Cible |
|---|---|
| Rétention J7 | > 40 % |
| Rétention J30 | > 20 % |
| Série moyenne à J30 | > 5 jours |
| Leçons complétées par utilisateur/mois | > 8 |
| Scan facture utilisé au moins 1× | > 60 % des users actifs |
| Note App Store / Play Store | ≥ 4,5 ⭐ |
| Crash-free sessions | > 99,5 % |
| Temps de démarrage à l'écran d'accueil | < 2 s |

---

## 🔓 Décisions ouvertes

Voir [DECISIONS.md](./DECISIONS.md) pour le journal complet.

| # | Décision | Statut |
|---|---|---|
| ADR-004 | Scan Gemini côté client vs. serveur au MVP | ❓ À DÉCIDER |
