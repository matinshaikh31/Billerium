part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];

  bool get isAuthenticated => this is Authenticated;
  bool get isLoading => this is AuthLoading;
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final AdminModel admin;

  const Authenticated(this.admin);

  @override
  List<Object?> get props => [admin];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordResetSent extends AuthState {}
