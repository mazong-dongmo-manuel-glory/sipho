import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../features/gamification/data/game_state_provider.dart';
import '../../features/profile/domain/shop_catalog.dart';
import '../theme/sipho_palette.dart';
import '../theme/sipho_typography.dart';

/// Affiche Sipho + cosmétiques équipés (`game/state.equippedItems`).
class SiphoMascot extends ConsumerWidget {
  final double size;
  final String moodAsset;
  final bool showEquipped;

  const SiphoMascot({
    super.key,
    this.size = 110,
    this.moodAsset = 'assets/images/sipho_happy.svg',
    this.showEquipped = true,
  });

  static String emojiFor(String itemId) => switch (itemId) {
        'sun_hat' => '👒',
        'cool_glasses' => '🕶️',
        'scarf_green' => '🧣',
        'scarf_clay' => '🧣',
        'flowered_nest' => '🌸',
        _ => '✨',
      };

  static String _chipLabel(BuildContext context, String id) {
    final fr = Localizations.localeOf(context).languageCode == 'fr';
    for (final item in kShopItems) {
      if (item.id == id) {
        return '${emojiFor(id)} ${fr ? item.labelFr : item.labelEn}';
      }
    }
    return '${emojiFor(id)} $id';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipped = showEquipped
        ? ref.watch(gameStateProvider).equippedItems
        : const <String>[];
    final asset = equipped.contains('flowered_nest')
        ? 'assets/images/sipho_nest.svg'
        : moodAsset;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: SvgPicture.asset(asset, fit: BoxFit.contain),
        ),
        if (equipped.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final id in equipped)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SiphoPalette.softSurface(context),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _chipLabel(context, id),
                    style: SiphoTypography.label.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: SiphoPalette.textPrimary(context),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
