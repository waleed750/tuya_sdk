import 'package:example/core/app_colors.dart';
import 'package:example/features/devices/data/model/discover_device_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/permissions_service.dart';
import 'connection_cubit.dart' as connection;
import 'widgets/device_discovery_list.dart';
import 'package:example/features/devices/presentation/cubit/devices_cubit.dart';

class BleOnboardingPage extends StatefulWidget {
  const BleOnboardingPage({Key? key}) : super(key: key);

  @override
  State<BleOnboardingPage> createState() => _BleOnboardingPageState();
}

class _BleOnboardingPageState extends State<BleOnboardingPage> {
  @override
  void dispose() {
    context.read<connection.ConnecitonCubit>().stopBleScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<connection.ConnecitonCubit>();
    final devicesCubit = context.read<DevicesCubit>();
    final isScanning = conn.isScanning;

    return Scaffold(
      appBar: AppBar(title: const Text('Add via Bluetooth')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Scanning for nearby Tuya BLE devices…'),
            const SizedBox(height: 12),
            Container(
              height: 50,
              child: Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.primary,

                        foregroundColor: Colors.white,
                        overlayColor: Colors.white24,
                      ),
                      onPressed: isScanning
                          ? null
                          : () async {
                              final ok = await PermissionsService.instance
                                  .ensureBlePermissions(context);
                              if (!ok) return;
                              await context
                                  .read<connection.ConnecitonCubit>()
                                  .startBleScan(timeoutSeconds: 30);
                            },
                      child: const Text('Start Scan'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isScanning
                          ? () async {
                              await context
                                  .read<connection.ConnecitonCubit>()
                                  .stopBleScan();
                            }
                          : null,
                      child: const Text('Stop'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 300,
              child:
                  BlocConsumer<
                    connection.ConnecitonCubit,
                    connection.ConnectionState
                  >(
                    listener: (ctx, state) async {
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
                        // Optional: refresh your home’s devices list after pairing
                        await ctx.read<DevicesCubit>().loadDevices();
                        if (ctx.mounted) {
                          Navigator.of(ctx).pop();
                        }
                      }
                    },
                    builder: (ctx, state) {
                      if (state is connection.OnboardingScanning) {
                        return Column(
                          children: [
                            const LinearProgressIndicator(),
                            const SizedBox(height: 8),
                            Text('Scanning… ${state.secondsLeft}s left'),
                            const Spacer(),
                          ],
                        );
                      }

                      if (state is connection.OnboardingDevicesFound) {
                        return DeviceDiscoveryList(
                          devices: state.devices,
                          // ⬇️ Immediate pairing on tap — no dialog.
                          onPair: (DiscoveredDevice d) async {
                            final homeId = devicesCubit.currentHomeId;
                            if (homeId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a Home first'),
                                ),
                              );
                              return;
                            }
                            await context
                                .read<connection.ConnecitonCubit>()
                                .pairSelected(
                                  d,
                                  homeId: homeId, // required for BLE binding
                                );
                          },
                        );
                      }

                      return const Center(
                        child: Text('Tap “Start Scan” to find BLE devices.'),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
