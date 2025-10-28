import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/admin_model.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthState.initial());

  Future<void> checkAuthStatus() async {
    try {
      emit(AuthState.loading());
      final admin = await _authRepository.getCurrentAdmin();
      if (admin != null) {
        emit(AuthState.authenticated(admin));
      } else {
        emit(AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.unauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    try {
      emit(AuthState.loading());
      final admin = await _authRepository.login(email, password);
      emit(AuthState.authenticated(admin));
    } catch (e) {
      emit(AuthState.error(e.toString()));
      await Future.delayed(const Duration(seconds: 2));
      emit(AuthState.unauthenticated());
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      emit(AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authRepository.resetPassword(email);
      emit(AuthState.passwordResetSent());
      // Return to unauthenticated state after a delay
      await Future.delayed(const Duration(seconds: 2));
      emit(AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
      await Future.delayed(const Duration(seconds: 2));
      emit(AuthState.unauthenticated());
    }
  }
}
