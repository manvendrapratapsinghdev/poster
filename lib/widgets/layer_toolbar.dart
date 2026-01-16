import 'package:flutter/material.dart';
import '../controllers/layer_controller.dart';

class LayerToolbar extends StatelessWidget {
  final LayerController controller;
  const LayerToolbar({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedLayer;
    if (selected == null) {
      return const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset',
              onPressed: () => controller.resetTransform(selected.id),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_upward),
              tooltip: 'Bring Forward',
              onPressed: () => controller.bringForward(selected.id),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward),
              tooltip: 'Send Backward',
              onPressed: () => controller.sendBackward(selected.id),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scale: ${selected.scale.toStringAsFixed(2)}'),
                  Slider(
                    value: selected.scale,
                    min: 0.2,
                    max: 3.0,
                    onChanged: (v) => controller.updateTransform(selected.id, scale: v),
                  ),
                  Text('Rotation: ${(selected.rotation * 57.2958).toStringAsFixed(1)}°'),
                  Slider(
                    value: selected.rotation,
                    min: -3.14,
                    max: 3.14,
                    onChanged: (v) => controller.updateTransform(selected.id, rotation: v),
                  ),
                  Text('Opacity: ${(selected.opacity * 100).toStringAsFixed(0)}%'),
                  Slider(
                    value: selected.opacity,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (v) => controller.setOpacity(selected.id, v),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(selected.visible ? Icons.visibility : Icons.visibility_off),
              tooltip: selected.visible ? 'Hide' : 'Show',
              onPressed: () => controller.toggleVisibility(selected.id),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Remove Layer',
              onPressed: () => controller.removeLayer(selected.id),
            ),
          ],
        ),
      ),
    );
  }
}

