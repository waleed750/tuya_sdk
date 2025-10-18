import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/permissions_service.dart';
import '../../services/tuya_onboarding_service.dart';
import 'connection_cubit.dart' as connection;
import 'widgets/device_discovery_list.dart';

class BleOnboardingPage extends StatefulWidget {
  const BleOnboardingPage({Key? key}) : super(key: key);

  @override
  State<BleOnboardingPage> createState() => _BleOnboardingPageState();
}

class _BleOnboardingPageState extends State<BleOnboardingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    context.read<connection.ConnecitonCubit>().stopBleScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add via Bluetooth')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Scanning for nearby BLE devices...'),
            SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final ok = await PermissionsService.instance
                        .ensureBlePermissions(context);
                    if (!ok) return;
                    await context
                        .read<connection.ConnecitonCubit>()
                        .startBleScan();
                  },
                  child: Text('Start Scan'),
                ),
                SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () async {
                    await context
                        .read<connection.ConnecitonCubit>()
                        .stopBleScan();
                  },
                  child: Text('Stop'),
                ),
              ],
            ),
            SizedBox(height: 12),
            Expanded(
              child:
                  BlocConsumer<
                    connection.ConnecitonCubit,
                    connection.ConnectionState
                  >(
                    listener: (ctx, state) {
                      if (state is connection.OnboardingError) {
                        ScaffoldMessenger.of(
                          ctx,
                        ).showSnackBar(SnackBar(content: Text(state.message)));
                      }
                      if (state is connection.OnboardingPairedSuccess) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('Paired ${state.device.name}'),
                          ),
                        );
                        Navigator.of(ctx).popUntil((route) => route.isFirst);
                      }
                    },
                    builder: (ctx, state) {
                      if (state is connection.OnboardingScanning) {
                        return Column(
                          children: [
                            LinearProgressIndicator(),
                            SizedBox(height: 8),
                            Text('Scanning... ${state.secondsLeft}s left'),
                            Expanded(
                              child: DeviceDiscoveryList(
                                devices: const [],
                                onPair: (d) => _showPairDialog(ctx, d),
                              ),
                            ),
                          ],
                        );
                      }
                      if (state is connection.OnboardingDevicesFound) {
                        return DeviceDiscoveryList(
                          devices: state.devices,
                          onPair: (d) => _showPairDialog(ctx, d),
                        );
                      }
                      return Center(
                        child: Text('Tap Start Scan to find BLE devices.'),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPairDialog(
    BuildContext ctx,
    DiscoveredDevice device,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: ctx,
      builder: (c) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Put device in pairing mode then tap Pair.'),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(c).pop(true);
                },
                child: Text('Pair'),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(c).pop(false),
                child: Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
    if (confirmed == true) {
      await context.read<connection.ConnecitonCubit>().pairSelected(device);
    }
  }
}
