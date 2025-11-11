import 'package:example/core/app_colors.dart';
import 'package:example/features/devices/presentation/cubit/devices_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/permissions_service.dart';
import 'connection_cubit.dart' as connection;
import 'data/model/discover_device_model.dart';
import 'widgets/device_discovery_list.dart';

class WifiOnboardingPage extends StatefulWidget {
  const WifiOnboardingPage({super.key});

  @override
  State<WifiOnboardingPage> createState() => _WifiOnboardingPageState();
}

class _WifiOnboardingPageState extends State<WifiOnboardingPage> {
  late final TextEditingController _wifiSSIDController;
  late final TextEditingController _wifiPasswordController;
  String _mode = 'AP'; // or 'EZ'

  @override
  void initState() {
    _wifiSSIDController = TextEditingController();
    _wifiPasswordController = TextEditingController();
    super.initState();

    // Pre-fill SSID from DevicesCubit (if available)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ssid = context.read<DevicesCubit>().currentSSID;
      if (ssid != null && ssid.isNotEmpty) {
        _wifiSSIDController.text = ssid;
      }
    });
  }

  @override
  void dispose() {
    if (!context.read<connection.ConnecitonCubit>().isClosed) {
      context.read<connection.ConnecitonCubit>().stopWifiScan();
    }
    _wifiSSIDController.dispose();
    _wifiPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devicesCubit = context.read<DevicesCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Add via Wi-Fi')),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _mode == 'AP'
                    ? 'AP mode: connect your phone to the device hotspot (e.g., SmartLife-XXXX), then return here.'
                    : _mode == 'Combo'
                    ? 'Combo mode: automatically discovers and pairs Wi-Fi + BLE dual-mode devices.'
                    : 'EZ mode: keep the phone on 2.4 GHz Wi-Fi and make sure the device LED is flashing fast.',
              ),
              Text(
                "Current Wi-Fi SSID: ${devicesCubit.currentSSID ?? '—'}\nHome ID: ${devicesCubit.currentHomeId ?? '—'}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.deviceOnline,
                ),
              ),

              // Mode picker
              DropdownButtonFormField<String>(
                initialValue: _mode,
                items: const [
                  DropdownMenuItem(
                    value: 'EZ',
                    child: Text('EZ (SmartConfig)'),
                  ),
                  DropdownMenuItem(
                    value: 'AP',
                    child: Text('AP (Device Hotspot)'),
                  ),
                  DropdownMenuItem(
                    value: 'Combo',
                    child: Text('Combo (Wi-Fi + BLE)'),
                  ),
                ],
                onChanged: (v) => setState(() => _mode = v ?? 'AP'),
                decoration: const InputDecoration(
                  labelText: 'Pairing Mode',
                  border: OutlineInputBorder(),
                ),
              ),

              // SSID
              TextFormField(
                controller: _wifiSSIDController,
                decoration: const InputDecoration(
                  labelText: 'Wi-Fi SSID',
                  border: OutlineInputBorder(),
                ),
              ),

              // Password
              TextFormField(
                controller: _wifiPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Wi-Fi Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),

              Row(
                spacing: 10,
                children: [
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
                            ).colorScheme.primary,
                          ),
                          onPressed: isScanning
                              ? () async {
                                  await context
                                      .read<connection.ConnecitonCubit>()
                                      .stopWifiScan();
                                }
                              : () async {
                                  // Permissions
                                  final ok = await PermissionsService.instance
                                      .ensureWifiScanPermissions(context);
                                  if (!ok) return;

                                  // Inputs
                                  final ssid = _wifiSSIDController.text.trim();
                                  final pwd = _wifiPasswordController.text;

                                  if (devicesCubit.currentHomeId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please select a Home first',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  if (ssid.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('SSID is required'),
                                      ),
                                    );
                                    return;
                                  }
                                  if (pwd.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Wi-Fi password is required',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  // Check mode and call appropriate method
                                  if (_mode == 'Combo') {
                                    // Use combo pairing

                                    await context
                                        .read<connection.ConnecitonCubit>()
                                        .startWifiComboPairing(
                                          homeId: devicesCubit.currentHomeId!,
                                          ssid: ssid,
                                          password: pwd,
                                          timeoutSeconds: 120,
                                        );
                                    // .startWifiBleComboConfig(
                                    //   homeId: devicesCubit.currentHomeId!,
                                    //   ssid: ssid,
                                    //   wifiPassword: pwd,
                                    //   scanTimeoutSeconds: 30,
                                    //   pairTimeoutSeconds: 120,
                                    // );
                                  } else {
                                    // Use regular Wi-Fi scan (EZ or AP mode)
                                    await context
                                        .read<connection.ConnecitonCubit>()
                                        .startWifiScan(
                                          homeId: devicesCubit.currentHomeId!,
                                          ssid: ssid,
                                          wifiPassword: pwd,
                                          mode: _mode, // 'EZ' or 'AP'
                                          timeoutSeconds: 120,
                                        );
                                  }
                                },
                          child: Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(isScanning ? 'Stop' : 'Start Scanning'),
                              if (isScanning)
                                const CupertinoActivityIndicator(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Results & progress
              SizedBox(
                height: 200,
                child: BlocConsumer<connection.ConnecitonCubit, connection.ConnectionState>(
                  listener: (ctx, state) async {
                    if (state is connection.OnboardingError) {
                      ScaffoldMessenger.of(
                        ctx,
                      ).showSnackBar(SnackBar(content: Text(state.message)));
                    }
                    if (state is connection.OnboardingPairedSuccess) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('Paired ${state.device.name}')),
                      );
                      // Refresh your home device list so the new one shows up
                      await ctx.read<DevicesCubit>().loadDevices();
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                      }
                    }
                  },
                  builder: (ctx, state) {
                    if (state is connection.OnboardingScanning) {
                      // While activator runs, show progress.
                      // In EZ mode you usually won't see a device list; success comes back directly.
                      final d = context
                          .read<connection.ConnecitonCubit>()
                          .device;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const LinearProgressIndicator(),
                          const SizedBox(height: 8),
                          Text('Pairing… ${state.secondsLeft}s left'),
                          const SizedBox(height: 8),
                          // If your cubit surfaces a device during AP/EZ, allow tap-to-pair immediately.
                          Expanded(
                            child: DeviceDiscoveryList(
                              devices: d == null ? const [] : [d],
                              // ⬇️ immediate pair on tap (no confirmation)
                              onPair: (DiscoveredDevice dev) async {
                                await context
                                    .read<connection.ConnecitonCubit>()
                                    .pairSelected(dev);
                              },
                            ),
                          ),
                        ],
                      );
                    }

                    if (state is connection.OnboardingDevicesFound) {
                      // If your flow surfaces devices before final success (mostly AP),
                      // enable tap-to-pair without confirmation
                      return Expanded(
                        child: DeviceDiscoveryList(
                          devices: state.devices,
                          onPair: (DiscoveredDevice dev) async {
                            await context
                                .read<connection.ConnecitonCubit>()
                                .pairSelected(dev);
                          },
                        ),
                      );
                    }

                    return Center(
                      child: Text(
                        'No scan active. Configure above and start scanning.',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
