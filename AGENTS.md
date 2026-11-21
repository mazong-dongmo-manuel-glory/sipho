# Instructions pour les agents IA — Sipho

Lire aussi : [README.md](./README.md) §15, [ENVIRONMENTS.md](./ENVIRONMENTS.md), [DECISIONS.md](./DECISIONS.md).

## Firebase — ne pas se tromper d’ID projet

| Rôle | Project ID (CLI / code) | Nom affiché console | Packages natifs |
|---|---|---|---|
| **Dev / QA** | `sipho-staging` | « sipho-dev » | `com.cargonomade.sipho.staging` |
| **Production** | `sipho-f5a01` | « sipho » | `com.cargonomade.sipho` |

### Interdit
- **`--project staging`** ou `projectId: 'staging'` — **cet ID n’existe pas** sur le compte Firebase Sipho (erreur 403 Service Usage).
- Pointer les builds debug vers `sipho-f5a01` (ce serait écrire en prod).

### Correct
```bash
firebase deploy --only firestore,storage,functions --project sipho-staging   # dev
firebase deploy --only firestore,storage,functions --project sipho-f5a01     # prod
# ou alias .firebaserc : --project staging / --project dev → sipho-staging
```

Constantes Dart : `kStagingFirebaseProjectId = 'sipho-staging'`, `kProdFirebaseProjectId = 'sipho-f5a01'`  
(`app/lib/core/firebase/firebase_environment.dart`).

Les **noms de flavors Dart** `dev` / `staging` / `prod` restent des labels d’entrée Flutter ; seul le **Firebase projectId** de QA est `sipho-staging`.

## Autres règles non négociables (rappel)
- Montants en **cents** (`int`), jamais `double`.
- XP / séries / graines / ligues = **serveur uniquement**.
- Pas de règle fiscale/pays en dur → packs `countries/{code}`.
- i18n FR+EN pour toute chaîne UI.
