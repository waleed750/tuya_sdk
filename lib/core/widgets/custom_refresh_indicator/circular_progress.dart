// ignore_for_file: library_private_types_in_public_api

import 'dart:math';

import 'package:flutter/material.dart';

/// Progress Indicator for [LiquidPullToRefresh]
class CircularProgress extends StatefulWidget {
  final double innerCircleRadius;
  final double progressPercent;
  final double progressCircleOpacity;
  final double progressCircleRadius;
  final double progressCircleBorderWidth;
  final Color backgroundColor;
  final double startAngle;

  const CircularProgress({
    super.key,
    required this.innerCircleRadius,
    required this.progressPercent,
    required this.progressCircleRadius,
    required this.progressCircleBorderWidth,
    required this.backgroundColor,
    required this.progressCircleOpacity,
    required this.startAngle,
  });

  @override
  _CircularProgressState createState() => _CircularProgressState();
}

class _CircularProgressState extends State<CircularProgress> {
  @override
  Widget build(BuildContext context) {
    double containerLength =
        2 * max(widget.progressCircleRadius, widget.innerCircleRadius);

    return SizedBox(
      height: containerLength,
      width: containerLength,
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: widget.progressCircleOpacity,
            child: SizedBox(
              height: widget.progressCircleRadius * 2,
              width: widget.progressCircleRadius * 2,
              child: CustomPaint(
                painter: RingPainter(
                  startAngle: widget.startAngle,
                  paintWidth: widget.progressCircleBorderWidth,
                  progressPercent: widget.progressPercent,
                  trackColor: widget.backgroundColor,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: widget.innerCircleRadius * 2,
              height: widget.innerCircleRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.backgroundColor,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CircularProgressIndicator extends StatefulWidget {
  const CircularProgressIndicator({super.key});

  @override
  _CircularProgressIndicatorState createState() =>
      _CircularProgressIndicatorState();
}

class _CircularProgressIndicatorState extends State<CircularProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class RingPainter extends CustomPainter {
  final double paintWidth;
  final Paint trackPaint;
  final Color trackColor;
  final double progressPercent;
  final double startAngle;

  RingPainter({
    required this.startAngle,
    required this.paintWidth,
    required this.progressPercent,
    required this.trackColor,
  }) : trackPaint = Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = paintWidth
          ..strokeCap = StrokeCap.square;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - paintWidth) / 2;

    final progressAngle = 2 * pi * progressPercent;

    canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        startAngle,
        progressAngle,
        false,
        trackPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
