import '../../domain/entities/device_entity.dart';

// Interface for Tuya Devices API
abstract class TuyaDevicesApi {
  Future<List<DeviceEntity>> listDevices();
}

// Mock implementation for development
class MockTuyaDevicesApi implements TuyaDevicesApi {
  @override
  Future<List<DeviceEntity>> listDevices() async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Return mock devices
    return [
      const DeviceEntity(
        id: 'device_001',
        name: 'Living Room Light',
        online: true,
        type: 'light',
        iconUrl: 'https://images.tuyacn.com/smart/icon/ay1550808259378Ow2P3/16e859fc5e0b4d3f9265.png',
      ),
      const DeviceEntity(
        id: 'device_002',
        name: 'Bedroom Light',
        online: false,
        type: 'light',
        iconUrl: 'https://images.tuyacn.com/smart/icon/ay1550808259378Ow2P3/16e859fc5e0b4d3f9265.png',
      ),
      const DeviceEntity(
        id: 'device_003',
        name: 'Smart Plug',
        online: true,
        type: 'plug',
        iconUrl: 'https://images.tuyacn.com/smart/icon/ay1550808259378Ow2P3/1551946267703jvkz5.png',
      ),
      const DeviceEntity(
        id: 'device_004',
        name: 'Air Conditioner',
        online: true,
        type: 'ac',
        iconUrl: 'https://images.tuyacn.com/smart/icon/ay1550808259378Ow2P3/1551946589633brusb.png',
      ),
    ];
  }
}