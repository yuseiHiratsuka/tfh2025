import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({
    required this.child,
    this.scrollable = false,
    this.gradient,
    super.key,
  });

  final Widget child;
  final bool scrollable;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveGradient = gradient ??
        LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        );

    Widget buildChild(BuildContext context) {
      Widget effectiveChild = SafeArea(
        child: child,
      );

      if (scrollable) {
        effectiveChild = _ScrollableBackground(child: effectiveChild);
      }

      return effectiveChild;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: effectiveGradient,
      ),
      child: buildChild(context),
    );
  }
}

class _ScrollableBackground extends StatelessWidget {
  const _ScrollableBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
