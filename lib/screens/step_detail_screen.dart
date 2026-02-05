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
