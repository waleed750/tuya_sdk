// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DiscoveredDevice {
  final String id;
  final String name;
  final String? productId;
  final String? uuid;
  final String? mac;
  final String? providerName;
  final String? flag;
  final String? address;
  final String? bleType;
  final String? deviceType;
  final String? configType;
  final String? ip;

  DiscoveredDevice({
    required this.id,
    required this.name,
    this.productId,
    this.uuid,
    this.mac,
    this.providerName,
    this.flag,
    this.address,
    this.bleType,
    this.deviceType,
    this.configType,
    this.ip,
  });

  DiscoveredDevice copyWith({
    String? id,
    String? name,
    String? productId,
    String? uuid,
    String? mac,
    String? providerName,
    String? flag,
    String? address,
    String? bleType,
    String? deviceType,
    String? configType,
    String? ip,
  }) {
    return DiscoveredDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      productId: productId ?? this.productId,
      uuid: uuid ?? this.uuid,
      mac: mac ?? this.mac,
      providerName: providerName ?? this.providerName,
      flag: flag ?? this.flag,
      address: address ?? this.address,
      bleType: bleType ?? this.bleType,
      deviceType: deviceType ?? this.deviceType,
      configType: configType ?? this.configType,
      ip: ip ?? this.ip,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'productId': productId,
      'uuid': uuid,
      'mac': mac,
      'providerName': providerName,
      'flag': flag,
      'address': address,
      'bleType': bleType,
      'deviceType': deviceType,
      'configType': configType,
      'ip': ip,
    };
  }

  factory DiscoveredDevice.fromMap(Map<String, dynamic> map) {
    return DiscoveredDevice(
      id: map['id'] as String,
      name: map['name'] as String,
      productId: map['productId'] != null ? map['productId'] as String : null,
      uuid: map['uuid'] != null ? map['uuid'] as String : null,
      mac: map['mac'] != null ? map['mac'] as String : null,
      providerName: map['providerName'] != null
          ? map['providerName'] as String
          : null,
      flag: map['flag'] != null ? map['flag'] as String : null,
      address: map['address'] != null ? map['address'] as String : null,
      bleType: map['bleType'] != null ? map['bleType'] as String : null,
      deviceType: map['deviceType'] != null
          ? map['deviceType'] as String
          : null,
      configType: map['configType'] != null
          ? map['configType'] as String
          : null,
      ip: map['ip'] != null ? map['ip'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DiscoveredDevice.fromJson(String source) =>
      DiscoveredDevice.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DiscoveredDevice(id: $id, name: $name, productId: $productId, uuid: $uuid, mac: $mac, providerName: $providerName, flag: $flag, address: $address, bleType: $bleType, deviceType: $deviceType, configType: $configType, ip: $ip)';
  }

  @override
  bool operator ==(covariant DiscoveredDevice other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.productId == productId &&
        other.uuid == uuid &&
        other.mac == mac &&
        other.providerName == providerName &&
        other.flag == flag &&
        other.address == address &&
        other.bleType == bleType &&
        other.deviceType == deviceType &&
        other.configType == configType &&
        other.ip == ip;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        productId.hashCode ^
        uuid.hashCode ^
        mac.hashCode ^
        providerName.hashCode ^
        flag.hashCode ^
        address.hashCode ^
        bleType.hashCode ^
        deviceType.hashCode ^
        configType.hashCode ^
        ip.hashCode;
  }
}
