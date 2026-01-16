import 'package:flutter/material.dart';
import '../controllers/layer_controller.dart';
import '../models/layer_model.dart';

class LayerListPanel extends StatelessWidget {
  final LayerController controller;
  const LayerListPanel({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      shrinkWrap: true,
      onReorder: (oldIndex, newIndex) => controller.reorderLayers(oldIndex, newIndex),
      children: [
        for (final layer in controller.layers)
          ListTile(
            key: ValueKey(layer.id),
            leading: Icon(_iconForType(layer.type)),
            title: Text(layer.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(layer.visible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => controller.toggleVisibility(layer.id),
                ),
                if (controller.selectedId == layer.id)
                  const Icon(Icons.check, color: Colors.blue),
              ],
            ),
            selected: controller.selectedId == layer.id,
            onTap: () => controller.selectLayer(layer.id),
          ),
      ],
    );
  }

  IconData _iconForType(LayerType type) {
    switch (type) {
      case LayerType.background:
        return Icons.image;
      case LayerType.template:
        return Icons.layers;
      case LayerType.face:
        return Icons.face;
      case LayerType.logo:
        return Icons.verified;
      case LayerType.custom:
      default:
        return Icons.photo;
    }
  }
}

