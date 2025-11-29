import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/providers/loading_provider.dart';

class LoadingOverlay extends ConsumerStatefulWidget {
  const LoadingOverlay({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends ConsumerState<LoadingOverlay> {
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);

    return Stack(
      children: [
        widget.child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
