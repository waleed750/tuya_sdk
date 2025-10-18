import 'package:example/core/app_colors.dart';
import 'package:example/features/devices/presentation/cubit/devices_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/permissions_service.dart';
import '../../services/tuya_onboarding_service.dart';
import 'connection_cubit.dart' as connection;
import 'widgets/device_discovery_list.dart';

class WifiOnboardingPage extends StatefulWidget {
  const WifiOnboardingPage({Key? key}) : super(key: key);

  @override
  State<WifiOnboardingPage> createState() => _WifiOnboardingPageState();
}

class _WifiOnboardingPageState extends State<WifiOnboardingPage> {
  @override
  void dispose() {
    context.read<connection.ConnecitonCubit>().stopWifiScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add via Wi‑Fi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 25,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Open system Wi‑Fi settings and connect to your device\'s AP. Return to the app to continue.',
            ),
            Text(
              "Current Wifi SSID: ${context.read<DevicesCubit>().currentSSID}\nReady to pair devices - Home ID : ${context.read<DevicesCubit>().currentHomeId}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.deviceOnline,
              ),
            ),
            Row(
              spacing: 10,
              children: [
                // Expanded(
                //   child: ElevatedButton(
                //     onPressed: () {
                //       // Open Wi-Fi settings - platform specific; use Intent via url launcher in real app.
                //       // TODO: implement open wifi settings.
                //     },
                //     child: Text('Open Wi‑Fi Settings'),
                //   ),
                // ),
                BlocBuilder<
                  connection.ConnecitonCubit,
                  connection.ConnectionState
                >(
                  builder: (context, state) {
                    final isScanning = context
                        .read<connection.ConnecitonCubit>()
                        .isScanning;
                    return Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainer,
                        ),
                        onPressed: () async {
                          if (isScanning) {
                            context
                                .read<connection.ConnecitonCubit>()
                                .stopWifiScan();
                            return;
                          }
                          final ok = await PermissionsService.instance
                              .ensureWifiScanPermissions(context);
                          if (!ok) return;
                          if (context.mounted) {
                            await context
                                .read<connection.ConnecitonCubit>()
                                .startWifiScan();
                          }
                        },
                        child: Row(
                          spacing: 10,
                          children: [
                            Text(isScanning ? 'Stop Scan' : 'Start Scanning '),
                            if (isScanning) CupertinoActivityIndicator(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: 16),
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
                    SnackBar(content: Text('Paired ${state.device.name}')),
                  );
                  Navigator.of(ctx).popUntil((route) => route.isFirst);
                }
              },
              builder: (ctx, state) {
                if (state is connection.OnboardingScanning) {
                  return Expanded(
                    child: Column(
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
                    ),
                  );
                }
                if (state is connection.OnboardingDevicesFound) {
                  return Expanded(
                    child: DeviceDiscoveryList(
                      devices: state.devices,
                      onPair: (d) => _showPairDialog(ctx, d),
                    ),
                  );
                }
                return Center(
                  child: Text('No scan active. Tap "I\'m Connected" to start.'),
                );
              },
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
