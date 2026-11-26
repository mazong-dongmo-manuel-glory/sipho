import 'package:flutter/material.dart';

/// Column that fills the viewport and scrolls when the content is taller.
///
/// Landscape phones are short. A [Spacer] still pins the last actions to the
/// bottom when there is room, and the page scrolls instead of painting text
/// outside the screen.
class SiphoFillScroll extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;

  const SiphoFillScroll({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: crossAxisAlignment,
                  children: children,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
