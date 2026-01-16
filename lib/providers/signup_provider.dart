import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/signup_repository.dart';

final signupRepositoryProvider = Provider<SignupRepository>((ref) => SignupRepository());

class SignupState {
  final AsyncValue<UserModel?> user;
  SignupState({required this.user});

  SignupState copyWith({AsyncValue<UserModel?>? user}) => SignupState(user: user ?? this.user);
}

class SignupNotifier extends StateNotifier<SignupState> {
  final SignupRepository repository;
  SignupNotifier(this.repository) : super(SignupState(user: const AsyncValue.data(null)));

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(user: const AsyncValue.loading());
    try {
      final user = await repository.signup(name: name, email: email, password: password, role: role);
      state = state.copyWith(user: AsyncValue.data(user));
    } catch (e, st) {
      state = state.copyWith(user: AsyncValue.error(e, st));
    }
  }
}

final signupProvider = StateNotifierProvider<SignupNotifier, SignupState>((ref) {
  return SignupNotifier(ref.watch(signupRepositoryProvider));
});

