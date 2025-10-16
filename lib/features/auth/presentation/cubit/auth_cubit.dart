// ignore_for_file: unused_field

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:example/features/auth/data/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuya_flutter_ha_sdk/models/user_model.dart';
import 'package:tuya_flutter_ha_sdk/tuya_flutter_ha_sdk_platform_interface.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  Timer? _verificationTimer;
  DateTime? _verificationStartTime;
  static const _verificationTimeoutMinutes = 5;
  static const _verificationPollIntervalSeconds = 5;

  AuthCubit() : super(const AuthIdle(isRegisterMode: false));

  TuyaUserModel? user;
  ThingSmartUserModel? thingSmartUserModel;
  void toggleMode() {
    if (state is AuthIdle) {
      final currentState = state as AuthIdle;
      emit(AuthIdle(isRegisterMode: !currentState.isRegisterMode));
    }
  }

  Future<void> login(String email, String password) async {
    emit(const AuthLoading(message: 'Logging in...'));
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
      }
      emit(AuthAuthenticated());
    } else {
      emit(AuthError(message: result['message'] ?? "Unknown error"));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String countryCode,
    required String code,
  }) async {
    // emit(const AuthLoading(message: 'Registering...'));
    // final result = await TuyaFlutterHaSdkPlatform.instance.creat(
    //   countryCode: '+1',
    //   email: email,
    //   password: password,
    //   createHome: false,
    // );
    // if (result.containsKey('uid')) {
    //   user = result;
    //   emit(AuthAuthenticated());
    // } else {
    //   emit(AuthError(message: result['message'] ?? "Unknown error"));
    // }
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
