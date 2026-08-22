import 'tuya_camera_platform_interface.dart';

class TuyaCameraMethods {
  /// Get a list of cameras added to a home
  static Future<List<Map<String, dynamic>>> listCameras({required int homeId}) {
    return TuyaCameraPlatform.instance.listCameras(homeId: homeId);
  }

  /// Get the capabilities of a given camera device
  static Future<Map<String, dynamic>> getCameraCapabilities({required String deviceId}) {
    return TuyaCameraPlatform.instance.getCameraCapabilities(deviceId: deviceId);
  }

  /// Start live streaming of a given camera
  static Future<void> startLiveStream({required String deviceId}) {
    return TuyaCameraPlatform.instance.startLiveStream(deviceId: deviceId);
  }

  /// Stop live streaming of a given camera
  static Future<void> stopLiveStream({required String deviceId}) {
    return TuyaCameraPlatform.instance.stopLiveStream(deviceId: deviceId);
  }

  /// Get alerts of a given device
  static Future<List<Map<String, dynamic>>> getDeviceAlerts({required String deviceId,required int year, required int month}) {
    return TuyaCameraPlatform.instance.getDeviceAlerts(deviceId: deviceId,year: year,month: month);
  }

  /// Save the current video to a given path
  static Future<void> saveVideoToGallery({required String filePath}) {
    return TuyaCameraPlatform.instance.saveVideoToGallery(filePath: filePath);
  }

  /// Stop saving the video
  static Future<void> stopSaveVideoToGallery() {
    return TuyaCameraPlatform.instance.stopSaveVideoToGallery();
  }

  /// Configure a set of DP codes on a device
  static Future<bool> setDeviceDpConfigs({
    required String deviceId,
    required Map<String, dynamic> dps,
  }) {
    return TuyaCameraPlatform.instance.setDeviceDpConfigs(
      deviceId: deviceId,
      dps: dps,
    );
  }

  /// Get the current configurations of set of DP codes on a device
  static Future<List<Map<String, dynamic>>> getDeviceDpConfigs({
    required String deviceId,
  }) {
    return TuyaCameraPlatform.instance.getDeviceDpConfigs(deviceId: deviceId);
  }

  /// Kick off APNs / FCM registration on the native side
  static Future<void> registerPush({required int type,required bool isOpen}) {
    return TuyaCameraPlatform.instance.registerPush(type: type,isOpen: isOpen);
  }

  /// Get all messages
  static Future<List<Map<String,dynamic>>> getAllMessages(){
    return TuyaCameraPlatform.instance.getAllMessages();
  }
}
