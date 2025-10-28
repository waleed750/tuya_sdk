import 'package:example/features/devices/presentation/widgets/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DeviceListTile extends StatelessWidget {
  final Map device;
  final bool isLocked;
  final bool isUnlocked;
  final VoidCallback? onLock;
  final VoidCallback? onUnlock;
  final VoidCallback onViewMore;
  final bool isloading;
  const DeviceListTile({
    super.key,
    required this.device,
    required this.isLocked,
    required this.isUnlocked,
    required this.isloading,
    this.onLock,
    this.onUnlock,
    required this.onViewMore,
  });

  @override
  Widget build(BuildContext context) {
    final iconUrl = device["iconUrl"] ?? device["icon"] ?? "";
    final name = device["name"] ?? "Unnamed Device";
    final mac = device["mac"] ?? "-";
    final isLock =
        (device["category"] == "lock") ||
        (device["dps"] != null &&
            (device["dps"]['1'] == 0 || device["dps"]['1'] == 1));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: iconUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: iconUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      Icon(LucideIcons.router, size: 32),
                )
              : Icon(LucideIcons.router, size: 32),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('MAC: $mac'),
            if (isLock)
              Text(
                isLocked ? 'Status: Locked' : 'Status: Unlocked',
                style: TextStyle(color: isLocked ? Colors.red : Colors.green),
              ),
            if (device["isOnline"] != null) ...[
              Row(
                spacing: 10,
                children: [
                  AvatarGlow(
                    startDelay: const Duration(milliseconds: 500),
                    glowColor: device["isOnline"]
                        ? Color(0xFF84E852)
                        : Colors.transparent,
                    glowShape: BoxShape.circle,
                    animate: device["isOnline"],
                    glowCount: 2,
                    curve: Curves.fastOutSlowIn,
                    repeat: device["isOnline"],
                    // color: isOnline ? success : danger,
                    duration: Duration(seconds: 1),
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: device["isOnline"]
                          ? Color(0xFF6DBE45)
                          : Color(0xFF991B1B),
                    ),
                  ),
                  Text(
                    device["isOnline"] ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: device["isOnline"] ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: isLock
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // IconButton(
                  //   icon: Icon(
                  //     Icons.lock,
                  //     color: isLocked ? Colors.red : Colors.grey,
                  //   ),
                  //   tooltip: 'Lock',
                  //   onPressed: isLocked ? null : onLock,
                  // ),
                  if (!isloading) ...[
                    IconButton(
                      icon: Icon(
                        Icons.lock_open,
                        color: isUnlocked ? Colors.green : Colors.grey,
                      ),
                      tooltip: 'Unlock',
                      onPressed: isUnlocked ? null : onUnlock,
                    ),
                  ] else ...[
                    CircularProgressIndicator(),
                  ],
                  IconButton(
                    icon: Icon(Icons.more_horiz),
                    tooltip: 'View More',
                    onPressed: onViewMore,
                  ),
                ],
              )
            : IconButton(
                icon: Icon(Icons.more_horiz),
                tooltip: 'View More',
                onPressed: onViewMore,
              ),
      ),
    );
  }
}
