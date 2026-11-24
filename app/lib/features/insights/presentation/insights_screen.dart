import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../data/insights_provider.dart';

/// Frame 23 · Conseil · insight Firestore + `generateInsight`.
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  bool _busy = false;
  String _focusTopic = 'general';

  Future<void> _generate({required bool acceptQuest}) async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await ref.read(insightsProvider.notifier).refresh(
          acceptQuest: acceptQuest,
          focusTopic: _focusTopic,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    if (result['status'] == 'error') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Conseil indisponible'),
          backgroundColor: SiphoColors.primaryDark,
        ),
      );
    } else if (acceptQuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quête ajoutée pour la semaine'),
          backgroundColor: SiphoColors.primaryDark,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncInsight = ref.watch(insightsProvider);

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: asyncInsight.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => ListView(
                    children: [
                      Text(
                        'Conseil de Sipho',
                        style: SiphoTypography.title.copyWith(
                          fontSize: 28,
                          color: SiphoPalette.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Impossible de charger le conseil. Réessaie.',
                        style: SiphoTypography.body.copyWith(
                          color: SiphoPalette.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                  data: (insight) {
                    final title = insight?.title.isNotEmpty == true
                        ? insight!.title
                        : 'Conseil de Sipho';
                    final body = insight?.body.isNotEmpty == true
                        ? insight!.body
                        : 'Génère un conseil à partir de ton mois en cours.';
                    final action = insight?.actionStep ?? '';
                    return ListView(
                      children: [
                        Text(
                          'Conseil de Sipho',
                          style: SiphoTypography.title.copyWith(
                            fontSize: 28,
                            color: SiphoPalette.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 96,
                          height: 96,
                          child: SvgPicture.asset(
                            'assets/images/sipho_worried.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SiphoSoftCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: SiphoTypography.bodyBold.copyWith(
                                  fontSize: 16,
                                  color: SiphoPalette.textPrimary(context),
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                body,
                                style: SiphoTypography.body.copyWith(
                                  fontSize: 16,
                                  color: SiphoPalette.textPrimary(context),
                                  height: 1.3,
                                ),
                              ),
                              if (action.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  action,
                                  style: SiphoTypography.body.copyWith(
                                    fontSize: 16,
                                    color: SiphoPalette.textPrimary(context),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (insight?.recommendedLessonId != null) ...[
                          const SizedBox(height: 12),
                          SiphoListRow(
                            title: 'Leçon suggérée',
                            trailing: insight!.recommendedLessonId!,
                            showChevron: true,
                            onTap: () => context.push('/learn'),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final topic in const [
                              ('general', 'Vue d\'ensemble'),
                              ('spending', 'Dépenses'),
                              ('fixed', 'Socle'),
                              ('goal', 'Objectif'),
                            ])
                              ChoiceChip(
                                label: Text(topic.$2),
                                selected: _focusTopic == topic.$1,
                                onSelected: _busy
                                    ? null
                                    : (_) =>
                                        setState(() => _focusTopic = topic.$1),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Contenu éducatif, pas un conseil financier personnalisé.',
                          style: SiphoTypography.label.copyWith(
                            fontWeight: FontWeight.w700,
                            color: SiphoPalette.textSecondary(context),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SiphoButton3D(
                label: _busy ? '…' : 'Accepter la quête',
                variant: SiphoButtonVariant.dark,
                onPressed: _busy ? null : () => _generate(acceptQuest: true),
              ),
              const SizedBox(height: 10),
              SiphoButton3D(
                label: _busy ? '…' : 'Nouveau conseil',
                variant: SiphoButtonVariant.outline,
                onPressed: _busy ? null : () => _generate(acceptQuest: false),
              ),
              const SizedBox(height: 10),
              SiphoButton3D(
                label: 'Plus tard',
                variant: SiphoButtonVariant.outline,
                onPressed: () {
                  final insight = asyncInsight.valueOrNull;
                  if (insight != null) {
                    ref.read(insightsProvider.notifier).dismiss(insight.id);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
