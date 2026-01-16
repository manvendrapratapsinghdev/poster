import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/business_profile.dart';
import '../services/business_profile_service.dart';

/// ---------- State ----------
class BusinessProfileState {
  final List<BusinessProfile> profiles;
  final bool loading;
  final String? error;

  BusinessProfileState({
    required this.profiles,
    required this.loading,
    this.error,
  });

  BusinessProfileState copyWith({
    List<BusinessProfile>? profiles,
    bool? loading,
    String? error,
  }) {
    return BusinessProfileState(
      profiles: profiles ?? this.profiles,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

/// ---------- Notifier ----------
class BusinessProfileNotifier extends StateNotifier<BusinessProfileState> {
  final BusinessProfileService service;

  BusinessProfileNotifier(this.service)
      : super(BusinessProfileState(profiles: [], loading: false));

  Future<void> loadProfiles() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final profiles = await service.fetchProfiles();
      state = state.copyWith(profiles: profiles, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> addProfile(BusinessProfile profile) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await service.createProfile(profile);
      await loadProfiles();
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> updateProfile(BusinessProfile profile, String profileId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await service.updateProfile(profile, profileId);
      await loadProfiles();
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> deleteProfile(String profileId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await service.deleteProfile(profileId);
      await loadProfiles();
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

/// ---------- Providers ----------

// Combines reading userId and token into one FutureProvider
final businessProfileServiceProvider =
FutureProvider<BusinessProfileService>((ref) async {
  const storage = FlutterSecureStorage();
  final userId = await storage.read(key: 'user_id');
  final token = await storage.read(key: 'access_token');

  if (userId == null || token == null) {
    throw Exception('Missing user_id or access_token in secure storage');
  }

  return BusinessProfileService(userId: userId, token: token);
});

final businessProfileProvider =
StateNotifierProvider<BusinessProfileNotifier, BusinessProfileState>((ref) {
  // Use the value from the FutureProvider once it resolves.
  final serviceAsync = ref.watch(businessProfileServiceProvider);

  // Until data is ready, provide a dummy notifier with empty state
  return serviceAsync.maybeWhen(
    data: (service) => BusinessProfileNotifier(service),
    orElse: () => BusinessProfileNotifier(
      BusinessProfileService(userId: '', token: ''), // dummy
    ),
  );
});
