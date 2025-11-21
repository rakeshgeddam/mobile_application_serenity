import 'package:flutter/material.dart';

class AppResponsiveContainer extends StatelessWidget {
  final Widget child;
  const AppResponsiveContainer({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final viewportHeight = media.size.height - media.padding.vertical;

    return SafeArea(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          // Ensure child fills at least the viewport height so inner Columns
          // and Spacer get finite constraints. This avoids infinite height
          // layout errors while keeping vertical scrolling when needed.
          constraints: BoxConstraints(minHeight: viewportHeight),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
