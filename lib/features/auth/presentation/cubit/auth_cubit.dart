import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/create_home_if_new_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/poll_verification_usecase.dart';
import '../../domain/usecases/register_after_verified_usecase.dart';
import '../../domain/usecases/send_verification_usecase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SendVerificationUseCase _sendVerificationUseCase;
  final PollVerificationUseCase _pollVerificationUseCase;
  final RegisterAfterVerifiedUseCase _registerAfterVerifiedUseCase;
  final LoginUseCase _loginUseCase;
  final CreateHomeIfNewUseCase _createHomeIfNewUseCase;

  Timer? _verificationTimer;
  DateTime? _verificationStartTime;
  static const _verificationTimeoutMinutes = 5;
  static const _verificationPollIntervalSeconds = 5;

  AuthCubit({
    required SendVerificationUseCase sendVerificationUseCase,
    required PollVerificationUseCase pollVerificationUseCase,
    required RegisterAfterVerifiedUseCase registerAfterVerifiedUseCase,
    required LoginUseCase loginUseCase,
    required CreateHomeIfNewUseCase createHomeIfNewUseCase,
  })  : _sendVerificationUseCase = sendVerificationUseCase,
        _pollVerificationUseCase = pollVerificationUseCase,
        _registerAfterVerifiedUseCase = registerAfterVerifiedUseCase,
        _loginUseCase = loginUseCase,
        _createHomeIfNewUseCase = createHomeIfNewUseCase,
        super(const AuthIdle(isRegisterMode: false));

  void toggleMode() {
    if (state is AuthIdle) {
      final currentState = state as AuthIdle;
      emit(AuthIdle(isRegisterMode: !currentState.isRegisterMode));
    }
  }

  Future<void> login(String email, String password) async {
    emit(const AuthLoading(message: 'Logging in...'));

    final result = await _loginUseCase(email: email, password: password);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> startRegistration(String email, String password) async {
    emit(const AuthLoading(message: 'Sending verification email...'));

    final result = await _sendVerificationUseCase(email);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) {
        emit(AuthNeedsVerification(
          email: email,
          password: password,
          lastChecked: DateTime.now(),
        ));
        _startVerificationPolling(email, password);
      },
    );
  }

  void _startVerificationPolling(String email, String password) {
    _verificationStartTime = DateTime.now();
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(
      const Duration(seconds: _verificationPollIntervalSeconds),
      (_) => _checkVerification(email, password),
    );
  }

  Future<void> _checkVerification(String email, String password) async {
    if (_verificationStartTime == null) return;

    final now = DateTime.now();
    final elapsedMinutes = now.difference(_verificationStartTime!).inMinutes;

    if (elapsedMinutes >= _verificationTimeoutMinutes) {
      _verificationTimer?.cancel();
      emit(const AuthError(message: 'Verification timed out. Please try again.'));
      return;
    }

    final result = await _pollVerificationUseCase(email);

    result.fold(
      (failure) {
        // Just update last checked time, don't show error
        if (state is AuthNeedsVerification) {
          final currentState = state as AuthNeedsVerification;
          emit(currentState.copyWith(lastChecked: now));
        }
      },
      (isVerified) {
        if (state is AuthNeedsVerification) {
          final currentState = state as AuthNeedsVerification;
          
          if (isVerified) {
            _verificationTimer?.cancel();
            _completeRegistration(email, password);
          } else {
            emit(currentState.copyWith(lastChecked: now));
          }
        }
      },
    );
  }

  Future<void> manualCheckVerification() async {
    if (state is AuthNeedsVerification) {
      final currentState = state as AuthNeedsVerification;
      final email = currentState.email;
      final password = currentState.password;
      
      emit(const AuthLoading(message: 'Checking verification status...'));
      
      final result = await _pollVerificationUseCase(email);
      
      result.fold(
        (failure) => emit(currentState.copyWith(lastChecked: DateTime.now())),
        (isVerified) {
          if (isVerified) {
            _verificationTimer?.cancel();
            _completeRegistration(email, password);
          } else {
            emit(currentState.copyWith(lastChecked: DateTime.now()));
          }
        },
      );
    }
  }

  Future<void> _completeRegistration(String email, String password) async {
    emit(const AuthLoading(message: 'Creating your account...'));

    final registerResult = await _registerAfterVerifiedUseCase(
      email: email,
      password: password,
    );

    await registerResult.fold(
      (failure) {
        emit(AuthError(message: failure.message));
        return;
      },
      (user) async {
        // Create default home
        final homeResult = await _createHomeIfNewUseCase(
          name: 'My Home',
          timeZoneId: DateTime.now().timeZoneName,
          lat: 0.0,
          lon: 0.0,
        );

        homeResult.fold(
          (failure) {
            // Even if home creation fails, we still consider the user authenticated
            emit(AuthAuthenticated(user: user));
          },
          (_) {
            emit(AuthAuthenticated(user: user));
          },
        );
      },
    );
  }

  void cancelVerification() {
    _verificationTimer?.cancel();
    emit(const AuthIdle(isRegisterMode: true));
  }

  @override
  Future<void> close() {
    _verificationTimer?.cancel();
    return super.close();
  }
}