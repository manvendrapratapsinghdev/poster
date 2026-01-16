import 'package:dio/dio.dart';
import 'package:social_post_mobile/config/api_config.dart';
import '../models/user_model.dart';

class SignupRepository {
  final Dio _dio;
  SignupRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
      "${ApiConfig.backedBaseUrl}/auth/register",
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 201) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Signup failed');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Signup failed');
      }
      throw Exception('Network error');
    }
  }
}

