import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/firebase/cloud_functions_service.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../../../core/widgets/sipho_list_row.dart';

/// Frame 17 · Leçon terminée · `completeLesson` avec le vrai lessonId.
class LessonDoneScreen extends ConsumerStatefulWidget {
  final String lessonId;
  final int xp;
  final bool perfect;
  final int durationSeconds;

  const LessonDoneScreen({
    super.key,
    this.lessonId = 'emergency_fund',
    this.xp = 30,
    this.perfect = true,
    this.durationSeconds = 134,
  });

  @override
  ConsumerState<LessonDoneScreen> createState() => _LessonDoneScreenState();
}

class _LessonDoneScreenState extends ConsumerState<LessonDoneScreen> {
  bool _sent = false;
  int _awardedXp = 0;

  @override
  void initState() {
    super.initState();
    _awardedXp = widget.xp;
    WidgetsBinding.instance.addPostFrameCallback((_) => _submit());
  }

  Future<void> _submit() async {
    if (_sent) return;
    _sent = true;
    final result = await ref.read(cloudFunctionsServiceProvider).completeLesson(
          lessonId: widget.lessonId,
          score: widget.perfect ? 100 : 70,
          durationSeconds: widget.durationSeconds < 2 ? 2 : widget.durationSeconds,
        );
    if (!mounted) return;
    final serverXp = (result['xpGained'] as num?)?.toInt() ??
        (result['xp'] as num?)?.toInt();
    if (serverXp != null) {
      setState(() => _awardedXp = serverXp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = widget.durationSeconds ~/ 60;
    final seconds = (widget.durationSeconds % 60).toString().padLeft(2, '0');

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
                      'Leçon terminée',
                      style: SiphoTypography.title.copyWith(
                        fontSize: 28,
                        color: SiphoPalette.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: SvgPicture.asset(
                        'assets/images/sipho_celebrating.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SiphoListRow(title: 'XP gagnés', trailing: '$_awardedXp'),
                    const SiphoSeparator(),
                    SiphoListRow(
                      title: 'Précision',
                      trailing: widget.perfect ? '100 %' : '70 %',
                    ),
                    const SiphoSeparator(),
                    SiphoListRow(title: 'Temps', trailing: '$minutes:$seconds'),
                  ],
                ),
              ),
              SiphoButton3D(
                label: 'Continuer',
                variant: SiphoButtonVariant.dark,
                onPressed: () => context.go('/learn'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
