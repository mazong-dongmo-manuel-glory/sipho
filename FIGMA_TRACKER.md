# 🎨 FIGMA TRACKER — Sipho

> Suivi de l'avancement des maquettes Figma et de l'implémentation des écrans.

**Fichier Figma :** [Sipho — Design](https://www.figma.com/design/nsdpHR62Ct0mjq1cgVGkwl/Untitled?node-id=2-29018)  
**Dernière mise à jour :** 2026-11-12

---

## 📱 Écrans — Statut

> Légendes : ⬜ Non commencé · 🖌️ Maquetté · ✅ Validé · 💻 Implémenté

| # | Écran | Maquetté | Validé | Implémenté | Notes |
|---|---|:---:|:---:|:---:|---|
| 1 | Splash (démarrage) | ⬜ | ⬜ | ⬜ | Fond vert profond, Sipho dans son nid |
| 2 | Bienvenue & Connexion | ⬜ | ⬜ | ⬜ | Apple + Google Sign-in |
| 3a | Onboarding — Question 1 (Prénom) | ⬜ | ⬜ | ⬜ | Bulle dialogue Sipho |
| 3b | Onboarding — Question 2 (Objectif) | ⬜ | ⬜ | ⬜ | Cartes sélectionnables |
| 3c | Onboarding — Question 3 (Revenu) | ⬜ | ⬜ | ⬜ | Clavier numérique |
| 4 | Construction du nid (dépenses fixes) | ⬜ | ⬜ | ⬜ | Style Tinder swipe |
| 5 | Détail d'une dépense fixe | ⬜ | ⬜ | ⬜ | Clavier géant, prélévement |
| 6 | Célébration fin d'onboarding | ⬜ | ⬜ | ⬜ | Confettis, +50 XP, badge |
| 7 | Pré-permission notifications | ⬜ | ⬜ | ⬜ | Sipho avec cloche |
| 8a | Accueil — Mode clair | ⬜ | ⬜ | ⬜ | Jauge circulaire, quêtes, carte éco |
| 8b | Accueil — Mode sombre | ⬜ | ⬜ | ⬜ | Version dark de l'accueil |
| 9 | Ajout express d'une dépense | ⬜ | ⬜ | ⬜ | Bottom sheet, clavier, catégories |
| 10 | Micro-récompense après ajout | ⬜ | ⬜ | ⬜ | Animation +5 XP, toast |
| 11a | Scan de facture — Caméra | ⬜ | ⬜ | ⬜ | Rayon laser jaune |
| 11b | Scan de facture — Validation | ⬜ | ⬜ | ⬜ | Champs pré-remplis, surligné incertain |
| 12 | Dépenses du mois | ⬜ | ⬜ | ⬜ | Onglets, liste groupée par jour |
| 13 | Mon socle (dépenses fixes) | ⬜ | ⬜ | ⬜ | Nid, mini-calendrier, statuts |
| 14 | Graphiques & Budgets | ⬜ | ⬜ | ⬜ | Anneau, barres, jauges horizontales |
| 15 | Apprendre — Chemin de leçons | ⬜ | ⬜ | ⬜ | Chemin sinueux style Duolingo |
| 16 | Leçon interactive | ⬜ | ⬜ | ⬜ | Question + 4 choix, barre progression |
| 17 | Résultat de leçon | ⬜ | ⬜ | ⬜ | +20 XP, Sipho fier |
| 18 | Classement (ligues) | ⬜ | ⬜ | ⬜ | Tableau ligue Or, podium, podium |
| 19 | Profil utilisateur | ⬜ | ⬜ | ⬜ | Avatar, stats, badges, paramètres |
| 20 | Paramètres | ⬜ | ⬜ | ⬜ | Notifs, langue, devise, compte |
| 21 | Récap mensuel | ⬜ | ⬜ | ⬜ | Rapport gamifié, Sipho danse |

**Total : 25 écrans (21 principaux + 4 variantes)**

---

## 🧩 Composants de la bibliothèque

| # | Composant | Statut Figma | Statut Flutter | Notes |
|---|---|:---:|:---:|---|
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
