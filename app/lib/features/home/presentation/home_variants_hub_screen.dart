import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../../core/widgets/sipho_page_header.dart';

/// Hub QA pour les frames Accueil 61–66 / 83 et Dépenses 67–69.
class HomeVariantsHubScreen extends StatelessWidget {
  const HomeVariantsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[
      ('Accueil · Vide', '/home/empty'),
      ('Accueil · Chargement', '/home/loading'),
      ('Accueil · Erreur', '/home/error'),
      ('Accueil · Juste', '/home/tight'),
      ('Accueil · Sous zéro', '/home/under-zero'),
      ('Retour après pause', '/home/welcome-back'),
      ('Accueil · Bien joué', '/home/well-done'),
      ('Accueil · Sombre', '/home/dark'),
      ('Dépenses · Vide', '/expenses/empty'),
      ('Dépenses · Erreur', '/expenses/error'),
      ('Dépenses · Chargement', '/expenses/loading'),
      ('Dépenses · Sombre', '/expenses/dark'),
      ('Suivi récompensé', '/expenses/reward'),
      ('Quiz · Bonne réponse', '/quiz/correct'),
      ('Cadeau ouvert', '/chest/opened'),
      ('Série · Coup de main', '/streak/help'),
      ('Récap · Série', '/recap?page=3'),
      ('Graphiques · Jours', '/charts/days'),
      ('Graphiques · Six mois', '/charts/six-months'),
      ('Android · Accueil', '/android/home'),
      ('Android · Dépenses', '/android/expenses'),
      ('Android · Apprendre', '/android/learn'),
      ('English · Home', '/en/home'),
      ('English · Expenses', '/en/expenses'),
      ('English · Learn', '/en/learn'),
    ];

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            const SiphoPageHeader(
              title: 'États maquettes',
              lead: 'Frames 61–69 et 83 · pour validation visuelle.',
            ),
            const SizedBox(height: 20),
            for (final item in items) ...[
              SiphoListRow(
                title: item.$1,
                showChevron: true,
                onTap: () => context.push(item.$2),
              ),
              const SiphoSeparator(),
            ],
          ],
        ),
      ),
    );
  }
}
