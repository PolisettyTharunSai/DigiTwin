import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import 'daily_recommendation_screen.dart';
import 'instructions_screen.dart';
import 'ar_view_page.dart';
import 'get_started_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Widget _frostedCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
      border: Border.all(color: Colors.grey.shade100),
    ),
    child: child,
  );
}

class _HomeScreenState extends State<HomeScreen> {
  static const primaryColor = Color(0xFFFF9644); // Primary Orange
  static const accentColor = Color(0xFFFFCE99);
  static const bgColor = Color(0xFFFFFDF1);

  int currentDay = 1;
  int currentImageIndex = 0;
  String dayText = "";
  String farmerName = "Farmer";
  DateTime? plantationDate;
  bool show3DModel = false;

  final CarouselSliderController _carouselController =
      CarouselSliderController();
  Timer? _autoScrollTimer;
  bool _hasTodayLogSubmitted = false;
  bool _isPopupShowing = false;

  @override
  void initState() {
    super.initState();
    _loadFarmerAndPlantation();
    _startAutoScroll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDailyPopup();
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  int get _calculatedTodayDay {
    if (plantationDate == null) return 1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(
      plantationDate!.year,
      plantationDate!.month,
      plantationDate!.day,
    );
    final diff = today.difference(start).inDays;
    return (diff + 1).clamp(1, 109);
  }

  Future<void> _checkDailyPopup({bool showIfMissing = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final String? lastCheckedDate = prefs.getString('last_daily_check_date');
    final bool? cachedSubmissionStatus = prefs.getBool(
      'has_today_log_submitted',
    );

    if (lastCheckedDate != today) {
      await _checkDatabaseForTodayLog(today, prefs);
    } else {
      if (mounted) {
        setState(() {
          _hasTodayLogSubmitted = cachedSubmissionStatus ?? false;
        });
      }
    }

    if (showIfMissing && !_hasTodayLogSubmitted) {
      if (mounted) {
        _showDailyCheckPopup();
      }
    }
  }

  Future<void> _checkDatabaseForTodayLog(
    String today,
    SharedPreferences prefs,
  ) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        final response = await supabase
            .from('plant_daily_log')
            .select('log_date')
            .eq('user_id', user.id)
            .eq('log_date', today)
            .maybeSingle();

        final bool logExists = response != null;

        await prefs.setString('last_daily_check_date', today);
        await prefs.setBool('has_today_log_submitted', logExists);

        if (mounted) {
          setState(() {
            _hasTodayLogSubmitted = logExists;
          });
        }
      } else {
        await prefs.setString('last_daily_check_date', today);
        await prefs.setBool('has_today_log_submitted', false);

        if (mounted) {
          setState(() {
            _hasTodayLogSubmitted = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking database for today\'s log: $e');
      await prefs.setString('last_daily_check_date', today);
      await prefs.setBool('has_today_log_submitted', false);

      if (mounted) {
        setState(() {
          _hasTodayLogSubmitted = false;
        });
      }
    }
  }

  Future<void> _loadFarmerAndPlantation() async {
    final prefs = await SharedPreferences.getInstance();

    if (mounted) {
      setState(() {
        farmerName = prefs.getString('farmerName') ?? "Farmer";
        String? savedDate = prefs.getString('plantingDate');
        if (savedDate != null) {
          plantationDate = DateTime.tryParse(savedDate);
          if (plantationDate != null) {
            currentDay = _calculatedTodayDay;
          }
        }
      });
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final res = await Supabase.instance.client
            .from('profile')
            .select('name, planting_date')
            .eq('id', user.id)
            .maybeSingle();

        if (res != null) {
          if (mounted) {
            setState(() {
              if (res['name'] != null) {
                farmerName = res['name'];
                prefs.setString('farmerName', farmerName);
              }
              if (res['planting_date'] != null) {
                String dateStr = res['planting_date'];
                DateTime? parsed = DateTime.tryParse(dateStr);

                if (parsed == null) {
                  try {
                    parsed = DateFormat("d/M/yyyy").parse(dateStr);
                  } catch (_) {
                    try {
                      parsed = DateFormat("dd/MM/yyyy").parse(dateStr);
                    } catch (_) {}
                  }
                }

                if (parsed != null) {
                  plantationDate = parsed;
                  prefs.setString('plantingDate', parsed.toIso8601String());
                  currentDay = _calculatedTodayDay;
                }
              }
            });
          }
        }
      } catch (e) {
        debugPrint("Error loading profile: $e");
      }
    }
    _loadDayData();
  }

  Future<void> _loadDayData() async {
    try {
      final text = await rootBundle.loadString(
        'assets/Data/day$currentDay/day$currentDay.txt',
      );
      if (mounted) setState(() => dayText = text);
    } catch (_) {
      if (mounted) {
        setState(() {
          dayText =
              "• Crop stage: Emergence (Germination)\n• Water requirement: 0 ml/plant\n• Nutrient application: None";
        });
      }
    }
  }

  List<String> _getImages() {
    final startDate = DateTime(2025, 12, 10);
    final date = startDate.add(Duration(days: currentDay - 1));
    final day = date.day;
    final monthAbbr = DateFormat('MMM').format(date).toLowerCase();

    String monthYearFolder;
    if (date.month == 12) {
      monthYearFolder = "December ${date.year}";
    } else {
      monthYearFolder = "${DateFormat('MMM').format(date)} ${date.year}";
    }

    final dayFolder = "$day $monthAbbr";

    return List.generate(10, (i) {
      final frameName = "frame_${(i).toString().padLeft(3, '0')}.webp";
      return "https://cdn.jsdelivr.net/gh/PolisettyTharunSai/DigiTwin@Data/potato_extracted_frames_comp/${Uri.encodeComponent(monthYearFolder)}/${Uri.encodeComponent(dayFolder)}/1/$frameName";
    });
  }

  String _getModelUrl() {
    return "https://raw.githubusercontent.com/PolisettyTharunSai/DigiTwin/Data/models/Day$currentDay.glb";
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (show3DModel) return;

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || show3DModel) {
        _autoScrollTimer?.cancel();
        return;
      }

      try {
        _carouselController.nextPage();
      } catch (e) {
        // Silently skip
      }
    });
  }

  Future<void> _pickViewingDate() async {
    if (plantationDate == null) return;

    final picked = await showDatePicker(
      context: context,
      initialDate:
          plantationDate!
              .add(Duration(days: currentDay - 1))
              .isBefore(plantationDate!)
          ? plantationDate!
          : plantationDate!.add(Duration(days: currentDay - 1)),
      firstDate: plantationDate!,
      lastDate: plantationDate!.add(const Duration(days: 108)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final diff = picked.difference(plantationDate!).inDays;
      if (mounted) {
        setState(() {
          currentDay = (diff + 1).clamp(1, 100);
          currentImageIndex = 0;
        });
      }
      _loadDayData();
    }
  }

  void _openFullScreenImage(int index, List<String> images) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FullScreenImageGallery(images: images, initialIndex: index),
      ),
    );
  }

  Future<void> _showDailyCheckPopup() async {
    if (_isPopupShowing) return;
    _isPopupShowing = true;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DailyCheckModal(),
    );
    _isPopupShowing = false;
  }

  Future<void> _showLogoutConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout from this device?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _handleLogout();
    }
  }

  Future<void> _handleLogout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const GetStartedScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
      }
    }
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
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: _showLogoutConfirmation,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.logout,
                                  size: 16,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hi $farmerName!",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Planting Date",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          plantationDate != null
                                              ? DateFormat(
                                                  'dd MMM yyyy',
                                                ).format(plantationDate!)
                                              : "Not Set",
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.assignment_turned_in_outlined,
                                    color: primaryColor,
                                  ),
                                  onPressed: () async {
                                    await _showDailyCheckPopup();
                                    _checkDailyPopup(showIfMissing: false);
                                  },
                                  tooltip: "Today's Plant Check",
                                ),
                                if (!_hasTodayLogSubmitted)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.info_outline,
                                color: primaryColor,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const InstructionsScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.calendar_today_outlined,
                                color: primaryColor,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const DailyRecommendationScreen(),
                                  ),
                                );
                              },
                              tooltip: "Daily Recommendations",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 100),
                          child: GestureDetector(
                            onTap: () {
                              if (mounted) {
                                setState(() {
                                  show3DModel = !show3DModel;
                                  if (!show3DModel) {
                                    _startAutoScroll();
                                  } else {
                                    _autoScrollTimer?.cancel();
                                  }
                                });
                              }
                            },
                            child: Container(
                              height: 45,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  AnimatedAlign(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    alignment: show3DModel
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      width: (screenWidth - 200 - 8) / 2,
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryColor.withOpacity(
                                              0.3,
                                            ),
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
                                              color: !show3DModel
                                                  ? Colors.white
                                                  : Colors.grey.shade700,
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
                                              color: show3DModel
                                                  ? Colors.white
                                                  : Colors.grey.shade700,
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
                        SizedBox(
                          height: imageHeight,
                          child: show3DModel
                              ? _buildTodayModel(modelUrl)
                              : _build2DCarousel(
                                  images,
                                  imageWidth,
                                  imageHeight,
                                ),
                        ),
                        const SizedBox(height: 15),
                        if (!show3DModel)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (i) {
                              final active = i == currentImageIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: active ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: active
                                      ? primaryColor
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              );
                            }),
                          ),
                        const SizedBox(height: 24),
                        _buildModernInsights(),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

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
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleNav(
                    icon: Icons.chevron_left,
                    onTap: currentDay > 1
                        ? () {
                            if (mounted) {
                              setState(() {
                                currentDay--;
                                currentImageIndex = 0;
                              });
                            }
                            _loadDayData();
                          }
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Day $currentDay",
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _pickViewingDate,
                          child: const Icon(
                            Icons.calendar_month,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _circleNav(
                    icon: Icons.chevron_right,
                    onTap: currentDay < 109
                        ? () {
                            if (mounted) {
                              setState(() {
                                currentDay++;
                                currentImageIndex = 0;
                              });
                            }
                            _loadDayData();
                          }
                        : null,
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

  Widget _buildModernInsights() {
    final lines = dayText.split('\n');
    String stage = "Emergence";
    String water = "0 ml";
    String nutrients = "None";

    for (var line in lines) {
      if (line.contains("stage:")) stage = line.split("stage:")[1].trim();
      if (line.contains("requirement:"))
        water = line.split("requirement:")[1].trim();
      if (line.contains("application:"))
        nutrients = line.split("application:")[1].trim();
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
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Column(
                  children: [
                    _insightCard(
                      icon: Icons.eco_outlined,
                      label: "Stage",
                      value: stage,
                      color: Colors.green.withOpacity(0.12),
                      iconColor: Colors.green,
                      fullWidth: true,
                    ),
                    const SizedBox(height: 12),
                    _insightCard(
                      icon: Icons.water_drop_outlined,
                      label: "Water",
                      value: _formatWaterText(water),
                      color: Colors.blue.withOpacity(0.1),
                      iconColor: Colors.blue,
                      fullWidth: true,
                    ),
                    const SizedBox(height: 12),
                    _insightCard(
                      icon: Icons.science_outlined,
                      label: "Nutrient Application",
                      value: nutrients,
                      color: Colors.orange.withOpacity(0.1),
                      iconColor: Colors.orange,
                      fullWidth: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatWaterText(String water) {
    final lower = water.toLowerCase().trim();
    if (RegExp(r'^0+(?:\.0+)?\s*ml').hasMatch(lower)) {
      return "No water required";
    }
    return water;
  }

  Widget _insightCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color iconColor,
    bool fullWidth = true,
  }) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                  maxLines: 3,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return fullWidth ? card : Expanded(child: card);
  }

  Widget _build2DCarousel(
    List<String> images,
    double imgWidth,
    double imgHeight,
  ) {
    return CarouselSlider(
      carouselController: _carouselController,
      options: CarouselOptions(
        height: imgHeight,
        viewportFraction: 1.0,
        enableInfiniteScroll: true,
        enlargeCenterPage: false,
        onPageChanged: (index, _) {
          if (mounted) setState(() => currentImageIndex = index);
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
                  color: Colors.black.withOpacity(0.1),
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
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
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
              color: Colors.black.withOpacity(0.1),
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

class DailyCheckModal extends StatefulWidget {
  const DailyCheckModal({super.key});

  @override
  State<DailyCheckModal> createState() => _DailyCheckModalState();
}

class _DailyCheckModalState extends State<DailyCheckModal> {
  bool? watered;
  final TextEditingController _waterAmountController = TextEditingController();
  String _selectedWaterUnit = "ml";
  bool pestsObserved = false;
  final TextEditingController _pestNotesController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  List<XFile> _images = [];
  bool _isSubmitting = false;
  bool _alreadySubmittedToday = false;

  @override
  void initState() {
    super.initState();
    _checkSubmissionStatus();
  }

  Future<void> _checkSubmissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? hasSubmitted = prefs.getBool('has_today_log_submitted');
    if (hasSubmitted == true) {
      if (mounted) setState(() => _alreadySubmittedToday = true);
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final List<XFile> pickedImages = await picker.pickMultiImage();
    if (pickedImages.isNotEmpty) {
      if (mounted) {
        setState(() {
          _images.addAll(pickedImages);
        });
      }
    }
  }

  Future<void> _submit() async {
    if (watered == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please answer if you watered the plant."),
        ),
      );
      return;
    }

    if (watered == true && _waterAmountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the amount of water used.")),
      );
      return;
    }

    if (mounted) setState(() => _isSubmitting = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final List<String> imageUrls = [];

      for (var image in _images) {
        final fileName =
            'public/${user.id}/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        await supabase.storage.from('daily_logs').upload(
          fileName,
          File(image.path),
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
        final publicUrl = supabase.storage
            .from('daily_logs')
            .getPublicUrl(fileName);
        imageUrls.add(publicUrl);
      }

      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final logData = {
        'user_id': user.id,
        'log_date': today,
        'watered': watered,
        'pests_observed': pestsObserved,
        'pest_notes': _pestNotesController.text,
        'feedback': _feedbackController.text,
        'images': imageUrls,
        'water_amount':
            watered == true
                ? double.tryParse(_waterAmountController.text)
                : null,
        'water_unit': watered == true ? _selectedWaterUnit : null,
      };

      await supabase.from('plant_daily_log').upsert(
        logData,
        onConflict: 'user_id, log_date',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_daily_check_date', today);
      await prefs.setBool('has_today_log_submitted', true);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Daily log submitted successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _waterAmountController.dispose();
    _pestNotesController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _HomeScreenState.primaryColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_florist,
                    color: _HomeScreenState.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Daily Plant Check",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _HomeScreenState.primaryColor,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => Navigator.pop(context),
                            tooltip: "Close",
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Log today’s care, water, and observations.",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_alreadySubmittedToday)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.25)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "You have already submitted a log for today. Submitting again will update your existing entry.",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            _frostedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Watering",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Did you water the plant today?",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    children: [
                      ChoiceChip(
                        label: const Text("Yes"),
                        selected: watered == true,
                        onSelected: (selected) {
                          if (mounted) setState(() => watered = true);
                        },
                        selectedColor: _HomeScreenState.primaryColor
                            .withOpacity(0.15),
                        labelStyle: TextStyle(
                          color:
                              watered == true
                                  ? _HomeScreenState.primaryColor
                                  : Colors.grey.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text("No"),
                        selected: watered == false,
                        onSelected: (selected) {
                          if (mounted) setState(() => watered = false);
                        },
                        selectedColor: _HomeScreenState.primaryColor
                            .withOpacity(0.15),
                        labelStyle: TextStyle(
                          color:
                              watered == false
                                  ? _HomeScreenState.primaryColor
                                  : Colors.grey.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (watered == true) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _waterAmountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: "Amount",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedWaterUnit,
                                isExpanded: true,
                                onChanged: (String? newValue) {
                                  if (mounted) {
                                    setState(() {
                                      _selectedWaterUnit = newValue!;
                                    });
                                  }
                                },
                                items:
                                    <String>['ml', 'liters'].map<
                                      DropdownMenuItem<String>
                                    >((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            _frostedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Observations",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Any pests or problems?",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Switch(
                        value: pestsObserved,
                        activeColor: _HomeScreenState.primaryColor,
                        onChanged: (v) {
                          if (mounted) setState(() => pestsObserved = v);
                        },
                      ),
                    ],
                  ),
                  if (pestsObserved) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _pestNotesController,
                      decoration: InputDecoration(
                        hintText: "Describe issues noticed...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            _frostedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Feedback / Notes",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _feedbackController,
                    decoration: InputDecoration(
                      hintText: "How's your plant doing overall?",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _frostedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Upload Photos",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ..._images.map(
                        (img) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(img.path),
                                width: 82,
                                height: 82,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () {
                                  if (mounted) {
                                    setState(() => _images.remove(img));
                                  }
                                },
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Icon(
                            Icons.add_a_photo,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _HomeScreenState.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child:
                    _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                          _alreadySubmittedToday
                              ? "Update Today's Log"
                              : "Submit Today's Log",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 10),
          ],
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
            physics:
                isZoomed
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              if (mounted) setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 6.0,
                onInteractionUpdate: (details) {
                  if (mounted) {
                    setState(() {
                      isZoomed = details.scale > 1.0;
                    });
                  }
                },
                child: Center(
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 50,
                        ),
                      );
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
