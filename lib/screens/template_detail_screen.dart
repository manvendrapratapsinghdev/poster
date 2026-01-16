import '../controllers/layer_controller.dart';
import '../widgets/layer_stack.dart';
import '../widgets/layer_list_panel.dart';
import '../widgets/layer_toolbar.dart';
import '../models/layer_model.dart';
import '../widgets/gradient_background.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'face_position_screen.dart';
import 'package:social_post_mobile/config/api_config.dart';

final templateProvider = FutureProvider.family<Map<String, dynamic>, String>(
    (ref, templateId) async {
  final storage = const FlutterSecureStorage();
  final token = await storage.read(key: 'access_token');
  final dio = Dio();
  dio.options.headers['accept'] = 'application/json';
  dio.options.headers['Authorization'] = 'Bearer $token';
  final baseUrl = const String.fromEnvironment('BACKEND_BASE_URL',
      defaultValue: ApiConfig.backedBaseUrl);
  final resp = await dio.get('$baseUrl/api/v1/templates/$templateId');
  return resp.data;
});

final faceImageProvider = StateProvider<File?>((ref) => null);
final editedTemplateProvider = StateProvider<File?>((ref) => null);

class TemplateDetailScreen extends ConsumerWidget {
  static const routeName = '/template-detail';
  final String templateId;

  const TemplateDetailScreen({super.key, required this.templateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templateAsync = ref.watch(templateProvider(templateId));
    final faceImage = ref.watch(faceImageProvider);
    final editedImage = ref.watch(editedTemplateProvider);

    // --- LayerController integration ---
    final layerController = LayerController();
    final repaintKey = GlobalKey();
    final canvasSize = const Size(320, 320); // You can adjust as needed

    // --- Helper to update or add background layer ---
    void setBackgroundLayer(String imagePath, ImageSourceType sourceType) {
      final bgIdx = layerController.layers.indexWhere((l) => l.type == LayerType.background);
      if (bgIdx != -1) {
        final old = layerController.layers[bgIdx];
        layerController.removeLayer(old.id);
      }
      layerController.addLayer(LayerModel(
        id: UniqueKey().toString(),
        name: 'Background',
        type: LayerType.background,
        imageSourceType: sourceType,
        imagePath: imagePath,
        zIndex: 0,
      ));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: const Text('Graphics', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        actionsIconTheme: const IconThemeData(color: Colors.white70),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: GradientBackground(
        child: SafeArea(
          child: templateAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load template.'),
                  const SizedBox(height: 8),
                  Text(err.toString()),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => ref.refresh(templateProvider(templateId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (template) {
              final imageUrl = template['file_path'] ?? '';
              final name = template['name'] ?? '';
              final description = template['description'] ?? '';
              final tags = (template['tags'] as List?)?.cast<String>() ?? [];
              final facePosition = template['face_position'] ?? {'x': 0.4, 'y': 0.4, 'width': 0.2, 'height': 0.2};
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- LayerStack replaces main image area ---
                    Center(
                      child: LayerStack(
                        controller: layerController,
                        repaintKey: repaintKey,
                        canvasSize: canvasSize,
                      ),
                    ),
                    // --- LayerToolbar for selected layer controls ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LayerToolbar(controller: layerController),
                    ),
                    // --- LayerListPanel for layer selection/reorder ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        height: 200,
                        child: LayerListPanel(controller: layerController),
                      ),
                    ),
                    // --- Template info ---
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: tags.map((tag) => Chip(label: Text(tag, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.grey,)).toList(),
                          ),
                        ],
                      ),
                    ),
                    // --- Horizontal ListView of templates for background selection ---
                    SizedBox(
                      height: 130,
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: fetchTemplatesList(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Failed to load templates'));
                          }
                          final templates = snapshot.data ?? [];
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            itemCount: templates.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, idx) {
                              final t = templates[idx];
                              final thumbUrl = t['file_path'] ?? '';
                              return GestureDetector(
                                onTap: () => setBackgroundLayer(thumbUrl, ImageSourceType.network),
                                child: Container(
                                  width: 100,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: thumbUrl.isNotEmpty
                                        ? Image.network(
                                            thumbUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, size: 40),
                                          )
                                        : const Icon(Icons.image, size: 40, color: Colors.grey),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Theme.of(context).colorScheme.primary,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.layers),
            label: 'Add Template Layer',
            onTap: () {
              final template = ref.read(templateProvider(templateId)).maybeWhen(
                data: (t) => t,
                orElse: () => null,
              );
              if (template == null) return;
              final imageUrl = template['file_path'] ?? '';
              layerController.addLayer(LayerModel(
                id: UniqueKey().toString(),
                name: 'Template',
                type: LayerType.template,
                imageSourceType: ImageSourceType.network,
                imagePath: imageUrl,
                zIndex: layerController.layers.length,
              ));
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.face),
            label: 'Add Face Layer',
            onTap: () async {
              final picker = ImagePicker();
              final picked = await picker.pickImage(source: ImageSource.gallery);
              if (picked != null) {
                layerController.addLayer(LayerModel(
                  id: UniqueKey().toString(),
                  name: 'Face',
                  type: LayerType.face,
                  imageSourceType: ImageSourceType.file,
                  imagePath: picked.path,
                  zIndex: layerController.layers.length,
                ));
              }
            },
          ),
        ],
      ),
    );
  }
}

// Helper to fetch all templates for the horizontal list
Future<List<Map<String, dynamic>>> fetchTemplatesList() async {
  final storage = const FlutterSecureStorage();
  final token = await storage.read(key: 'access_token');
  final dio = Dio();
  dio.options.headers['accept'] = 'application/json';
  dio.options.headers['Authorization'] = 'Bearer $token';
  final baseUrl = const String.fromEnvironment('BACKEND_BASE_URL', defaultValue: ApiConfig.backedBaseUrl);
  final resp = await dio.get('$baseUrl/api/v1/templates');
  if (resp.statusCode == 200 && resp.data is List) {
    return List<Map<String, dynamic>>.from(resp.data);
  }
  return [];
}
