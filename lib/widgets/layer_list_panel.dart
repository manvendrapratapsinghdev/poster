import 'package:flutter/material.dart';
import '../controllers/layer_controller.dart';
import '../models/layer_model.dart';

class LayerListPanel extends StatelessWidget {
  final LayerController controller;

  const LayerListPanel({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final layers = controller.layers;

        if (layers.isEmpty) {
          return const Center(
            child: Text(
              'No layers added',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ReorderableListView.builder(
          itemCount: layers.length,
          onReorder: (oldIndex, newIndex) {
            // Prevent moving template layer from bottom (index 0)
            if (layers[oldIndex].type == LayerType.template && oldIndex == 0) {
              return;
            }

            // Template stays at index 0 - force other layers to index 1 or higher
            if (newIndex == 0) {
              newIndex = 1;
            }

            controller.moveLayer(oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            final layer = layers[index];
            final isSelected = controller.selectedId == layer.id;

            return ListTile(
              key: ValueKey(layer.id),
              leading: Icon(
                _getLayerIcon(layer.type),
                color: isSelected ? Colors.blue : Colors.grey,
              ),
              title: Text(
                layer.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              ),
              subtitle: Text(
                '${layer.type.name} • ${layer.visible ? "Visible" : "Hidden"}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      layer.visible ? Icons.visibility : Icons.visibility_off,
                      size: 16,
                    ),
                    onPressed: () => controller.toggleVisibility(layer.id),
                  ),
                  const Icon(Icons.drag_handle),
                ],
              ),
              selected: isSelected,
              onTap: () => controller.selectLayer(layer.id),
              tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
            );
          },
        );
      },
    );
  }

  IconData _getLayerIcon(LayerType type) {
    switch (type) {
      case LayerType.template:
        return Icons.layers;
      case LayerType.background:
        return Icons.image;
      case LayerType.face:
        return Icons.face;
      case LayerType.logo:
        return Icons.verified;
      default:
        return Icons.layers;
    }
  }
}
