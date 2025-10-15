import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? token;

  const AuthUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.token,
  });

  @override
  List<Object?> get props => [uid, email, displayName, token];
}