# Brief Figma — Maquettes de l'application Sipho

Copie ce texte dans Figma (Figma Make / First Draft ou un plugin IA). Si l'outil limite la longueur, envoie d'abord la partie **« Contexte et design system »**, puis les écrans **un par un ou par groupe**.

---

## PARTIE 1 — Contexte et design system (à envoyer en premier)

Crée les maquettes d'une **application mobile** appelée **Sipho**, un « Duolingo de l'argent » : une app de finance personnelle **gamifiée**, joyeuse et très simple. Elle aide à suivre ses dépenses, gérer ses dépenses fixes mensuelles, scanner ses factures, apprendre la finance par petites leçons et progresser grâce aux séries, quêtes, ligues et récompenses. Le style s'inspire de Duolingo (formes rondes, couleurs vives, boutons épais, mascotte expressive) avec une **identité africaine moderne et élégante**.

**Format :** iPhone 15 (393 × 852), mode clair. Ajoute aussi une version mode sombre de l'écran d'accueil. Textes de l'interface en **français**. Devise d'exemple : **$ CAD**. Prénom d'exemple : **Amina**.

**Mascotte : Sipho le tisserin.** C'est un petit oiseau tisserin jaune vif, rond et dodu, avec un masque noir autour des yeux, de grands yeux brillants et expressifs, un petit bec conique et une écharpe en tissu à motifs africains (style kente ou wax, vert et terre cuite). Le style est flat illustration, très expressif, cartoon et mignon, sans contours épais. Il apparaît dans presque chaque écran avec une émotion adaptée : content, fier, qui danse, inquiet, triste, endormi, en fête. Son **nid tressé** représente le budget de l'utilisateur.

**Couleurs :**
| Rôle | Couleur |
|---|---|
| Primaire (actions, succès) | Vert Sipho `#1F9D55` |
| Primaire foncé (ombre des boutons, titres) | Vert profond `#14342B` |
| Accent récompenses / XP / mascotte | Jaune tisserin `#F2B705` |
| Accent secondaire / alertes douces | Terre cuite `#C8553D` |
| Fond | Crème `#FFF8EC` |
| Cartes | Blanc `#FFFFFF` |
| Texte principal | `#1E2A2F` |
| Texte secondaire | `#5B6770` |
| Avertissement (budget 70–90 %) | `#F2B705` |
| Danger (budget > 90 %) | `#E5484D` |
| Flamme de série | Dégradé `#FF9F1C` → `#FF5A1F` |

**Typographie :** une police arrondie, chaleureuse et très lisible, de type **Nunito** ou **Baloo 2**.
- Titres en ExtraBold, 24 à 28 pt.
- Montants très gros en Black, 40 à 56 pt.
- Corps de texte 15 à 16 pt.
- Libellés 13 pt.

**Formes et composants :**
- Coins très arrondis : 16 à 24 px pour les cartes, 999 px pour les pastilles.
- **Boutons « 3D »** façon Duolingo : bouton plein vert avec une bordure inférieure de 4 px plus foncée, qui donne un effet de relief. Hauteur 56 px, pleine largeur, texte en majuscules ExtraBold.
- Cartes blanches avec ombre très douce et bordure fine `#EDE6D8`.
- Barre de navigation en bas avec 5 onglets à icônes colorées et épaisses, l'onglet actif encadré : **Accueil, Dépenses, Apprendre, Classement, Profil**.
- Bouton flottant rond **« + »** vert, 64 px, au-dessus de la navigation.
- En haut de la plupart des écrans, une barre de statut de jeu avec 3 pastilles : la **flamme de série** avec un nombre, les **graines d'or** avec un nombre, et le **niveau**.
- Motifs africains (tissage, wax) très discrets en arrière-plan, sur certaines cartes et sur les écrans de récompense, jamais chargés.
- Icônes de catégories en pastilles colorées : Loyer 🏠, Internet 📶, Électricité 💡, Téléphone 📱, Épicerie 🛒, Transport 🚌, Restos 🍔, Shopping 🛍️, Loisirs 🎮, Santé 💊, Famille / transferts 💌, Autre ✨.
- Espacements sur une grille de 8 px, marges latérales de 20 px.

