import 'package:flutter/material.dart';

class TimelineLinePainter extends CustomPainter {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;

  TimelineLinePainter({
    required this.currentStep,
    required this.totalSteps,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final segmentWidth = size.width / (totalSteps - 1);

    for (int i = 0; i < totalSteps - 1; i++) {
      final startX = i * segmentWidth;
      final endX = (i + 1) * segmentWidth;

      // Draw active color from step 1 to current step
      if (i < currentStep - 1) {
        paint.color = activeColor;
      } else {
        paint.color = inactiveColor;
      }

      canvas.drawLine(
        Offset(startX, 0),
        Offset(endX, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(TimelineLinePainter oldDelegate) {
    return oldDelegate.currentStep != currentStep;
  }
}
