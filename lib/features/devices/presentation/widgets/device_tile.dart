import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_flutter.dart';

import '../../../../core/app_colors.dart';
import '../../domain/entities/device_entity.dart';

class DeviceTile extends StatelessWidget {
  final DeviceEntity device;
  final VoidCallback? onTap;

  const DeviceTile({
    Key? key,
    required this.device,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildDeviceIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.type ?? 'Device',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceIcon() {
    IconData iconData;
    
    switch (device.type?.toLowerCase()) {
      case 'light':
        iconData = LucideIcons.lightbulb;
        break;
      case 'plug':
        iconData = LucideIcons.plug;
        break;
      case 'ac':
        iconData = LucideIcons.fan;
        break;
      default:
        iconData = LucideIcons.smartphone;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: device.online ? AppColors.success : AppColors.error,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          device.online ? 'Online' : 'Offline',
          style: TextStyle(
            fontSize: 14,
            color: device.online ? AppColors.success : AppColors.error,
          ),
        ),
      ],
    );
  }
}