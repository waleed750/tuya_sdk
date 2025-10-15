import 'package:equatable/equatable.dart';

class DeviceEntity extends Equatable {
  final String id;
  final String name;
  final bool online;
  final String? type;
  final String? iconUrl;

  const DeviceEntity({
    required this.id,
    required this.name,
    required this.online,
    this.type,
    this.iconUrl,
  });

  @override
  List<Object?> get props => [id, name, online, type, iconUrl];
}