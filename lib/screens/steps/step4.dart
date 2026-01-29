import 'package:flutter/material.dart';

class Step4Content extends StatelessWidget {
  const Step4Content({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF7F3DFF);
    final double imageHeight = MediaQuery.of(context).size.height / 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Image Header
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              'assets/images/step4.png',
              height: imageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: imageHeight,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // 2. Main Title
        const Text(
          "Sowing & Field Preparation",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Success starts with the right timing and a perfectly prepared seedbed.",
          style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
        ),
        const SizedBox(height: 25),

        // 3. Sowing Window Section (Themed Purple)
        _buildSectionHeader(
          "The Sowing Window",
          Icons.calendar_month,
          primaryPurple,
        ),
        const SizedBox(height: 12),
        _buildWindowCard(
          "Long-Duration (135–140 Days)",
          "10 Nov – 30 Nov",
          "BEST YIELD: Early sowing allows better tillering and heavier grains.",
          Colors.green,
        ),
        const SizedBox(height: 10),
        _buildWindowCard(
          "Short-Duration (120–125 Days)",
          "Up to 15 Dec",
          "LATE SOWING: Yield potential drops quickly after mid-December.",
          Colors.orange,
        ),
        const SizedBox(height: 10),
        _buildWarningBox(
          "Sowing after 15 Dec leads to shriveled grains due to heat.",
        ),

        const SizedBox(height: 30),

        // 4. Field Preparation Section (New Detailed UI)
        _buildSectionHeader("Field Preparation", Icons.landscape, Colors.brown),
        const SizedBox(height: 12),

        _buildDetailedPrepCard(
          title: "Tilth Quality",
          icon: Icons.architecture,
          color: Colors.brown,
          description:
              "One disking followed by harrowing. Aim for moderately fine soil (not powdery) and a well-levelled field.",
          points: [
            "Correct seed depth placement",
            "Better germination & uniform growth",
          ],
        ),

        _buildDetailedPrepCard(
          title: "Zero Tillage",
          icon: Icons.eco,
          color: Colors.teal,
          description:
              "Sowing without ploughing, especially useful after rice harvest.",
          points: [
            "Saves time, fuel, and costs",
            "Conserves soil moisture",
            "Allows early sowing for higher yield",
          ],
        ),

        _buildDetailedPrepCard(
          title: "Dibbling",
          icon: Icons.straighten,
          color: Colors.blueGrey,
          description:
              "Placing seeds manually in lines or holes. Can be done in prepared fields or zero tillage.",
          points: [
            "Requires less seed quantity",
            "Ensures precise depth and spacing",
            "Better crop establishment",
          ],
        ),

        const SizedBox(height: 30),

        // 5. Sowing Methods
        _buildSectionHeader(
          "Choosing a Sowing Method",
          Icons.settings_suggest,
          primaryPurple,
        ),
        const SizedBox(height: 15),

        _buildMethodCard(
          "Broadcasting",
          "Seeds are scattered by hand. Simple but less uniform.",
          Icons.pan_tool_alt,
          primaryPurple,
        ),
        _buildMethodCard(
          "Behind the plough",
          "Seeds are dropped in the furrow made by the plough.",
          Icons.hardware,
          primaryPurple,
        ),
        _buildMethodCard(
          "Drilling",
          "Using a seed drill for right depth and spacing.",
          Icons.line_weight,
          primaryPurple,
        ),
        _buildMethodCard(
          "FIRB System",
          "Raised beds with furrows. Saves water and improves aeration.",
          Icons.water_drop,
          primaryPurple,
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  // --- REFINED HELPER WIDGETS ---

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // FIXED: Prevents heading from being pushed to next line by using a Column for mobile-first wrapping
  Widget _buildWindowCard(String type, String date, String desc, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  date,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedPrepCard({
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required List<String> points,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          ...points.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: color.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(
    String title,
    String desc,
    IconData icon,
    Color themeColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: themeColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: themeColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox(String text) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
