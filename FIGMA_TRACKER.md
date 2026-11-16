# 🎨 FIGMA TRACKER — Sipho

> Suivi de l'avancement des maquettes Figma et de l'implémentation des écrans.

**Fichier Figma :** [Sipho — Design](https://www.figma.com/design/nsdpHR62Ct0mjq1cgVGkwl/Untitled) (clé `nsdpHR62Ct0mjq1cgVGkwl`, page « Page 1 ». Le fichier s'appelle encore « Untitled » : à renommer.)
**Dernière mise à jour :** 2026-11-15 (relecture du fichier réel : 33 frames iPhone 15 de 393 × 852 + 1 frame « Sipho · Bibliothèque locale »)

> Ancien lien du tracker (`node-id=2-29018`) : un nœud de 200 × 200 px, pas un écran. Ne pas l'utiliser.

---

## 📱 Écrans — Statut

> Légendes : ⬜ Non commencé · 🖌️ Maquetté · ✅ Validé par Manuel · 💻 Implémenté dans l'app
> « Validé » reste ⬜ partout : la validation par Manuel n'a pas encore été faite. Les 33 frames ont été relues visuellement le 2026-11-15 : toutes sont cohérentes avec les tokens (palette, Nunito, boutons 3D, mascotte).
> « Implémenté » = une route / un écran équivalent existe dans l'app, sans comparaison pixel à pixel.

| # | Frame Figma (id) | Maquetté | Validé | Implémenté | Notes |
|---|---|:---:|:---:|:---:|---|
| 1 | 01 · Démarrage (`2:28911`) | 🖌️ | ⬜ | 💻 | `/splash` |
| 2 | 02 · Bienvenue (`2:28913`) | 🖌️ | ⬜ | 💻 | `/login` |
| 3a | 03a · Ton prénom (`2:28915`) | 🖌️ | ⬜ | 💻 | `onboarding_name_step` |
| 3b | 03b · Ton pays (`2:28917`) | 🖌️ | ⬜ | 🟡 | Pays, région et devise présents ; « Utiliser ma position » absent (`geolocator` non utilisé) |
| 3c | 03c · Ton objectif (`2:28919`) | 🖌️ | ⬜ | 💻 | `onboarding_goal_step` ; pas d'écran revenu (voir TRACKER) |
| 4 | 04 · Construisons ton nid (`2:28921`) | 🖌️ | ⬜ | 💻 | `/fixed-expenses/swipe` |
| 5 | 05 · Dépense fixe (`2:28923`) | 🖌️ | ⬜ | 💻 | `/fixed-expenses/amount` |
| 6 | 06 · Nid terminé (`2:28925`) | 🖌️ | ⬜ | 💻 | Badge « Bâtisseur » annoncé mais non attribué par le serveur |
| 7 | 07 · Notifications (`2:28927`) | 🖌️ | ⬜ | 💻 | `/onboarding/notifications` |
| 8a | 08 · Accueil clair (`2:28929`) | 🖌️ | ⬜ | 💻 | Relu |
| 8b | 08 · Accueil sombre (`2:28931`) | 🖌️ | ⬜ | 💻 | Thème sombre suit le système (`ThemeMode.system`) |
| 9 | 09 · Ajout express (`2:28933`) | 🖌️ | ⬜ | 💻 | `/expenses/add` ; saisie multi-devises à finir |
| 10 | 10 · Micro-récompense (`2:28935`) | 🖌️ | ⬜ | 💻 | Sons / vibrations branchés |
| 11a | 11a · Scanner (`2:28937`) | 🖌️ | ⬜ | 💻 | `/expenses/scan` |
| 11b | 11b · Vérifier le ticket (`2:28939`) | 🖌️ | ⬜ | 💻 | `/expenses/validate` |
| 12 | 12 · Dépenses du mois (`2:28941`) | 🖌️ | ⬜ | 🟡 | `/expenses` ; ni étiquette « 📷 scanné » ni ligne en devise étrangère (« 25,00 € → 36,80 $ ») dans la liste |
| 13 | 13 · Mon socle (`2:28943`) | 🖌️ | ⬜ | 💻 | Relu ; `/fixed-expenses` |
| 14 | 14 · Graphiques et budgets (`2:28945`) | 🖌️ | ⬜ | 💻 | `/charts`, `/budget` |
| 15 | 15 · Chemin de leçons (`2:28947`) | 🖌️ | ⬜ | 💻 | Relu ; l'app a 2 unités (la maquette en montre une + « Unité 3 : CELI » verrouillée) |
| 16 | 16 · Quiz / Bonne réponse (`2:28949`, `2:28951`) | 🖌️ | ⬜ | 💻 | Une seule question par leçon dans l'app |
| 17 | 17 · Leçon terminée (`2:28953`) | 🖌️ | ⬜ | 💻 | `/lesson-done` branché sur la réponse de `completeLesson` (XP, précision, temps, bonus) depuis le 2026-11-15 |
| 18 | 18 · Série prolongée (`2:28955`) | 🖌️ | ⬜ | 💻 | `/streak` |
| 19 | 19 · Cadeau fermé / ouvert (`2:28957`, `2:28959`) | 🖌️ | ⬜ | 💻 | `/chest` affiche la vraie récompense de `claimQuest` ; la maquette montre « Gel de série ×1 », que le serveur n'attribue pas : écart de contenu à trancher |
| 20 | 20 · Ligue Or (`2:28961`) | 🖌️ | ⬜ | 💻 | Relu ; onglet « Mon pays » : « Bientôt disponible » |
| 21 | 21 · Profil (`2:28963`) | 🖌️ | ⬜ | 🟡 | Section « Mes objectifs » **absente** (la chaîne existe, aucun écran ni donnée `goals`) |
| 22 | 22 · Boutique (`2:28965`) | 🖌️ | ⬜ | 💻 | Achats réels (ADR-013) ; objets non portés par Sipho (Rive) |
| 23 | 23 · Conseil de Sipho (`2:28967`) | 🖌️ | ⬜ | 🟡 | Conseils IA : service présent, écran à confirmer (V2) |
| 24 | 24a / 24b / 24c · Récap (`2:28969`, `2:28971`, `2:28973`) | 🖌️ | ⬜ | 💻 | `/recap` |
| 25 | 25 · Réglages (`2:28975`) | 🖌️ | ⬜ | 💻 | `/settings`, `/notification-settings` |

**Total : 33 frames** (25 écrans du brief + variantes) — tous maquettés.

### Écarts constatés à la relecture du 2026-11-15 (code à écrire)
| Priorité | Écart | Détail |
|---|---|---|
| ✅ fait | Fin de leçon et cadeau en dur | Branchés sur les vraies réponses serveur (voir CHANGELOG) |
| 1 | Revenu mensuel absent de l'onboarding | Sans lui, « Reste à vivre » et « sous budget » ne fonctionnent pas pour un nouvel utilisateur |
| 2 | Liste des dépenses | Étiquette « scanné » et ligne en devise étrangère (montant d'origine → montant converti) |
| 3 | Mes objectifs (profil) | Collection `goals`, barre de progression, création et dépôt |
| 4 | Saisie multi-devises | Choix de la devise dans l'ajout express + conversion `fx/latest` |
| 5 | « Utiliser ma position » | Géoloc approximative à la demande, libellés seulement (README §4.1) |
| 6 | Cadeau : « Gel de série » | Le serveur n'attribue pas de gel via `claimQuest` ; décider d'en ajouter ou de retirer la ligne de la maquette |
| 7 | Onglet « Mon pays » de la ligue | Affiche « Bientôt disponible » |

### Écrans de l'app absents de Figma (à maquetter)
- Onglet **Amis** du classement : code ami, demandes, liste.
- **Contacts** : consentement, comparaison par empreintes, invitation SMS / e-mail.
- **Vérification de numéro** (SMS).
- Détail d'un **badge** ; états de la boutique (Possédé / Pas assez de graines / Stock plein).
- **Saisie multi-devises**, **localisation à la demande**, **objectifs d'épargne**, **Premium** (V2).
- Étapes d'onboarding manquantes selon le README : étape de vie et revenu (la région est déjà collectée).

---

## 🧩 Composants de la bibliothèque

> Figma : 🖌️ présent dans la frame « Sipho · Bibliothèque locale » (relue le 2026-11-15) · ⬜ absent. Ce sont des éléments de la frame, pas encore de vrais composants Figma avec variantes : à vérifier.
> Flutter : 💻 widget partagé dans `app/lib/core/widgets` · 🟡 existe mais propre à une feature · ⬜ pas de widget dédié.

| # | Composant | Statut Figma | Statut Flutter | Notes |
|---|---|:---:|:---:|---|
| 1 | `SiphoButton3D` | 🖌️ | 💻 | Primaire, secondaire, désactivé, danger |
| 2 | `GameBar` | 🖌️ | 💻 | Pastilles flamme / graines / niveau |
| 3 | `SiphoBubble` | 🖌️ | 💻 | Bulle dialogue mascotte |
| 4 | `GaugeCircular` | 🖌️ | 💻 | Jauge reste à vivre |
| 5 | `GaugeHorizontal` | 🖌️ | 💻 | Vert / jaune / rouge |
| 6 | `AmountKeypad` | 🖌️ | 💻 | Clavier numérique géant |
| 7 | `BottomNav` | 🖌️ | 💻 | 5 onglets, 5 états actifs |
| 8 | `CategoryChip` | 🖌️ | ⬜ | 12 catégories ; pas de widget partagé |
| 9 | `ExpenseCard` | 🖌️ | ⬜ | Ligne de transaction |
| 10 | `FixedExpenseCard` | 🖌️ | 🟡 | Dans `fixed_expenses/presentation` |
| 11 | `QuestRow` | 🖌️ | 🟡 | `QuestCard` dans `home/presentation` |
| 12 | `EcoCard` | 🖌️ | 🟡 | `EconomyCard` dans `home/presentation` |
| 13 | `LeagueRow` | 🖌️ | 🟡 | Dans `leaderboard/presentation` |
| 14 | `BadgeWidget` | ⬜ | 🟡 | Absent de la bibliothèque Figma ; grille de badges dans le profil |
| 15 | `XpToast` | 🖌️ | ⬜ | Toast « Bien joué ! 2/3 pour ta quête » ; pas de widget partagé |
| 16 | `SiphoAvatar` | 🖌️ | 🟡 | 8 poses dessinées dans Figma ; l'app utilise des SVG (`SiphoArt`), pas Rive |

---|---|:---:|:---:|---|
| 1 | `SiphoButton3D` | ⬜ | ⬜ | Bouton relief style Duolingo |
| 2 | `GameBar` | ⬜ | ⬜ | Barre 🔥 XP / graines / niveau |
| 3 | `SiphoBubble` | ⬜ | ⬜ | Bulle dialogue mascotte |
| 4 | `GaugeCircular` | ⬜ | ⬜ | Jauge reste à vivre |
| 5 | `GaugeHorizontal` | ⬜ | ⬜ | Jauge budget catégorie |
| 6 | `AmountKeypad` | ⬜ | ⬜ | Clavier numérique géant |
| 7 | `BottomNav` | ⬜ | ⬜ | Navigation 5 onglets |
| 8 | `CategoryChip` | ⬜ | ⬜ | Pastille icône catégorie |
| 9 | `ExpenseCard` | ⬜ | ⬜ | Carte dépense liste |
| 10 | `FixedExpenseCard` | ⬜ | ⬜ | Carte dépense fixe (statut) |
| 11 | `QuestRow` | ⬜ | ⬜ | Ligne de quête avec barre |
| 12 | `EcoCard` | ⬜ | ⬜ | Carte économique du jour |
| 13 | `LeagueRow` | ⬜ | ⬜ | Ligne classement ligue |
| 14 | `BadgeWidget` | ⬜ | ⬜ | Badge/trophée débloqué |
| 15 | `XpToast` | ⬜ | ⬜ | Toast animation +XP |
| 16 | `SiphoAvatar` | ⬜ | ⬜ | Avatar Rive avec émotion |

---

## 🎨 Design Tokens validés

### Couleurs

| Rôle | Token | Valeur |
|---|---|---|
| Primaire (actions, succès) | `colorPrimary` | `#1F9D55` |
| Primaire foncé (ombres, titres) | `colorPrimaryDark` | `#14342B` |
| Accent XP / mascotte | `colorAccentGold` | `#F2B705` |
| Accent secondaire / alertes | `colorAccentTerra` | `#C8553D` |
| Fond app | `colorBackground` | `#FFF8EC` |
| Fond cartes | `colorSurface` | `#FFFFFF` |
| Texte principal | `colorTextPrimary` | `#1E2A2F` |
| Texte secondaire | `colorTextSecondary` | `#5B6770` |
| Avertissement (budget 70–90 %) | `colorWarning` | `#F2B705` |
| Danger (budget > 90 %) | `colorDanger` | `#E5484D` |
| Flamme série (gradient début) | `colorFlameStart` | `#FF9F1C` |
| Flamme série (gradient fin) | `colorFlameEnd` | `#FF5A1F` |
| Bordure cartes | `colorBorder` | `#EDE6D8` |

**Statut tokens couleurs :** ⬜ À valider en Figma

### Typographie (Nunito)

| Usage | Poids | Taille | Token |
|---|---|---|---|
| Montants géants | Black (900) | 40–56 pt | `textStyleAmountHero` |
| Titres écrans | ExtraBold (800) | 24–28 pt | `textStyleTitle` |
| Sous-titres | Bold (700) | 18–20 pt | `textStyleSubtitle` |
| Corps de texte | Regular (400) | 15–16 pt | `textStyleBody` |
| Libellés | SemiBold (600) | 13 pt | `textStyleLabel` |
| Boutons | ExtraBold (800) | 15 pt MAJ | `textStyleButton` |

**Statut tokens typo :** ⬜ À valider en Figma

### Espacements (grille 8px)

| Token | Valeur | Usage |
|---|---|---|
| `spacing2` | 2 px | Micro espacement |
| `spacing4` | 4 px | Très compact |
| `spacing8` | 8 px | Élément interne |
| `spacing12` | 12 px | Padding interne carte |
| `spacing16` | 16 px | Padding standard |
| `spacing20` | 20 px | Marges latérales |
| `spacing24` | 24 px | Entre sections |
| `spacing32` | 32 px | Sections importantes |
| `spacing48` | 48 px | Espacement hero |

### Border Radius

| Token | Valeur | Usage |
|---|---|---|
| `radius8` | 8 px | Champs de texte |
| `radius16` | 16 px | Cartes standard |
| `radius24` | 24 px | Grandes cartes |
| `radius999` | 999 px | Pastilles, boutons pill |

---

## 🎞️ Animations Rive / Lottie à produire

| Fichier | Type | Émotions / États | Phase | Statut |
|---|---|---|---|---|
| `sipho_mascot.riv` | Rive | content, fier, danse, inquiet, triste, endormi, fête, neutre (8 émotions) | Phase 0 | ⬜ |
| `sipho_nest.riv` | Rive | vide → tissage progressif → complet | Phase 0 | ⬜ |
| `confetti_celebration.json` | Lottie | Explosion confettis jaunes/verts | Phase 0 | ⬜ |
| `xp_coins.json` | Lottie | Pièces qui volent vers pastille XP | Phase 4 | ⬜ |
| `streak_fire.json` | Lottie | Flamme qui brûle (série active) | Phase 4 | ⬜ |
| `scan_laser.json` | Lottie | Rayon laser qui balaie | Phase 3 | ⬜ |

---

## 📝 Notes

- Le style général s'inspire de **Duolingo** (boutons 3D, chemin sinueux, gamification) avec une **identité africaine moderne** (couleurs chaudes, motifs wax/kente discrets)
- La mascotte **Sipho le tisserin** : oiseau jaune vif, dodu, masque noir, écharpe à motifs kente — style flat illustration
- Toutes les maquettes sont en **iPhone 15 (393 × 852)**, mode clair, avec version sombre pour l'accueil
- Textes de l'interface en **français**, devise exemple **$ CAD**, prénom exemple **Amina**
- Icônes de catégories en pastilles colorées : 🏠 🛒 💡 📱 📶 🚌 🍔 🛍️ 🎮 💊 💌 ✨
