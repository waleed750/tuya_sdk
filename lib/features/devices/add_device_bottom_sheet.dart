import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddDeviceBottomSheet extends StatelessWidget {
  const AddDeviceBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 12),
            Text('Add Device', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _OptionCard(
                    icon: Icons.wifi,
                    title: 'Add via Wi‑Fi',
                    subtitle:
                        'Connect to device Wi‑Fi, we\'ll discover it automatically.',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/onboarding/wifi');
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _OptionCard(
                    icon: Icons.bluetooth,
                    title: 'Add via Bluetooth',
                    subtitle: 'Scan nearby BLE devices and pair securely.',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/onboarding/ble');
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 6),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
