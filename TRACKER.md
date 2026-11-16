# 📊 TRACKER — Sipho

> **"Le Duolingo de l'argent"** — App mobile Flutter gamifiée de finance personnelle

| Champ | Valeur |
|---|---|
| **Statut** | 🔄 MVP fonctionnel — finitions (sons, Rive, contenu, staging/prod) puis bêta |
| **Démarrage** | 12 novembre 2026 |
| **Dernière mise à jour** | 15 novembre 2026 |
| **Santé du code** | `flutter analyze` propre · 263 tests Flutter · 110 tests Functions (hors émulateur) — mesuré le 15 novembre |

> Ce suivi a été remis à jour d'après l'état réel du code (il indiquait encore « Phase 1 à venir »).
> Légende : ✅ fait · 🟡 partiel · ⬜ à faire · 🎨 dépend d'assets créatifs (hors code)

---

## 🏗️ Stack validée

| Couche | Technologie |
|---|---|
| Mobile | Flutter 3.47+ / Dart 3.3+ |
| State management | Riverpod 2 |
| Navigation | go_router 14 |
| Modèles | freezed + json_serializable |
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
| 1 | Fondations | 🟡 | Firebase staging/prod, iOS schemes |
| 2 | Cœur finances | ✅ | — |
| 2b | International & économie | 🟡 | Multi-devises dans la saisie, localisation à la demande, packs pays supplémentaires |
| 3 | Scan IA | ✅ | Quotas à confirmer, jeu de factures de test |
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
- [x] ✨ Lottie : registre + préchargement + tests ; trophée (ligue) et éclats (cadeau) ajoutés. Reste : podium, validation de quête, montée de niveau, animations de designer
- [ ] 🎨 Mascotte Sipho — illustration finale + animations Rive (8 émotions). État : illustrations **SVG** en place, `app/assets/rive/` vide
- [ ] 🎨 Sons (10 sons). État : `app/assets/sounds/` vide
- [ ] 🟡 10 leçons rédigées. État : 6 leçons en 2 unités dans l'app (`lesson_catalog.dart`, chemin côté serveur dans `shared/lessonPath.ts`) ; le JSON `content/lessons/unit_1_budget_basics.json` n'est pas lu par l'app

