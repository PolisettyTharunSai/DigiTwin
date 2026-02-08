import 'package:flutter/material.dart';
import 'steps/step1.dart';
import 'steps/step2.dart';
import 'steps/step3.dart';
import 'steps/step4.dart';
import 'steps/step5.dart';
import 'steps/step6.dart';

class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);

    path.quadraticBezierTo(
      size.width * 0.05,
      size.height,
      size.width * 0.15,
      size.height,
    );

    path.lineTo(size.width * 0.85, size.height);

    path.quadraticBezierTo(
      size.width * 0.95,
      size.height,
      size.width,
      size.height - 20,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _ProgressLinePainter extends CustomPainter {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;

  _ProgressLinePainter({
    required this.currentStep,
    required this.totalSteps,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
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
  bool shouldRepaint(_ProgressLinePainter oldDelegate) {
    return oldDelegate.currentStep != currentStep;
  }
}


class StepDetailScreen extends StatelessWidget {
  final int stepIndex;
  final String title;

  const StepDetailScreen({
    super.key,
    required this.stepIndex,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF9644);
    const background = Color(0xFFFFFDF1);
    final String locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- HEADER (STATIC) ----------
          ClipPath(
            clipper: _BottomCurveClipper(),
            child: Container(
              padding: const EdgeInsets.only(
                top: 50,
                left: 10,
                right: 10,
                bottom: 18,
              ),
              width: double.infinity,
              color: primaryOrange,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------- STEP PROGRESS INDICATOR ----------
          _buildStepProgressIndicator(),

          // ---------- SCROLLABLE CONTENT ----------
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: _getStepContent(locale),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepProgressIndicator() {
    const primaryOrange = Color(0xFFFF9644);
    const lightOrange = Color(0xFFFFCE99);
    const background = Color(0xFFFFFDF1);

    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final iconSize = 44.0;
          final spacing = (constraints.maxWidth - (6 * iconSize)) / 5;

          return SizedBox(
            height: 70,
            child: Stack(
              children: [
                // Progress lines
                Positioned(
                  top: iconSize / 2 - 2,
                  left: iconSize / 2,
                  right: iconSize / 2,
                  child: CustomPaint(
                    painter: _ProgressLinePainter(
                      currentStep: stepIndex,
                      totalSteps: 6,
                      activeColor: primaryOrange,
                      inactiveColor: lightOrange.withOpacity(0.3),
                    ),
                  ),
                ),
                // Step icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    final stepNumber = index + 1;
                    final isActive = stepNumber == stepIndex;
                    final isCompleted = stepNumber < stepIndex;
                    final isReachable = stepNumber <= stepIndex;

                    return _buildStepIcon(
                      stepNumber: stepNumber,
                      isActive: isActive,
                      isCompleted: isCompleted,
                      isReachable: isReachable,
                      iconSize: iconSize,
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepIcon({
    required int stepNumber,
    required bool isActive,
    required bool isCompleted,
    required bool isReachable,
    required double iconSize,
  }) {
    const primaryOrange = Color(0xFFFF9644);
    const lightOrange = Color(0xFFFFCE99);
    const darkBrown = Color(0xFF562F00);

    Color backgroundColor;
    Color iconColor;

    if (isActive) {
      backgroundColor = primaryOrange;
      iconColor = Colors.white;
    } else if (isCompleted) {
      backgroundColor = lightOrange;
      iconColor = darkBrown;
    } else {
      backgroundColor = lightOrange.withOpacity(0.3);
      iconColor = darkBrown.withOpacity(0.4);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: primaryOrange.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            _getStepIcon(stepNumber),
            color: iconColor,
            size: 22,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'STEP $stepNumber',
          style: TextStyle(
            fontSize: 9,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isReachable ? darkBrown : darkBrown.withOpacity(0.4),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  IconData _getStepIcon(int stepNumber) {
    switch (stepNumber) {
      case 1:
        return Icons.menu_book_rounded;
      case 2:
        return Icons.wb_sunny_rounded;
      case 3:
        return Icons.settings_rounded;
      case 4:
        return Icons.grain_rounded;
      case 5:
        return Icons.science_rounded;
      case 6:
        return Icons.water_drop_rounded;
      default:
        return Icons.circle;
    }
  }

  Widget _getStepContent(String locale) {
    switch (stepIndex) {
      case 1:
        return Step1Content(locale: locale);
      case 2:
        return Step2Content(locale: locale);
      case 3:
        return Step3Content(locale: locale);
      case 4:
        return Step4Content(locale: locale);
      case 5:
        return Step5Content(locale: locale);
      case 6:
        return Step6Content(locale: locale);
      default:
        return Step1Content(locale: locale);
    }
  }
}
