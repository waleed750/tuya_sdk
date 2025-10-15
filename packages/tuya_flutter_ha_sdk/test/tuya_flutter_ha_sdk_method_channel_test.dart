import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuya_flutter_ha_sdk/tuya_flutter_ha_sdk_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelTuyaFlutterHaSdk platform = MethodChannelTuyaFlutterHaSdk();
  const MethodChannel channel = MethodChannel('tuya_flutter_ha_sdk');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
