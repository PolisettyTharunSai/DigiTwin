import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _plantingDate;
  String? _location;
  bool _planted = false;

  @override
  void initState() {
    super.initState();
    _loadPlantingDate();
  }

  Future<void> _loadPlantingDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedDate = prefs.getString('planting_date');
    if (savedDate != null) {
      setState(() {
        _plantingDate = DateTime.parse(savedDate);
        _planted = true;
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.green.shade900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _plantingDate = pickedDate;
      });
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission permanently denied.'),
        ),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _location =
          'Lat: ${position.latitude.toStringAsFixed(5)}, Lng: ${position.longitude.toStringAsFixed(5)}';
    });
  }

  Future<void> _confirmPlanting() async {
    if (_plantingDate == null || _location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and capture location first!'),
        ),
      );
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Planting'),
        content: Text(
          'Do you want to plant wheat crop on\n'
          '${_plantingDate!.toLocal().toString().split(' ')[0]}\n'
          'at $_location?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('planting_date', _plantingDate!.toIso8601String());

      // Add to "my_crops" list
      List<String> cropsList = prefs.getStringList('my_crops') ?? [];
      Map<String, dynamic> cropEntry = {
        'name': 'Wheat',
        'date': _plantingDate!.toIso8601String(),
        'location': _location!,
      };
      cropsList.add(jsonEncode(cropEntry));
      await prefs.setStringList('my_crops', cropsList);

      setState(() {
        _planted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🌾 Wheat crop planted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Card(
                elevation: 6,
                color: const Color(0xFFF7FDF8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Plant Your Wheat Crop',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: const Text('Select Planting Date'),
                        onPressed: _selectDate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          foregroundColor: Colors.green.shade900,
                        ),
                      ),
                      if (_plantingDate != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Selected Date: ${_plantingDate!.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.my_location),
                        label: const Text('Capture Live Location'),
                        onPressed: _getLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          foregroundColor: Colors.green.shade900,
                        ),
                      ),
                      if (_location != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _location!,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.agriculture),
                        label: const Text('Plant Wheat Crop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: _confirmPlanting,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
