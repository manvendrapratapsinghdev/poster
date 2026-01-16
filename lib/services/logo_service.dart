import 'dart:io';
import 'package:dio/dio.dart';
import '../models/business_logo.dart';
import 'api_service.dart';

class LogoService extends BaseApiService {
  Future<List<BusinessLogo>> getLogos(String userId, String promotionId) async {
    final response = await get('/api/v1/logo/$userId/business/$promotionId/logos');
    if (response.statusCode == 200) {
      final data = response.data as List;
      return data.map((e) => BusinessLogo.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch logos');
    }
  }

  Future<BusinessLogo> uploadLogo(String userId, String promotionId, File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path),
    });
    final response = await post(
      '/api/v1/logo/$userId/business/$promotionId/logos',
      data: formData,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return BusinessLogo.fromJson(response.data);
    } else {
      throw Exception('Failed to upload logo');
    }
  }

  Future<BusinessLogo> updateLogo(String userId, String promotionId, String logoId, File newImage) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(newImage.path),
    });
    final response = await put(
      '/api/v1/logo/$userId/business/$promotionId/logos/$logoId',
      data: formData,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return BusinessLogo.fromJson(response.data);
    } else {
      throw Exception('Failed to update logo');
    }
  }

  Future<void> deleteLogo(String userId, String promotionId, String logoId) async {
    final response = await delete(
      '/api/v1/logo/$userId/business/$promotionId/logos/$logoId',
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete logo');
    }
  }
}
