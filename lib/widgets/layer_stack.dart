import 'package:flutter/material.dart';
import '../controllers/layer_controller.dart';
import '../widgets/layer_widget.dart';
import '../models/layer_model.dart';

class LayerStack extends StatelessWidget {
  final LayerController controller;
  final GlobalKey repaintKey;
  final Size canvasSize;

  const LayerStack({
    Key? key,
    required this.controller,
    required this.repaintKey,
    required this.canvasSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: canvasSize.width,
        height: canvasSize.height,
        color: Colors.white,
        child: Stack(
          children: [
            for (final layer in controller.layers)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => controller.selectLayer(layer.id),
                  child: LayerWidget(
                    model: layer,
                    selected: controller.selectedId == layer.id,
                    onTransformChange: (data) {
                      controller.updateTransform(
                        layer.id,
                        scale: data.scale,
                        rotation: data.rotation,
                        offset: data.offset,
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

