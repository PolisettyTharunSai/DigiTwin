import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sections/section1_identity.dart';
import 'sections/section2_climate.dart';
import 'sections/section3_temperature.dart';
import 'sections/section4_growth_stages.dart';
import 'sections/section5_sowing.dart';
import 'sections/section6_seed_spacing.dart';
import 'sections/section7_nutrients.dart';
import 'sections/section8_weeds_harvest.dart';
import 'widgets/wheat_card.dart';
import '../services/location_service.dart';
import 'home_screen.dart';

enum NavAction { next, prev }

class PlaceholderScreen extends StatefulWidget {
  const PlaceholderScreen({super.key});

  @override
  State<PlaceholderScreen> createState() => _PlaceholderScreenState();
}

class _PlaceholderScreenState extends State<PlaceholderScreen>
    with SingleTickerProviderStateMixin {
  static const primaryColor = Color(0xFF7F3DFF);
  static const lightPurple = Color(0xFFEFE7FF);
  static const darkText = Color(0xFF161719);

  late final AnimationController _controller;

  late Animation<double> _fadeOutCurrent;
  late Animation<Offset> _slideInNext;
  late Animation<Offset> _slideOutCurrent;
  late Animation<double> _fadeInPrev;

  int currentIndex = 0;
  int targetIndex = 0;

  NavAction? action;

  late final List<Widget> cards;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  double? _lat;
  double? _lng;
  bool _locationFetched = false;

  bool _isExactDate = true;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();

    cards = const [
      _IntroCard(),
      Section1Identity(),
      Section2Climate(),
      Section3Temperature(),
      Section4GrowthStages(),
      Section5Sowing(),
      Section6SeedSpacing(),
      Section7Nutrients(),
      Section8WeedsHarvest(),
    ];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeOutCurrent = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _slideInNext =
        Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.35, 1.0, curve: Curves.easeInOutCubic),
          ),
        );

    _slideOutCurrent =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(1, 0),
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
          ),
        );

    _fadeInPrev = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          currentIndex = targetIndex;
          action = null;
        });
        _controller.reset();
      }
    });
  }

  void _goNext() {
    if (currentIndex >= cards.length - 1 || action != null) return;

    setState(() {
      action = NavAction.next;
      targetIndex = currentIndex + 1;
    });

    _controller.forward(from: 0);
  }

  void _goPrev() {
    if (currentIndex <= 0 || action != null) return;

    setState(() {
      action = NavAction.prev;
      targetIndex = currentIndex - 1;
    });

    _controller.forward(from: 0);
  }

  Future<void> _markAsPlanted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCropPlanted', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _showPlantingPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setPopupState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Plant Your Crop",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 24),

                _buildPopupTextField(
                  controller: _nameController,
                  label: "Farmer Name",
                  icon: Icons.person_outline,
                ),

                _buildPopupTextField(
                  label: "Selected Crop",
                  initialValue: "Wheat",
                  icon: Icons.grass,
                  enabled: false,
                ),

                _buildPopupTextField(
                  controller: _dateController,
                  label: "Planting Date",
                  hint: "Select Date",
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: primaryColor,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (pickedDate != null) {
                      setPopupState(() {
                        _dateController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(pickedDate);
                      });
                    }
                  },
                ),

                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F1F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildToggleButton(
                        text: "Exact",
                        isActive: _isExactDate,
                        onTap: () => setPopupState(() => _isExactDate = true),
                      ),
                      _buildToggleButton(
                        text: "Approx",
                        isActive: !_isExactDate,
                        onTap: () => setPopupState(() => _isExactDate = false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _buildPopupTextField(
                  controller: _notesController,
                  label: "Farmer Notes (optional)",
                  icon: Icons.edit_note,
                  maxLines: 2,
                ),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLocating
                        ? null
                        : () async {
                            setPopupState(() => _isLocating = true);
                            try {
                              final pos = await LocationService.getCurrentLocation();
                              setPopupState(() {
                                _lat = pos.latitude;
                                _lng = pos.longitude;
                                _locationFetched = true;
                              });
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Failed to get location: $e")),
                                );
                              }
                            }
                            setPopupState(() => _isLocating = false);
                          },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: lightPurple, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLocating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primaryColor,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.my_location,
                                size: 18,
                                color: primaryColor,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Capture Location",
                                style: TextStyle(color: primaryColor),
                              ),
                            ],
                          ),
                  ),
                ),

                if (_locationFetched)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lightPurple.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          "Lat: ${_lat!.toStringAsFixed(4)}, Lng: ${_lng!.toStringAsFixed(4)}",
                          style: const TextStyle(color: primaryColor),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _markAsPlanted();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Planting Confirmed! 🌱")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Confirm Planting",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String text,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupTextField({
    required String label,
    required IconData icon,
    TextEditingController? controller,
    String? initialValue,
    String? hint,
    bool enabled = true,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        enabled: enabled,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        style: const TextStyle(color: darkText),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryColor),
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          labelStyle: TextStyle(color: Colors.grey[600]),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFF1F1F5), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFF1F1F5), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCards() {
    if (action == NavAction.next) {
      return Stack(
        alignment: Alignment.center,
        children: [
          FadeTransition(opacity: _fadeOutCurrent, child: cards[currentIndex]),
          SlideTransition(position: _slideInNext, child: cards[targetIndex]),
        ],
      );
    }
    if (action == NavAction.prev) {
      return Stack(
        alignment: Alignment.center,
        children: [
          SlideTransition(
            position: _slideOutCurrent,
            child: cards[currentIndex],
          ),
          FadeTransition(opacity: _fadeInPrev, child: cards[targetIndex]),
        ],
      );
    }
    return cards[currentIndex];
  }

  Widget _buildDots() {
    if (currentIndex == 0) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(8, (i) {
        final active = (currentIndex - 1) == i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 14 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _navCard({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: lightPurple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        "Wheat Cultivation Timeline",
        style: TextStyle(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildNavBar(),
            const SizedBox(height: 12),
            Expanded(child: Center(child: _buildAnimatedCards())),
            const SizedBox(height: 8),
            _buildDots(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentIndex > 0)
                    _navCard(
                      icon: Icons.arrow_back,
                      text: "Previous",
                      onTap: _goPrev,
                    )
                  else
                    const SizedBox(width: 120),
                  _navCard(
                    icon: Icons.arrow_forward,
                    text: currentIndex == 0
                        ? "Start"
                        : currentIndex == cards.length - 1
                        ? "Plant 🌱"
                        : "Next",
                    onTap: currentIndex == cards.length - 1
                        ? () => _showPlantingPopup(context)
                        : _goNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();
  @override
  Widget build(BuildContext context) {
    return const WheatCard(
      title: "🌾 Welcome",
      content:
          "This guided timeline walks you through\nthe COMPLETE wheat cultivation process\nfrom sowing to harvest.\n\nTap START to begin.",
    );
  }
}
