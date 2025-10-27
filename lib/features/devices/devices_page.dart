import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_colors.dart';
import 'add_device_bottom_sheet.dart';
import 'presentation/cubit/devices_cubit.dart';

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
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<DevicesCubit, DevicesState>(
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
                  padding: const EdgeInsets.all(16),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    log('Device: $device');
                    // Determine if this device is a smart lock (by type or dps)
                    final isLock =
                        (device["category"] == "lock") ||
                        (device["dps"] != null &&
                            (device["dps"]['1'] == 0 ||
                                device["dps"]['1'] == 1));
                    final isLocked =
                        device["dps"] != null && device["dps"]['1'] == 0;
                    final isUnlocked =
                        device["dps"] != null && device["dps"]['1'] == 1;

                    Widget listTile = ListTile(
                      title: Row(
                        children: [
                          Text(device["name"] ?? "Unnamed Device"),
                          if (isLock)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(
                                isLocked ? Icons.lock : Icons.lock_open,
                                color: isLocked ? Colors.red : Colors.green,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                      trailing: isLock
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.lock,
                                    color: isLocked ? Colors.red : Colors.grey,
                                  ),

                                  tooltip: isLocked ? 'Lock' : 'Unlock',
                                  onPressed: isLocked
                                      ? () => context
                                            .read<DevicesCubit>()
                                            .unlockDevice(device)
                                      : () => context
                                            .read<DevicesCubit>()
                                            .lockDevice(device),
                                ),
                              ],
                            )
                          : null,
                      // onTap: () {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(
                      //       content: Text('Selected ${device["name"]}'),
                      //       duration: const Duration(seconds: 1),
                      //     ),
                      //   );
                      // },
                    );

                    if (isLock) {
                      // Only allow swipe-to-delete for lock devices
                      return Dismissible(
                        key: ValueKey(device["devId"] ?? device["id"] ?? index),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                        style: TextStyle(color: Colors.red),
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
                        child: listTile,
                      );
                    } else {
                      return listTile;
                    }
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
