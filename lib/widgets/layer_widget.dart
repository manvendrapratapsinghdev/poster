import 'package:flutter/material.dart';
import 'dart:io';
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
    if (model.imagePath.isEmpty) {
      imageWidget = const SizedBox.shrink();
    } else {
      switch (model.imageSourceType) {
        case ImageSourceType.file:
          final file = File(model.imagePath);
          imageWidget = FutureBuilder<bool>(
            future: file.exists(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox.shrink();
              }
              if (snapshot.data == true) {
                return Image.file(
                  file,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40),
                );
              } else {
                return const Icon(Icons.broken_image, size: 40);
              }
            },
          );
          break;
        case ImageSourceType.network:
          imageWidget = Image.network(
            model.imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40),
          );
          break;
        case ImageSourceType.asset:
          imageWidget = Image.asset(
            model.imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40),
          );
          break;
      }
    }

    // --- Drag logic ---
    Offset _dragStart = Offset.zero;
    Offset _dragOffset = model.offset;

    Widget draggableImage = GestureDetector(
      onPanStart: (details) {
        _dragStart = details.localPosition;
      },
      onPanUpdate: (details) {
        final delta = details.localPosition - _dragStart;
        _dragOffset = model.offset + delta;
        onTransformChange(LayerTransformData(
          scale: model.scale,
          rotation: model.rotation,
          offset: _dragOffset,
        ));
      },
      child: imageWidget,
    );

    Widget content = Opacity(
      opacity: model.opacity,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..translate(model.offset.dx, model.offset.dy)
          ..scale(model.scale)
          ..rotateZ(model.rotation),
        child: draggableImage,
      ),
    );

    // --- Arrow icons for manual move ---
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
