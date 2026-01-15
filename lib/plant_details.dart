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
  final String? notes;
  final String? dateAccuracy;

  const RecommendationsPage({
    super.key,
    required this.cropName,
    required this.plantingDate,
    this.notes,
    this.dateAccuracy,
  });

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  late DateTime _selectedDate;
  final int _totalDays = 100;
  bool _isEditingNotes = false;
  late TextEditingController _notesController;
  String _editableNotes = "";

  List<String> _imagePaths = [];
  List<String> _instructions = [];

  double? _temperature;
  int? _humidity;
  String? _weatherDescription;
  bool _loadingWeather = true;

  int _selectedImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _editableNotes = widget.notes ?? "";
    _notesController = TextEditingController(text: _editableNotes);

    _selectedDate = DateTime.now();
    if (_selectedDate.isBefore(widget.plantingDate)) {
      _selectedDate = widget.plantingDate;
    }
    _loadDayData();
    _loadWeather();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    return 'https://raw.githubusercontent.com/PolisettyTharunSai/DigiTwin/version2/DAY1.glb';
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

    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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

  /// 🖼️ FULL SCREEN IMAGE PREVIEW
  void _showImagePreview(int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      ClipRRect(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: PageView.builder(
                            itemCount: _imagePaths.length,
                            controller: PageController(
                              initialPage: initialIndex,
                            ),
                            onPageChanged: (index) {
                              setState(() {
                                _selectedImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Image.asset(
                                _imagePaths[index],
                                fit: BoxFit.contain,
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              "Day $_currentDay",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.arrow_back),
                                    label: const Text("Prev Day"),
                                    onPressed: _currentDay > 1
                                        ? () async {
                                      setState(() {
                                        _selectedDate = _selectedDate
                                            .subtract(
                                          const Duration(days: 1),
                                        );
                                      });
                                      await _loadDayData();
                                      setDialogState(() {});
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
                                      backgroundColor: Colors.green.shade600,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: _currentDay < _totalDays
                                        ? () async {
                                      setState(() {
                                        _selectedDate = _selectedDate.add(
                                          const Duration(days: 1),
                                        );
                                      });
                                      await _loadDayData();
                                      setDialogState(() {});
                                    }
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🌱 CROP STATUS CARD
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: SizedBox(
                  height: 240,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _imagePaths.length,
                    onPageChanged: (i) =>
                        setState(() => _selectedImageIndex = i),
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _showImagePreview(i),
                      child: Image.asset(
                        _imagePaths[i],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
              ),

              _navArrow(
                Icons.chevron_left,
                Alignment.centerLeft,
                _selectedImageIndex > 0
                    ? () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                )
                    : null,
              ),
              _navArrow(
                Icons.chevron_right,
                Alignment.centerRight,
                _selectedImageIndex < _imagePaths.length - 1
                    ? () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                )
                    : null,
              ),

              if (_isToday)
                Positioned(top: 12, left: 12, child: _badge("LIVE STATUS")),
              Positioned(top: 12, right: 12, child: _badge("Day $_currentDay")),
              Positioned(bottom: 12, right: 12, child: _watchIn3D(context)),
            ],
          ),

          /// DOTS
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_imagePaths.length, (i) {
                bool active = i == _selectedImageIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: active ? 10 : 6,
                  width: active ? 10 : 6,
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.green.shade600
                        : Colors.grey.shade400,
                    shape: BoxShape.circle,
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
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${(progress * 100).round()}%",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _dateInfo(
                      "PLANTED",
                      DateFormat('dd/MM/yyyy').format(widget.plantingDate),
                      accuracy: widget.dateAccuracy,
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
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Prev Day"),
                    onPressed: _currentDay > 1
                        ? () {
                      setState(() {
                        _selectedDate = _selectedDate.subtract(
                          const Duration(days: 1),
                        );
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
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _currentDay < _totalDays
                        ? () {
                      setState(() {
                        _selectedDate = _selectedDate.add(
                          const Duration(days: 1),
                        );
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

  /// 🔹 NAV ARROWS (CENTERED)
  Widget _navArrow(IconData icon, Alignment alignment, VoidCallback? onTap) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.black.withOpacity(0.4),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
          ),
        ),
      ),
    );
  }

  Widget _watchIn3D(BuildContext context) {
    return GestureDetector(
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.view_in_ar, color: Colors.green, size: 18),
            SizedBox(width: 6),
            Text(
              "Watch in 3D",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
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

  Widget _dateInfo(String label, String value, {String? accuracy}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black,
            ),
            children: [
              TextSpan(text: value),
              if (accuracy != null)
                TextSpan(
                  text: ' ($accuracy)',
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🔹 INFO CARDS ROW
  Widget _infoCardsRow() {
    return Row(
      children: const [
        Expanded(
          child: _InfoCard(
            title: "SOIL",
            value: "42%",
            icon: Icons.water_drop,
            color: Colors.blue,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _InfoCard(
            title: "PH",
            value: "6.5",
            icon: Icons.science,
            color: Colors.purple,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _InfoCard(
            title: "PEST",
            value: "Low",
            icon: Icons.bug_report,
            color: Colors.orange,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _InfoCard(
            title: "HEALTH",
            value: "98",
            icon: Icons.favorite,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  /// 🔹 NOTES CARD
  Widget _notesCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.green.shade100.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.note_alt_rounded,
                    color: Colors.green.shade700,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Farmer’s Notes",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),

              /// EDIT ICON
              IconButton(
                icon: Icon(
                  _isEditingNotes ? Icons.close : Icons.edit,
                  color: Colors.green.shade700,
                ),
                tooltip: _isEditingNotes ? "Cancel" : "Edit Notes",
                onPressed: () {
                  setState(() {
                    _isEditingNotes = !_isEditingNotes;
                    _notesController.text = _editableNotes;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// BODY
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isEditingNotes
                ? Column(
              key: const ValueKey("edit"),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Write important observations...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.green.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.green.shade600,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                /// ACTION BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        setState(() => _isEditingNotes = false);
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text("Save"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _editableNotes = _notesController.text;
                          _isEditingNotes = false;
                        });
                      },
                    ),
                  ],
                ),
              ],
            )
                : Text(
              _editableNotes,
              key: const ValueKey("view"),
              style: TextStyle(
                fontSize: 14.5,
                height: 1.5,
                color: Colors.green.shade900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 DAILY ROUTINE CARD
  Widget _dailyRoutineCard() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER (Dark)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1F2F44),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Daily Routine - Day $_currentDay",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  "AI Guided Optimization",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          /// BODY
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE
                Text(
                  "Sowing and seedbed preparation",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 16),

                /// WATERING
                _routineItem(
                  icon: Icons.water_drop,
                  iconColor: Colors.blue,
                  title: "WATERING",
                  description:
                  "Apply light irrigation before sowing and provide gentle watering after sowing if the soil is dry.",
                ),

                /// NUTRITION
                _routineItem(
                  icon: Icons.science,
                  iconColor: Colors.purple,
                  title: "NUTRITION",
                  description:
                  "Apply a basal NPK dose of 50:60:40 kg/ha during final land preparation.",
                ),

                /// PROTECTION
                _routineItem(
                  icon: Icons.bug_report,
                  iconColor: Colors.orange,
                  title: "PROTECTION",
                  description:
                  "Treat seeds with Thiram or Carbendazim at 2.5 g/kg before sowing to prevent diseases.",
                ),

                const SizedBox(height: 12),

                /// EXPERT TIPS
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.info, color: Colors.green),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Maintain a sowing depth of 4 to 5 cm to ensure uniform emergence.",
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _routineItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor.withOpacity(0.15),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 13)),
              ],
            ),
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
        title: Text('${widget.cropName} Details'),
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
            _infoCardsRow(),
            _notesCard(),
            _dailyRoutineCard(),
            const SizedBox(height: 20),
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

/// 🔹 SMALL INFO CARD
class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}