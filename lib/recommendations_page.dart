import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart' show rootBundle;
// import 'ar_view_page1.dart';
import 'ar_view_page.dart';

class RecommendationsPage extends StatefulWidget {
  final String cropName;
  final DateTime plantingDate;

  const RecommendationsPage({
    super.key,
    required this.cropName,
    required this.plantingDate,
  });

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  late DateTime _selectedDate;
  final int _totalDays = 100;

  List<String> _imagePaths = [];
  List<String> _instructions = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    if (_selectedDate.isBefore(widget.plantingDate)) {
      _selectedDate = widget.plantingDate;
    }
    _loadDayData();
  }

  int get _currentDay {
    int day = _selectedDate.difference(widget.plantingDate).inDays + 1;
    if (day < 1) day = 1;
    if (day > _totalDays) day = _totalDays;
    return day;
  }

  String _getModelForDay(int day) {
    // if (day <= 7) {
    //   return 'assets/Models/mesh1.obj';
    // } else {
    //   return 'assets/Models/mesh2.obg';
    // }
    return 'https://raw.githubusercontent.com/PolisettyTharunSai/DigiTwin/main/wheat0.glb';
  }

  Future<void> _loadDayData() async {
    int day = _currentDay;
    String dayFolder = "assets/Data/day$day";

    List<String> images = [];
    List<String> lines = [];

    try {
      for (int i = 1; i <= 5; i++) {
        images.add("$dayFolder/images/day${day}_$i.jpg");
      }

      String txt = await rootBundle.loadString("$dayFolder/day$day.txt");
      lines = txt
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
    } catch (e) {
      lines = ["No data available for Day $day."];
    }

    setState(() {
      _imagePaths = images;
      _instructions = lines;
    });
  }

  void _openDatePicker() async {
    DateTime firstDay = widget.plantingDate;
    DateTime lastDay = firstDay.add(Duration(days: _totalDays));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDay,
      lastDate: lastDay,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadDayData();
    }
  }

  void _goToNextDay() {
    DateTime newDate = _selectedDate.add(const Duration(days: 1));
    if (newDate.isBefore(widget.plantingDate.add(Duration(days: _totalDays)))) {
      setState(() => _selectedDate = newDate);
      _loadDayData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have reached the last day 🌾')),
      );
    }
  }

  void _goToPreviousDay() {
    DateTime newDate = _selectedDate.subtract(const Duration(days: 1));
    if (newDate.isBefore(widget.plantingDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are already on Day 1 🌱')),
      );
    } else {
      setState(() => _selectedDate = newDate);
      _loadDayData();
    }
  }

  void _showInstructions() {
    final filtered =
    _instructions.where((line) => line.trim().isNotEmpty).toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Day $_currentDay Instructions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: filtered.map((e) => Text("• $e")).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int day = _currentDay;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cropName} Recommendations'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month, color: Colors.green),
                  onPressed: _openDatePicker,
                ),
              ],
            ),
            const SizedBox(height: 15),

            Expanded(
              child: _imagePaths.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : CarouselSlider(
                options: CarouselOptions(
                  height: 300,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  viewportFraction: 0.85,
                ),
                items: _imagePaths.map((path) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      path,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ARViewPage(
                      cropName: widget.cropName,
                      modelPath: _getModelForDay(day),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.view_in_ar),
              label: const Text('View in AR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _goToPreviousDay,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Before Day'),
                ),
                ElevatedButton.icon(
                  onPressed: _goToNextDay,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next Day'),
                ),
              ],
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: _showInstructions,
              icon: const Icon(Icons.info_outline),
              label: const Text('Show Instructions'),
            ),

            const SizedBox(height: 10),

            Text(
              'Day $day of your crop cycle',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
