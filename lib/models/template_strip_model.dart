import 'package:flutter/material.dart';

class PositionOffset {
  final double x;
  final double y;

  PositionOffset({required this.x, required this.y});

  factory PositionOffset.fromJson(Map<String, dynamic> json) {
    return PositionOffset(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }
}

class TemplateMetaData {
  final Color color;
  final double opacity;
  final double heightFactor;
  final Alignment alignment;
  final PositionOffset namePosition;
  final PositionOffset contactPosition;
  final PositionOffset addressPosition;
  final PositionOffset otherInfoPosition;
  final PositionOffset logoPosition;
  final double fontSize;

  TemplateMetaData({
    required this.color,
    required this.opacity,
    required this.heightFactor,
    required this.alignment,
    required this.namePosition,
    required this.contactPosition,
    required this.addressPosition,
    required this.otherInfoPosition,
    required this.logoPosition,
    required this.fontSize,
  });

  factory TemplateMetaData.fromJson(Map<String, dynamic> json) {
    Alignment parseAlignment(String? align) {
      switch (align) {
        case 'topCenter':
          return Alignment.topCenter;
        case 'bottomCenter':
        default:
          return Alignment.bottomCenter;
      }
    }

    return TemplateMetaData(
      color: (json['color'] is String && json['color'] != null && json['color'].startsWith('#'))
          ? Color(int.tryParse(json['color'].replaceFirst('#', '0xff')) ?? 0xFF000000)
          : Colors.black,
      opacity: (json['opacity'] is num)
          ? (json['opacity'] as num).toDouble()
          : 1.0,
      heightFactor: (json['height_factor'] is num)
          ? (json['height_factor'] as num).toDouble()
          : 0.3,
      alignment: parseAlignment(json['alignment'] as String?),
      namePosition: (json['name_position'] is Map<String, dynamic>)
          ? PositionOffset.fromJson(json['name_position'])
          : PositionOffset(x: 0, y: 0),
      contactPosition: (json['contact_position'] is Map<String, dynamic>)
          ? PositionOffset.fromJson(json['contact_position'])
          : PositionOffset(x: 0, y: 0),
      addressPosition: (json['address_position'] is Map<String, dynamic>)
          ? PositionOffset.fromJson(json['address_position'])
          : PositionOffset(x: 0, y: 0),
      otherInfoPosition: (json['other_info_position'] is Map<String, dynamic>)
          ? PositionOffset.fromJson(json['other_info_position'])
          : PositionOffset(x: 0, y: 0),
      logoPosition: (json['logo_position'] is Map<String, dynamic>)
          ? PositionOffset.fromJson(json['logo_position'])
          : PositionOffset(x: 0, y: 0),
      fontSize: (json['font_size'] is double) ? json['font_size'] as double : 18,
    );
  }
}

class TemplateStripModel {
  final String id;
  final String name;
  final String category;
  final String subcategory;
  final String politicalParty;
  final String language;
  final List<String> tags;
  final String description;
  final String targetAudience;
  final String fileUrl;
  final String sampleFileUrl;
  final String backgroundUrl;
  final TemplateMetaData metadata;

  TemplateStripModel({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.politicalParty,
    required this.language,
    required this.tags,
    required this.description,
    required this.targetAudience,
    required this.fileUrl,
    required this.sampleFileUrl,
    required this.backgroundUrl,
    required this.metadata,
  });

  factory TemplateStripModel.fromJson(Map<String, dynamic> json) {
    return TemplateStripModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      politicalParty: json['political_party'] ?? '',
      language: json['language'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      description: json['description'] ?? '',
      targetAudience: json['target_audience'] ?? '',
      fileUrl: json['file_url'] ?? '',
      sampleFileUrl: json['sample_file_url'] ?? '',
      backgroundUrl: json['background_url'] ?? '',
      metadata: TemplateMetaData.fromJson(json['metadata'] ?? {}),
    );
  }
}
