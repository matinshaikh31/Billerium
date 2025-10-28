import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/admin_model.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    try {
      emit(AuthLoading());
      final admin = await _authRepository.getCurrentAdmin();
      if (admin != null) {
        emit(Authenticated(admin));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      final admin = await _authRepository.login(email, password);
      emit(Authenticated(admin));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authRepository.resetPassword(email);
      emit(PasswordResetSent());
      // Return to unauthenticated state after a delay
      await Future.delayed(const Duration(seconds: 2));
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }
}
