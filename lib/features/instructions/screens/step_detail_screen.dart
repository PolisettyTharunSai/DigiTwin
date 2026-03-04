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
    path.quadraticBezierTo(size.width * 0.05, size.height, size.width * 0.15, size.height);
    path.lineTo(size.width * 0.85, size.height);
    path.quadraticBezierTo(size.width * 0.95, size.height, size.width, size.height - 20);
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
  final bool isRtl;
  final Color activeColor;
  final Color inactiveColor;

  _ProgressLinePainter({
    required this.currentStep,
    required this.totalSteps,
    required this.isRtl,
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
      int logicalIndex = isRtl ? (totalSteps - 2 - i) : i;
      paint.color = logicalIndex < currentStep - 1 ? activeColor : inactiveColor;
      canvas.drawLine(Offset(startX, 0), Offset(endX, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_ProgressLinePainter oldDelegate) {
    return oldDelegate.currentStep != currentStep || oldDelegate.isRtl != isRtl;
  }
}

class StepDetailScreen extends StatefulWidget {
  final int stepIndex;
  final String title;
  final String? locale;

  const StepDetailScreen({
    super.key,
    required this.stepIndex,
    required this.title,
    this.locale,
  });

  @override
  State<StepDetailScreen> createState() => _StepDetailScreenState();
}

class _StepDetailScreenState extends State<StepDetailScreen> {
  late PageController _pageController;
  late int _currentStepIndex;

  @override
  void initState() {
    super.initState();
    _currentStepIndex = widget.stepIndex;
    _pageController = PageController(initialPage: widget.stepIndex - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToStep(int index) {
    _pageController.animateToPage(
      index - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF9644);
    const background = Color(0xFFFFFDF1);
    final String effectiveLocale =
        widget.locale ?? Localizations.localeOf(context).languageCode;
    final bool isRtl = effectiveLocale == 'ur';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: background,
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipPath(
                  clipper: _BottomCurveClipper(),
                  child: Container(
                    padding: const EdgeInsets.only(top: 28, left: 10, right: 10, bottom: 10),
                    width: double.infinity,
                    color: primaryOrange,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _getStepTitle(_currentStepIndex),
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
                _buildStepProgressIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentStepIndex = index + 1),
                    children: List.generate(6, (index) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        child: _getStepContent(index + 1, effectiveLocale),
                      );
                    }),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStepIndex > 1)
                    FloatingActionButton.extended(
                      heroTag: 'step_prev_btn',
                      onPressed: () => _navigateToStep(_currentStepIndex - 1),
                      backgroundColor: Colors.white,
                      elevation: 4,
                      label: const Text('PREV', style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: primaryOrange),
                    )
                  else
                    const SizedBox(width: 48),
                  if (_currentStepIndex < 6)
                    FloatingActionButton.extended(
                      heroTag: 'step_next_btn',
                      onPressed: () => _navigateToStep(_currentStepIndex + 1),
                      backgroundColor: primaryOrange,
                      elevation: 4,
                      label: const Text('NEXT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      icon: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle(int index) {
    final String locale = widget.locale ?? 'en';
    final Map<String, List<String>> translations = {
      'en': ['Introduction', 'Climate & Soil', 'Seed & Sowing', 'Nutrient Management', 'Field Care', 'Harvest & Storage'],
      'hi': ['परिचय', 'जलवायु और मिट्टी', 'बीज और बुवाई', 'पोषक तत्व प्रबंधन', 'खेत की देखभाल', 'कटाई और भंडारण'],
      'pa': ['ਜਾਣ-ਪਛਾਣ', 'ਜਲਵਾਯੂ ਅਤੇ ਮਿੱਟੀ', 'ਬੀਜ ਅਤੇ ਬਿਜਾਈ', 'ਪੌਸ਼ਟਿਕ ਤੱਤ ਪ੍ਰਬੰਧਨ', 'ਖੇਤ ਦੀ ਦੇਖਭਾਲ', 'ਕਟਾਈ ਅਤੇ ਭੰਡਾਰਨ'],
      'ta': ['அறிமுகம்', 'காலநிலை மற்றும் மண்', 'விதை மற்றும் விதைப்பு', 'ஊட்டச்சத்து மேலாண்மை', 'வயல் பராமரிப்பு', 'அறுவடை மற்றும் சேமிப்பு'],
      'te': ['పరిచయం', 'వాతావరణం & నేల', 'విత్తనాలు & నాటడం', 'పోషక నిర్వహణ', 'క్షేత్ర సంరక్షణ', 'కోత & నిల్వ'],
      'kn': ['ಪರಿಚಯ', 'ಹವಾಮಾನ ಮತ್ತು ಮಣ್ಣು', 'ಬೀಜ ಮತ್ತು ಬಿತ್ತನೆ', 'ಪೋಷಕಾಂಶ ನಿರ್ವಹಣೆ', 'ಕ್ಷೇತ್ರದ ಆರೈಕೆ', 'ಕೊಯ್ಲು ಮತ್ತು ಸಂಗ್ರಹಣೆ'],
      'mr': ['ओळख', 'हवामान आणि माती', 'बियाणे आणि पेरणी', 'पोषक तत्व व्यवस्थापन', 'शेत देखभाल', 'काढणी आणि साठवणूक'],
      'gu': ['પરિચય', 'આબોહવા અને જમીન', 'બીજ અને વાવણી', 'પોષક તત્વોનું સંચાલન', 'ખેતરની સંભાળ', 'કાપણી અને સંગ્રહ'],
      'bn': ['ভূমিকা', 'জলবায়ু ও মাটি', 'বীজ ও বপন', 'পুষ্টি ব্যবস্থাপনা', 'মাঠের যত্ন', 'সংগ্রহ ও সংরক্ষণ'],
      'ml': ['ആമുഖം', 'കാലാവസ്ഥയും മണ്ണും', 'വിത്തും വിതയ്ക്കലും', 'പോഷക മാനേജ്‌മെന്റ്', 'വയൽ പരിപالനം', 'വിളവെടുപ്പും സംഭരണവും'],
      'ur': ['تعارف', 'آب و ہوا اور مٹی', 'بیج اور بوائی', 'غذائی اجزاء کا انتظام', 'کھیت کی دیکھ بھال', 'کٹائی اور ذخیرہ'],
    };
    final list = translations[locale] ?? translations['en']!;
    return (index >= 1 && index <= list.length) ? list[index - 1] : list[0];
  }

  Widget _buildStepProgressIndicator() {
    const primaryOrange = Color(0xFFFF9644);
    const lightOrange = Color(0xFFFFCE99);
    const background = Color(0xFFFFFDF1);

    final isRtl =
        (widget.locale ?? Localizations.localeOf(context).languageCode) == 'ur';
    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const iconSize = 32.0;
          return SizedBox(
            height: 70,
            child: Stack(
              children: [
                Positioned(
                  top: iconSize / 2 - 2,
                  left: iconSize / 2,
                  right: iconSize / 2,
                  child: CustomPaint(
                    painter: _ProgressLinePainter(
                      currentStep: isRtl ? (7 - _currentStepIndex) : _currentStepIndex,
                      totalSteps: 6,
                      isRtl: isRtl,
                      activeColor: primaryOrange,
                      inactiveColor: lightOrange.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  children: List.generate(6, (index) {
                    final stepNumber = isRtl ? (6 - index) : (index + 1);
                    final isActive = stepNumber == _currentStepIndex;
                    final isCompleted = isRtl ? stepNumber > _currentStepIndex : stepNumber < _currentStepIndex;
                    final isReachable = isRtl ? stepNumber >= _currentStepIndex : stepNumber <= _currentStepIndex;
                    return GestureDetector(
                      onTap: () => _navigateToStep(stepNumber),
                      child: _buildStepIcon(
                        stepNumber: stepNumber,
                        isActive: isActive,
                        isCompleted: isCompleted,
                        isReachable: isReachable,
                        iconSize: iconSize,
                      ),
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
      backgroundColor = lightOrange.withValues(alpha: 0.3);
      iconColor = darkBrown.withValues(alpha: 0.4);
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
                ? [BoxShadow(color: primaryOrange.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Icon(_getStepIcon(stepNumber), color: iconColor, size: 22),
        ),
        const SizedBox(height: 4),
        Text(
          'STEP $stepNumber',
          style: TextStyle(
            fontSize: 9,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isReachable ? darkBrown : darkBrown.withValues(alpha: 0.4),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  IconData _getStepIcon(int stepNumber) {
    switch (stepNumber) {
      case 1: return Icons.menu_book_rounded;
      case 2: return Icons.wb_sunny_rounded;
      case 3: return Icons.settings_rounded;
      case 4: return Icons.grain_rounded;
      case 5: return Icons.science_rounded;
      case 6: return Icons.water_drop_rounded;
      default: return Icons.circle;
    }
  }

  Widget _getStepContent(int index, String locale) {
    switch (index) {
      case 1: return Step1Content(locale: locale);
      case 2: return Step2Content(locale: locale);
      case 3: return Step3Content(locale: locale);
      case 4: return Step4Content(locale: locale);
      case 5: return Step5Content(locale: locale);
      case 6: return Step6Content(locale: locale);
      default: return Step1Content(locale: locale);
    }
  }
}
