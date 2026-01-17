import 'package:flutter/material.dart';
import '../controllers/layer_controller.dart';
import '../models/layer_model.dart';

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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
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
              Container(
                width: 320, // Set a fixed width for the controls
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.zoom_out),
                          tooltip: 'Zoom Out',
                          onPressed: () {
                            double newScale = selected.scale - 0.05;
                            if (newScale < 0.2) newScale = 0.2;
                            controller.updateTransform(selected.id, scale: newScale);
                          },
                        ),
                        Text('Scale: ${selected.scale.toStringAsFixed(2)}'),
                        IconButton(
                          icon: const Icon(Icons.zoom_in),
                          tooltip: 'Zoom In',
                          onPressed: () {
                            double newScale = selected.scale + 0.05;
                            if (newScale > 3.0) newScale = 3.0;
                            controller.updateTransform(selected.id, scale: newScale);
                          },
                        ),
                      ],
                    ),
                    // Arrow buttons for layer movement
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 4,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_left),
                          onPressed: () {
                            final targetLayer = selected.type == LayerType.template
                              ? selected
                              : controller.layers.firstWhere((l) => l.type == LayerType.template, orElse: () => selected);
                            final offset = targetLayer.offset + const Offset(-10, 0);
                            controller.updateTransform(targetLayer.id, offset: offset);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_upward),
                          onPressed: () {
                            final targetLayer = selected.type == LayerType.template
                              ? selected
                              : controller.layers.firstWhere((l) => l.type == LayerType.template, orElse: () => selected);
                            final offset = targetLayer.offset + const Offset(0, -10);
                            controller.updateTransform(targetLayer.id, offset: offset);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_downward),
                          onPressed: () {
                            final targetLayer = selected.type == LayerType.template
                              ? selected
                              : controller.layers.firstWhere((l) => l.type == LayerType.template, orElse: () => selected);
                            final offset = targetLayer.offset + const Offset(0, 10);
                            controller.updateTransform(targetLayer.id, offset: offset);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_right),
                          onPressed: () {
                            final targetLayer = selected.type == LayerType.template
                              ? selected
                              : controller.layers.firstWhere((l) => l.type == LayerType.template, orElse: () => selected);
                            final offset = targetLayer.offset + const Offset(10, 0);
                            controller.updateTransform(targetLayer.id, offset: offset);
                          },
                        ),
                      ],
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
      ),
    );
  }
}
