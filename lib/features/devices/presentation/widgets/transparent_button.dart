import 'package:flutter/material.dart';

import '../../../../core/loader_widget.dart';

class TransparentButton extends StatelessWidget {
  const TransparentButton({
    super.key,
    this.onTap,
    required this.isLoading,
    required this.text,
    this.icon,
    this.bgColor,
  });
  final void Function()? onTap;
  final bool isLoading;
  final String text;
  final IconData? icon;
  final Color? bgColor;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        width: 160,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor ?? theme.colorScheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline, // light mode border
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  Icon(
                    icon,
                    color: bgColor != null
                        ? Colors.white
                        : theme.textTheme.titleSmall?.color,
                  ),
                  Opacity(
                    opacity: isLoading ? 0 : 1,
                    child: Text(
                      text,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: bgColor != null ? Colors.white : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              Align(
                alignment: Alignment.center,
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
