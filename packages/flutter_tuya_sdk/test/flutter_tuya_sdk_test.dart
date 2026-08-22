import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tuya_sdk/flutter_tuya_sdk_platform_interface.dart';
import 'package:flutter_tuya_sdk/flutter_tuya_sdk_method_channel.dart';

void main() {
  final FlutterTuyaSdkPlatform initialPlatform = FlutterTuyaSdkPlatform.instance;

  test('$MethodChannelFlutterTuyaSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterTuyaSdk>());
  });
}
