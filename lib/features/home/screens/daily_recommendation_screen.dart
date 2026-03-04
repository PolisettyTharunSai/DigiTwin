import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class DailyRecommendationScreen extends StatefulWidget {
  const DailyRecommendationScreen({super.key});

  @override
  State<DailyRecommendationScreen> createState() => _DailyRecommendationScreenState();
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
        final lines = data.split('\n');
        final recommendation = {
          'day': 'Day $i',
          'crop_stage': 'Not available',
          'water_requirement': 'Not available',
          'nutrient_application': 'Not available',
        };
        for (final line in lines) {
          if (line.startsWith('Crop stage:')) {
            recommendation['crop_stage'] = line.substring('Crop stage: '.length).trim();
          } else if (line.startsWith('Water requirement:')) {
            recommendation['water_requirement'] = line.substring('Water requirement: '.length).trim();
          } else if (line.startsWith('Nutrient application:')) {
            recommendation['nutrient_application'] = line.substring('Nutrient application: '.length).trim();
          }
        }
        if (recommendation['crop_stage'] != 'Not available' ||
            recommendation['water_requirement'] != 'Not available' ||
            recommendation['nutrient_application'] != 'Not available') {
          recommendations.add(recommendation);
        }
      } catch (e) {
        debugPrint('Error loading recommendation for day $i: $e');
      }
    }
    return recommendations;
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF9644);
    const bg = Color(0xFFFFF9F2);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(primary: primary),
            Expanded(
              child: FutureBuilder<List<Map<String, String>>>(
                future: _recommendations,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) return const Center(child: Text('Error loading recommendations.'));
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No recommendations found.'));
                  final recommendations = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) {
                      final rec = recommendations[index];
                      return _DayCard(recommendation: rec, index: index, total: recommendations.length, primary: primary);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary, primary.withValues(alpha: 0.85)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Daily Recommendations',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(18)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_outlined, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text('Season Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.recommendation, required this.index, required this.total, required this.primary});
  final Map<String, String> recommendation;
  final int index;
  final int total;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final bool isLast = index == total - 1;
    const Color textColor = Color(0xFF2D2007);
    const Color subText = Color(0xFF6F5F45);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Timeline(isLast: isLast, primary: primary),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, 8))],
                gradient: const LinearGradient(colors: [Color(0xFFFFF5EA), Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
                        child: Text(recommendation['day'] ?? 'Day', style: TextStyle(color: primary, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
                      ),
                      _pill(icon: Icons.eco, label: recommendation['crop_stage'] ?? '', color: primary, textColor: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _infoRow(icon: Icons.water_drop, label: 'Water Requirement', value: recommendation['water_requirement'] ?? '', textColor: textColor, subText: subText),
                  const SizedBox(height: 10),
                  _infoRow(icon: Icons.science, label: 'Nutrient Application', value: recommendation['nutrient_application'] ?? '', textColor: textColor, subText: subText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill({required IconData icon, required String label, required Color color, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.28), blurRadius: 10, offset: const Offset(0, 6))]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, color: textColor, size: 16), const SizedBox(width: 6), Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 12))],
      ),
    );
  }

  Widget _infoRow({required IconData icon, required String label, required String value, required Color textColor, required Color subText}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: primary.withValues(alpha: 0.12), shape: BoxShape.circle), child: Icon(icon, color: primary, size: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 14, height: 1.35, color: subText)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.isLast, required this.primary});
  final bool isLast;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 18, height: 18,
          decoration: BoxDecoration(
            color: Colors.white, border: Border.all(color: primary, width: 3), shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))],
          ),
        ),
        if (!isLast)
          Container(
            width: 3, height: 110, margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [primary.withValues(alpha: 0.7), primary.withValues(alpha: 0.15)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
      ],
    );
  }
}
