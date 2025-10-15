import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'tuya_camera_method_channel.dart';

abstract class TuyaCameraPlatform extends PlatformInterface {
  TuyaCameraPlatform() : super(token: _token);

  static final Object _token = Object();

  static TuyaCameraPlatform _instance = TuyaCameraMethodChannel();

  static TuyaCameraPlatform get instance => _instance;

  static set instance(TuyaCameraPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Get a list of cameras added to a home
  Future<List<Map<String, dynamic>>> listCameras({required int homeId});

  /// Get the capabilities of a given camera device
  Future<Map<String, dynamic>> getCameraCapabilities({required String deviceId});

  /// Start live streaming of a given camera
  Future<void> startLiveStream({required String deviceId});

  /// Stop live streaming of a given camera
  Future<void> stopLiveStream({required String deviceId});

  /// Get alerts of a given device
  Future<List<Map<String, dynamic>>> getDeviceAlerts({required String deviceId,required int year, required int month});

  /// Save the current video to a given path
  Future<void> saveVideoToGallery({required String filePath});

  /// Stop saving the video
  Future<void> stopSaveVideoToGallery();

  /// Configure a set of DP codes on a device
  Future<bool> setDeviceDpConfigs({
    required String deviceId,
    required Map<String, dynamic> dps,
  });

  /// Get the current configurations of set of DP codes on a device
  Future<List<Map<String, dynamic>>> getDeviceDpConfigs({
    required String deviceId,
  });


  /// Kick off APNs / FCM registration on the native side
  Future<void> registerPush({
    required int type,required bool isOpen
});

  /// Get all messages
  Future<List<Map<String,dynamic>>> getAllMessages();
}
