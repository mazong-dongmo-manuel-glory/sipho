# Environnements Sipho — Dev (`sipho-staging`) & Production (`sipho-f5a01`)

Architecture **à deux projets Firebase** (corrigée 2026-11-20).

> **Attention — ID projet :** le projet de **dev/QA** a l’ID **`sipho-staging`**  
> (nom affiché dans la console : **« sipho-dev »**).  
> L’ID nu `staging` **n’existe pas** sur le compte Firebase Sipho.  
> Toujours déployer avec `--project sipho-staging` (ou l’alias `.firebaserc` `staging` / `dev`).

| Environnement | Project ID | Nom affiché console | Rôle | Point d'entrée Flutter | Packages natifs |
|---|---|---|---|---|---|
| **Dev / QA** | `sipho-staging` | « sipho-dev » | Dev local, QA, données de test | `lib/main_dev.dart`, `lib/main_staging.dart`, ou `main.dart` en **debug** | `com.cargonomade.sipho.staging` |
| **Production** | `sipho-f5a01` | « sipho » | Utilisateurs finaux, stores | `lib/main_prod.dart`, ou `main.dart` en **release** | `com.cargonomade.sipho` |

> Note : un projet `sipho-prod` peut aussi apparaître dans la liste Firebase ; **la prod active du repo est `sipho-f5a01`**.

`.firebaserc` :

```json
{
  "projects": {
    "default": "sipho-f5a01",
    "prod": "sipho-f5a01",
    "staging": "sipho-staging",
    "dev": "sipho-staging"
  }
}
```

Les **flavors Dart** s’appellent `dev` / `staging` / `prod` (noms d’entrée Flutter).  
Les flavors `dev` et `staging` ciblent **le même** projet Firebase `sipho-staging`.  
Le flavor `prod` cible `sipho-f5a01`.  
`assertFirebaseConfigured` refuse de démarrer si les clés sont `REPLACE_ME` ou si le `projectId` est faux.

---

## 1. Fichiers d'options Flutter

| Fichier | Projet attendu | État |
|---|---|---|
| `app/lib/core/firebase/firebase_options_prod.dart` | `sipho-f5a01` | Configuré (apps `com.cargonomade.sipho`) |
| `app/lib/core/firebase/firebase_options_staging.dart` | `sipho-staging` | À générer avec FlutterFire |
| `app/lib/core/firebase/firebase_options_dev.dart` | `sipho-staging` | À générer (même projet) |

### Configurer `sipho-staging` (une fois)

1. Console → projet **sipho-staging** (affiché sipho-dev) → apps :
   - Android / iOS : `com.cargonomade.sipho.staging`
2. Activer Storage (« Get Started ») si pas encore fait.
3. Puis :

```bash
cd app
flutterfire configure \
  --project=sipho-staging \
  --out=lib/core/firebase/firebase_options_staging.dart \
  --ios-bundle-id=com.cargonomade.sipho.staging \
  --android-package-name=com.cargonomade.sipho.staging

flutterfire configure \
  --project=sipho-staging \
  --out=lib/core/firebase/firebase_options_dev.dart \
  --ios-bundle-id=com.cargonomade.sipho.staging \
  --android-package-name=com.cargonomade.sipho.staging
```

Prod :

```bash
flutterfire configure \
  --project=sipho-f5a01 \
  --out=lib/core/firebase/firebase_options_prod.dart \
  --ios-bundle-id=com.cargonomade.sipho \
  --android-package-name=com.cargonomade.sipho
```

### Lancer l'app

```bash
# Dev / QA → sipho-staging
flutter run -t lib/main_dev.dart \
  --dart-define=APP_CHECK_DEBUG_TOKEN=<uuid-enregistré-sur-sipho-staging>

flutter run -t lib/main_staging.dart \
  --dart-define=APP_CHECK_DEBUG_TOKEN=<uuid-enregistré-sur-sipho-staging>

# Prod → sipho-f5a01
flutter run -t lib/main_prod.dart --release
flutter build appbundle -t lib/main_prod.dart --release
```

