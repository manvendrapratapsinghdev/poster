import 'package:dio/dio.dart';
import 'package:social_post_mobile/config/api_config.dart';

class TemplateService {
  final Dio _dio;
  TemplateService(String accessToken, [Dio? dio])
      : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: ApiConfig.backedBaseUrl,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ));

  Future<List<Map<String, dynamic>>> fetchTemplates(
      {Map<String, dynamic>? params}) async {
    print('fetchTemplates called with params: $params');
    final response = await _dio.get('/api/v1/templates/', queryParameters: params ?? {});
    print('API response: ${response.data}');
    List? items;
    if (response.data is List) {
      items = response.data as List;
    } else if (response.data is Map) {
      if (response.data['items'] is List) {
        items = response.data['items'] as List;
      } else if (response.data['data'] is List) {
        items = response.data['data'] as List;
      }
    }
    return items?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<Map<String, dynamic>> fetchTemplateDetails(String id) async {
    final response = await _dio.get('/api/v1/templates/$id');
    return response.data;
  }
}
