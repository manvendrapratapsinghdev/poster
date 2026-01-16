import '../services/api_service.dart';

class TemplateStripRepository {
  final BaseApiService _apiService;
  TemplateStripRepository([BaseApiService? apiService])
      : _apiService = apiService ?? BaseApiService();

  Future<List<Map<String, dynamic>>> fetchTemplateStrips() async {
    final response = await _apiService.get(
      '/api/v1/template-strips',
      queryParameters: {'page': 1, 'limit': 10},
    );
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
}

