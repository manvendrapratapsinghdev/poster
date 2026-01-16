import 'package:flutter/material.dart';
import '../models/layer_model.dart';

class LayerWidget extends StatelessWidget {
  final LayerModel model;
  final bool selected;
  final ValueChanged<LayerTransformData> onTransformChange;

  const LayerWidget({
    Key? key,
    required this.model,
    required this.selected,
    required this.onTransformChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!model.visible) return const SizedBox.shrink();
    Widget imageWidget;
    switch (model.imageSourceType) {
      case ImageSourceType.file:
        imageWidget = Image.asset(model.imagePath, fit: BoxFit.contain);
        break;
      case ImageSourceType.network:
        imageWidget = Image.network(model.imagePath, fit: BoxFit.contain);
        break;
      case ImageSourceType.asset:
        imageWidget = Image.asset(model.imagePath, fit: BoxFit.contain);
        break;
    }
    Widget content = Opacity(
      opacity: model.opacity,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..translate(model.offset.dx, model.offset.dy)
          ..scale(model.scale)
          ..rotateZ(model.rotation),
        child: imageWidget,
      ),
    );
    if (selected) {
      content = Stack(
        children: [
          content,
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return content;
  }
}

class LayerTransformData {
  final double scale;
  final double rotation;
  final Offset offset;
  LayerTransformData({required this.scale, required this.rotation, required this.offset});
}

