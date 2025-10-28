import 'package:flutter/material.dart';

class MapControlButton extends StatelessWidget {
  const MapControlButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 30,
    this.borderRadius = 6,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: theme.colorScheme.onPrimary, width: 1),
        ),
        child: Icon(icon, size: 18, color: theme.colorScheme.secondary),
      ),
    );
  }
}
