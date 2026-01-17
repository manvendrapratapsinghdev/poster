import 'package:flutter/material.dart';
import 'dart:math';
import '../models/layer_model.dart';
import 'package:collection/collection.dart';

class LayerController extends ChangeNotifier {
  final List<LayerModel> _layers = [];
  String? _selectedId;

  List<LayerModel> get layers => List.unmodifiable(_layers..sort((a, b) => a.zIndex.compareTo(b.zIndex)));
  String? get selectedId => _selectedId;
  LayerModel? get selectedLayer =>
      _layers.firstWhereOrNull((l) => l.id == _selectedId);

  void addLayer(LayerModel layer) {
    if (_layers.length >= 10) return;
    _layers.add(layer);
    _selectedId = layer.id;
    notifyListeners();
  }

  void removeLayer(String id) {
    _layers.removeWhere((l) => l.id == id);
    if (_selectedId == id) _selectedId = null;
    notifyListeners();
  }

  void selectLayer(String id) {
    _selectedId = id;
    notifyListeners();
  }

  void updateTransform(String id, {double? scale, double? rotation, Offset? offset}) {
    final idx = _layers.indexWhere((l) => l.id == id);
    if (idx == -1) return;
    final l = _layers[idx];
    _layers[idx] = l.copyWith(
      scale: scale ?? l.scale,
      rotation: rotation ?? l.rotation,
      offset: offset ?? l.offset,
    );
    notifyListeners();
  }

  void toggleVisibility(String id) {
    final idx = _layers.indexWhere((l) => l.id == id);
    if (idx == -1) return;
    final l = _layers[idx];
    _layers[idx] = l.copyWith(visible: !l.visible);
    notifyListeners();
  }

  void setOpacity(String id, double opacity) {
    final idx = _layers.indexWhere((l) => l.id == id);
    if (idx == -1) return;
    final l = _layers[idx];
    _layers[idx] = l.copyWith(opacity: opacity);
    notifyListeners();
  }

  void bringForward(String id) {
    final idx = _layers.indexWhere((l) => l.id == id);
    if (idx == -1 || idx == _layers.length - 1) return;
    final l = _layers.removeAt(idx);
    _layers.insert(idx + 1, l);
    _reindex();
    notifyListeners();
  }

  void sendBackward(String id) {
    final idx = _layers.indexWhere((l) => l.id == id);
    if (idx <= 0) return;
    final l = _layers.removeAt(idx);
    _layers.insert(idx - 1, l);
    _reindex();
    notifyListeners();
  }

  void reorderLayers(int oldIndex, int newIndex) {
    if (oldIndex < 0 || newIndex < 0 || oldIndex >= _layers.length || newIndex >= _layers.length) return;
    final l = _layers.removeAt(oldIndex);
    _layers.insert(newIndex, l);
    _reindex();
    notifyListeners();
  }

  void resetTransform(String id) {
    final idx = _layers.indexWhere((l) => l.id == id);
    if (idx == -1) return;
    final l = _layers[idx];
    _layers[idx] = l.copyWith(scale: 1.0, rotation: 0.0, offset: Offset.zero, opacity: 1.0);
    notifyListeners();
  }

  /// Update imagePath and imageSourceType for a layer by id
  void updateLayer(String id, {String? imagePath, ImageSourceType? imageSourceType}) {
    final idx = _layers.indexWhere((l) => l.id == id);
    if (idx == -1) return;
    final l = _layers[idx];
    _layers[idx] = l.copyWith(
      imagePath: imagePath ?? l.imagePath,
      imageSourceType: imageSourceType ?? l.imageSourceType,
    );
    notifyListeners();
  }

  /// Move a layer from oldIndex to newIndex with proper adjustment
  void moveLayer(int oldIndex, int newIndex) {
    if (oldIndex < 0 || newIndex < 0 || oldIndex >= _layers.length || newIndex >= _layers.length) return;
    if (oldIndex == newIndex) return;

    // Adjust newIndex if oldIndex < newIndex
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final layer = _layers.removeAt(oldIndex);
    _layers.insert(newIndex, layer);
    _reindex();
    notifyListeners();
  }

  void _reindex() {
    for (int i = 0; i < _layers.length; i++) {
      _layers[i] = _layers[i].copyWith(zIndex: i);
    }
  }

  void clear() {
    _layers.clear();
    _selectedId = null;
    notifyListeners();
  }
}
