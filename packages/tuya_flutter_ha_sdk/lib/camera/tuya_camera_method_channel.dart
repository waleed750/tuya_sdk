import 'dart:developer';

import 'package:flutter/services.dart';
import 'tuya_camera_platform_interface.dart';

class TuyaCameraMethodChannel extends TuyaCameraPlatform {
  static const MethodChannel _channel = MethodChannel(
    'tuya_flutter_ha_sdk/camera',
  );

  /// Get a list of cameras added to a home
  /// [homeId] details is passed on to native
  /// listCamera function of native is invoked
  @override
  Future<List<Map<String, dynamic>>> listCameras({required int homeId}) async {
    final List<dynamic> result = await _channel.invokeMethod('listCameras', {
      'homeId': homeId,
    });
    return result.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Get the capabilities of a given camera device
  /// [deviceId] details is passed on to native
  /// getCameraCapabilities function of native is invoked
  @override
  Future<Map<String, dynamic>> getCameraCapabilities({
    required String deviceId,
  }) async {
    log("before calling capabilities");
    final Map result = await _channel.invokeMethod('getCameraCapabilities', {
      'deviceId': deviceId,
    });
    log("after calling capabilities");
    return Map<String, dynamic>.from(result);
  }

  /// Start live streaming of a given camera
  /// [deviceId] details is passed on to native
  /// startLiveStream function of native is invoked
  @override
  Future<void> startLiveStream({required String deviceId}) async {
    await _channel.invokeMethod('startLiveStream', {'deviceId': deviceId});
  }

  /// Stop live streaming of a given camera
  /// [deviceId] details is passed on to native
  /// stopLiveStream function of native is invoked
  @override
  Future<void> stopLiveStream({required String deviceId}) async {
    await _channel.invokeMethod('stopLiveStream', {'deviceId': deviceId});
  }

  /// Get alerts of a given device
  /// [deviceId], [year], [month] details are passed to native
  /// getDeviceAlerts function of native is invoked
  @override
  Future<List<Map<String, dynamic>>> getDeviceAlerts({
    required String deviceId,
    required int year,
    required int month,
  }) async {
    final List<dynamic> result = await _channel.invokeMethod(
      'getDeviceAlerts',
      {'deviceId': deviceId, 'year': year, 'month': month},
    );
    return result.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Save the current video to a given path
  /// [filePath] details is passed on to native
  /// saveVideoToGallery function of native is invoked
  @override
  Future<void> saveVideoToGallery({required String filePath}) async {
    await _channel.invokeMethod('saveVideoToGallery', {'filePath': filePath});
  }

  /// Stop saving the video
  /// stopSaveVideoToGallery function of native is invoked
  @override
  Future<void> stopSaveVideoToGallery() async {
    await _channel.invokeMethod('stopSaveVideoToGallery');
  }

  /// Configure a set of DP codes on a device
  /// [deviceId],[dps] details is passed on to native
  /// setDeviceDpConfigs function of native is invoked
  @override
  Future<bool> setDeviceDpConfigs({
    required String deviceId,
    required Map<String, dynamic> dps,
  }) async {
    log("dps");
    log(dps.toString());
    return await _channel.invokeMethod<bool>('setDeviceDpConfigs', {
          'deviceId': deviceId,
          'dps': dps,
        }) ??
        false;
  }

  /// Get the current configurations of set of DP codes on a device
  /// [deviceId] details is passed on to native
  /// getDeviceDpConfigs function of native is invoked
  @override
  Future<List<Map<String, dynamic>>> getDeviceDpConfigs({
    required String deviceId,
  }) async {
    final List<dynamic> result = await _channel.invokeMethod(
      'getDeviceDpConfigs',
      {'deviceId': deviceId},
    );
    return result.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Kick off APNs / FCM registration on the native side
  /// [type],[isOpen] details are passed on to native
  /// registerPush function of native is invoked
  @override
  Future<void> registerPush({required int type, required bool isOpen}) {
    return _channel.invokeMethod('registerPush', {
      'type': type,
      'isOpen': isOpen,
    });
  }

  /// Get all messages
  /// getAllMessages function of native is invoked
  @override
  Future<List<Map<String, dynamic>>> getAllMessages() async {
    final List<dynamic> result = await _channel.invokeMethod("getAllMessages");
    return result.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
