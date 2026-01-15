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

  @override
  void initState() {
    super.initState();
    _loadCrops();
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
      body: _myCrops.isEmpty
          ? Center(
        child: Text(
          'No crops planted yet 🌱',
          style: TextStyle(
            fontSize: 18,
            color: Colors.green.shade700,
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadCrops,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: _myCrops.length,
          itemBuilder: (context, index) {
            final crop = _myCrops[index];

            final cropName =
            _safe(crop['crop'], fallback: 'Unknown Crop');
            final farmer =
            _safe(crop['farmerName'], fallback: 'Unknown Farmer');
            final dateIso = crop['date'];
            final notes = crop['notes'];

            final day = _cropDay(dateIso);
            final imagePath = _dayImagePath(day);
            final dateText = dateIso != null
                ? DateTime.parse(dateIso)
                .toLocal()
                .toString()
                .split(' ')[0]
                : 'Unknown Date';

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

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: openDetails,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🖼️ Image
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: Colors.green.shade100,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.green,
                            ),
                          );
                        },
                      ),
                    ),

                    /// 📄 Info + Action
                    Expanded(
                      child: Padding(
                        padding:
                        const EdgeInsets.fromLTRB(10, 8, 10, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$cropName (Day $day)',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),

                            Row(
                              children: [
                                const Icon(Icons.person,
                                    size: 14, color: Colors.green),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    farmer,
                                    style: const TextStyle(
                                        fontSize: 12),
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 14, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  dateText,
                                  style: const TextStyle(
                                      fontSize: 11),
                                ),
                              ],
                            ),

                            const Spacer(),

                            /// 👉 Action Button
                            Align(
                              alignment: Alignment.bottomRight,
                              child: InkWell(
                                onTap: openDetails,
                                borderRadius:
                                BorderRadius.circular(30),
                                splashColor:
                                Colors.green.withOpacity(0.2),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(
                                    Icons.chevron_right,
                                    color: Colors.green,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
