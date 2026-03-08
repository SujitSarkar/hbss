import 'package:flutter/material.dart';

import 'package:maori_health/presentation/shared/widgets/loading_widget.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const .all(20),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: .circular(10)),
                  child: const LoadingWidget(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
