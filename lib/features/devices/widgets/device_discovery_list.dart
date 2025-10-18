import 'package:flutter/material.dart';
import '../../../services/tuya_onboarding_service.dart';
import '../data/model/discover_device_model.dart';

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
    return ListView.separated(
      itemCount: devices.length,
      separatorBuilder: (_, _) => Divider(height: 1),
      shrinkWrap: true,
      itemBuilder: (ctx, i) {
        final d = devices[i];
        return ListTile(
          leading: CircleAvatar(child: Icon(Icons.device_unknown)),
          title: Text(d.name),
          subtitle: Text('• ${d.id}'),
          trailing: Icon(Icons.chevron_right),
          onTap: () => onPair(d),
        );
      },
    );
  }
}
