part of 'auth_cubit.dart';

class AuthState extends Equatable {
  final bool isAuthenticated;
  final bool isLoading;
  final String? message;
  final AdminModel? admin;

  const AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.message,
    this.admin,
  });

  factory AuthState.initial() {
    return const AuthState(
      isAuthenticated: false,
      isLoading: false,
      message: null,
      admin: null,
    );
  }

  factory AuthState.loading() {
    return const AuthState(
      isAuthenticated: false,
      isLoading: true,
      message: null,
      admin: null,
    );
  }

  factory AuthState.authenticated(AdminModel admin) {
    return AuthState(
      isAuthenticated: true,
      isLoading: false,
      message: null,
      admin: admin,
    );
  }

  factory AuthState.unauthenticated({String? message}) {
    return AuthState(
      isAuthenticated: false,
      isLoading: false,
      message: message,
      admin: null,
    );
  }

  factory AuthState.error(String message) {
    return AuthState(
      isAuthenticated: false,
      isLoading: false,
      message: message,
      admin: null,
    );
  }

  factory AuthState.passwordResetSent() {
    return const AuthState(
      isAuthenticated: false,
      isLoading: false,
      message: 'Password reset email sent!',
      admin: null,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? message,
    AdminModel? admin,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      admin: admin ?? this.admin,
    );
  }

  @override
  List<Object?> get props => [isAuthenticated, isLoading, message, admin];
}