**Ton :** joyeux, encourageant, jamais culpabilisant. Les messages de Sipho sont courts et drôles, dans des **bulles de dialogue**.

---

## PARTIE 2 — Écrans à générer

### 1. Écran de démarrage (splash)
Fond vert profond. Sipho au centre dans son nid. Le logo « Sipho » est en dessous, avec un « o » qui ressemble à un petit nid. Slogan : « Fais-toi un cadeau : ton avenir. »

### 2. Bienvenue et connexion
Fond crème, avec Sipho qui salue d'une aile, en grand, en haut. Le titre « Bienvenue chez Sipho ! » est suivi du sous-titre « Le guide gamifié vers ta prospérité financière ». Deux boutons :
- « Continuer avec Apple » (noir) ;
- « Continuer avec Google » (blanc avec bordure).

Petit texte en bas : conditions et confidentialité.

### 3. Onboarding conversationnel (3 écrans)
Une barre de progression verte en haut. Sipho est en bas à gauche avec une bulle de dialogue, et les réponses sont en grosses cartes sélectionnables.
- **3a.** « Salut ! Moi c'est Sipho. Comment tu t'appelles ? » Un champ prénom.
- **3b.** « Tu vis où ? » Liste de pays avec drapeaux : Canada (pré-sélectionné), France, Cameroun, Côte d'Ivoire, Sénégal, Belgique… Puis une région « Québec » et la devise « $ CAD ». Petit bouton secondaire « Utiliser ma position ».
- **3c.** « Quel est ton objectif principal ? » Quatre cartes avec icônes :
  - « Arrêter d'être à découvert » ;
  - « Épargner pour un projet » ;
  - « Comprendre mon argent » ;
  - « Préparer ma retraite ».

### 4. Configuration du socle : cartes à glisser
Titre : « Construisons ton nid ! ». Une grande carte illustrée au centre, de style Tinder, montre l'icône Loyer 🏠 et le texte « Tu paies un loyer ? ». Deux gros boutons ronds en dessous : ✕ (gris) et ✓ (vert). En haut, le nid de Sipho est partiellement tissé, avec un compteur « 3 brins tissés ». Indication : « Glisse à droite pour oui ».

### 5. Détail d'une dépense fixe
Titre « Loyer ».
- Un très gros montant « 950 $ » au centre.
- Un clavier numérique géant aux touches arrondies.
- En dessous, un sélecteur « Prélevé le : 1er du mois » et un interrupteur « Paiement automatique ».
- Bouton 3D « AJOUTER AU NID ».

### 6. Célébration de fin d'onboarding
Plein écran, avec confettis jaunes et verts et Sipho qui danse devant son nid terminé. Texte : « Ton nid est prêt ! » et « +50 XP ». Un badge « Bâtisseur » apparaît. Bouton « CONTINUER ».

### 7. Pré-permission des notifications
Sipho tient une petite cloche. Texte : « Je peux te rappeler de garder ta flamme ? Max 2 rappels par jour, promis. » Boutons « OUI, RAPPELLE-MOI » et « Plus tard ».

### 8. Accueil (écran principal) — version claire ET version sombre
De haut en bas :
- La barre de jeu : 🔥 12, graines d'or 340, niveau 7.
- La salutation « Bonjour Amina ! » avec Sipho content à droite.
- **Grande carte « Reste à vivre »** : une jauge circulaire épaisse et animée, verte aux deux tiers, avec au centre « 642 $ » en très gros et en dessous « reste pour novembre ». Sous la jauge, une ligne : « Revenu 2 800 $ · Fixes 1 690 $ · Dépensé 468 $ ».
- **Carte « Prochaine dépense fixe »** : Internet 📶 · 75 $ · demain, avec un bouton « Payé ✓ ».
- **Section « Quêtes du jour »** avec 3 lignes, chacune avec une icône, une barre de progression et une récompense en cadeau :
  - « Note 3 dépenses » (2/3) ;
  - « Fais une leçon » (0/1) ;
  - « Reste sous ton budget restos » (✓).
