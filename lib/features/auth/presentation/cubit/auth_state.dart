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
  final int resendSecondsLeft;

  const AuthNeedsVerification({
    required this.email,
    required this.password,
    required this.lastChecked,
    this.resendSecondsLeft = 0,
  });

  AuthNeedsVerification copyWith({
    String? email,
    String? password,
    DateTime? lastChecked,
    int? resendSecondsLeft,
  }) {
    return AuthNeedsVerification(
      email: email ?? this.email,
      password: password ?? this.password,
      lastChecked: lastChecked ?? this.lastChecked,
      resendSecondsLeft: resendSecondsLeft ?? this.resendSecondsLeft,
    );
  }

  @override
  List<Object> get props => [email, password, lastChecked, resendSecondsLeft];
}

final class AuthAuthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class VerificationSendCodeLoading extends AuthState {}

class VerificationSendCodeSuccess extends AuthState {}

class VerificationSendCodeError extends AuthState {}
