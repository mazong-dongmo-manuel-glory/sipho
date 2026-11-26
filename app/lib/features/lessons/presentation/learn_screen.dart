import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../core/firebase/cloud_functions_service.dart';
import '../../../core/theme/sipho_colors.dart';
import '../../../core/theme/sipho_palette.dart';
import '../../../core/theme/sipho_typography.dart';
import '../../../core/widgets/sipho_button_3d.dart';
import '../data/lesson_progress_provider.dart';
import '../domain/lesson_catalog.dart';

enum _LessonStatus { done, current, locked }

/// Frames 15a + 33–36 · Parcours unités (catalogue serveur).
class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  _LessonStatus _map(LessonUiStatus s) => switch (s) {
        LessonUiStatus.done => _LessonStatus.done,
        LessonUiStatus.current => _LessonStatus.current,
        LessonUiStatus.locked => _LessonStatus.locked,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fr = Localizations.localeOf(context).languageCode == 'fr';
    final progress = ref.watch(lessonProgressProvider);
    final notifier = ref.read(lessonProgressProvider.notifier);
    final currentId = notifier.currentLessonId;

    return Scaffold(
      backgroundColor: SiphoPalette.background(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Text(
              l10n.learnTitle,
              style: SiphoTypography.title.copyWith(
                fontSize: 28,
                color: SiphoPalette.textPrimary(context),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.learnPathLead,
              style: SiphoTypography.body.copyWith(
                fontSize: 16,
                color: SiphoPalette.textSecondary(context),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            for (final unit in kLessonCatalog) ...[
              _UnitHeader(label: fr ? unit.titleFr : unit.titleEn),
              const SizedBox(height: 12),
              for (var i = 0; i < unit.lessons.length; i++) ...[
                Builder(builder: (context) {
                  final lesson = unit.lessons[i];
                  final status = _map(notifier.statusFor(lesson.id));
                  final title = fr ? lesson.titleFr : lesson.titleEn;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LessonPathRow(
                      title: title,
                      subtitle: lesson.id == currentId ? l10n.learnYourTurn : null,
                      status: status,
                      indent: i.isOdd ? 74 : 4,
                      onTap: status == _LessonStatus.locked
                          ? null
                          : () => context.push('/lesson/card', extra: {
                                'id': lesson.id,
                                'title': title,
                              }),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 8),
            ],
            Text(
              '${progress.length} / ${kAllLessonIds.length}',
              style: SiphoTypography.label.copyWith(
                fontWeight: FontWeight.w700,
                color: SiphoPalette.textSecondary(context),
              ),
            ),
            const SizedBox(height: 16),
            SiphoButton3D(
              label: fr ? '✨ Défi IA Sipho' : '✨ Sipho AI challenge',
              variant: SiphoButtonVariant.secondary,
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      fr
                          ? 'Sipho prépare une leçon…'
                          : 'Sipho is preparing a lesson…',
                    ),
                  ),
                );
                final result = await ref
                    .read(cloudFunctionsServiceProvider)
                    .generateNextLesson(locale: fr ? 'fr' : 'en');
                if (!context.mounted) return;
                if (result['status'] == 'error') {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        result['message']?.toString() ??
                            l10n.authErrorGeneric,
                      ),
                      backgroundColor: SiphoColors.primaryDark,
                    ),
                  );
                  return;
                }
                if (result['reason'] == 'core_incomplete') {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        fr
                            ? 'Termine d’abord le parcours principal.'
                            : 'Finish the main path first.',
                      ),
                    ),
                  );
                  return;
                }
                final lesson = result['lesson'] as Map?;
                final title = lesson?['title']?.toString() ??
                    (fr ? 'Leçon IA' : 'AI lesson');
                final id = (result['lessonId'] ?? lesson?['id'] ?? 'ai')
                    .toString();
                context.push('/lesson/card', extra: {
                  'id': id,
                  'title': title,
                });
              },
            ),
            const SizedBox(height: 12),
            SiphoButton3D(
              label: fr
                  ? '🌍 Leçon pour mon pays'
                  : '🌍 Lesson for my country',
              variant: SiphoButtonVariant.secondary,
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      fr
                          ? 'Sipho prépare une leçon locale…'
                          : 'Sipho is preparing a local lesson…',
                    ),
                  ),
                );
                final result = await ref
                    .read(cloudFunctionsServiceProvider)
                    .generateCountryLessons(locale: fr ? 'fr' : 'en');
                if (!context.mounted) return;
                if (result['status'] == 'error') {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        result['message']?.toString() ??
                            l10n.authErrorGeneric,
                      ),
                      backgroundColor: SiphoColors.primaryDark,
                    ),
                  );
                  return;
                }
                if (result['generated'] == false &&
                    result['reused'] != true) {
                  final reason = result['reason']?.toString() ?? '';
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        reason == 'no_api_key'
                            ? (fr
                                ? 'IA indisponible pour le moment.'
                                : 'AI unavailable right now.')
                            : (fr
                                ? 'Impossible de générer la leçon pays.'
                                : 'Could not generate the country lesson.'),
                      ),
                    ),
                  );
                  return;
                }
                final lesson = result['lesson'] as Map?;
                final title = lesson?['title']?.toString() ??
                    (fr ? 'Leçon pays' : 'Country lesson');
                final id = (result['slotId'] ??
                        lesson?['slotId'] ??
                        lesson?['lessonId'] ??
                        'country')
                    .toString();
                context.push('/lesson/card', extra: {
                  'id': id,
                  'title': title,
                });
              },
            ),
            const SizedBox(height: 12),
            SiphoLessonFooter(
              onChest: () => context.push('/chest'),
              onQuiz: () {
                final id = currentId ?? kAllLessonIds.first;
                LessonDef? def;
                for (final u in kLessonCatalog) {
                  for (final l in u.lessons) {
                    if (l.id == id) def = l;
                  }
                }
                context.push('/quiz', extra: {
                  'id': id,
                  'title': fr ? (def?.titleFr ?? id) : (def?.titleEn ?? id),
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitHeader extends StatelessWidget {
  final String label;
  const _UnitHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: SiphoTypography.label.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: SiphoPalette.textSecondary(context),
        height: 1.3,
      ),
    );
  }
}

class SiphoLessonFooter extends StatelessWidget {
  final VoidCallback onChest;
  final VoidCallback onQuiz;

  const SiphoLessonFooter({
    super.key,
    required this.onChest,
    required this.onQuiz,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: onChest,
          child: Text(
            l10n.learnSeeChests,
            style: SiphoTypography.bodyBold.copyWith(
              color: SiphoPalette.textPrimary(context),
            ),
          ),
        ),
        TextButton(
          onPressed: onQuiz,
          child: Text(
            l10n.learnJumpQuiz,
            style: SiphoTypography.bodyBold.copyWith(
              color: SiphoPalette.textPrimary(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _LessonPathRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final _LessonStatus status;
  final double indent;
  final VoidCallback? onTap;

  const _LessonPathRow({
    required this.title,
    required this.status,
    this.subtitle,
    this.indent = 4,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: InkWell(
        onTap: status == _LessonStatus.locked ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            _LessonNode(status: status),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: SiphoTypography.bodyBold.copyWith(
                      fontSize: 16,
                      color: SiphoPalette.textPrimary(context),
                      height: 1.3,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: SiphoTypography.label.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: SiphoPalette.textPrimary(context),
                        height: 1.3,
                      ),
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

class _LessonNode extends StatelessWidget {
  final _LessonStatus status;

  const _LessonNode({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color face;
    late Color edge;
    late IconData icon;
    late Color iconColor;

    switch (status) {
      case _LessonStatus.done:
        face = SiphoColors.accentGold;
        edge = SiphoColors.accentGoldEdge;
        icon = Icons.star_rounded;
        iconColor = SiphoColors.lessonStarIcon;
      case _LessonStatus.current:
        face = SiphoColors.primary;
        edge = SiphoColors.primaryDark;
        icon = Icons.play_arrow_rounded;
        iconColor = Colors.white;
      case _LessonStatus.locked:
        face = SiphoColors.lessonLockedFace;
        edge = SiphoColors.lessonLockedEdge;
        icon = Icons.lock_rounded;
        iconColor = SiphoColors.lessonLockedIcon;
    }

    return SizedBox(
      width: 48,
      height: 52,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 3.2,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: edge, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: face, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