- **Carte économique du jour** : petite carte à bordure jaune avec la mention « 📈 Inflation alimentaire au Canada : 3,4 % », la phrase « ≈ +11 $/mois sur ton épicerie » et un lien « Lire (20 s) ».
- Le bouton flottant « + » et la navigation en bas.

### 9. Ajout express d'une dépense
Demi-écran (bottom sheet) avec un montant géant « 18,50 $ » et un clavier numérique géant. Au-dessus du clavier, une grille de 8 catégories en pastilles rondes, « Restos » sélectionné. À côté du bouton 3D « AJOUTER », une icône appareil photo « Scanner ».

### 10. Micro-récompense après l'ajout
Une petite animation au-dessus du bouton : « +5 XP », des pièces qui volent vers la pastille XP, et Sipho qui fait un pouce levé. Toast en bas : « Bien joué ! 2/3 pour ta quête. »

### 11. Scan de facture
- **11a. Caméra** : vue caméra avec un cadre aux coins arrondis et un rayon laser jaune qui balaie le ticket. Texte : « Place ta facture dans le cadre ». Gros bouton déclencheur rond.
- **11b. Validation** : en haut, une miniature du ticket. En dessous, des champs pré-remplis dans une carte :
  - Marchand « IGA » ;
  - Date « 10 nov. 2026 » ;
  - Total « 48,49 $ » ;
  - TPS 2,11 $, TVQ 4,21 $ ;
  - Catégorie « Épicerie 🛒 ».

  Un champ incertain est surligné en jaune avec la mention « À vérifier ». Sipho dit : « J'ai tout lu ! Vérifie juste la date. » Bouton 3D « VALIDER (+15 XP) ».

### 12. Dépenses du mois
- En haut, des onglets « Ce mois · Mon socle · Graphiques ».
- Sélecteur de mois « Novembre 2026 ».
- Liste groupée par jour, chaque ligne avec l'icône de catégorie, le marchand, une note et le montant à droite.
- Une étiquette « 📷 scanné » sur certaines lignes.
- Une ligne en devise étrangère : « 25,00 € → 36,80 $ ».

### 13. Mon socle (dépenses fixes)
- Illustration du nid de Sipho en haut.
- Un mini-calendrier du mois avec des points sur les jours d'échéance.
- Une liste de cartes, chacune avec un statut « Payé ✓ » (vert), « À venir » (gris) ou « Demain » (jaune) :
  - Loyer 950 $ (1er) ;
  - Internet 75 $ (15) ;
  - Électricité 60 $ (20) ;
  - Téléphone 45 $ (5) ;
  - Épicerie 400 $ (enveloppe, barre 62 %) ;
  - Transport 100 $ (enveloppe) ;
  - Famille / transferts 150 $.
- Total en bas : « Socle : 1 690 $/mois ».

### 14. Graphiques et budgets
- Un anneau de répartition par catégorie.
- Des barres de dépenses par jour.
- Une liste de budgets par catégorie avec des jauges horizontales :
  - Restos 85 % (jaune, icône ⚠️) ;
  - Shopping 40 % (vert) ;
  - Loisirs 95 % (rouge).
- Sipho inquiet à côté de « Loisirs » dit : « On ralentit un peu ? »
- Une phrase de résumé : « Tu as dépensé 12 % de moins que le mois dernier 🎉 ».

### 15. Apprendre : chemin de leçons
Un chemin vertical sinueux de gros boutons ronds en 3D, à la manière de Duolingo :
- les leçons terminées sont dorées avec une étoile ;
- la leçon actuelle est verte et pulse ;
- les leçons verrouillées sont grises.

Les bannières d'unité indiquent « Unité 1 : Les bases du budget » et « Unité 3 : Le CELI 🇨🇦 ». Sipho est assis à côté du chemin. En haut, la carte économique du jour.

### 16. Leçon : quiz
- Barre de progression en haut et bouton ✕.
- Question : « Où placer ton fonds d'urgence ? »
- Quatre réponses en grosses cartes, l'une sélectionnée avec une bordure bleue.
- Bouton 3D « VÉRIFIER ».
- Variante : un bandeau vert en bas « Excellent ! » avec Sipho content et le bouton « CONTINUER ».

