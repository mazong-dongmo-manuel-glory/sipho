# 📊 TRACKER — Sipho

> **"Le Duolingo de l'argent"** — App mobile Flutter gamifiée de finance personnelle

| Champ | Valeur |
|---|---|
| **Statut** | 🔄 Phase 0 — Cadrage & Design |
| **Démarrage** | 12 novembre 2026 |
| **Dernière mise à jour** | 12 novembre 2026 |

---

## 🏗️ Stack validée

| Couche | Technologie |
|---|---|
| Mobile | Flutter 3.22+ / Dart 3.3+ |
| State management | Riverpod 2 + riverpod_generator |
| Navigation | go_router 14 |
| Modèles | freezed + json_serializable |
| Backend | Firebase (Auth, Firestore, Functions, Storage, Messaging, Remote Config) |
| IA | Firebase AI Logic (Gemini) |
| Animations | Rive 0.13, Lottie 3 |
| Graphiques | fl_chart 0.69 |
| Audio | flutter_soloud 3.2 |
| CI/CD | GitHub Actions |
| Déploiement | Flavors dev / staging / prod |

---

## 📅 Phases du projet

| Phase | Nom | Durée | Statut | Avancement |
|---|---|---|---|---|
| 0 | Cadrage & Design | 3 sem | 🔄 EN COURS | 33 % |
| 1 | Fondations | 3 sem | ⏳ À VENIR | 0 % |
| 2 | Cœur finances | 4 sem | ⏳ À VENIR | 0 % |
| 2b | International & économie | 3 sem | ⏳ À VENIR | 0 % |
| 3 | Scan IA | 2 sem | ⏳ À VENIR | 0 % |
| 4 | Gamification | 3 sem | ⏳ À VENIR | 0 % |
| 5 | Notifications | 2 sem | ⏳ À VENIR | 0 % |
| 6 | Bêta & Lancement | 3 sem | ⏳ À VENIR | 0 % |
| V2 | — | 8–10 sem | 🔮 FUTUR | — |
| V3 | — | 10–12 sem | 🔮 FUTUR | — |

---

## ✅ Tâches par phase

### Phase 0 — Cadrage & Design (3 sem) 🔄 EN COURS

- [x] README / spec complète
- [x] Brief Figma (FIGMA.md)
- [ ] Maquettes Figma validées (25 écrans)
- [ ] Mascotte Sipho — illustration finale + animations Rive (8 émotions)
- [ ] Sons (10 sons)
- [ ] 10 leçons rédigées (contenu pédagogique)

---

### Phase 1 — Fondations (3 sem) ⏳ À VENIR

- [ ] Flavors dev / staging / prod configurés
- [ ] Firebase ×3 projets initialisés (sipho-dev, sipho-staging, sipho-prod)
- [ ] FlutterFire configure (3 projets — `firebase_options_*.dart`)
- [ ] Thème / tokens complets (couleurs, typo, espacements, radius)
- [ ] i18n FR + EN opérationnel (ARB + l10n.yaml)
- [ ] go_router avec toutes les routes nommées
- [ ] `Money` (cents) + `LocalDay` implémentés et testés
- [ ] CI/CD GitHub Actions (lint, test, build)
- [ ] Règles Firestore testées (`firebase-rules-test`)
- [ ] App Check configuré (dev bypass + prod DeviceCheck/Play Integrity)

---

### Phase 2 — Cœur finances (4 sem) ⏳ À VENIR

- [ ] Onboarding conversationnel (questions + construction du nid)
- [ ] Mon socle — saisie des dépenses fixes mensuelles
- [ ] Dépenses variables — saisie express (bottom sheet + clavier)
- [ ] Agrégats Cloud Functions (totaux mensuels, reste à vivre)
- [ ] Budget & reste à vivre (jauge circulaire, carte accueil)
- [ ] Graphiques fl_chart (anneau catégories, barres par jour)

---

### Phase 2b — International & économie (3 sem) ⏳ À VENIR

- [ ] Packs pays Firestore (CA, FR, CM, CI, SN)
- [ ] Multi-devises + taux de change
- [ ] Localisation complète (formats dates, montants)
- [ ] Indicateurs économiques (inflation, taux directeurs)
- [ ] Cartes économiques du jour

---

### Phase 3 — Scan IA (2 sem) ⏳ À VENIR

