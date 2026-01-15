import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'plant_details.dart';

class MyCropsPage extends StatefulWidget {
  const MyCropsPage({super.key});

  @override
  State<MyCropsPage> createState() => _MyCropsPageState();
}

class _MyCropsPageState extends State<MyCropsPage> {
  List<Map<String, dynamic>> _myCrops = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCropFilter;

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCrops() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cropsList = prefs.getStringList('my_crops') ?? [];

    /// 🌱 Default crop for testing (only once)
    if (cropsList.isEmpty) {
      cropsList.add(
        jsonEncode({
          'farmerName': 'Test Farmer',
          'crop': 'Wheat',
          'date': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'dateAccuracy': 'Exact',
          'location': 'Lat: 17.3850, Lng: 78.4867',
          'notes': 'Default test crop',
        }),
      );
      await prefs.setStringList('my_crops', cropsList);
    }

    setState(() {
      _myCrops = cropsList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    });
  }

  List<Map<String, dynamic>> get _filteredCrops {
    return _myCrops.where((crop) {
      final matchesSearch = _searchQuery.isEmpty ||
          crop.values.any((value) =>
              value.toString().toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesFilter = _selectedCropFilter == null ||
          crop['crop'] == _selectedCropFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  List<String> get _uniqueCropTypes {
    return _myCrops
        .map((crop) => crop['crop']?.toString() ?? 'Unknown')
        .toSet()
        .toList();
  }

  /// 🔐 Safe string
  String _safe(dynamic value, {String fallback = 'Unknown'}) {
    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }
    return value.toString();
  }

  /// 📅 Crop day calculation
  int _cropDay(String? isoDate) {
    if (isoDate == null) return 0;
    try {
      final planted = DateTime.parse(isoDate);
      final diff = DateTime.now().difference(planted).inDays;
      return diff < 0 ? 0 : diff + 1;
    } catch (_) {
      return 0;
    }
  }

  /// 🖼️ Day-based image
  String _dayImagePath(int day) {
    if (day <= 0) {
      return 'assets/Data/day1/images/day1_5.jpg';
    }
    return 'assets/Data/day$day/images/day${day}_5.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final filteredCrops = _filteredCrops;
    final cropTypes = _uniqueCropTypes;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F3),

      /// 🌾 AppBar
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.shade700,
                Colors.green.shade500,
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(22),
            ),
          ),
        ),
        title: const Text(
          'Digital Twin',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.green),
            ),
            onSelected: (value) {
              if (value == 'profile') {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Profile'),
                    content: const Text(
                      '👤 Farmer Profile\n\nName: Test Farmer\nRole: User',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              } else if (value == 'logout') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out (demo)')),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.green),
                    SizedBox(width: 10),
                    Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      /// 🌱 Body
      body: Column(
        children: [
          /// 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search crops...',
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),

          /// 🏷️ Filter Chips
          if (cropTypes.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedCropFilter == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCropFilter = null;
                      });
                    },
                    selectedColor: Colors.green.shade600,
                    labelStyle: TextStyle(
                      color: _selectedCropFilter == null ? Colors.white : Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...cropTypes.map((type) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(type),
                        selected: _selectedCropFilter == type,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCropFilter = selected ? type : null;
                          });
                        },
                        selectedColor: Colors.green.shade600,
                        labelStyle: TextStyle(
                          color: _selectedCropFilter == type ? Colors.white : Colors.green.shade700,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

          /// 🌾 Crops List
          Expanded(
            child: _myCrops.isEmpty
                ? Center(
                    child: Text(
                      'No crops planted yet 🌱',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green.shade700,
                      ),
                    ),
                  )
                : filteredCrops.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No matches found 🔍',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadCrops,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: filteredCrops.length,
                          itemBuilder: (context, index) {
                            final crop = filteredCrops[index];

                            final cropName = _safe(crop['crop'], fallback: 'Unknown Crop');
                            final farmer = _safe(crop['farmerName'], fallback: 'Unknown Farmer');
                            final dateIso = crop['date'];
                            final notes = crop['notes'];

                            final day = _cropDay(dateIso);
                            final imagePath = _dayImagePath(day);

                            void openDetails() {
                              if (dateIso != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RecommendationsPage(
                                      cropName: cropName,
                                      plantingDate: DateTime.parse(dateIso),
                                      notes: notes,
                                    ),
                                  ),
                                );
                              }
                            }

                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.95, end: 1.0),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              builder: (context, scale, child) {
                                return Transform.scale(scale: scale, child: child);
                              },
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: openDetails,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Stack(
                                      children: [
                                        /// 🌿 Plant Image
                                        Positioned.fill(
                                          child: Image.asset(
                                            imagePath,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              color: Colors.green.shade100,
                                              child: const Icon(Icons.image, size: 40),
                                            ),
                                          ),
                                        ),

                                        /// 🌫️ Gradient Overlay
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.black.withValues(alpha: 0.15),
                                                  Colors.black.withValues(alpha: 0.65),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        /// 🟢 Day Badge (Top Right)
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade600,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              'Day $day',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),

                                        /// 📄 Crop Info (Bottom)
                                        Positioned(
                                          left: 12,
                                          right: 12,
                                          bottom: 14,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              /// 🌾 Crop Name
                                              Text(
                                                cropName,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),

                                              const SizedBox(height: 6),

                                              /// 👨‍🌾 Farmer Name
                                              Row(
                                                children: [
                                                  const Icon(Icons.person,
                                                      size: 14, color: Colors.white70),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      farmer,
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 12,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
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
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
