import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({required this.child, this.scrollable = false, super.key});

  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    Widget buildChild(BuildContext context) {
      Widget effectiveChild = SafeArea(
        child: child,
      );

      if (scrollable) {
        effectiveChild = _ScrollableBackground(child: effectiveChild);
      }

      return effectiveChild;
    }

    return MediaQuery(
      data: mediaQuery.copyWith(
        padding: mediaQuery.padding +
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: buildChild(context),
      ),
    );
  }
}

class _ScrollableBackground extends StatelessWidget {
  const _ScrollableBackground({required this.child, super.key});

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
