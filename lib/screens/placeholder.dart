import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';
import '../models/planting_data.dart';

import 'steps/step1.dart';
import 'steps/step2.dart';
import 'steps/step3.dart';
import 'steps/step4.dart';
import 'steps/step5.dart';
import 'steps/step6.dart';

class PlaceholderScreen extends StatefulWidget {
  const PlaceholderScreen({super.key});

  @override
  State<PlaceholderScreen> createState() => _PlaceholderScreenState();
}

class _PlaceholderScreenState extends State<PlaceholderScreen> {
  static const Color primaryPurple = Color(0xFF7F3DFF);
  static const Color unselectedPurple = Color(0xFFF4EFFF);
  static const Color inactiveIconColor = Color(0xFFB18BFF);

  int currentActiveStage = 1;
  final int totalStages = 6;

  // Form State
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String selectedDate = "DD/MM/YYYY";
  String? _currentPosition;
  double? _lat;
  double? _lng;
  bool isExact = true;
  bool isCapturing = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('farmerName');
    if (savedName != null && mounted) {
      setState(() {
        _nameController.text = savedName;
      });
    }
  }

  Widget _getStepContent() {
    switch (currentActiveStage) {
      case 1: return const Step1Content();
      case 2: return const Step2Content();
      case 3: return const Step3Content();
      case 4: return const Step4Content();
      case 5: return const Step5Content();
      case 6: return const Step6Content();
      default: return const Step1Content();
    }
  }

  Future<void> _determinePosition(StateSetter setSheetState) async {
    setSheetState(() => isCapturing = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setSheetState(() {
        _lat = position.latitude;
        _lng = position.longitude;
        _currentPosition = "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
        isCapturing = false;
      });
    } catch (e) {
      setSheetState(() => isCapturing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not fetch location")));
      }
    }
  }

  void _showPlantingForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 35,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Plant Your Crop",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryPurple),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        _buildField(Icons.person_outline, "Farmer Name", _nameController),
                        _buildCropField(),
                        _buildField(
                          Icons.calendar_today_outlined,
                          selectedDate,
                          null,
                          isReadOnly: true,
                          onTap: () => _selectDate(setSheetState),
                          isPlaceholder: selectedDate == "DD/MM/YYYY",
                        ),
                        _buildToggleSwitch(setSheetState),
                        _buildField(Icons.notes_outlined, "Notes (optional)", _notesController),
                        _buildLocationButton(setSheetState),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 160,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_nameController.text.trim().isNotEmpty &&
                                  selectedDate != "DD/MM/YYYY" &&
                                  _currentPosition != null) {
                                _showReviewDialog();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please fill all details and capture location")),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryPurple,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Confirm Planting", style: TextStyle(color: Colors.white, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(IconData icon, String hint, TextEditingController? controller, {bool isReadOnly = false, VoidCallback? onTap, bool isPlaceholder = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 42,
        child: TextField(
          controller: controller,
          readOnly: isReadOnly,
          onTap: onTap,
          style: TextStyle(fontSize: 12, color: isPlaceholder ? Colors.grey : Colors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: primaryPurple, size: 16),
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  Widget _buildCropField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.grass, color: primaryPurple, size: 16),
            SizedBox(width: 10),
            Text("Wheat", style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(StateSetter setSheetState) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: 34,
        width: 180,
        decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            _toggleItem("Exact", isExact, setSheetState),
            _toggleItem("Approx", !isExact, setSheetState),
          ],
        ),
      ),
    );
  }

  Widget _toggleItem(String label, bool active, StateSetter setSheetState) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setSheetState(() => isExact = (label == "Exact")),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(color: active ? primaryPurple : Colors.transparent, borderRadius: BorderRadius.circular(6)),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.grey, fontSize: 11)),
        ),
      ),
    );
  }

  Widget _buildLocationButton(StateSetter setSheetState) {
    return GestureDetector(
      onTap: () => _determinePosition(setSheetState),
      child: Container(
        height: 38,
        width: 180,
        decoration: BoxDecoration(border: Border.all(color: primaryPurple.withOpacity(0.3)), borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: isCapturing
              ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: primaryPurple))
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.my_location, color: primaryPurple, size: 14),
              const SizedBox(width: 6),
              Text(_currentPosition ?? "Capture Location", style: const TextStyle(color: primaryPurple, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  void _showReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Center(
          child: Text("Review Details", style: TextStyle(fontSize: 16, color: primaryPurple, fontWeight: FontWeight.bold)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _reviewRow("Farmer", _nameController.text),
            _reviewRow("Crop", "Wheat"),
            _reviewRow("Date", selectedDate),
            _reviewRow("Location", _currentPosition ?? ""),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Edit", style: TextStyle(fontSize: 12, color: Colors.grey))),
          ElevatedButton(
            onPressed: _handleFinalConfirm,
            style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, padding: const EdgeInsets.symmetric(horizontal: 20)),
            child: const Text("Confirm", style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  void _handleFinalConfirm() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User not logged in")));
      return;
    }

    final name = _nameController.text.trim();

    // Convert date
    final parts = selectedDate.split('/');
    final parsedDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));

    final plantingData = {
      'id': user.id,
      'name': name,
      'email': user.email,
      'crop': "Wheat",
      'planting_date': parsedDate.toIso8601String(),
      'latitude': _lat ?? 0.0,
      'longitude': _lng ?? 0.0,
      'is_exact': isExact,
      'notes': _notesController.text.trim(),
      'is_crop_planted': true,
    };

    try {
      // Use profile table for all crop and user data. 
      // users table is removed from schema.
      await supabase.from('profile').update(plantingData).eq('id', user.id);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isCropPlanted', true);
      await prefs.setString('farmerName', name);
      await prefs.setString('plantingData', jsonEncode(plantingData));

      if (!mounted) return;
      Navigator.pop(context); // Dialog
      Navigator.pop(context); // Bottom Sheet
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save data: $e")));
      }
    }
  }

  Future<void> _selectDate(StateSetter setSheetState) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2027),
    );
    if (picked != null) {
      setSheetState(() => selectedDate = "${picked.day}/${picked.month}/${picked.year}");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLastStep = currentActiveStage == totalStages;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryPurple,
        elevation: 0,
        centerTitle: true,
        title: const Text("Agricultural Guide", style: TextStyle(color: Colors.white, fontSize: 16)),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildTimeline(),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: _getStepContent())),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildNavigationButtons(isLastStep),
    );
  }

  Widget _buildTimeline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(totalStages, (index) {
          int stageNumber = index + 1;
          bool done = stageNumber <= currentActiveStage;
          return Expanded(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(color: done ? primaryPurple : unselectedPurple, shape: BoxShape.circle),
                  child: Icon(stageNumber < currentActiveStage ? Icons.check : _getIconForStage(stageNumber), size: 14, color: done ? Colors.white : inactiveIconColor),
                ),
                const SizedBox(height: 4),
                Text("STEP $stageNumber", style: TextStyle(fontSize: 6, color: done ? primaryPurple : Colors.grey)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationButtons(bool isLastStep) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (currentActiveStage > 1)
            _navCircleButton(icon: Icons.arrow_back, onPressed: () => setState(() => currentActiveStage--))
          else
            const SizedBox(width: 45),
          _navCircleButton(
            label: isLastStep ? "Plant" : null,
            icon: isLastStep ? null : Icons.arrow_forward,
            onPressed: () => isLastStep ? _showPlantingForm() : setState(() => currentActiveStage++),
            isPrimary: isLastStep,
          ),
        ],
      ),
    );
  }

  Widget _navCircleButton({IconData? icon, String? label, required VoidCallback onPressed, bool isPrimary = false}) {
    return SizedBox(
      height: 45,
      width: label != null ? 80 : 45,
      child: FloatingActionButton(
        elevation: 2,
        heroTag: label ?? icon.toString(),
        onPressed: onPressed,
        backgroundColor: unselectedPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: label != null
            ? Text(label, style: const TextStyle(color: primaryPurple, fontSize: 13, fontWeight: FontWeight.bold))
            : Icon(icon, color: primaryPurple, size: 20),
      ),
    );
  }

  IconData _getIconForStage(int stage) {
    switch (stage) {
      case 1: return Icons.menu_book;
      case 2: return Icons.wb_sunny;
      case 3: return Icons.settings;
      case 4: return Icons.grain;
      case 5: return Icons.biotech;
      case 6: return Icons.water_drop;
      default: return Icons.circle;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
