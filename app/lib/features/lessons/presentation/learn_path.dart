import 'package:flutter/material.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/app/theme/app_colors.dart';
import 'package:sipho/core/widgets/sipho_art.dart';
import 'package:sipho/features/lessons/domain/lesson_catalog.dart';

const _font = 'Nunito';

/// Where a lesson stands on the path. Lessons are linear: only the next one is playable.
enum LessonNodeState { done, current, locked }

LessonNodeState lessonNodeState({
  required String lessonId,
  required Set<String> completed,
  required String? nextId,
}) {
  if (completed.contains(lessonId)) return LessonNodeState.done;
  if (lessonId == nextId) return LessonNodeState.current;
  return LessonNodeState.locked;
}

const _swing = [0.0, 0.55, 0.9, 0.55, 0.0, -0.55, -0.9, -0.55];

/// Horizontal position of the [index]-th node of a unit, from -1 (far left) to 1 (far right).
/// The nodes wind like a snake instead of standing in a column.
double pathNodeOffset(int index) => _swing[index % _swing.length];

/// Widest sideways shift of a node, in logical pixels.
const double kPathAmplitude = 64;
const double _nodeSize = 72;
const double _lipHeight = 7;

/// One unit of the path: its banner, its lesson nodes, then the end-of-unit gift.
class LearnUnitSection extends StatelessWidget {
  const LearnUnitSection({
    super.key,
    required this.progress,
    required this.completed,
    required this.nextId,
    required this.language,
    required this.onLessonTap,
    this.currentKey,
  });

  final UnitProgress progress;
  final Set<String> completed;
  final String? nextId;
  final String language;
  final void Function(CatalogLesson lesson, LessonNodeState state) onLessonTap;

