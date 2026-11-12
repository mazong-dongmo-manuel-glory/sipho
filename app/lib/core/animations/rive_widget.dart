import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveWidget extends StatelessWidget {
  const RiveWidget({
    super.key,
    required this.assetPath,
    this.artboard,
    this.stateMachineName,
    this.animationName,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.onInit,
  });

  final String assetPath;
  final String? artboard;
  final String? stateMachineName;
  final String? animationName;
  final BoxFit fit;
  final Alignment alignment;
  final void Function(Artboard)? onInit;

  @override
  Widget build(BuildContext context) {
    return RiveAnimation.asset(
      assetPath,
      artboard: artboard,
      stateMachines: stateMachineName != null ? [stateMachineName!] : [],
      animations: animationName != null ? [animationName!] : [],
      fit: fit,
      alignment: alignment,
      onInit: onInit,
    );
  }
}
