abstract class Failure {
  final String message;
  
  Failure(this.message);
}

class AuthFailure extends Failure {
  AuthFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}

class VerificationFailure extends Failure {
  VerificationFailure(String message) : super(message);
}

class HomeCreationFailure extends Failure {
  HomeCreationFailure(String message) : super(message);
}

class DevicesFailure extends Failure {
  DevicesFailure(String message) : super(message);
}