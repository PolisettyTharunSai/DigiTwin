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
import '../widgets/image_indicator.dart';
import '../widgets/media_carousel.dart';

// Shared
import '../../../shared/dialogs/custom_calendar_dialog.dart';
import '../../../shared/widgets/fullscreen_image_gallery.dart';
import '../../../shared/widgets/no_visual_info_widget.dart';

/// Screen allowing historical exploration of the crop timeline.
class ExploreTimelineScreen extends StatefulWidget {
  const ExploreTimelineScreen({super.key});

  @override
  State<ExploreTimelineScreen> createState() => _ExploreTimelineScreenState();
}

class _ExploreTimelineScreenState extends State<ExploreTimelineScreen> {
  // ── Services ───────────────────────────────────────────────────────────────
  final _homeService = HomeService();

  // ── State ──────────────────────────────────────────────────────────────────
  int _currentDay = 1;
  int _currentImageIndex = 0;
  DateTime? _plantationDate;
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
  }

  Future<void> _loadFarmerAndPlantation() async {
    final result = await ProfileService.instance.loadFarmerAndPlantation();
    if (!mounted) return;
    setState(() {
      _plantationDate = result['plantationDate'];
      if (_plantationDate != null) {
        _currentDay = DayUtils.calculateTodayDay(_plantationDate!);
      }
    });
    await _loadDayData();
  }

  Future<void> _loadDayData() async {
    final data = await _homeService.loadDayData(_currentDay);
    if (!mounted) return;
    setState(() {
      _dayData = data;
    });
  }

  // ── Auto-scroll ────────────────────────────────────────────────────────────

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) {
        _autoScrollTimer?.cancel();
        return;
      }
      // Only scroll if we are past the visual data start day
      if (_currentDay > AppConstants.VISUAL_DATA_START_DAY) {
        try {
          _carouselController.nextPage();
        } catch (e) {
          debugPrint('AutoScroll: Controller not ready yet: $e');
        }
      }
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

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final images = DayUtils.getImagesForDay(_currentDay);
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth * 0.85;
    final imageHeight = imageWidth * 1.5;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Explore Timeline',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // ── Media Content ────────────────────────────────
                        SizedBox(
                          height: imageHeight,
                          child: _buildMediaContent(
                            images: images,
                            imageWidth: imageWidth,
                            imageHeight: imageHeight,
                          ),
                        ),

                        const SizedBox(height: 15),

                        // ── Image dot indicator ──────────────────────────
                        if (_currentDay > AppConstants.VISUAL_DATA_START_DAY)
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
