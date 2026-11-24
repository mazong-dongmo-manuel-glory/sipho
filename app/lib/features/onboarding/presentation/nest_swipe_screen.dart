import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../../countries/data/countries_provider.dart';
import '../../countries/domain/country_pack.dart';

/// Frame 04 · Socle à glisser — items depuis `countries/{code}.defaultFixedExpenses`.
class NestSwipeScreen extends ConsumerStatefulWidget {
  const NestSwipeScreen({super.key});

  @override
  ConsumerState<NestSwipeScreen> createState() => _NestSwipeScreenState();
}

class _NestSwipeScreenState extends ConsumerState<NestSwipeScreen> {
  int _index = 0;
  int _woven = 0;

  List<({String id, String name, String emoji})> _buildItems(
    CountryPack pack,
    bool fr,
  ) {
    final ids = pack.defaultFixedExpenses.isNotEmpty
        ? pack.defaultFixedExpenses
        : const [
            'rent',
            'internet',
            'electricity',
            'phone',
            'groceries',
            'transport',
          ];
    return [
      for (final id in ids)
        () {
          final meta = fixedExpenseMeta(id);
          return (
            id: id,
            name: fr ? meta.labelFr : meta.labelEn,
            emoji: meta.emoji,
          );
        }(),
    ];
  }

  void _yes(List<({String id, String name, String emoji})> items) {
    if (items.isEmpty) return;
    final item = items[_index.clamp(0, items.length - 1)];
    context.push('/onboarding/nest/amount', extra: {
      'id': item.id,
      'name': item.name,
      'emoji': item.emoji,
    }).then((added) {
      if (added == true) setState(() => _woven++);
      _advance(items.length);
    });
  }

  void _no(int length) => _advance(length);

  void _advance(int length) {
    if (_index >= length - 1) {
      context.go('/onboarding/ready');
      return;
    }
    setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fr = Localizations.localeOf(context).languageCode == 'fr';
    final pack = ref.watch(userCountryPackProvider);
    final items = _buildItems(pack, fr);
    if (items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/onboarding/ready');
      });
      return Scaffold(backgroundColor: SiphoPalette.background(context));
    }
    final safeIndex = _index.clamp(0, items.length - 1);
    final item = items[safeIndex];

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      l10n.onboardingNestTitle,
                      style: SiphoTypography.title.copyWith(
                        fontSize: 28,
                        color: SiphoPalette.textPrimary(context),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.onboardingNestLead,
                      style: SiphoTypography.body.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 106,
                      height: 106,
                      child: SvgPicture.asset(
                        'assets/images/sipho_nest.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.onboardingNestStrands(_woven),
                      style: SiphoTypography.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SiphoSoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.socleAsk(item.name),
                            style: SiphoTypography.bodyBold.copyWith(
                              fontSize: 16,
                              color: SiphoPalette.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.onboardingNestHint,
                            style: SiphoTypography.body.copyWith(
                              fontSize: 16,
                              color: SiphoPalette.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: SiphoButton3D(
                      label: l10n.socleNo,
                      variant: SiphoButtonVariant.secondary,
                      onPressed: () => _no(items.length),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SiphoButton3D(
                      label: l10n.socleYes,
                      variant: SiphoButtonVariant.dark,
                      onPressed: () => _yes(items),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