- [ ] Caméra + compression image (`image_picker` + `image`)
- [ ] Gemini Firebase AI Logic — extraction ticket de caisse
- [ ] Écran de validation (champs pré-remplis + surligné incertain)
- [ ] Quotas scan Remote Config (limite mensuelle par utilisateur)

---

### Phase 4 — Gamification (3 sem) ⏳ À VENIR

- [ ] XP serveur + limites par jour (Cloud Functions)
- [ ] Séries + gels + réparations (streak logic)
- [ ] Graines d'or + boutique (economy)
- [ ] Cadeaux de Sipho (récompenses aléatoires)
- [ ] Quêtes (quotidiennes, hebdomadaires, mensuelles)
- [ ] Sipho Rive — 8 émotions animées (content, fier, danse, inquiet, triste, endormi, fête, neutre)
- [ ] Sons + vibrations (SoundService)
- [ ] Récap mensuel (rapport gamifié)

---

### Phase 5 — Notifications (2 sem) ⏳ À VENIR

- [ ] FCM setup complet (Android + iOS)
- [ ] `notifyScheduler` Cloud Function (cycle 15 min)
- [ ] 10 types de notifications implémentés
- [ ] Préférences utilisateur (plages horaires, fréquence)
- [ ] Plafond + escalade (anti-spam)

---

### Phase 6 — Bêta & Lancement (3 sem) ⏳ À VENIR

- [ ] TestFlight (iOS) + Play Internal Testing (Android)
- [ ] Data safety (Play Store) + Privacy Nutrition Labels (App Store)
- [ ] Conformité RGPD / Loi 25 (Québec)
- [ ] Lancement pays prioritaires (CA, FR, CM)

---

### V2 (8–10 sem) 🔮 FUTUR

> Ligues, défis entre amis, conseils IA personnalisés, abonnement premium

---

### V3 (10–12 sem) 🔮 FUTUR

> Intégration bancaire, agrégateur de comptes, investissements basiques

---

## 🔥 Prochaines actions immédiates — Phase 1 (Fondations)

1. Créer les 3 projets Firebase Console : `sipho-dev`, `sipho-staging`, `sipho-prod`
2. Configurer les flavors Flutter (android/app/build.gradle + iOS schemes)
3. Exécuter `flutterfire configure` pour chaque environnement
4. Implémenter `app_colors.dart`, `app_text_styles.dart`, `app_theme.dart`
5. Configurer `l10n.yaml` + ARB FR/EN
6. Implémenter `Money` class (cents) + tests unitaires
7. Implémenter `LocalDay` + tests unitaires
8. Configurer les GitHub Actions CI

---

## 🏢 Firebase Projects

| Environnement | Project ID | Usage |
|---|---|---|
| Développement | `sipho-dev` | Dev local, tests, émulateurs |
| Staging | `sipho-staging` | QA, tests d'intégration, beta interne |
| Production | `sipho-prod` | Utilisateurs finaux |

---

## 📦 Dépendances clés

| Package | Version | Rôle |
|---|---|---|
| `flutter_riverpod` | ^2.5.1 | State management |
| `riverpod_annotation` | ^2.3.5 | Code generation Riverpod |
| `go_router` | ^14.3.0 | Navigation déclarative |
| `freezed_annotation` | ^2.4.4 | Modèles immuables |
| `json_annotation` | ^4.9.0 | Sérialisation JSON |
| `firebase_core` | ^3.6.0 | Base Firebase |
| `firebase_auth` | ^5.3.1 | Authentification |
| `cloud_firestore` | ^5.4.4 | Base de données |
| `cloud_functions` | ^5.1.3 | Cloud Functions |
| `firebase_messaging` | ^15.1.3 | Notifications push |
| `firebase_ai` | ^2.3.0 | Gemini / AI Logic |
| `firebase_app_check` | ^0.3.1+3 | Sécurité API |
| `firebase_remote_config` | ^5.1.3 | Config à distance |
| `firebase_analytics` | ^11.3.3 | Analytics |
| `firebase_crashlytics` | ^4.1.3 | Crash reporting |
| `rive` | ^0.13.14 | Animations mascotte |
| `lottie` | ^3.1.2 | Animations JSON |
| `fl_chart` | ^0.69.0 | Graphiques |
| `flutter_soloud` | ^3.2.1 | Audio |
| `intl` | ^0.19.0 | Internationalisation |
| `in_app_purchase` | ^3.2.0 | Achats in-app |
| `image_picker` | ^1.1.2 | Scan factures |
| `app_links` | ^6.3.3 | App Links / Universal Links |

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
