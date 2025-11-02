part of 'auth_cubit.dart';

class AuthState extends Equatable {
  final bool isAuthenticated;
  final String? message;
  final bool isLoading;
  final bool isPasswordVisible;

  const AuthState({
    required this.isAuthenticated,
    this.message,
    required this.isLoading,
    required this.isPasswordVisible,
  });

  // Initial state
  factory AuthState.initial() {
    return const AuthState(
      isAuthenticated: false,
      message: null,
      isLoading: false,
      isPasswordVisible: false,
    );
  }

  // Copy with method to update state
  AuthState copyWith({
    bool? isAuthenticated,
    String? message,
    bool? isLoading,
    bool? isPasswordVisible,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      message: message ?? this.message,
      isLoading: isLoading ?? this.isLoading,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }

  @override
  List<Object?> get props => [isAuthenticated, message, isLoading];
}
