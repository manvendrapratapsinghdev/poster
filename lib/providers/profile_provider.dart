import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile.dart';
import '../services/profile_api_service.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState {
  final Profile? profile;
  final ProfileStatus status;
  final String? error;

  ProfileState({this.profile, this.status = ProfileStatus.initial, this.error});

  ProfileState copyWith({
    Profile? profile,
    ProfileStatus? status,
    String? error,
  }) =>
      ProfileState(
        profile: profile ?? this.profile,
        status: status ?? this.status,
        error: error,
      );
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileApiService api;
  ProfileNotifier(this.api) : super(ProfileState());

  Future<void> fetchProfile() async {
    state = state.copyWith(status: ProfileStatus.loading, error: null);
    try {
      final profile = await api.getProfile();
      state = state.copyWith(profile: profile, status: ProfileStatus.loaded);
    } catch (e) {
      state = state.copyWith(status: ProfileStatus.error, error: e.toString());
    }
  }

  Future<Profile?> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(status: ProfileStatus.loading, error: null);
    try {
      final profile = await api.updateProfile(data);
      state = state.copyWith(profile: profile, status: ProfileStatus.loaded);
      return profile;
    } catch (e) {
      state = state.copyWith(status: ProfileStatus.error, error: e.toString());
      return null;
    }
  }

  Future<Profile?> uploadAvatar(String filePath) async {
    state = state.copyWith(status: ProfileStatus.loading, error: null);
    try {
      final profile = await api.uploadAvatar(filePath);
      state = state.copyWith(profile: profile, status: ProfileStatus.loaded);
      return profile;
    } catch (e) {
      state = state.copyWith(status: ProfileStatus.error, error: e.toString());
      return null;
    }
  }

  Future<String?> changePassword(String oldPwd, String newPwd) async {
    try {
      final message = await api.changePassword(oldPwd, newPwd);
      return message;
    } catch (e) {
      state = state.copyWith(status: ProfileStatus.error, error: e.toString());
      final message = "Failed to change password";
      return message;
    }
  }

  Future<Profile?> updatePreferences(Map<String, dynamic> prefs) async {
    try {
      final profile = await api.updatePreferences(prefs);
      state = state.copyWith(profile: profile, status: ProfileStatus.loaded);
      return profile;
    } catch (e) {
      state = state.copyWith(status: ProfileStatus.error, error: e.toString());
      return null;
    }
  }

  Future<void> deleteAccount() async {
    try {
      await api.deleteAccount();
      state = ProfileState(); // Reset state
    } catch (e) {
      state = state.copyWith(status: ProfileStatus.error, error: e.toString());
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(ref.watch(profileApiServiceProvider)),
);