### 17. Fin de leçon
Plein écran de célébration montrant :
- les stats en 3 cartes : « XP gagnés 30 », « Précision 100 % », « Temps 2:14 » ;
- Sipho en fête ;
- le bouton « CONTINUER ».

### 18. Série prolongée
Grosse flamme animée au centre avec « 13 » et le texte « jours de série ! ». Calendrier de la semaine avec des coches orange. Sipho fier. Bouton « CONTINUER ».

### 19. Cadeau de Sipho (coffre)
Une boîte cadeau emballée dans un tissu wax vert et jaune, avec un nœud, sur fond rayonnant. Texte : « Touche pour ouvrir ». Variante ouverte : « +50 graines d'or » et un « Gel de série ».

### 20. Classement : ligue de la semaine
- En-tête : badge « Ligue Or », « Se termine dans 2 j 5 h ».
- Une **zone de promotion** verte pour le top 7.
- Liste de 30 joueurs, chacun avec son rang, un avatar (une mascotte tisserin de couleurs variées), un pseudo et l'XP de la semaine. **Aucun montant d'argent.**
- La ligne de l'utilisateur, « Amina — 8e — 420 XP », est surlignée.
- Une **zone de relégation** rouge pour les 5 derniers.
- Onglets en haut : « Ligue · Amis · Mon pays ».

### 21. Profil
- Sipho et son nid personnalisé, avec un bouton « Boutique ».
- Le pseudo et la mention « Membre depuis nov. 2026 ».
- Une grille de statistiques : série record, XP total, ligue, leçons terminées.
- Une grille de badges, certains verrouillés.
- Une section « Mes objectifs » : « Voyage au Cameroun · 1 200 / 3 000 $ » avec une barre de progression.
- Un bouton « Inviter des amis ».

### 22. Boutique
Grille d'articles pour Sipho et son nid : chapeau, lunettes, écharpes wax de différentes couleurs, décorations du nid et « Gel de série ». Chaque article affiche son prix en graines d'or et un bouton « Acheter ».

### 23. Conseil personnalisé de Sipho
Carte avec Sipho qui tient une loupe. Texte : « Tes sorties au resto ont augmenté de 38 % ce mois-ci. » Proposition : « Quête : 2 repas maison de plus cette semaine (+50 XP) ». Boutons « ACCEPTER LA QUÊTE » et « Plus tard ». Petite mention en bas : « Contenu éducatif, pas un conseil financier personnalisé. »

### 24. Récap mensuel (style « Wrapped »)
Une série de 3 cartes verticales plein écran, colorées et animées :
- **24a.** « En octobre, tu as noté 64 dépenses 📝 » ;
- **24b.** « Ta plus belle progression : Restos −22 % » ;
- **24c.** « Tu t'es fait un cadeau de 142 $ d'économies 🎁 » avec Sipho en fête.

Bouton « Partager ». Indicateurs de pagination en haut, comme des stories.

### 25. Réglages des notifications et des sons
Une liste d'interrupteurs :
- Rappels de série ;
- Alertes budget ;
- Amis et ligue ;
- Conseils ;
- Actualité économique ;
- Récap mensuel ;
- Sons ;
- Vibrations ;
- Voix de Sipho.

Un sélecteur « Heure de rappel préférée : 19 h ».

---

## PARTIE 3 — Composants à créer dans la bibliothèque

- Bouton 3D : primaire, secondaire, désactivé, danger.
- Pastilles de la barre de jeu : flamme, graines, niveau.
- Carte dépense fixe : payé, à venir, demain, enveloppe.
- Ligne de transaction.
- Jauge circulaire « reste à vivre ».
- Jauge horizontale de budget : vert, jaune, rouge.
- Carte de quête avec progression et cadeau.
- Carte économique du jour.
- Bulle de dialogue de Sipho.
- Clavier numérique géant.
- Grille de catégories.
- Bouton de leçon rond (terminé, actuel, verrouillé).
- Ligne de classement.
- Navigation basse à 5 onglets.
- Bouton flottant « + ».
- Toast de récompense.
- Les **8 poses de Sipho** : content, fier, danse, inquiet, triste, endormi, en fête, salue.