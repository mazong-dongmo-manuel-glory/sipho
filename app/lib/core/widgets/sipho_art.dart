import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A Sipho illustration placed in its Figma frame.
///
/// [width] and [height] are the SVG root size at [referenceFrame].
/// Smaller frames scale that artwork uniformly.
class SiphoArt extends StatelessWidget {
  const SiphoArt({
    super.key,
    required this.asset,
    required this.frame,
    required this.referenceFrame,
    required this.width,
    required this.height,
    required this.left,
    required this.top,
    this.semanticsLabel = 'Sipho',
  });

  const SiphoArt.happy(
      {super.key, this.frame = 240, this.semanticsLabel = 'Sipho'})
      : asset = 'assets/images/sipho_happy.svg',
        referenceFrame = 240,
        width = 179.095,
        height = 216,
        left = 30.456,
        top = 12;

  const SiphoArt.waving(
      {super.key, this.frame = 240, this.semanticsLabel = 'Sipho'})
      : asset = 'assets/images/sipho_waving.svg',
        referenceFrame = 240,
        width = 218.113,
        height = 197.495,
        left = 9.883,
        top = 20.881;

  const SiphoArt.proud(
      {super.key, this.frame = 104, this.semanticsLabel = 'Sipho'})
      : asset = 'assets/images/sipho_proud.svg',
        referenceFrame = 104,
        width = 89.5051,
        height = 93.6,
        left = 7.2488,
        top = 5.2;

  const SiphoArt.worried(
      {super.key, this.frame = 65, this.semanticsLabel = 'Sipho'})
      : asset = 'assets/images/sipho_worried.svg',
        referenceFrame = 65,
        width = 47.8106,
        height = 58.5,
        left = 8.593,
        top = 3.25;

  const SiphoArt.celebrating(
      {super.key, this.frame = 271, this.semanticsLabel = 'Sipho'})
      : asset = 'assets/images/sipho_celebrating.svg',
        referenceFrame = 271,
        width = 246.068,
        height = 222.22,
        left = 11.38,
        top = 24.39;

  const SiphoArt.sleeping(
      {super.key, this.frame = 61, this.semanticsLabel = 'Sipho'})
      : asset = 'assets/images/sipho_sleeping.svg',
        referenceFrame = 61,
        width = 53.3014,
        height = 54.9,
        left = 3.849,
        top = 3.05;

  final String asset;
  final double frame;
  final double referenceFrame;
  final double width;
  final double height;
  final double left;
  final double top;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final scale = frame / referenceFrame;
    return SizedBox(
      width: frame,
      height: frame,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: left * scale,
            top: top * scale,
            child: SvgPicture.asset(
              asset,
              width: width * scale,
              height: height * scale,
              semanticsLabel: semanticsLabel,
            ),
          ),
        ],
      ),
    );
  }
}

/// Green primary face with the deep-green lip from the Figma button.
const figmaButtonRadius = BorderRadius.all(Radius.circular(16));
