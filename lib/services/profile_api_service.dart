import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:social_post_mobile/config/api_config.dart';
import '../models/profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';

final profileApiServiceProvider = Provider<ProfileApiService>((ref) {
  // You may want to configure Dio and storage globally in your app and inject here.
  final dio = Dio();
  final storage = const FlutterSecureStorage();
  const baseUrl = ApiConfig.backedBaseUrl; // <-- Set your API base URL
  return ProfileApiService(dio: dio, storage: storage, baseUrl: baseUrl);
});

class ProfileApiService extends BaseApiService {
  final String baseUrl;
  final FlutterSecureStorage storage;

  ProfileApiService({Dio? dio, required this.storage, required this.baseUrl}) : super(dio);

  Future<Profile> getProfile() async {
    final resp = await dio.get(
      '$baseUrl/api/v1/users/me',
    );
    storage.write(key: 'user_id', value: resp.data['id']);
    return Profile.fromJson(resp.data);
  }

  Future<Profile> updateProfile(Map<String, dynamic> data) async {
    final resp = await dio.put(
      '$baseUrl/api/v1/users/me',
      data: data,
    );
    return Profile.fromJson(resp.data);
  }

  Future<Profile> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });
    final resp = await dio.post(
      '$baseUrl/api/v1/profile/me/avatar',
      data: formData,
    );
    return Profile.fromJson(resp.data);
  }

  Future<String> changePassword(String oldPwd, String newPwd) async {
    final resp = await dio.post(
      '$baseUrl/api/v1/profile/me/change-password',
      data: {'old_password': oldPwd, 'new_password': newPwd},
    );
    return resp.data['message'] ?? 'Unknown response';
  }

  Future<Profile> updatePreferences(Map<String, dynamic> prefs) async {
    final resp = await dio.put(
      '$baseUrl/api/v1/profile/me/preferences',
      data: prefs,
    );
    return Profile.fromJson(resp.data);
  }

  Future<void> deleteAccount() async {
    await dio.delete(
      '$baseUrl/api/v1/profile/me',
    );
  }
}
