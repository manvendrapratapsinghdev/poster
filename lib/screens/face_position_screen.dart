import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';

class FacePositionScreen extends StatelessWidget {
  final String imageUrl;
  final Map<String, dynamic> initialPosition;
  const FacePositionScreen(
      {super.key, required this.imageUrl, required this.initialPosition});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,),
      body: GradientBackground(
        child: Center(child: Text('Face Position Editor (implement UI here)')),
      ),
    );
  }
}
