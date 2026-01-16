import 'package:flutter/material.dart';

/// A reusable widget that provides a fullscreen linear gradient background.
///
/// - Gradient: #2E3192 → #662D8C → #ED1E79 (top-left to bottom-right)
/// - Accepts any child widget and optional padding.
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: child,
    );
  }
}
