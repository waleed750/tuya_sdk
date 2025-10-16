part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthIdle extends AuthState {
  final bool isRegisterMode;

  const AuthIdle({required this.isRegisterMode});

  @override
  List<Object> get props => [isRegisterMode];
}

class AuthLoading extends AuthState {
  final String? message;

  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthNeedsVerification extends AuthState {
  final String email;
  final String password;
  final DateTime lastChecked;

  const AuthNeedsVerification({
    required this.email,
    required this.password,
    required this.lastChecked,
  });

  AuthNeedsVerification copyWith({
    String? email,
    String? password,
    DateTime? lastChecked,
  }) {
    return AuthNeedsVerification(
      email: email ?? this.email,
      password: password ?? this.password,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }

  @override
  List<Object> get props => [email, password, lastChecked];
}

final class AuthAuthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
