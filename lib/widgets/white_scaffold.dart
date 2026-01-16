import 'package:flutter/material.dart';

/// A reusable Scaffold with a white background.
/// Accepts optional appBar, body, bottomNavigationBar, floatingActionButton, bodyPadding, and drawer.
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

