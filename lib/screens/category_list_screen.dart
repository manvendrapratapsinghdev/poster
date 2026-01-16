import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';

class CategoryListScreen extends StatelessWidget {
  static const routeName = '/categories';
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories', style: TextStyle(color: Colors.black87)),
        iconTheme: const IconThemeData(color: Colors.black),
        actionsIconTheme: const IconThemeData(color: Colors.transparent),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradientBackground(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: 8, // TODO: Replace with categories count
          itemBuilder: (context, i) => GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/api/v1/categories/',
                arguments: {'category': 'Category $i'}),
            child: Card(
              child: Center(child: Text('Category $i')),
            ),
          ),
        ),
      ),
    );
  }
}
