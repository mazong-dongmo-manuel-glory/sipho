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
**Statut :** ❓ À DÉCIDER

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

Chaque flavor Flutter pointe vers le bon projet via `firebase_options_<env>.dart`.

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
- Les configurations pays (taxes TVA/TPS/TVQ, devise par défaut, catégories suggérées) sont stockées dans **Firestore** (`/countryPacks/{countryCode}`)
- Chargées au démarrage et mises en cache localement
- Mises à jour sans release via Firestore
- Aucune règle fiscale en dur dans le code Dart

### Conséquences
- Ajout d'un nouveau pays = simple document Firestore (pas de release)
- Risque : si Firestore indisponible au premier lancement, fallback sur le pack CA intégré en assets
- Tests d'intégration nécessaires pour chaque pack pays

---

*Dernière mise à jour : 2026-11-12*
