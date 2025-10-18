import 'package:flutter/material.dart';
import '../../../services/tuya_onboarding_service.dart';

class DeviceDiscoveryList extends StatelessWidget {
  final List<DiscoveredDevice> devices;
  final void Function(DiscoveredDevice) onPair;

  const DeviceDiscoveryList({
    Key? key,
    required this.devices,
    required this.onPair,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return Center(child: Text('No devices found.'));
    }
    return ListView.separated(
      itemCount: devices.length,
      separatorBuilder: (_, _) => Divider(height: 1),
      shrinkWrap: true,
      itemBuilder: (ctx, i) {
        final d = devices[i];
        return ListTile(
          leading: CircleAvatar(child: Icon(d.icon ?? Icons.device_unknown)),
          title: Text(d.name),
          subtitle: Text(d.rssi != null ? 'RSSI ${d.rssi} • ${d.id}' : d.id),
          trailing: Icon(Icons.chevron_right),
          onTap: () => onPair(d),
        );
      },
    );
  }
}
