import 'package:flutter/material.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/app/theme/app_radius.dart';
import 'package:sipho/app/theme/app_spacing.dart';
import 'package:sipho/app/theme/app_text_styles.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  static const _items = [
    {'title': 'Gel de série 🧊', 'desc': 'Protège ta flamme si tu oublies un jour', 'price': '150'},
    {'title': 'Chapeau d\'explorateur 🤠', 'desc': 'Pour Sipho le tisserin', 'price': '200'},
    {'title': 'Écharpe Wax Soleil 🧣', 'desc': 'Motif kente jaune et vert', 'price': '300'},
    {'title': 'Nid Doré Majestueux 🪺', 'desc': 'Décoration spéciale pour ton nid', 'price': '500'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Boutique de Sipho 🌾'),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, i) {
            final item = _items[i];
            return Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.cardRadius,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title']!, style: AppTextStyles.bodySemiBold),
                        const SizedBox(height: 2),
                        Text(item['desc']!, style: AppTextStyles.labelSm),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: const StadiumBorder(),
                    ),
                    child: Text('${item['price']} 🌾'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

