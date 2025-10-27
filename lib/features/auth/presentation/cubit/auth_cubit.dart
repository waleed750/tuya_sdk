// ignore_for_file: unused_field

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:example/core/cache/app_prefs.dart';
import 'package:example/features/auth/data/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuya_flutter_ha_sdk/models/user_model.dart';
import 'package:tuya_flutter_ha_sdk/tuya_flutter_ha_sdk_platform_interface.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  Timer? _verificationTimer;
  Timer? _resendTimer;
  DateTime? _verificationStartTime;
  static const _verificationTimeoutMinutes = 5;
  static const _verificationPollIntervalSeconds = 5;
  static const _resendCooldownSeconds = 30;

  AuthCubit() : super(const AuthIdle(isRegisterMode: false));
  bool isRegisterMode = false;
  TuyaUserModel? user;
  ThingSmartUserModel? thingSmartUserModel;
  void toggleMode() {
    // if (state is AuthIdle) {
    // final currentState = state as AuthIdle;
    isRegisterMode = !isRegisterMode;
    emit(AuthIdle(isRegisterMode: isRegisterMode));
    // }
  }

  Future<void> automateLogin() async {
    final userData = await secureStorage.getUserData();
    if (userData != null) {
      user = TuyaUserModel.fromMap(userData);
      final resultInfo = await TuyaFlutterHaSdkPlatform.instance
          .getCurrentUser();
      if (resultInfo.isNotEmpty) {
        thingSmartUserModel = ThingSmartUserModel.fromJson(resultInfo);
        emit(AuthAuthenticated());
      } else {
        isRegisterMode = false;
        emit(const AuthIdle(isRegisterMode: false));
      }
    } else {
      isRegisterMode = false;
      emit(const AuthIdle(isRegisterMode: false));
    }
  }

  Future<void> saveUserData() async {
    if (user != null) {
      await secureStorage.saveUserData(user!.toJson());
    }
  }

  void getUserData() async {
    final userData = await secureStorage.getUserData();
    if (userData != null) {
      thingSmartUserModel = ThingSmartUserModel.fromJson(
        userData as Map<String, dynamic>,
      );
    }
  }

  Future<void> login(String email, String password) async {
    emit(const AuthLoading(message: 'Logging in...'));
    try {
      final result = await TuyaFlutterHaSdkPlatform.instance.loginWithEmail(
        countryCode: '+1',
        email: email,
        password: password,
        createHome: false,
      );
      if (result.containsKey('uid')) {
        user = TuyaUserModel.fromMap(result);
        final resultInfo = await TuyaFlutterHaSdkPlatform.instance
            .getCurrentUser();
        if (resultInfo.isNotEmpty) {
          thingSmartUserModel = ThingSmartUserModel.fromJson(resultInfo);
          await saveUserData();
          emit(AuthAuthenticated());
        } else {
          emit(AuthError(message: "Failed to fetch user info"));
        }
      } else {
        emit(AuthError(message: result['message'] ?? "Unknown error"));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> sendVerifcationCode(String email) async {
    // emit(const AuthLoading(message: 'Sending verification code...'));
    try {
      emit(VerificationSendCodeLoading());
      //The purpose of the verification code. Valid values:
      // 1: register an account with an email address
      // 2: login to the app with an email address
      // 3: reset the password of an account that is registered with an email address
      await TuyaFlutterHaSdkPlatform.instance.sendVerificationCode(
        countryCode: '1',
        account: email,
        accountType: 'email',
      );
      _verificationStartTime = DateTime.now();

      // Start periodic verification checks
      _verificationTimer?.cancel();
      // _verificationTimer = Timer.periodic(
      //   const Duration(seconds: _verificationPollIntervalSeconds),
      //   (_) => _checkVerification(email),
      // );

      // Start resend cooldown
      // _startResendCooldown();

      // Emit state indicating we need verification and provide lastChecked
      emit(
        AuthNeedsVerification(
          email: email,
          password: '',
          lastChecked: DateTime.now(),
          resendSecondsLeft: _resendCooldownSeconds,
        ),
      );
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    int secondsLeft = _resendCooldownSeconds;
    // Update state immediately with starting seconds
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsLeft--;
      final current = state;
      if (current is AuthNeedsVerification) {
        emit(
          current.copyWith(
            resendSecondsLeft: secondsLeft > 0 ? secondsLeft : 0,
          ),
        );
      }
      if (secondsLeft <= 0) {
        _resendTimer?.cancel();
      }
    });
  }

  Future<void> resendVerification(String email) async {
    final current = state;
    if (current is AuthNeedsVerification && current.resendSecondsLeft > 0) {
      // still cooling down
      return;
    }

    // Call platform to resend verification code
    await TuyaFlutterHaSdkPlatform.instance.sendVerificationCode(
      countryCode: '+1',
      account: email,
      accountType: '1',
    );

    // Restart cooldown
    _startResendCooldown();
  }

  Future<void> _checkVerification(String email) async {
    try {
      // call an API to check if user verified - placeholder: getCurrentUser
      final resultInfo = await TuyaFlutterHaSdkPlatform.instance
          .getCurrentUser();
      if (resultInfo.isNotEmpty) {
        // Verified
        thingSmartUserModel = ThingSmartUserModel.fromJson(resultInfo);
        user = TuyaUserModel.fromMap({'uid': thingSmartUserModel?.uid ?? ''});
        _verificationTimer?.cancel();
        _resendTimer?.cancel();
        emit(AuthAuthenticated());
      } else {
        // update lastChecked
        final current = state;
        if (current is AuthNeedsVerification) {
          emit(current.copyWith(lastChecked: DateTime.now()));
        }
      }
    } catch (e) {
      // ignore errors but update lastChecked timestamp
      final current = state;
      if (current is AuthNeedsVerification) {
        emit(current.copyWith(lastChecked: DateTime.now()));
      }
    }
  }

  /// Public manual check (used by UI "I Verified My Email")
  Future<void> checkNow(String email) async => _checkVerification(email);

  Future<void> register({
    required String email,
    required String password,
    required String countryCode,
    required String code,
  }) async {
    emit(const AuthLoading(message: 'Registering...'));
    try {
      final result = await TuyaFlutterHaSdkPlatform.instance
          .registerAccountWithEmail(
            countryCode: '+1',
            email: email,
            password: password,
            code: code,
          );
      if (result.containsKey('uid')) {
        user = TuyaUserModel.fromMap(result);
        emit(AuthAuthenticated());
      } else {
        emit(AuthError(message: result['message'] ?? "Unknown error"));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void cancelVerification() {
    _verificationTimer?.cancel();
    _resendTimer?.cancel();
    isRegisterMode = true;
    emit(const AuthIdle(isRegisterMode: true));
  }

  @override
  Future<void> close() {
    _verificationTimer?.cancel();
    return super.close();
  }
}