`main.dart` sans target : **debug → sipho-staging**, **release → sipho-f5a01**.

---

## 2. Déploiements Firebase

```bash
# Production
firebase deploy --only firestore:rules,firestore:indexes,storage --project sipho-f5a01
firebase deploy --only functions --project sipho-f5a01

# Dev / QA
firebase deploy --only firestore:rules,firestore:indexes,storage --project sipho-staging
firebase deploy --only functions --project sipho-staging

# Alias .firebaserc (les alias CLI `staging`/`dev` résolvent vers sipho-staging)
firebase deploy --only firestore,storage,functions --project prod
firebase deploy --only firestore,storage,functions --project staging   # alias → sipho-staging
firebase deploy --only firestore,storage,functions --project sipho-staging  # ID explicite (préféré)
```

### Seed contenu (packs pays)

**État `sipho-staging` (2026-11-20)** : packs `countries/{CA,CI,CM,FR,SN,generic}` + `lessons/unit_1_budget_basics` déjà écrits. **Ne jamais seed sur `sipho-f5a01`.**

Script Admin SDK (`content/scripts/import.ts`) — nécessite Application Default Credentials :

```bash
# Une fois par machine (ouvre le navigateur Google) :
gcloud auth application-default login
# ou : export GOOGLE_APPLICATION_CREDENTIALS=/chemin/service-account.json

cd /chemin/vers/sipho
GCLOUD_PROJECT=sipho-staging \
  npx --prefix functions ts-node content/scripts/import.ts
```

Sans ADC (`Unable to refresh... ADC`), le seed staging a été fait via l’API Firestore REST avec le token CLI Firebase (`firebase login` déjà actif) — équivalent PATCH sur `countries/*` et `lessons/*`. Pour rejouer l’import Admin SDK localement : lancer d’abord `gcloud auth application-default login`.
---

## 3. CI/CD

| Workflow | Déclencheur | Projet Firebase |
|---|---|---|
| `ci.yml` | PR / push | — |
| `deploy_dev.yml` | branche `develop` | `sipho-staging` |
| `deploy_staging.yml` | branche `staging` | `sipho-staging` |
| `deploy_prod.yml` | tag `v*.*.*` | `sipho-f5a01` |

Secrets : `FIREBASE_TOKEN_STAGING`, `FIREBASE_TOKEN_PROD`,  
`FIREBASE_PROJECT_STAGING` (= `sipho-staging`), `FIREBASE_PROJECT_PROD` (= `sipho-f5a01`),  
`GOOGLE_SERVICES_JSON_STAGING`, `GOOGLE_SERVICES_JSON_PROD`.

---

## 4. Variables Functions / actus éco

Par projet : `GEMINI_API_KEY`, `GEMINI_MODEL`, `FX_FEED_URL`, `SCAN_QUOTA_PER_DAY`,  
`GNEWS_API_KEY` (optionnel — sinon Google News RSS gratuit, ADR-016).

Remote Config : `scan_quota_per_day`, `ai_model`.

---

## 5. Sign in with Apple (iOS + Android)

Configurée le **2026-11-22** sur le compte Apple Team **`B2K3M34M6S`** (Manuel Glory Mazong Dongmo).  
La **même** clé Apple Auth et le **même** Services ID servent les deux projets Firebase.

### Identifiants Apple Developer

| Élément | Valeur |
|---|---|
| Team ID | `B2K3M34M6S` |
| App ID (primary, Sign in with Apple) | `com.cargonomade.sipho.staging` (description « Sipho Staging ») |
| Services ID | `com.cargonomade.sipho.signin` (description « Sipho Sign in with Apple ») |
| Auth Key (Sign in with Apple) | Key ID **`8Q8KF2BT48`** — fichier local typique `AuthKey_8Q8KF2BT48.p8` (**ne pas committer**) |

