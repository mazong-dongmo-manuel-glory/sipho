# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Versionnage Sémantique](https://semver.org/lang/fr/).

---

## [Unreleased] - 2026-11-12

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
