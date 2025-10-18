class DiscoveredDevice {
  final String id;
  final String name;
  final String? productId;
  final String? ip;
  DiscoveredDevice({
    required this.id,
    required this.name,
    this.productId,
    this.ip,
  });
}
