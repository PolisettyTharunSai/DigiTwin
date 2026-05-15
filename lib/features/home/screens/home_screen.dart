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
import '../../../core/services/notification_service.dart';
import '../../../core/utils/day_utils.dart';

// Home feature
import '../models/day_data.dart';
import '../services/home_service.dart';
import '../widgets/growth_parameters_section.dart';
import '../widgets/home_header.dart';
import '../widgets/image_indicator.dart';
import '../widgets/media_carousel.dart';

// Daily log feature
import '../../daily_log/screens/daily_check_modal.dart';
import '../../daily_log/screens/daily_log_list_screen.dart';
import '../../daily_log/services/daily_log_service.dart';

// Shared
import '../../../shared/widgets/fullscreen_image_gallery.dart';
import '../../../shared/widgets/no_visual_info_widget.dart';

// Other screens
import '../../instructions/screens/instructions_screen.dart';
import '../../onboarding/screens/get_started_screen.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../support/screens/customer_support_screen.dart';
import '../../support/screens/plant_analysis_screen.dart';
import 'explore_timeline_screen.dart';

/// Entry point for the main dashboard: coordinates services and widgets.
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
  String? _avatarUrl;
  bool _hasTodayLogSubmitted = false;
  bool _isPopupShowing = false;
  bool _isAdmin = false;
  bool _exploreAllDays = false;
  bool _isHelpExpanded = false;
  DayData _dayData = DayData.fallback();

  final CarouselSliderController _carouselController =
      CarouselSliderController();
  Timer? _autoScrollTimer;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadFarmerAndPlantation();
    _startAutoScroll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDailyPopup();
      NotificationService.instance.checkSystemNotifications();
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _exploreAllDays = prefs.getBool('explore_all_days') ?? false;
      });
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  // ── Data loading ───────────────────────────────────────────────────────────

  Future<void> _loadFarmerAndPlantation() async {
    final result = await ProfileService.instance.loadFarmerAndPlantation();
    _checkAdminStatus();
    if (!mounted) return;
    setState(() {
      _farmerName = result['farmerName'];
      _plantationDate = result['plantationDate'];
      _avatarUrl = result['avatarUrl'];
      if (_plantationDate != null) {
        _currentDay = DayUtils.calculateTodayDay(_plantationDate!);
      }
    });
    await _loadDayData();
  }

  void _checkAdminStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final res = await Supabase.instance.client
            .from('profile')
            .select('is_admin')
            .eq('id', user.id)
            .maybeSingle();

        if (res != null && res['is_admin'] == true) {
          if (mounted) {
            setState(() {
              _isAdmin = true;
            });
          }
        }
      } catch (e) {
        debugPrint('HomeService: Error checking admin status — $e');
      }
    }
  }

  Future<void> _loadDayData() async {
    final data = await _homeService.loadDayData(_currentDay);
    if (!mounted) return;
    setState(() {
      _dayData = data;
    });
  }

  // ── Daily log check ────────────────────────────────────────────────────────

  Future<void> _checkDailyPopup({bool showIfMissing = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String? lastChecked = prefs.getString(
      AppConstants.PREF_LAST_DAILY_CHECK_DATE,
    );
    final bool? cached = prefs.getBool(
      AppConstants.PREF_HAS_TODAY_LOG_SUBMITTED,
    );

    bool submitted;
    if (lastChecked != today) {
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
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) {
        _autoScrollTimer?.cancel();
        return;
      }
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

  void _toggleHelpFab() {
    setState(() => _isHelpExpanded = !_isHelpExpanded);
  }

  void _openCustomerSupport() {
    setState(() => _isHelpExpanded = false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomerSupportScreen()),
    );
  }

  void _openPlantAnalysis() {
    setState(() => _isHelpExpanded = false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlantAnalysisScreen()),
    );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error logging out: \$e')));
      }
    }
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
      drawer: _buildDrawer(),
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
                  avatarUrl: _avatarUrl,
                  isAdmin: _isAdmin,
                  onAdminTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminDashboardScreen(),
                    ),
                  ),
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
                ),

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

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(right: 16, bottom: 24, child: _buildHelpFab()),
        ],
      ),
    );
  }

  // ── Private build helpers ──────────────────────────────────────────────────

  Widget _buildHelpFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildHelpAction(
          visible: _isHelpExpanded,
          icon: Icons.support_agent_rounded,
          label: 'Customer Support',
          onTap: _openCustomerSupport,
          offset: 18,
        ),
        const SizedBox(height: 10),
        _buildHelpAction(
          visible: _isHelpExpanded,
          icon: Icons.eco_outlined,
          label: 'Analyze Plant',
          onTap: _openPlantAnalysis,
          offset: 8,
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 6,
          onPressed: _toggleHelpFab,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              _isHelpExpanded
                  ? Icons.close_rounded
                  : Icons.help_outline_rounded,
              key: ValueKey(_isHelpExpanded),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpAction({
    required bool visible,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required double offset,
  }) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: AnimatedSlide(
          offset: visible ? Offset.zero : Offset(0, offset / 56),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.14),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: AppColors.primary, size: 19),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.darkBrown,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaContent({
    required List<String> images,
    required double imageWidth,
    required double imageHeight,
  }) {
    if (_currentDay <= AppConstants.VISUAL_DATA_START_DAY) {
      return NoVisualInfoWidget(
        message: 'No visual information available\nbefore day ${AppConstants.VISUAL_DATA_START_DAY + 1}.',
        height: imageHeight,
      );
    }

    return MediaCarousel(
      images: images,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      carouselController: _carouselController,
      onPageChanged: (index) => setState(() => _currentImageIndex = index),
      onImageTap: (index) => _openFullScreenImage(index, images),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Options',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Daily Log History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DailyLogListScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_turned_in_outlined),
            title: const Text("Today's Plant Check"),
            onTap: () async {
              Navigator.pop(context);
              await _showDailyCheckPopup();
              await _checkDailyPopup(showIfMissing: false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Instructions'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InstructionsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.eco_outlined),
            title: const Text('Analyze Plant'),
            onTap: () {
              Navigator.pop(context);
              _openPlantAnalysis();
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent_rounded),
            title: const Text('Customer Support'),
            onTap: () {
              Navigator.pop(context);
              _openCustomerSupport();
            },
          ),
          const Spacer(),
          const Divider(),
          if (_exploreAllDays)
            ListTile(
              leading: const Icon(Icons.timeline),
              title: const Text('Explore Timeline'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExploreTimelineScreen(),
                  ),
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ).then((_) => _loadSettings());
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
