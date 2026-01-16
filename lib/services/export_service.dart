// ExportService: capturePost() to export RepaintBoundary as PNG file
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

Future<File> capturePost(GlobalKey repaintKey, {double pixelRatio = 3.0}) async {
  final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) throw Exception('Canvas not found');
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) throw Exception('Failed to encode image');
  final buffer = byteData.buffer.asUint8List();
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/post_${DateTime.now().millisecondsSinceEpoch}.png');
  await file.writeAsBytes(buffer);
  return file;
}

