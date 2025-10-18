import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_colors.dart';
import 'add_device_bottom_sheet.dart';
import 'presentation/cubit/devices_cubit.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({Key? key}) : super(key: key);

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
              final devices = [];

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
                    return ListTile(
                      title: Text(device.name),
                      onTap: () {
                        // Device detail navigation would go here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Selected ${device.name}'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    );
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
