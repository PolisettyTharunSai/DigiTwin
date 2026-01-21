import 'dart:async';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import 'instructions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const primaryColor = Color(0xFF7F3DFF);

  int currentDay = 4;
  int currentImageIndex = 0;
  String dayText = "";
  bool show3DModel = false; // Toggle state for 3D/2D view

  final CarouselSliderController _carouselController =
  CarouselSliderController();

  Timer? _autoScrollTimer;

  static const double carouselHeight = 260;
  static const double dotsHeight = 24;
  static const double toggleButtonHeight = 50;
  static const double aiCardHeight = 170;

  @override
  void initState() {
    super.initState();
    _loadDayData();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDayData() async {
    try {
      final text = await rootBundle.loadString(
        'assets/Data/day$currentDay/day$currentDay.txt',
      );
      setState(() => dayText = text);
    } catch (_) {
      setState(() {
        dayText =
        "• Crop stage: Emergence (Germination)\n• Water requirement: 0 ml/plant\n• Nutrient application: None";
      });
    }
  }

  List<String> _getImages() {
    return List.generate(
      5,
          (i) => 'assets/Data/day$currentDay/images/day${currentDay}_${i + 1}.jpg',
    );
  }

  List<String> _getModels() {
    return List.generate(
      5,
          (i) => 'assets/Data/day$currentDay/models/day${currentDay}_${i + 1}.glb',
    );
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _carouselController.nextPage();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2024, 4, 10),
      initialDate: DateTime(2024, 1, currentDay),
    );

    if (picked != null) {
      setState(() {
        currentDay = picked.day.clamp(1, 100);
        currentImageIndex = 0;
      });
      _loadDayData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = _getImages();
    final models = _getModels();

    return Scaffold(
      backgroundColor: Colors.white,

      /// 🟣 CURVED APP BAR (stable)
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: ClipPath(
          clipper: _BottomCurveClipper(),
          child: AppBar(
            backgroundColor: primaryColor,
            elevation: 0,
            automaticallyImplyLeading: false,

            /// ✅ (i) button added here
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InstructionsScreen(),
                    ),
                  );
                },
              ),
            ],

            flexibleSpace: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: _pickDate,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Day $currentDay",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      /// ✅ SCROLLABLE BODY (NO OVERFLOW EVER)
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            const SizedBox(height: 12),

            /// 🎠 CAROUSEL - Shows either 2D images or 3D models
            SizedBox(
              height: carouselHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  show3DModel
                      ? _build3DCarousel(models)
                      : _build2DCarousel(images),

                  // Navigation arrows
                  Positioned(
                    left: 8,
                    child: _ArrowButton(
                      icon: Icons.chevron_left,
                      onTap: () => _carouselController.previousPage(),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    child: _ArrowButton(
                      icon: Icons.chevron_right,
                      onTap: () => _carouselController.nextPage(),
                    ),
                  ),
                ],
              ),
            ),

            /// 🔵 DOTS
            SizedBox(
              height: dotsHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final active = i == currentImageIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 14 : 8,
                    height: active ? 14 : 8,
                    decoration: BoxDecoration(
                      color: active ? primaryColor : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 12),

            /// 🔄 TOGGLE BUTTON - Switch between 2D and 3D
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: toggleButtonHeight,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            show3DModel = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: !show3DModel
                                ? primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  color: !show3DModel
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "2D Images",
                                  style: TextStyle(
                                    color: !show3DModel
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            show3DModel = true;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: show3DModel
                                ? primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.view_in_ar,
                                  color: show3DModel
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "3D Models",
                                  style: TextStyle(
                                    color: show3DModel
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 🧠 AI INSIGHTS
            SizedBox(
              height: aiCardHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "AI Crop Insights",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...dayText
                          .split('\n')
                          .take(3)
                          .map(
                            (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: primaryColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  line.replaceAll("•", "").trim(),
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ⏮️ ⏭️ DAY NAVIGATION
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: currentDay > 1
                            ? () {
                          setState(() => currentDay--);
                          _loadDayData();
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Previous Day",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: currentDay < 100
                            ? () {
                          setState(() => currentDay++);
                          _loadDayData();
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Next Day",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build 2D Image Carousel
  Widget _build2DCarousel(List<String> images) {
    return CarouselSlider(
      carouselController: _carouselController,
      options: CarouselOptions(
        height: carouselHeight,
        viewportFraction: 0.85,
        enableInfiniteScroll: true,
        enlargeCenterPage: false,
        onPageChanged: (index, _) {
          setState(() => currentImageIndex = index);
        },
      ),
      items: images.asMap().entries.map((entry) {
        final i = entry.key;
        final img = entry.value;
        final isActive = i == currentImageIndex;

        return AnimatedScale(
          scale: isActive ? 1.0 : 0.94,
          duration: const Duration(milliseconds: 300),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              img,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Build 3D Model Carousel
  Widget _build3DCarousel(List<String> models) {
    return CarouselSlider(
      carouselController: _carouselController,
      options: CarouselOptions(
        height: carouselHeight,
        viewportFraction: 0.85,
        enableInfiniteScroll: true,
        enlargeCenterPage: false,
        onPageChanged: (index, _) {
          setState(() => currentImageIndex = index);
        },
      ),
      items: models.asMap().entries.map((entry) {
        final i = entry.key;
        final model = entry.value;
        final isActive = i == currentImageIndex;

        return AnimatedScale(
          scale: isActive ? 1.0 : 0.94,
          duration: const Duration(milliseconds: 300),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ModelViewer(
              src: model,
              alt: 'A 3D model of crop for day $currentDay',
              ar: false,
              autoRotate: true,
              cameraControls: true,
              backgroundColor: Colors.grey.shade100,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// ◀️ ▶️ Arrow Button
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 28),
        ),
      ),
    );
  }
}

/// ✂️ Curved AppBar clipper
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
  bool shouldReclip(_) => false;
}
