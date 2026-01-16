import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/template_service.dart';
import '../repositories/template_strip_repository.dart';

final templateServiceProvider = FutureProvider<TemplateService>((ref) async {
  // Read access_token from secure storage
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'access_token');
  if (token == null) {
    throw Exception('No access token found');
  }
  return TemplateService(token);
});

// Example usage:
// ref.watch(templateServiceProvider).when(
//   data: (service) => ...,
//   loading: () => CircularProgressIndicator(),
//   error: (e, _) => Text('Error: $e'),
// );

class TemplateProviderParams extends Equatable {
  final String category;
  final String subcategory;
  const TemplateProviderParams(
      {required this.category, required this.subcategory});

  @override
  List<Object?> get props => [category, subcategory];

  Map<String, dynamic> toMap() => {
        'category': category,
        'subcategory': subcategory,
      };
}

final templatesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, TemplateProviderParams>(
        (ref, params) async {
  final serviceAsync = await ref.watch(templateServiceProvider.future);
  return await serviceAsync.fetchTemplates(params: params.toMap());
});

final templateStripsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = TemplateStripRepository();
  return await repo.fetchTemplateStrips();
});
