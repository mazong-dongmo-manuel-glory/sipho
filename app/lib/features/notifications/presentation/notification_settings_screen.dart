import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _streak = true;
  bool _budget = true;
  bool _fixed = true;
  bool _tips = true;
  bool _economy = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.cardRadius,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Rappels de série 🔥'),
                    subtitle: const Text('Garde ta flamme active'),
                    value: _streak,
                    onChanged: (val) => setState(() => _streak = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Alertes budget ⚠️'),
                    subtitle: const Text('Quand tu approches 80% d\'une catégorie'),
                    value: _budget,
                    onChanged: (val) => setState(() => _budget = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Échéances fixes 📅'),
                    subtitle: const Text('Rappels pour tes factures à payer'),
                    value: _fixed,
                    onChanged: (val) => setState(() => _fixed = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Conseils hebdomadaires 💡'),
                    subtitle: const Text('Recommandations Sipho personnalisées'),
                    value: _tips,
                    onChanged: (val) => setState(() => _tips = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Actualité économique 📈'),
                    subtitle: const Text('Taux directeur et inflation locale'),
                    value: _economy,
                    onChanged: (val) => setState(() => _economy = val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

