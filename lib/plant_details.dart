import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
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

  double? _temperature;
  int? _humidity;
  String? _weatherDescription;
  bool _loadingWeather = true;

  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    if (_selectedDate.isBefore(widget.plantingDate)) {
      _selectedDate = widget.plantingDate;
    }
    _loadDayData();
    _loadWeather();
  }

  int get _currentDay {
    int day = _selectedDate.difference(widget.plantingDate).inDays + 1;
    if (day < 1) day = 1;
    if (day > _totalDays) day = _totalDays;
    return day;
  }

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  DateTime get _estimatedHarvest =>
      widget.plantingDate.add(const Duration(days: 100));

  String _getModelForDay(int day) {
    return 'https://raw.githubusercontent.com/PolisettyTharunSai/DigiTwin/main/wheat0comp.glb';
  }

  /// 🌤 WEATHER
  Future<void> _loadWeather() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> crops = prefs.getStringList('my_crops') ?? [];
      if (crops.isEmpty) {
        setState(() => _loadingWeather = false);
        return;
      }

      final lastCrop = jsonDecode(crops.last);
      final location = lastCrop['location'];

      final lat = double.parse(
        location.split(',')[0].replaceAll('Lat:', '').trim(),
      );
      final lon = double.parse(
        location.split(',')[1].replaceAll('Lng:', '').trim(),
      );

      const apiKey = '96fede33103a6901b4a135d4f0172d38';
      final url =
          'https://api.openweathermap.org/data/2.5/weather'
          '?lat=$lat&lon=$lon&units=metric&appid=$apiKey';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        setState(() => _loadingWeather = false);
        return;
      }

      final data = jsonDecode(response.body);
      setState(() {
        _temperature = (data['main']['temp'] as num).toDouble();
        _humidity = data['main']['humidity'] as int;
        _weatherDescription = data['weather'][0]['description'];
        _loadingWeather = false;
      });
    } catch (_) {
      setState(() => _loadingWeather = false);
    }
  }

  /// 📂 DAY DATA
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
      lines = txt.split('\n').where((e) => e.trim().isNotEmpty).toList();
    } catch (_) {
      lines = ["No data available for Day $day."];
    }

    setState(() {
      _imagePaths = images;
      _instructions = lines;
      _selectedImageIndex = 0;
    });
  }

  /// 🌤 WEATHER CARD
  Widget _weatherCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.cloud, color: Colors.blue.shade400, size: 36),
          const SizedBox(width: 12),
          _loadingWeather || _temperature == null
              ? const Text("Fetching weather...")
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${_temperature!.round()}°C | $_humidity% Humidity",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "Current Weather • ${_weatherDescription ?? 'Clear'}",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🌱 CROP STATUS CARD (UPDATED)
  Widget _cropStatusCard() {
    if (_imagePaths.isEmpty) return const SizedBox();

    double progress = _currentDay / _totalDays;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18),
        ],
      ),
      child: Column(
        children: [
          /// IMAGE AREA
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.asset(
                  _imagePaths[_selectedImageIndex],
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              /// LIVE STATUS (only today)
              if (_isToday)
                Positioned(top: 12, left: 12, child: _badge("LIVE STATUS")),

              /// DAY BADGE
              Positioned(
                top: 12,
                right: 12,
                child: _badge("Day $_currentDay of $_totalDays"),
              ),

              /// WATCH IN 3D
              Positioned(
                bottom: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ARViewPage(
                          cropName: widget.cropName,
                          modelPath: _getModelForDay(_currentDay),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.view_in_ar,
                            color: Colors.green, size: 18),
                        SizedBox(width: 6),
                        Text(
                          "Watch in 3D",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          /// DOT INDICATOR
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_imagePaths.length, (index) {
                bool isActive = index == _selectedImageIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedImageIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: isActive ? 10 : 6,
                    width: isActive ? 10 : 6,
                    decoration: BoxDecoration(
                      color:
                      isActive ? Colors.green.shade600 : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),

          /// DETAILS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "GROWTH COMPLETION",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  "${(progress * 100).round()}%",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _dateInfo(
                      "PLANTED",
                      DateFormat('dd/MM/yyyy')
                          .format(widget.plantingDate),
                    ),
                    _dateInfo(
                      "EST. HARVEST",
                      DateFormat('dd/MM/yyyy').format(_estimatedHarvest),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// PREV / NEXT DAY
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Previous Day"),
                    onPressed: _currentDay > 1
                        ? () {
                      setState(() {
                        _selectedDate = _selectedDate
                            .subtract(const Duration(days: 1));
                        _loadDayData();
                      });
                    }
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("Next Day"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600),
                    onPressed: _currentDay < _totalDays
                        ? () {
                      setState(() {
                        _selectedDate =
                            _selectedDate.add(const Duration(days: 1));
                        _loadDayData();
                      });
                    }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _dateInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Day $_currentDay Instructions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _instructions.map((e) => Text("• $e")).toList(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _weatherCard(),
            const SizedBox(height: 20),
            _cropStatusCard(),
            const SizedBox(height: 20),

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