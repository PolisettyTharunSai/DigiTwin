import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onPlantingConfirmed;

  const HomePage({
    super.key,
    this.onPlantingConfirmed,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _plantingDate;
  String? _location;

  final Color _iconGreen = Colors.green.shade700;

  final TextEditingController _farmerNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  String _selectedCrop = 'Wheat';
  String _dateAccuracy = 'Exact';

  final List<String> _cropOptions = [
    'Wheat',
    'Rice',
    'Maize',
    'Cotton',
    'Pulses',
  ];

  @override
  void dispose() {
    _farmerNameController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _plantingDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _plantingDate = picked;
        _dateController.text = _dateFormat.format(picked);
      });
    }
  }

  Future<void> _getLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      _showSnack('Please enable location services');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _location =
      'Lat: ${pos.latitude.toStringAsFixed(5)}, '
          'Lng: ${pos.longitude.toStringAsFixed(5)}';
    });
  }

  Future<void> _confirmPlanting() async {
    if (_farmerNameController.text.trim().isEmpty) {
      _showSnack('Please enter farmer name');
      return;
    }

    if (_plantingDate == null || _location == null) {
      _showSnack('Please select date and capture location');
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> crops = prefs.getStringList('my_crops') ?? [];

    crops.add(jsonEncode({
      'farmerName': _farmerNameController.text.trim(),
      'crop': _selectedCrop,
      'date': _plantingDate!.toIso8601String(),
      'dateAccuracy': _dateAccuracy,
      'location': _location,
      'notes': _notesController.text,
    }));

    await prefs.setStringList('my_crops', crops);

    widget.onPlantingConfirmed?.call();
  }

  void _showSnack(String msg) {
    // Note: Since we are in a Dialog, this might show on the underlying screen
    // or need a Scaffold ancestor. NavigationWrapper provides a Scaffold, so this works.
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Fix: Changed Scaffold to Material to allow shrink-wrapping.
    return Material(
      color: const Color(0xFFF0F8F3),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Plant Your Crop',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _farmerNameController,
                      decoration: InputDecoration(
                        labelText: 'Farmer Name',
                        prefixIcon:
                        Icon(Icons.person, color: _iconGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _selectedCrop,
                      decoration: InputDecoration(
                        labelText: 'Select Crop',
                        prefixIcon:
                        Icon(Icons.grass, color: _iconGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _cropOptions
                          .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCrop = v!),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: _selectDate,
                      decoration: InputDecoration(
                        labelText: 'Planting Date',
                        prefixIcon:
                        Icon(Icons.calendar_today, color: _iconGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                setState(() => _dateAccuracy = 'Exact'),
                            child: const Text('Exact'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                setState(() => _dateAccuracy = 'Approx'),
                            child: const Text('Approx'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Farmer Notes (optional)',
                        prefixIcon:
                        Icon(Icons.note_alt, color: _iconGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.my_location),
                      label: const Text('Capture Location'),
                      onPressed: _getLocation,
                    ),

                    if (_location != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_location!),
                      ),
                  ],
                ),
              ),
            ),

            /// ✅ OUTSIDE CARD
            const SizedBox(height: 16),

            ElevatedButton.icon(
              icon: const Icon(Icons.agriculture),
              label: const Text('Confirm Planting'),
              onPressed: _confirmPlanting,
              style: ElevatedButton.styleFrom(
                backgroundColor: _iconGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}