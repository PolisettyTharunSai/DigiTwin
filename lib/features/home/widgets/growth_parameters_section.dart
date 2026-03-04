import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/day_utils.dart';

/// Displays the three growth-parameter insight cards:
/// crop stage, water requirement, and nutrient application.
class GrowthParametersSection extends StatelessWidget {
  final String stage;
  final String water;
  final String nutrients;

  const GrowthParametersSection({
    super.key,
    required this.stage,
    required this.water,
    required this.nutrients,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Growth Parameters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GrowthParameterCard(
            icon: Icons.eco_outlined,
            label: 'Stage',
            value: stage,
            iconBgColor: Colors.green.withOpacity(0.12),
            iconColor: Colors.green,
          ),
          const SizedBox(height: 12),
          GrowthParameterCard(
            icon: Icons.water_drop_outlined,
            label: 'Water',
            value: DayUtils.formatWaterText(water),
            iconBgColor: Colors.blue.withOpacity(0.1),
            iconColor: Colors.blue,
          ),
          const SizedBox(height: 12),
          GrowthParameterCard(
            icon: Icons.science_outlined,
            label: 'Nutrient Application',
            value: nutrients,
            iconBgColor: Colors.orange.withOpacity(0.1),
            iconColor: Colors.orange,
          ),
        ],
      ),
    );
  }
}

/// A single parameter insight card used in [GrowthParametersSection].
class GrowthParameterCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconBgColor;
  final Color iconColor;

  const GrowthParameterCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconBgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 3,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
