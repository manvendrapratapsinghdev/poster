import 'package:flutter/material.dart';

/// A reusable Scaffold with a fullscreen linear gradient background.
///
/// - Gradient: #2E3192 → #662D8C → #ED1E79 (top-left to bottom-right)
/// - AppBar and BottomNavigationBar should be transparent (set backgroundColor: Colors.transparent, elevation: 0)
/// - Accepts optional appBar, body, and bottomNavigationBar.
class GradientScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final FloatingActionButton? floatingActionButton;
  final EdgeInsetsGeometry? bodyPadding;
  final Widget? drawer; // <-- Add drawer parameter

  const GradientScaffold({
    super.key,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.bodyPadding,
    this.drawer, // <-- Add drawer to constructor
  });

  @override
  Widget build(BuildContext context) {
    // NOTE: When using GradientScaffold, ensure any AppBar passed in has backgroundColor: Colors.transparent and elevation: 0 for best results.
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFFFFFFF),
                Color(0xFFFFFFFF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Scaffold with transparent background
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar,
          body: bodyPadding != null
              ? Padding(padding: bodyPadding!, child: body)
              : body,
          bottomNavigationBar: bottomNavigationBar != null
              ? Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.transparent,
                  ),
                  child: bottomNavigationBar!,
                )
              : null,
          floatingActionButton: floatingActionButton,
          drawer: drawer, // <-- Pass drawer to Scaffold
        ),
      ],
    );
  }
}

/// A reusable Scaffold with a white background.
///
/// - AppBar and BottomNavigationBar will have default styling.
/// - Accepts optional appBar, body, and bottomNavigationBar.
class WhiteScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final FloatingActionButton? floatingActionButton;
  final EdgeInsetsGeometry? bodyPadding;
  final Widget? drawer;

  const WhiteScaffold({
    super.key,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.bodyPadding,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      body: bodyPadding != null
          ? Padding(padding: bodyPadding!, child: body)
          : body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
    );
  }
}

// Export WhiteScaffold for use in other files
// export 'gradient_scaffold.dart' show WhiteScaffold;

