import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Plays a bundled Lottie animation (see `SiphoLotties`).
///
/// - Respects the system "reduce animations" setting: nothing moves, the first frame is shown.
/// - A missing or corrupt file leaves an empty box of the same size instead of an error screen.
/// - Decorative: hidden from screen readers.
class LottieWidget extends StatelessWidget {
  const LottieWidget({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.animate = true,
    this.onLoaded,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool repeat;
  final bool animate;
  final void Function(LottieComposition)? onLoaded;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return ExcludeSemantics(
      child: Lottie.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        repeat: repeat && !reduce,
        animate: animate && !reduce,
        onLoaded: onLoaded,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('[Lottie] could not show $assetPath: $error');
          return SizedBox(width: width, height: height);
        },
      ),
    );
  }
}
