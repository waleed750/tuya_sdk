import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/app_colors.dart';
import 'add_device_bottom_sheet.dart';
import 'presentation/cubit/devices_cubit.dart';
import 'widgets/device_list_tile.dart';
import 'widgets/device_details_sheet.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  @override
  void initState() {
    super.initState();
    context.read<DevicesCubit>().loadDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Devices'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<DevicesCubit>().loadDevices();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 3),
        child: BlocBuilder<DevicesCubit, DevicesState>(
          buildWhen: (previous, current) =>
              current is! DeviceStateChanged &&
              current is! DeviceErrorChangedState &&
              current is! DeviceStateLoading,
          builder: (context, state) {
            if (state is DevicesInitial || state is DevicesLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            } else if (state is DevicesRefreshing || state is DevicesLoaded) {
              // final devices = state is DevicesRefreshing
              //     ? state.devices
              //     : (state as DevicesLoaded).devices;
              final devices = context.read<DevicesCubit>().devices;

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DevicesCubit>().loadDevices();
                },
                color: AppColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 0,
                  ),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    log('Device: $device');
                    final isLock =
                        (device["category"] == "lock") ||
                        (device["dps"] != null &&
                            (device["dps"]['1'] == 0 ||
                                device["dps"]['1'] == 1));
                    final isLocked =
                        device["dps"] != null && device["dps"]['1'] == 0;
                    final isUnlocked =
                        device["dps"] != null && device["dps"]['1'] == 1;

                    return BlocConsumer<DevicesCubit, DevicesState>(
                      listener: (context, state) {
                        if (state is DeviceErrorChangedState &&
                            state.deviceId ==
                                (device["devId"] ?? device["uuid"])) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.errorMessage),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      listenWhen: (previous, current) =>
                          current is DeviceStateChanged ||
                          current is DeviceErrorChangedState ||
                          current is DeviceStateLoading ||
                          (current is DeviceRemoteUnlockRequested &&
                              current.deviceId ==
                                  (device["devId"] ??
                                      device["id"] ??
                                      device["uuid"])),
                      buildWhen: (previous, current) {
                        return current is DeviceStateChanged ||
                            current is DeviceErrorChangedState ||
                            current is DeviceStateLoading ||
                            (current is DeviceRemoteUnlockRequested &&
                                current.deviceId ==
                                    (device["devId"] ??
                                        device["id"] ??
                                        device["uuid"]));
                      },
                      builder: (context, state) {
                        final isRequestingUnlock =
                            state is DeviceRemoteUnlockRequested &&
                            state.deviceId ==
                                (device["devId"] ??
                                    device["id"] ??
                                    device["uuid"]);
                        return Column(
                          children: [
                            if (isRequestingUnlock)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Text(
                                  'User is now requesting an unlock...',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            Dismissible(
                              key: ValueKey(
                                device["devId"] ?? device["id"] ?? index,
                              ),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text('Delete Smart Lock'),
                                        content: Text(
                                          'Are you sure you want to delete this smart lock?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            child: Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ) ??
                                    false;
                              },
                              onDismissed: (direction) {
                                // TODO: Call cubit/device delete method here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Smart lock deleted')),
                                );
                              },
                              child: DeviceListTile(
                                device: device,
                                isLocked: isLocked,
                                isUnlocked: isUnlocked,
                                isloading:
                                    state is DeviceStateLoading &&
                                    state.deviceId ==
                                        (device["devId"] ?? device["uuid"]),
                                onLock: () => context
                                    .read<DevicesCubit>()
                                    .lockDevice(device),
                                onUnlock: () => context
                                    .read<DevicesCubit>()
                                    .unlockDevice(device),
                                onViewMore: () => showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) =>
                                      DeviceDetailsSheet(device: device),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                    // } else {
                    //   // Default widget for non-lock devices
                    //   return DeviceListTile(
                    //     device: device,
                    //     isLocked: false,
                    //     isUnlocked: false,
                    //     onLock: null,
                    //     onUnlock: null,
                    //     isloading:
                    //         state is DeviceStateLoading &&
                    //         state.deviceId ==
                    //             (device["devId"] ?? device["uuid"]),
                    //     onViewMore: () => showModalBottomSheet(
                    //       context: context,
                    //       isScrollControlled: true,
                    //       backgroundColor: Colors.transparent,
                    //       builder: (_) => DeviceDetailsSheet(device: device),
                    //     ),
                    //   );
                    // }
                  },
                ),
              );
            }
            // س
            return Center(child: Text('No devices yet. Tap + to add one.'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          isScrollControlled: true,
          builder: (_) => AddDeviceBottomSheet(),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
