import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/app_colors.dart';
import '../cubit/devices_cubit.dart';

class DevicesListPage extends StatefulWidget {
  const DevicesListPage({super.key});

  @override
  State<DevicesListPage> createState() => _DevicesListPageState();
}

class _DevicesListPageState extends State<DevicesListPage> {
  @override
  void initState() {
    super.initState();
    context.read<DevicesCubit>().loadDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Devices'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<DevicesCubit, DevicesState>(
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
            if (devices.isEmpty) {
              return _buildEmptyState();
            }

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
                  return SizedBox.shrink();
                  // return DeviceTile(
                  //   device: device,
                  //   onTap: () {
                  //     // Device detail navigation would go here
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(
                  //         content: Text('Selected ${device.name}'),
                  //         duration: const Duration(seconds: 1),
                  //       ),
                  //     );
                  //   },
                  // );
                },
              ),
            );
          } else if (state is DevicesError) {
            return _buildErrorState(state.message);
          }

          return Container();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DevicesCubit>().loadDevices();
      },
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          const Icon(LucideIcons.list, size: 64, color: AppColors.neutral400),
          const SizedBox(height: 24),
          const Text(
            'No devices found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Add devices to your Tuya Smart Home to see them here',
            style: TextStyle(fontSize: 16, color: AppColors.neutral600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // context.read<DevicesCubit>().refreshDevices();
            },
            icon: Icon(LucideIcons.refreshCw),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return RefreshIndicator(
      onRefresh: () => context.read<DevicesCubit>().loadDevices(),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          const Icon(LucideIcons.badgeInfo, size: 64, color: AppColors.error),
          const SizedBox(height: 24),
          const Text(
            'Error loading devices',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: AppColors.neutral600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<DevicesCubit>().loadDevices();
            },
            icon: const Icon(LucideIcons.refreshCw),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