Domaines / return URLs enregistrés sur le Services ID :

- Domaines : `sipho-staging.firebaseapp.com`, `sipho-f5a01.firebaseapp.com`
- Return URLs :
  - `https://sipho-staging.firebaseapp.com/__/auth/handler`
  - `https://sipho-f5a01.firebaseapp.com/__/auth/handler`

### Firebase Auth → provider Apple

Sur **chaque** projet (`sipho-staging` et `sipho-f5a01`) :

1. Authentication → Sign-in method → **Apple** → Enable
2. **Services ID** : `com.cargonomade.sipho.signin`
3. **OAuth code flow configuration** (obligatoire pour Android) :
   - Apple team ID : `B2K3M34M6S` (**aucun espace** avant/après)
   - Key ID : `8Q8KF2BT48` (**aucun espace** avant/après)
   - Private key : contenu du `.p8` (BEGIN/END PRIVATE KEY), **vrais** retours à la ligne — pas la séquence littérale `\n`

Sans le code flow → erreur client  
`[firebase_auth/operation-not-allowed] … Code flow is not enabled for Apple.`

Espaces ou `\n` littéraux dans Team/Key/`.p8` →  
`[firebase_auth/invalid-credential]` (Android HTTP 400 / iOS « Invalid OAuth response from apple.com »),  
message UI : « Identifiant Apple invalide… ».

Vérif rapide (doit renvoyer un `authUri` appleid.apple.com) :

```bash
# Remplacer API_KEY par la Web API key du projet (firebase_options_*.dart)
curl -s -X POST "https://identitytoolkit.googleapis.com/v1/accounts:createAuthUri?key=API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{"providerId":"apple.com","continueUri":"https://sipho-staging.firebaseapp.com/__/auth/handler"}'
```

### App Flutter

| Plateforme | Implémentation (`AuthRepository.signInWithApple`) |
|---|---|
| iOS / macOS | Natif `SignInWithApple` + nonce → `signInWithCredential` |
| Android | `AppleAuthProvider` + `signInWithProvider` (Custom Tabs) |

Constantes Dart : `kAppleTeamId`, `kAppleServicesId`, `kAppleSignInKeyId`,  
`kAppleAuthHandlerStaging` / `kAppleAuthHandlerProd` dans  
`app/lib/core/firebase/firebase_environment.dart`.

### Rotation / regen

Si la clé `.p8` est perdue : créer une **nouvelle** Auth Key Sign in with Apple dans  
Apple Developer → Keys, mettre à jour Key ID + private key dans **les deux** consoles Firebase,  
mettre à jour `kAppleSignInKeyId` et cette section.

---

## 6. Checklist console

### `sipho-staging` (dev — affiché sipho-dev)
- [x] Firestore rules + indexes
- [x] Cloud Functions + `.env.sipho-staging` (GEMINI, SCAN_QUOTA=20, FX_FEED)
- [x] Remote Config publié (`remoteconfig.template.json`)
- [x] Apps Android/iOS `com.cargonomade.sipho.staging` + options Dart générées
- [x] App Check debug tokens Android/iOS enregistrés (locaux CLI — ne pas committer)
- [ ] Storage Firebase : **Get Started** console puis `firebase deploy --only storage --project sipho-staging`
- [x] Auth Google + Apple (OAuth code flow Android, Services ID `com.cargonomade.sipho.signin`)
- [ ] Auth Phone (+ SHA Android, APNs iOS)
- [ ] FCM / APNs production-like pour tests push
- [x] Seed packs pays + leçon unit_1 (Firestore REST 2026-11-20 ; `import.ts` → ADC si rejoué)

### `sipho-f5a01` (prod)
- [x] Firestore rules/indexes déployés
- [x] Auth Apple OAuth code flow (même Services ID / Key ID que staging)
- [ ] Vérifier Auth Google / Phone, Storage, App Check, FCM, secrets
- [ ] Packages **sans** `.staging` : `com.cargonomade.sipho`
