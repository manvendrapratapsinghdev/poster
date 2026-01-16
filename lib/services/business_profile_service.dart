import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/business_profile.dart';

class BusinessProfileService {
  final Dio _dio;
  final String userId;
  final String token;

  BusinessProfileService({required this.userId, required this.token})
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConfig.backedBaseUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ));

  Future<List<BusinessProfile>> fetchProfiles() async {
    final response = await _dio.get('/api/v1/business-promotion/$userId/business-promotions');
    final data = response.data as List;
    return data.map((e) => BusinessProfile.fromJson(e)).toList();
  }

  Future<void> createProfile(BusinessProfile profile) async {
    await _dio.post(
      '/api/v1/business-promotion/$userId/business-promotions',
      data: profile.toJson(),
    );
  }

  Future<void> updateProfile(BusinessProfile profile, String profileId) async {
    await _dio.put(
      '/api/v1/business-promotion/$userId/business-promotions/$profileId',
      data: profile.toJson(),
    );
  }

  Future<void> deleteProfile(String profileId) async {
    await _dio.delete(
      '/api/v1/business-promotion/$userId/business-promotions/$profileId',
    );
  }
}
