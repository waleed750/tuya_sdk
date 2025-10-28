// import 'package:flutter_test/flutter_test.dart';
// import 'package:tuya_flutter_ha_sdk/tuya_flutter_ha_sdk.dart';
// import 'package:tuya_flutter_ha_sdk/tuya_flutter_ha_sdk_platform_interface.dart';
// import 'package:tuya_flutter_ha_sdk/tuya_flutter_ha_sdk_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockTuyaFlutterHaSdkPlatform
//     with MockPlatformInterfaceMixin
//     implements TuyaFlutterHaSdkPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final TuyaFlutterHaSdkPlatform initialPlatform = TuyaFlutterHaSdkPlatform.instance;

//   test('$MethodChannelTuyaFlutterHaSdk is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelTuyaFlutterHaSdk>());
//   });

//   test('getPlatformVersion', () async {
//     TuyaFlutterHaSdk tuyaFlutterHaSdkPlugin = TuyaFlutterHaSdk();
//     MockTuyaFlutterHaSdkPlatform fakePlatform = MockTuyaFlutterHaSdkPlatform();
//     TuyaFlutterHaSdkPlatform.instance = fakePlatform;

//     expect(await tuyaFlutterHaSdkPlugin.getPlatformVersion(), '42');
//   });
// }
