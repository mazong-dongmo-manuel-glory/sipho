import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/firebase/cloud_functions_service.dart';
import '../../../core/feedback/feedback_cue.dart';
import '../../../core/feedback/feedback_service.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';
import '../data/quests_provider.dart';

/// Frames 19a / 19b · Cadeau · claim d’une quête `completed`.
class ChestScreen extends ConsumerStatefulWidget {
  final bool initialOpened;

  const ChestScreen({super.key, this.initialOpened = false});

  @override
  ConsumerState<ChestScreen> createState() => _ChestScreenState();
}

class _ChestScreenState extends ConsumerState<ChestScreen> {
  late bool _opened;
  bool _busy = false;
  int _seeds = 0;
  int _xp = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _opened = widget.initialOpened;
  }

  Future<void> _open() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final claimable = ref
        .read(questsProvider)
        .where((q) => q.status == 'completed')
        .toList();
    if (claimable.isEmpty) {
      setState(() {
        _busy = false;
        _error = 'Aucune quête à réclamer pour le moment.';
      });
      return;
    }
    final quest = claimable.first;
    final result =
        await ref.read(cloudFunctionsServiceProvider).claimQuest(questId: quest.id);
    if (!mounted) return;
    if (result['status'] == 'error') {
      setState(() {
        _busy = false;
        _error = 'Récompense indisponible pour le moment.';
      });
      ref.read(feedbackServiceProvider).play(SiphoCue.softError);
      return;
    }
    setState(() {
      _opened = true;
      _busy = false;
      _seeds = (result['gemsGained'] as num?)?.toInt() ??
          (result['seeds'] as num?)?.toInt() ??
          (result['gems'] as num?)?.toInt() ??
          0;
      _xp = (result['xpGained'] as num?)?.toInt() ??
          (result['xp'] as num?)?.toInt() ??
          0;
    });
    ref.read(feedbackServiceProvider).play(SiphoCue.giftOpened);
  }

  @override
  Widget build(BuildContext context) {
    final claimableCount =
        ref.watch(questsProvider).where((q) => q.status == 'completed').length;

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      _opened ? 'Un cadeau bien mérité !' : 'Une surprise pour toi',
                      style: SiphoTypography.title.copyWith(
                        fontSize: 28,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _opened
                          ? 'Chaque petit effort compte.'
                          : claimableCount > 0
                              ? 'Tu as $claimableCount quête(s) à ouvrir.'
                              : 'Termine une quête pour débloquer ton cadeau.',
                      style: SiphoTypography.body.copyWith(
                        fontSize: 16,
                        color: SiphoPalette.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: SvgPicture.asset(
                          _opened
                              ? 'assets/images/gift_inside.svg'
                              : 'assets/images/gift_box.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_error != null)
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: SiphoTypography.bodyBold.copyWith(
                          color: SiphoColors.accentTerra,
                        ),
                      )
                    else if (!_opened)
                      Text(
                        'Touche pour ouvrir',
                        textAlign: TextAlign.center,
                        style: SiphoTypography.bodyBold.copyWith(
                          fontSize: 16,
                          color: SiphoPalette.textPrimary(context),
                        ),
                      )
                    else ...[
                      SiphoListRow(title: 'Graines d’or', trailing: '+$_seeds'),
                      const SiphoSeparator(),
                      SiphoListRow(title: 'XP', trailing: '+$_xp'),
                    ],
                  ],
                ),
              ),
              SiphoButton3D(
                label: _busy
                    ? '…'
                    : _opened
                        ? 'Super, merci Sipho !'
                        : 'Ouvrir mon cadeau',
                variant: SiphoButtonVariant.dark,
                onPressed: _busy
                    ? null
                    : _opened
                        ? () => context.go('/learn')
                        : _open,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
