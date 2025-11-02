import 'dart:async';

import 'package:billing_software/core/routes/routes.dart';
import 'package:billing_software/features/auth/domain/repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AuthCubit({required this.authRepo}) : super(AuthState.initial());
  StreamSubscription<bool>? authStream;
  final loginFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void checkAuth() {
    authStream = authRepo.authStateChanges().listen((isAuthenticated) {
      emit(state.copyWith(isAuthenticated: isAuthenticated));
    });
  }

  void login(String email, String password) async {
    if (loginFormKey.currentState?.validate() ?? false) {
      try {
        emit(state.copyWith(isLoading: true));
        await authRepo.login(email.trim().toLowerCase(), password);
        emit(
          state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            message: null, // Clear any previous error messages
          ),
        );
        // Router will automatically redirect due to the redirect logic
      } catch (e) {
        emit(
          state.copyWith(
            isLoading: false,
            message: e.toString(),
            isAuthenticated: false,
          ),
        );
      }
    }
  }

  void logout(BuildContext context) async {
    try {
      emit(state.copyWith(isLoading: true));
      await authRepo.logout();
      // Clear form data
      emailController.clear();
      passwordController.clear();
      emit(
        state.copyWith(isAuthenticated: false, isLoading: false, message: null),
      );

      context.go(Routes.login);
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: e.toString()));
    }
  }

  //forget password
  Future<void> forgetPassword(String email) async {
    if (email.isEmpty) {
      emit(state.copyWith(message: "Please enter your email first"));
      return;
    }

    emit(state.copyWith(isLoading: true, message: null));
    try {
      await authRepo.forgetPassword(email);
      emit(
        state.copyWith(
          message: "Password reset email sent successfully",
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(message: e.toString(), isLoading: false));
    }
  }

  @override
  Future<void> close() {
    authStream?.cancel();
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
