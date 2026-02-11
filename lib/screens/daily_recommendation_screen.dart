
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class DailyRecommendationScreen extends StatefulWidget {
  const DailyRecommendationScreen({super.key});

  @override
  State<DailyRecommendationScreen> createState() =>
      _DailyRecommendationScreenState();
}

class _DailyRecommendationScreenState extends State<DailyRecommendationScreen> {
  late Future<List<Map<String, String>>> _recommendations;

  @override
  void initState() {
    super.initState();
    _recommendations = _loadRecommendations();
  }

  Future<List<Map<String, String>>> _loadRecommendations() async {
    final List<Map<String, String>> recommendations = [];
    for (int i = 1; i <= 109; i++) {
      final path = 'assets/Data/day$i/day$i.txt';
      try {
        final data = await rootBundle.loadString(path);
        final lines = data.split('
');
        final recommendation = {
          'day': 'Day $i',
          'crop_stage': lines[0].split(': ')[1],
          'water_requirement': lines[1].split(': ')[1],
          'nutrient_application': lines[2].split(': ')[1],
        };
        recommendations.add(recommendation);
      } catch (e) {
        // Handle file not found or other errors
        print('Error loading recommendation for day $i: $e');
      }
    }
    return recommendations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Recommendations'),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _recommendations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading recommendations.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No recommendations found.'));
          }

          final recommendations = snapshot.data!;
          return ListView.builder(
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation['day']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildRecommendationRow(
                        icon: Icons.eco,
                        label: 'Crop Stage',
                        value: recommendation['crop_stage']!,
                      ),
                      const SizedBox(height: 10),
                      _buildRecommendationRow(
                        icon: Icons.water_drop,
                        label: 'Water Requirement',
                        value: recommendation['water_requirement']!,
                      ),
                      const SizedBox(height: 10),
                      _buildRecommendationRow(
                        icon: Icons.science,
                        label: 'Nutrient Application',
                        value: recommendation['nutrient_application']!,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRecommendationRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}