  /// Attached to the current node so the screen can scroll to it.
  final GlobalKey? currentKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unit = progress.unit;
    return Column(
      children: [
        LearnUnitBanner(progress: progress, language: language),
        const SizedBox(height: 12),
        for (var i = 0; i < unit.lessons.length; i++)
          Builder(builder: (context) {
            final lesson = unit.lessons[i];
            final state = lessonNodeState(
              lessonId: lesson.id,
              completed: completed,
              nextId: nextId,
            );
            return LessonPathNode(
              key: ValueKey('path-node-${lesson.id}'),
              anchorKey: state == LessonNodeState.current ? currentKey : null,
              lesson: lesson,
              state: state,
              offset: pathNodeOffset(i),
              language: language,
              onTap: () => onLessonTap(lesson, state),
            );
          }),
        UnitGiftNode(
          reached: progress.completed,
          caption: l10n.learnUnitGiftLabel,
          reward: '+${unit.bonusXp} XP · +${unit.bonusSeeds} 🌾',
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

/// Header of a unit: number, title, subtitle, progress. Grey while the unit is locked.
class LearnUnitBanner extends StatelessWidget {
  const LearnUnitBanner({
    super.key,
    required this.progress,
    required this.language,
  });

  final UnitProgress progress;
  final String language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unit = progress.unit;
    final locked = !progress.unlocked;
    final background = locked ? AppColors.border : AppColors.primary;
    final titleColor = locked ? AppColors.textSecondary : Colors.white;
    final subColor = locked ? AppColors.textSecondary : AppColors.mint;
    final status = progress.completed
        ? l10n.learnUnitDone
        : locked
            ? '🔒  ${l10n.learnUnitLocked}'
            : null;

    return Semantics(
      container: true,
      label: '${l10n.learnUnitLabel(progress.index + 1)}. '
          '${unit.title(language)}. '
          '${l10n.learnUnitProgress(progress.done, progress.total)}',
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          boxShadow: locked
              ? null
              : const [
                  BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 4)),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.learnUnitLabel(progress.index + 1),
                    style: TextStyle(
                      fontFamily: _font,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: subColor,
                    ),
                  ),
                ),
                Text(
                  l10n.learnUnitProgress(progress.done, progress.total),
                  style: TextStyle(
                    fontFamily: _font,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: subColor,
                  ),
                ),
              ],
            ),
            Text(
              unit.title(language),
              style: TextStyle(
                fontFamily: _font,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: titleColor,
              ),
            ),
            Text(
              unit.subtitle.of(language),
              style: TextStyle(
                fontFamily: _font,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: subColor,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 8,
                child: Stack(
                  children: [
                    ColoredBox(
                      color: locked ? AppColors.surface : AppColors.primaryDark,
                    ),
                    FractionallySizedBox(
                      widthFactor: progress.ratio,
                      child: const ColoredBox(color: AppColors.accent),
                    ),
                  ],
                ),
              ),
            ),
            if (status != null) ...[
              const SizedBox(height: 6),
              Text(
                status,
                style: TextStyle(
                  fontFamily: _font,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: subColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A lesson on the path: a round 3D button, with the lesson's name and size under it.
class LessonPathNode extends StatelessWidget {
  const LessonPathNode({
    super.key,
    required this.lesson,
    required this.state,
    required this.offset,
    required this.language,
    required this.onTap,
    this.anchorKey,
  });

  final CatalogLesson lesson;
  final LessonNodeState state;
  final double offset;
  final String language;
  final VoidCallback onTap;
  final GlobalKey? anchorKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = state == LessonNodeState.current;
    final locked = state == LessonNodeState.locked;
    final stateLabel = switch (state) {
      LessonNodeState.done => l10n.learnDone,
      LessonNodeState.current => l10n.learnYourTurn,
      LessonNodeState.locked => l10n.learnLocked,
    };

    final node = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (current) ...[
          const _YourTurnBubble(),
          const SizedBox(height: 6),
        ],
        _RoundNode(state: state),
        const SizedBox(height: 8),
        SizedBox(
          width: 150,
          child: Column(
            children: [
              Text(
                '${lesson.emoji} ${lesson.title(language)}',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: _font,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color:
                      locked ? AppColors.textSecondary : AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${l10n.learnLessonMinutes(lesson.minutes)} · '
                '${l10n.learnLessonSteps(lesson.steps.length)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: _font,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    // Sipho stands on the side opposite to the node, next to the lesson to play.
    final siphoSide = offset > 0 ? -1.0 : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            if (current)
              Positioned.fill(
                child: Align(
                  alignment: Alignment(siphoSide, -0.2),
                  child:
                      const ExcludeSemantics(child: SiphoArt.happy(frame: 84)),
                ),
              ),
            Semantics(
              button: true,
              enabled: true,
              label: '${lesson.title(language)}. $stateLabel',
              excludeSemantics: true,
              onTap: onTap,
              child: GestureDetector(
                key: anchorKey,
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: Transform.translate(
                  offset: Offset(offset * kPathAmplitude, 0),
                  child: node,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundNode extends StatelessWidget {
  const _RoundNode({required this.state});

  final LessonNodeState state;

  @override
  Widget build(BuildContext context) {
    final (face, lip, icon, iconColor) = switch (state) {
      LessonNodeState.done => (
          AppColors.accent,
          AppColors.starLip,
          Icons.star_rounded,
          Colors.white,
        ),
      LessonNodeState.current => (
          AppColors.primary,
          AppColors.primaryDark,
          Icons.play_arrow_rounded,
          Colors.white,
        ),
      LessonNodeState.locked => (
          AppColors.border,
          AppColors.lockLip,
          Icons.lock_rounded,
          AppColors.lockIcon,
        ),
    };
    return SizedBox(
      width: _nodeSize,
      height: _nodeSize + _lipHeight,
      child: Stack(
        children: [
          Positioned(
            top: _lipHeight,
            child: Container(
              width: _nodeSize,
              height: _nodeSize,
              decoration: BoxDecoration(color: lip, shape: BoxShape.circle),
            ),
          ),
          Container(
            width: _nodeSize,
            height: _nodeSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: face, shape: BoxShape.circle),
            child: Icon(icon, size: 38, color: iconColor),
          ),
        ],
      ),
    );
  }
}

/// "Your turn" speech bubble above the current node; it bobs unless animations are reduced.
class _YourTurnBubble extends StatefulWidget {
  const _YourTurnBubble();

  @override
  State<_YourTurnBubble> createState() => _YourTurnBubbleState();
}

class _YourTurnBubbleState extends State<_YourTurnBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -4 * Curves.easeInOut.transform(_controller.value)),
        child: child,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: Text(
              l10n.learnYourTurn,
              style: const TextStyle(
                fontFamily: _font,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -6),
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    right: BorderSide(color: AppColors.border, width: 2),
                    bottom: BorderSide(color: AppColors.border, width: 2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The gift at the end of a unit: opens once all its lessons are done (the server pays it).
class UnitGiftNode extends StatelessWidget {
  const UnitGiftNode({
    super.key,
    required this.reached,
    required this.caption,
    required this.reward,
  });

  final bool reached;
  final String caption;
  final String reward;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$caption. $reward',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: reached ? AppColors.seedPill : AppColors.border,
                shape: BoxShape.circle,
                border: Border.all(
                  color: reached ? AppColors.accent : AppColors.lockLip,
                  width: 2,
                ),
              ),
              child: Opacity(
                opacity: reached ? 1 : 0.45,
                child: const Text('🎁', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              caption,
              style: TextStyle(
                fontFamily: _font,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color:
                    reached ? AppColors.primaryDark : AppColors.textSecondary,
              ),
            ),
            Text(
              reward,
              style: const TextStyle(
                fontFamily: _font,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
