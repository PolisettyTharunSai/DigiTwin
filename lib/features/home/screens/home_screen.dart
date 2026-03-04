import 'dart:async';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/utils/day_utils.dart';

// Home feature
import '../models/day_data.dart';
import '../services/home_service.dart';
import '../widgets/day_navigation_bar.dart';
import '../widgets/growth_parameters_section.dart';
import '../widgets/home_header.dart';
import '../widgets/image_indicator.dart';
import '../widgets/media_carousel.dart';
import '../widgets/model_viewer_card.dart';
import '../widgets/view_toggle.dart';

// Daily log feature
import '../../daily_log/screens/daily_check_modal.dart';
import '../../daily_log/services/daily_log_service.dart';

// Shared
import '../../../shared/dialogs/custom_calendar_dialog.dart';
import '../../../shared/widgets/fullscreen_image_gallery.dart';
import '../../../shared/widgets/no_visual_info_widget.dart';

// Other screens
import '../../ar_view/screens/ar_view_screen.dart';
import '../../instructions/screens/instructions_screen.dart';
import '../../onboarding/screens/get_started_screen.dart';
import 'daily_recommendation_screen.dart';

/// Entry point for the main dashboard: coordinates services and widgets.
/// All data loading is delegated to [ProfileService], [HomeService], and
/// [DailyLogService]. All UI is delegated to the extracted widget files.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Services ───────────────────────────────────────────────────────────────
  final _homeService = HomeService();

  // ── State ──────────────────────────────────────────────────────────────────
  int _currentDay = 1;
  int _currentImageIndex = 0;
  String _farmerName = 'Farmer';
  DateTime? _plantationDate;
  bool _show3DModel = false;
  bool _hasTodayLogSubmitted = false;
  bool _isPopupShowing = false;
  bool _modelExists = true;
  DayData _dayData = DayData.fallback();

  final CarouselSliderController _carouselController =
      CarouselSliderController();
  Timer? _autoScrollTimer;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadFarmerAndPlantation();
    _startAutoScroll();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkDailyPopup());
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  // ── Data loading ───────────────────────────────────────────────────────────

  Future<void> _loadFarmerAndPlantation() async {
    final result = await ProfileService.instance.loadFarmerAndPlantation();
    if (!mounted) return;
    setState(() {
      _farmerName = result['farmerName'];
      _plantationDate = result['plantationDate'];
      if (_plantationDate != null) {
        _currentDay = DayUtils.calculateTodayDay(_plantationDate!);
      }
    });
    await _loadDayData();
  }

  Future<void> _loadDayData() async {
    final data = await _homeService.loadDayData(_currentDay);
    final modelExists = await _homeService.checkModelExists(_currentDay);
    if (!mounted) return;
    setState(() {
      _dayData = data;
      _modelExists = modelExists;
    });
  }

  // ── Daily log check ────────────────────────────────────────────────────────

  Future<void> _checkDailyPopup({bool showIfMissing = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String? lastChecked =
        prefs.getString(AppConstants.PREF_LAST_DAILY_CHECK_DATE);
    final bool? cached =
        prefs.getBool(AppConstants.PREF_HAS_TODAY_LOG_SUBMITTED);

    bool submitted;
    if (lastChecked != today) {
      // New day or first run → query DB via service
      submitted = await DailyLogService.instance.checkTodayLogStatus();
    } else {
      submitted = cached ?? false;
    }

    if (mounted) setState(() => _hasTodayLogSubmitted = submitted);

    if (showIfMissing && !submitted && mounted) {
      _showDailyCheckPopup();
    }
  }

  // ── Auto-scroll ────────────────────────────────────────────────────────────

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (_show3DModel) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _show3DModel) {
        _autoScrollTimer?.cancel();
        return;
      }
      try {
        _carouselController.nextPage();
      } catch (_) {}
    });
  }

  // ── Navigation helpers ─────────────────────────────────────────────────────

  Future<void> _showCustomCalendar() async {
    if (_plantationDate == null) return;
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (_) => CustomCalendarDialog(
        initialDate: _plantationDate!.add(Duration(days: _currentDay - 1)),
        plantationDate: _plantationDate!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _currentDay = picked.difference(_plantationDate!).inDays + 1;
        _currentImageIndex = 0;
      });
      await _loadDayData();
    }
  }

  void _openFullScreenImage(int index, List<String> images) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FullscreenImageGallery(images: images, initialIndex: index),
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
      builder: (_) =>
          DailyCheckModal(initialAlreadySubmitted: _hasTodayLogSubmitted),
    );
    _isPopupShowing = false;
  }

  Future<void> _showLogoutConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
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
              backgroundColor: AppColors.primary,
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
    if (confirmed == true) await _handleLogout();
  }

  Future<void> _handleLogout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const GetStartedScreen()),
        (_) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error logging out: $e')));
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final images = DayUtils.getImagesForDay(_currentDay);
    final modelUrl = DayUtils.getModelUrlForDay(_currentDay);
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth * 0.85;
    final imageHeight = imageWidth * 1.5;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Decorative background circle
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),

                // ── Header ─────────────────────────────────────────────────
                HomeHeader(
                  farmerName: _farmerName,
                  plantationDate: _plantationDate,
                  hasTodayLogSubmitted: _hasTodayLogSubmitted,
                  onLogoutTap: _showLogoutConfirmation,
                  onDailyCheckTap: () async {
                    await _showDailyCheckPopup();
                    await _checkDailyPopup(showIfMissing: false);
                  },
                  onInstructionsTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InstructionsScreen(),
                    ),
                  ),
                  onRecommendationsTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DailyRecommendationScreen(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // ── 2D / 3D Toggle ──────────────────────────────
                        ViewToggle(
                          show3DModel: _show3DModel,
                          onToggle: (value) {
                            setState(() {
                              _show3DModel = value;
                              if (!_show3DModel) {
                                _startAutoScroll();
                              } else {
                                _autoScrollTimer?.cancel();
                              }
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        // ── Media Content ────────────────────────────────
                        SizedBox(
                          height: imageHeight,
                          child: _buildMediaContent(
                            images: images,
                            modelUrl: modelUrl,
                            imageWidth: imageWidth,
                            imageHeight: imageHeight,
                          ),
                        ),

                        const SizedBox(height: 15),

                        // ── Image dot indicator ──────────────────────────
                        if (!_show3DModel &&
                            _currentDay > AppConstants.VISUAL_DATA_START_DAY)
                          ImageIndicator(
                            imageCount: images.length,
                            currentIndex: _currentImageIndex,
                          ),

                        const SizedBox(height: 24),

                        // ── Growth parameters ────────────────────────────
                        GrowthParametersSection(
                          stage: _dayData.stage,
                          water: _dayData.water,
                          nutrients: _dayData.nutrients,
                        ),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Floating day navigation bar ──────────────────────────────────
          DayNavigationBar(
            currentDay: _currentDay,
            maxDay: AppConstants.TOTAL_CROP_DAYS,
            onPrevious: () {
              setState(() {
                _currentDay--;
                _currentImageIndex = 0;
              });
              _loadDayData();
            },
            onNext: () {
              setState(() {
                _currentDay++;
                _currentImageIndex = 0;
              });
              _loadDayData();
            },
            onCalendarTap: _showCustomCalendar,
          ),
        ],
      ),
    );
  }

  // ── Private build helpers ──────────────────────────────────────────────────

  Widget _buildMediaContent({
    required List<String> images,
    required String modelUrl,
    required double imageWidth,
    required double imageHeight,
  }) {
    // Days 1–30: no visual data yet
    if (_currentDay <= AppConstants.VISUAL_DATA_START_DAY) {
      return NoVisualInfoWidget(
        message: 'No visual information available\nfor the first 30 days.',
        height: imageHeight,
      );
    }

    // 3D model view
    if (_show3DModel) {
      return _modelExists
          ? ModelViewerCard(
              modelUrl: modelUrl,
              currentDay: _currentDay,
              onFullscreenTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArViewScreen(
                    modelPath: modelUrl,
                    cropName: 'Day $_currentDay',
                  ),
                ),
              ),
            )
          : NoVisualInfoWidget(
              message: '3D Model not available\nfor today.',
              height: imageHeight,
            );
    }

    // 2D image carousel
    return MediaCarousel(
      images: images,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      carouselController: _carouselController,
      onPageChanged: (index) => setState(() => _currentImageIndex = index),
      onImageTap: (index) => _openFullScreenImage(index, images),
    );
  }
}