### Phase 1 — Fondations
- [x] Environnements dev / staging / prod choisis côté Dart (`main.dart`, `main_dev.dart`, `main_staging.dart`) ; **plus de flavors Android** (retirés le 2026-11-14, ADR-005)
- [ ] Flavors Android + schémas iOS : à rétablir quand staging et prod existeront
- [x] Projet Firebase dev (`sipho-f5a01`) + `firebase_options_dev.dart`
- [ ] Firebase staging / prod + `flutterfire configure` (valeurs `REPLACE_ME`, l'app refuse de démarrer)
- [x] Thème / tokens (couleurs, typo, espacements, radius)
- [x] i18n FR + EN (ARB + `l10n.yaml`)
- [x] go_router avec routes nommées
- [x] `Money` (cents) + `LocalDay` + tests unitaires (`test/core/money`, `test/core/time`)
- [x] CI GitHub Actions (lint, test, build)
- [x] Règles Firestore + tests émulateur (`functions/src/__tests__/*.emulator.test.ts`)
- [ ] App Check : code intégré, jeton debug dev fourni par `--dart-define=APP_CHECK_DEBUG_TOKEN` (secret, dépôt public) et à enregistrer dans la console ; Play Integrity / App Attest à configurer avant la release ; enforcement serveur à activer

### Phase 2 — Cœur finances
- [x] Onboarding conversationnel (nom, pays, objectif, nid)
- [ ] Onboarding : le README §3.1 prévoit aussi l'étape de vie et le revenu mensuel (fourchette) ; la région et la devise sont collectées, mais ni l'étape de vie ni le revenu (le revenu démarre à 0 et ne se règle que depuis le profil, alors qu'il alimente « reste à vivre » et la règle « sous budget » : un nouvel utilisateur n'a donc pas ces deux fonctions tant qu'il ne l'a pas saisi) — à trancher : ajouter ou retirer du README
- [x] Mon socle — dépenses fixes (cartes à glisser, montant, liste, « Payé ✓ »)
- [x] Dépenses variables — saisie express
- [x] Agrégats Cloud Functions (`onTransactionWrite`, `generateMonth`)
- [x] Budget & reste à vivre (jauge, carte d'accueil)
- [x] Graphiques fl_chart (anneau, barres)

### Phase 2b — International & économie
- [x] Packs pays Firestore (CA, FR, CM, générique) — **CI, SN à ajouter**
- [ ] 🟡 Multi-devises : `currency` / `amountMainCents` / `fxRates` côté données et Functions ; saisie multi-devise à finaliser
- [x] Formats montants / dates localisés
- [x] Indicateurs économiques (`economyFetch`, `economyAlerts`, `economySummaries`)
- [x] Écran économie (cartes du jour)
- [ ] Localisation à la demande (`geolocator` déclaré, non utilisé)

### Phase 3 — Scan IA
- [x] Caméra + compression image
- [x] Gemini — extraction ticket (`receipt_parser`, `parseReceipt`)
- [x] Écran de validation
- [ ] Quotas scan (Remote Config) — à confirmer

### Phase 4 — Gamification
- [x] XP serveur + limites par jour (Cloud Functions)
- [x] Séries + gels (consommation automatique, achat en boutique, plafond 2). ⬜ Réparation sous 24 h et paliers de série (3, 7, 14, 30…) non faits
- [x] Graines d'or ; boutique à achats réels côté serveur (`buyShopItem`, ADR-013). Reste : les objets achetés ne sont pas encore portés par Sipho 🎨
- [x] Cadeaux de Sipho (écran d'ouverture)
- [x] Quêtes du jour serveur, réclamation (`claimQuest`), quêtes IA
- [x] Accueil et écran de série lus depuis le **vrai** état serveur (plus de valeurs en dur)
- [ ] 🎨 Sipho Rive — 8 émotions animées
- [x] Vibrations + sons **branchés** (`core/feedback/`) : dépense, « Payé ✓ », scan, quiz, quête réclamée, cadeau, niveau, ligue, série ; réglages Sons / Vibrations / Voix actifs
- [x] 10 sons **provisoires** CC0 (Kenney) dans `app/assets/sounds/` (93 Ko au total), régénérables avec `app/tool/build_sounds.py`, crédits dans `CREDITS.txt`. À écouter sur appareil ; pour un son final, déposer un fichier du même nom
- [ ] 🎨 Sons finaux à l'identité kalimba / kora (signature `level_up`) et voix de Sipho (`sipho_happy`, `sipho_proud`, `sipho_worried`, absentes : ignorées sans erreur)
- [ ] `uh_oh` (alerte budget) : fichier prévu mais aucun déclencheur côté client pour l'instant
- [ ] Vérifier sur appareil : mode silencieux iOS, musique en cours non coupée, vibrations
- [x] Chemin de leçons par unités : verrouillage **serveur** + bonus de fin d'unité (30 XP, 10 graines, une fois) + unité 2 (ADR-011)
- [x] Badges attribués par le serveur (8) + affichage dans le profil + son (ADR-012). Reste : badge « Bâtisseur » d'onboarding, badges quêtes / amis / budget, son dédié
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
- [ ] Phone Auth : empreintes SHA Android + Play Integrity, APNs / reCAPTCHA iOS, quotas et régions SMS (coût, abus)
- [ ] Partage par lien (App Links / Universal Links) : il manque un domaine + `assetlinks.json` / AASA sur Firebase Hosting
- [ ] Parrainage : récompense différée au filleul actif 7 jours + XP hors classement (anti comptes jetables, voir ADR-010)
- [ ] Défis 1v1, encouragements, séries entre amis, conseils IA personnalisés, abonnement premium

### V3
> Intégration bancaire, agrégateur de comptes, investissements basiques

---

## 🔥 Prochaines actions

1. **Sons** : écouter les 10 sons provisoires sur appareil (iOS silencieux, musique, vibrations) et signaler ceux à remplacer 🎨
1a. ✅ **Écran de fin de leçon** branché sur `completeLesson` (XP, précision, temps, bonus d'unité, niveau) ; précision réelle : une réponse juste après une erreur n'est plus une leçon « parfaite » (score 100 / 50 / 33…)
1b. ✅ **Écran cadeau** : affiche la vraie récompense de `claimQuest` (graines, XP, niveau) ; plus de « gel de série » inventé
1c. **Revenu mensuel à l'onboarding** (voir Phase 2) puis écarts de la relecture Figma : voir `FIGMA_TRACKER.md` (liste priorisée)
2. **Quêtes** : vérifier sur appareil la carte « sous budget » et le bouton « Aucune dépense » ; lancer `npm run test:emulator` (Java requis) pour valider les nouveaux tests de quêtes
3. **Contenu** : rédiger les leçons restantes (unité 3, plusieurs questions par leçon) (`content/lessons/`) et les packs CI / SN
4. **Environnements** : créer `sipho-staging` / `sipho-prod`, `flutterfire configure`, schemes iOS
5. **Multi-devises** : finaliser la saisie avec conversion (`fx/latest`)
6. **Vérifier** quotas de scan, notifications sur appareil
7. **Localisation du code** : plusieurs textes FR/EN restent en dur dans `lessons/domain/learn_quests.dart` (règle 6 du README)

---

## 🏢 Firebase Projects

| Environnement | Project ID | Usage |
|---|---|---|
| Développement | `sipho-f5a01` (alias `dev`) | Dev local, tests, émulateurs |
| Staging | `sipho-staging` | QA, tests d'intégration, beta interne — **non configuré** |
| Production | `sipho-prod` | Utilisateurs finaux — **non configuré** |

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
