import 'dart:async';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import 'instructions_screen.dart';
import 'ar_view_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const primaryColor = Color.fromARGB(255, 127, 61, 255); // Primary Purple
  static const accentColor = Color(0xFFB18BFF);
  static const bgColor = Color(0xFFF7F6FB);

  int currentDay = 1;
  int currentImageIndex = 0;
  String dayText = "";
  String farmerName = "Farmer";
  DateTime? plantationDate;
  bool show3DModel = false;

  final CarouselSliderController _carouselController = CarouselSliderController();
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _loadFarmerAndPlantation();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFarmerAndPlantation() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final res = await Supabase.instance.client
            .from('profile')
            .select('name, planting_date')
            .eq('id', user.id)
            .maybeSingle();
        
        if (res != null) {
          setState(() {
            if (res['name'] != null) farmerName = res['name'];
            if (res['planting_date'] != null) {
              // Handle potential format differences (D/M/YYYY vs DD/MM/YYYY)
              String dateStr = res['planting_date'];
              try {
                plantationDate = DateFormat("d/M/yyyy").parse(dateStr);
              } catch (_) {
                plantationDate = DateFormat("dd/MM/yyyy").parse(dateStr);
              }
              
              // Calculate currentDay: today - plantationDate + 1
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final start = DateTime(plantationDate!.year, plantationDate!.month, plantationDate!.day);
              
              final diff = today.difference(start).inDays;
              currentDay = (diff + 1).clamp(1, 100);
            }
          });
        }
      } catch (e) {
        debugPrint("Error loading profile: $e");
      }
    }
    _loadDayData(); // Load data after calculation
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
        (i) {
          final folder = "${currentDay + 5}th jan";
          return "https://raw.githubusercontent.com/PolisettyTharunSai/DigiTwin/Wheat-v1/assets/extracted_frames_comp/${Uri.encodeComponent(folder)}/1/frame_${(i + 1).toString().padLeft(3, '0')}.webp";
        }
    );
  }

  String _getModelUrl() {
    return "https://raw.githubusercontent.com/PolisettyTharunSai/DigiTwin/version2/assets/Models/Day$currentDay.glb";
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
      initialDate: DateTime.now(),
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2026, 12, 31),
      currentDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
              secondary: Colors.orange, // Color for the "today" highlight
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (plantationDate != null) {
          final start = DateTime(plantationDate!.year, plantationDate!.month, plantationDate!.day);
          final select = DateTime(picked.year, picked.month, picked.day);
          final diff = select.difference(start).inDays;
          currentDay = (diff + 1).clamp(1, 100);
        } else {
          currentDay = picked.day.clamp(1, 100);
        }
        currentImageIndex = 0;
      });
      _loadDayData();
    }
  }

  void _openFullScreenImage(int index, List<String> images) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageGallery(
          images: images,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = _getImages();
    final modelUrl = _getModelUrl();
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth * 0.85; 
    final imageHeight = imageWidth * 1.5;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),

                // 🌿 HEADER SECTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi $farmerName!",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: _pickDate,
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              children: [
                                Text(
                                  "Day $currentDay",
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down, color: primaryColor),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.info_outline, color: primaryColor),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const InstructionsScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🌱 CONTENT AREA
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // View Switcher (2D/3D Slider)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 100),
                          child: GestureDetector(
                            onTap: () => setState(() => show3DModel = !show3DModel),
                            child: Container(
                              height: 45,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha:0.5),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: Colors.white.withValues(alpha:0.3)),
                              ),
                              child: Stack(
                                children: [
                                  AnimatedAlign(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    alignment: show3DModel ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      width: (screenWidth - 200 - 8) / 2, 
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryColor.withValues(alpha:0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            "2D",
                                            style: TextStyle(
                                              color: !show3DModel ? Colors.white : Colors.grey.shade700,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            "3D",
                                            style: TextStyle(
                                              color: show3DModel ? Colors.white : Colors.grey.shade700,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Carousel or 3D Model
                        SizedBox(
                          height: imageHeight,
                          child: show3DModel
                              ? _buildTodayModel(modelUrl)
                              : _build2DCarousel(images, imageWidth, imageHeight),
                        ),

                        const SizedBox(height: 15),

                        // Dot Indicators
                        if (!show3DModel)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (i) {
                              final active = i == currentImageIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: active ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: active ? primaryColor : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              );
                            }),
                          ),

                        const SizedBox(height: 24),

                        // 📊 INSIGHTS SECTION
                        _buildModernInsights(),

                        const SizedBox(height: 120), 
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🎮 MINIMALIST DAY NAVIGATION
          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: Container(
              height: 65,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Prev Circle
                  _circleNav(
                    icon: Icons.chevron_left,
                    onTap: currentDay > 1 ? () {
                      setState(() => currentDay--);
                      _loadDayData();
                    } : null,
                  ),
                  
                  // Day Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Day $currentDay",
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  // Next Circle
                  _circleNav(
                    icon: Icons.chevron_right,
                    onTap: currentDay < 100 ? () {
                      setState(() => currentDay++);
                      _loadDayData();
                    } : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleNav({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: onTap != null ? primaryColor : Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  // 📊 MODERN INSIGHTS UI
  Widget _buildModernInsights() {
    final lines = dayText.split('\n');
    String stage = "Emergence";
    String water = "0 ml";
    String nutrients = "None";

    for (var line in lines) {
      if (line.contains("stage:")) stage = line.split("stage:")[1].trim();
      if (line.contains("requirement:")) water = line.split("requirement:")[1].trim();
      if (line.contains("application:")) nutrients = line.split("application:")[1].trim();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Growth Parameters",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _insightCard(
                icon: Icons.eco_outlined,
                label: "Stage",
                value: stage,
                color: primaryColor.withValues(alpha:0.1),
                iconColor: primaryColor,
              ),
              const SizedBox(width: 12),
              _insightCard(
                icon: Icons.water_drop_outlined,
                label: "Water",
                value: water,
                color: Colors.blue.withValues(alpha:0.1),
                iconColor: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _insightCard(
            icon: Icons.science_outlined,
            label: "Nutrient Application",
            value: nutrients,
            color: Colors.orange.withValues(alpha:0.1),
            iconColor: Colors.orange,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _insightCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color iconColor,
    bool fullWidth = false,
  }) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return fullWidth ? card : Expanded(child: card);
  }

  Widget _build2DCarousel(List<String> images, double imgWidth, double imgHeight) {
    return CarouselSlider(
      carouselController: _carouselController,
      options: CarouselOptions(
        height: imgHeight,
        viewportFraction: 1.0,
        enableInfiniteScroll: true,
        enlargeCenterPage: false,
        onPageChanged: (index, _) {
          setState(() => currentImageIndex = index);
        },
      ),
      items: images.asMap().entries.map((entry) {
        final i = entry.key;
        final img = entry.value;

        return GestureDetector(
          onTap: () => _openFullScreenImage(i, images),
          child: Container(
            width: imgWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.network(
                img,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: primaryColor));
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey));
                },
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTodayModel(String modelUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            children: [
              ModelViewer(
                key: ValueKey(modelUrl),
                src: modelUrl,
                alt: '3D model for Day $currentDay',
                ar: true,
                arModes: const ['scene-viewer', 'webxr-ar-only', 'quick-look'],
                cameraControls: true,
                autoRotate: true,
                backgroundColor: Colors.white,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.fullscreen, color: primaryColor),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ARViewPage(
                          modelPath: modelUrl,
                          cropName: "Day $currentDay",
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenImageGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late PageController _pageController;
  late int _currentIndex;
  bool isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            physics: isZoomed ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 6.0,
                onInteractionUpdate: (details) {
                  setState(() {
                    isZoomed = details.scale > 1.0;
                  });
                },
                child: Center(
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 50));
                    },
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: CircleAvatar(
              backgroundColor: Colors.black26,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${_currentIndex + 1} / ${widget.images.length}",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
