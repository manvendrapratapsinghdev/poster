import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

final categoryApiServiceProvider =
    Provider<BaseApiService>((ref) => BaseApiService());

final categoriesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final authStatus = ref.watch(authProvider);
  if (authStatus != AuthStatus.authenticated) {
    // Not authenticated, do not call API
    return [];
  }
  final api = ref.watch(categoryApiServiceProvider);
  final response = await api.get('/api/v1/categories');
  if (response.statusCode == 403) {
    throw Exception('Not authenticated');
  }
  final data = response.data as List?;
  return data?.cast<Map<String, dynamic>>() ?? [];
});

final subcategoryProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, categoryId) async {
    final authStatus = ref.watch(authProvider);
    if (authStatus != AuthStatus.authenticated) {
      return [];
    }
    final api = ref.watch(categoryApiServiceProvider);
    final response = await api.get('/api/v1/categories/$categoryId');
    final data = response.data['subcategories'] as List?;
    return data?.cast<Map<String, dynamic>>() ?? [];
  },
);
