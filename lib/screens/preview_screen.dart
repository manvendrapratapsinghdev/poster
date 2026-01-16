// PreviewScreen: shows exported image, allows save/share
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class PreviewScreen extends StatelessWidget {
  final File imageFile;
  const PreviewScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Post')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(imageFile, width: 300, height: 300, fit: BoxFit.contain),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  onPressed: () async {
                    // Saving logic can be added here (gallery, etc.)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Image saved to temp directory.')),
                    );
                  },
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  onPressed: () async {
                    await Share.shareXFiles([XFile(imageFile.path)], text: 'Check out my post!');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

