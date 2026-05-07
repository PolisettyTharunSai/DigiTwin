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
import '../../ar_view/screens/ar_view_screen.dart';
import '../../instructions/screens/instructions_screen.dart';
import '../../onboarding/screens/get_started_screen.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../settings/screens/settings_screen.dart';
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
  bool _isChatOpen = false;
  bool _isChatMinimized = false;
  bool _isChatFullscreen = false;
  bool _isBotTyping = false;
  DayData _dayData = DayData.fallback();
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final List<_ChatMessage> _chatMessages = [
    _ChatMessage(
      text:
          'Hi, I am your DigiTwin assistant. Ask me about water, nutrients, or day progress.',
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

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
    _chatController.dispose();
    _chatScrollController.dispose();
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

  void _openChat() {
    setState(() {
      _isChatOpen = true;
      _isChatMinimized = false;
    });
    _scrollChatToBottom();
  }

  void _scrollChatToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScrollController.hasClients) return;
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendChatMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty || _isBotTyping) return;

    setState(() {
      _chatMessages.add(
        _ChatMessage(text: message, isUser: true, timestamp: DateTime.now()),
      );
      _chatController.clear();
      _isBotTyping = true;
    });
    _scrollChatToBottom();

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    setState(() {
      _chatMessages.add(
        _ChatMessage(
          text: _buildAssistantReply(message),
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      _isBotTyping = false;
    });
    _scrollChatToBottom();
  }

  String _buildAssistantReply(String input) {
    final text = input.toLowerCase();

    if (text.contains('water') || text.contains('irrigation')) {
      return 'Day \$_currentDay irrigation guidance: \${_dayData.water}. Keep soil moisture even and avoid overwatering.';
    }

    if (text.contains('nutrient') || text.contains('fertilizer')) {
      return 'For Day \$_currentDay, nutrient guidance is: \${_dayData.nutrients}. Apply gradually and monitor leaf response.';
    }

    if (text.contains('day') || text.contains('today')) {
      return 'You are currently on Day \$_currentDay (Today). You can explore other days from the Timeline in the side menu.';
    }

    if (text.contains('hello') || text.contains('hi') || text.contains('hey')) {
      return 'Hello! Ask me anything about crop progress, water, nutrients, or how to use this screen.';
    }

    return 'I understood your question. For best guidance, share your concern with details like symptoms, or whether you need water or nutrient help.';
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

          if (_isChatOpen) _buildChatWindow(),

          if (!_isChatOpen || _isChatMinimized)
            Positioned(
              right: 16,
              bottom: 24,
              child: FloatingActionButton(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 6,
                onPressed: _openChat,
                child: const Icon(Icons.chat_bubble_outline_rounded),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatWindow() {
    if (_isChatMinimized) {
      return const SizedBox.shrink();
    }

    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final bool fullscreen = _isChatFullscreen;
    final double screenWidth = MediaQuery.of(context).size.width;

    final Widget chatSurface = Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: fullscreen
              ? BorderRadius.zero
              : const BorderRadius.all(Radius.circular(20)),
          boxShadow: fullscreen
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
        ),
        child: Column(
          children: [
            Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: fullscreen
                    ? BorderRadius.zero
                    : const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  if (fullscreen)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isChatFullscreen = false;
                        });
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: Colors.white,
                    )
                  else
                    const SizedBox(width: 6),
                  const Icon(
                    Icons.smart_toy_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'DigiTwin Assistant',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isChatMinimized = true;
                      });
                    },
                    icon: const Icon(Icons.minimize_rounded),
                    color: Colors.white,
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isChatFullscreen = !_isChatFullscreen;
                      });
                    },
                    icon: Icon(
                      fullscreen
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                    ),
                    color: Colors.white,
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isChatOpen = false;
                        _isChatMinimized = false;
                        _isChatFullscreen = false;
                      });
                    },
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: const Color(0xFFFFFBF6),
                child: ListView.builder(
                  controller: _chatScrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  itemCount: _chatMessages.length + (_isBotTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isBotTyping && index == _chatMessages.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Text(
                            'Typing...',
                            style: TextStyle(
                              color: AppColors.darkBrown,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }

                    final message = _chatMessages[index];
                    final isUser = message.isUser;
                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: screenWidth * (fullscreen ? 0.74 : 0.62),
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                        decoration: BoxDecoration(
                          color: isUser ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(14),
                            topRight: const Radius.circular(14),
                            bottomLeft: Radius.circular(isUser ? 14 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 14),
                          ),
                          border: isUser
                              ? null
                              : Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.16,
                                  ),
                                ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.text,
                              style: TextStyle(
                                color: isUser
                                    ? Colors.white
                                    : AppColors.darkBrown,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('hh:mm a').format(message.timestamp),
                              style: TextStyle(
                                fontSize: 11,
                                color: isUser
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: fullscreen
                    ? BorderRadius.zero
                    : const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendChatMessage(),
                      decoration: InputDecoration(
                        hintText: 'Write your doubt...',
                        filled: true,
                        fillColor: const Color(0xFFFFF2E8),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: _sendChatMessage,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (fullscreen) {
      return Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: SafeArea(child: chatSurface),
      );
    }

    return Positioned(
      right: 16,
      bottom: 86 + keyboardInset,
      child: SizedBox(
        width: screenWidth > 420 ? 390 : screenWidth - 24,
        height: 460,
        child: chatSurface,
      ),
    );
  }

  // ── Private build helpers ──────────────────────────────────────────────────

  Widget _buildMediaContent({
    required List<String> images,
    required double imageWidth,
    required double imageHeight,
  }) {
    if (_currentDay <= AppConstants.VISUAL_DATA_START_DAY) {
      return NoVisualInfoWidget(
        message: 'No visual information available\nfor the first 30 days.',
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
                MaterialPageRoute(
                  builder: (_) => const DailyLogListScreen(),
                ),
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
