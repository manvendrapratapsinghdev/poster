import 'dart:ui';
import 'package:flutter/material.dart';

/// Enum for image source type
enum ImageSourceType { file, network, asset }

/// Model for a single layer in the stack
class LayerModel {
  final String id;
  final String name;
  final LayerType type;
  final ImageSourceType imageSourceType;
  final String imagePath;
  bool visible;
  double scale;
  double rotation;
  Offset offset;
  double opacity;
  int zIndex;

  LayerModel({
    required this.id,
    required this.name,
    required this.type,
    required this.imageSourceType,
    required this.imagePath,
    this.visible = true,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.offset = Offset.zero,
    this.opacity = 1.0,
    required this.zIndex,
  });

  LayerModel copyWith({
    String? id,
    String? name,
    LayerType? type,
    ImageSourceType? imageSourceType,
    String? imagePath,
    bool? visible,
    double? scale,
    double? rotation,
    Offset? offset,
    double? opacity,
    int? zIndex,
  }) {
    return LayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      imageSourceType: imageSourceType ?? this.imageSourceType,
      imagePath: imagePath ?? this.imagePath,
      visible: visible ?? this.visible,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      offset: offset ?? this.offset,
      opacity: opacity ?? this.opacity,
      zIndex: zIndex ?? this.zIndex,
    );
  }
}

/// Enum for layer type
enum LayerType {
  background,
  template,
  face,
  logo,
  custom,
}

