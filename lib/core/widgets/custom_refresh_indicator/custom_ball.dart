import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../app_colors.dart';

class AnimatedBallWithProgress extends StatefulWidget {
  const AnimatedBallWithProgress({super.key});

  @override
  State<AnimatedBallWithProgress> createState() =>
      _AnimatedBallWithProgressState();
}

class _AnimatedBallWithProgressState extends State<AnimatedBallWithProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
        ),
        Positioned.fill(
          child: CircularProgressIndicator(
            strokeWidth: 5,
            strokeAlign: 2,
            strokeCap: StrokeCap.round,
            color: AppColors.background,
          ),
        ),
      ],
    );
    // .scale(duration: 1.seconds);seconds: 2
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
