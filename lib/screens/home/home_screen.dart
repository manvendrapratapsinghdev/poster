// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../providers/category_provider.dart';
// import '../templates/template_list_screen.dart' as templates;
//
// class HomeScreen extends ConsumerWidget {
//   const HomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final categoriesAsync = ref.watch(categoriesProvider);
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Categories===========', style: TextStyle(color: Colors.white)),
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: categoriesAsync.when(
//         data: (categories) {
//           if (categories.isEmpty) {
//             return const Center(child: Text('No categories found.'));
//           }
//           return GridView.builder(
//             padding: const EdgeInsets.all(16),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//               childAspectRatio: 1,
//             ),
//             itemCount: categories.length,
//             itemBuilder: (context, i) {
//               final category = categories[i];
//               return GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => SubcategoryScreen(
//                         categoryId: category['id'].toString(),
//                         categoryName: category['name'] ?? '',
//                       ),
//                     ),
//                   );
//                 },
//                 child: Card(
//                   elevation: 3,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         category['image'] != null
//                             ? Image.network(category['image'], height: 60)
//                             : const Icon(Icons.category, size: 60),
//                         const SizedBox(height: 12),
//                         Text(
//                           category['name'] ?? '',
//                           style: Theme.of(context).textTheme.titleMedium,
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, stack) => Center(child: Text('Error: $err')),
//       ),
//     );
//   }
// }
//
// class SubcategoryScreen extends ConsumerWidget {
//   final String categoryId;
//   final String categoryName;
//   const SubcategoryScreen(
//       {required this.categoryId, required this.categoryName, super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final subcategoriesAsync = ref.watch(subcategoryProvider(categoryId));
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(categoryName, style: const TextStyle(color: Colors.white)),
//         iconTheme: const IconThemeData(color: Colors.white),
//         actionsIconTheme: const IconThemeData(color: Colors.transparent),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: subcategoriesAsync.when(
//         data: (subcategories) {
//           if (subcategories.isEmpty) {
//             return const Center(child: Text('No subcategories found.'));
//           }
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: subcategories.length,
//             itemBuilder: (context, i) {
//               final sub = subcategories[i];
//               return Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: ListTile(
//                   title: Text(sub['name'] ?? ''),
//                   subtitle: sub['tags'] != null
//                       ? Wrap(
//                           spacing: 6,
//                           children: List<Widget>.from(
//                             (sub['tags'] as List).map(
//                                 (tag) => Chip(label: Text(tag.toString()))),
//                           ),
//                         )
//                       : null,
//                   onTap: () {
//                     // Import TemplateListScreen only when needed
//                     // ignore: unused_import
//
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => templates.TemplateListScreen(
//                           categoryName: categoryName,
//                           subcategoryName: sub['name'] ?? '',
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, stack) => Center(child: Text('Error: $err')),
//       ),
//     );
//   }
// }
