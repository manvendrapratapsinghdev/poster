import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthNotifier extends StateNotifier<AuthStatus> {
  static const _storage = FlutterSecureStorage();
  AuthNotifier() : super(AuthStatus.loading) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    state = AuthStatus.loading;
    final token = await _storage.read(key: 'access_token');
    if (token != null && token.isNotEmpty) {
      state = AuthStatus.authenticated;
    } else {
      state = AuthStatus.unauthenticated;
    }
  }

  Future<void> login(String token) async {
    state = AuthStatus.loading;
    await _storage.write(key: 'access_token', value: token);
    state = AuthStatus.authenticated;
  }

  Future<void> logout() async {
    state = AuthStatus.loading;
    await _storage.deleteAll();
    state = AuthStatus.unauthenticated;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthStatus>((ref) => AuthNotifier());
