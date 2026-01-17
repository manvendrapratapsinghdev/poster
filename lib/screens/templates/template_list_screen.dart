import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/template_provider.dart';
import '../poster_screen.dart';
import '../../widgets/gradient_background.dart';
import '../widgets/image_overlay_card.dart';

// Provider to store currently selected strip URL
final selectedStripProvider = StateProvider<String?>((ref) => null);

class TemplateListScreen extends ConsumerWidget {
  final String categoryName;
  final String subcategoryName;
  const TemplateListScreen({
    required this.categoryName,
    required this.subcategoryName,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(
      templatesProvider(
        TemplateProviderParams(
          category: categoryName,
          subcategory: subcategoryName,
        ),
      ),
    );

    final selectedStripUrl = ref.watch(selectedStripProvider);

    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text(
          subcategoryName,
          style: const TextStyle(color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: GradientBackground(
        child: SafeArea(
          child: templatesAsync.when(
            data: (templates) {
              if (templates.isEmpty) {
                return const Center(child: Text('No templates found.'));
              }
              return Column(
                children: [
                  // -------- Grid of Templates --------
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: templates.length,
                      itemBuilder: (context, i) {
                        final template = templates[i];

                        // If a strip is selected → use it as foreground
                        final effectiveForegroundUrl = selectedStripUrl ??
                            template['foreground_url'] ??
                            template['overlay_url'] ??
                            '';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PosterScreen(
                                  templateId: template['_id'].toString(),
                                  initialBackgroundUrl: template['thumbnail_url'] ?? '',
                                  // pass templates for selection in poster screen in backgrounds
                                  backgrounds: templates.map((t) => t['thumbnail_url'] as String).toList(),
                                ),
                              ),
                            );
                          },
                          child: ImageOverlayCard(
                            backgroundUrl: template['thumbnail_url'] ?? '',
                            foregroundUrl: effectiveForegroundUrl,
                            topIcon: Icons.favorite_border,
                            onIconTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Selected template: ${template['name'] ?? ''}",
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // -------- Horizontal Template Strip --------
                  SizedBox(
                    height: 30,
                    child: Consumer(
                      builder: (context, ref, _) {
                        final stripsAsync = ref.watch(templateStripsProvider);
                        final selected = ref.watch(selectedStripProvider);

                        return stripsAsync.when(
                          data: (strips) {
                            if (strips.isEmpty) {
                              return const Center(
                                  child: Text('No template strips found'));
                            }
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: strips.length,
                              itemBuilder: (context, i) {
                                final strip = strips[i];
                                final stripUrl = strip['sample_file_url'];
                                final isSelected = selected == stripUrl;

                                return GestureDetector(
                                  onTap: () {
                                    // Toggle selection
                                    if (isSelected) {
                                      ref
                                          .read(selectedStripProvider.notifier)
                                          .state = null;
                                    } else {
                                      ref
                                          .read(selectedStripProvider.notifier)
                                          .state = stripUrl;
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Stack(
                                        children: [
                                          stripUrl != null
                                              ? Image.network(
                                            stripUrl,
                                            width: 100,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                stackTrace) =>
                                                Container(
                                                  width: 100,
                                                  height: 120,
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                      Icons.image,
                                                      size: 40),
                                                ),
                                          )
                                              : Container(
                                            width: 100,
                                            height: 120,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.image,
                                                size: 40),
                                          ),

                                          // Top-right tick icon for selection
                                          if (isSelected)
                                            Positioned(
                                              top: 6,
                                              right: 6,
                                              child: CircleAvatar(
                                                radius: 12,
                                                backgroundColor: Colors.white
                                                    .withOpacity(0.8),
                                                child: const Icon(
                                                  Icons.check,
                                                  color: Colors.green,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => const Center(
                              child: CircularProgressIndicator()),
                          error: (err, stack) =>
                              Center(child: Text('Error: $err')),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ),
    );
  }
}
