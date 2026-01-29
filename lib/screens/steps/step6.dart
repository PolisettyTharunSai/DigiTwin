import 'package:flutter/material.dart';

class Step6Content extends StatelessWidget {
  const Step6Content({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2196F3);
    const Color wheatOrange = Color(0xFFFFA000);
    const Color weedGreen = Color(0xFF4CAF50);

    return LayoutBuilder(
      key: const ValueKey('step6_layout_builder'),
      builder: (context, constraints) {
        final double imageHeight = constraints.maxWidth * 0.5;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Image
              Container(
                width: double.infinity,
                height: imageHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/step6.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.water_drop,
                        size: 40,
                        color: primaryBlue.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Irrigation & Crop Care",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Wheat responds strongly to irrigation. 4–6 waterings are usually required for a healthy crop.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 25),

              // 2. CRITICAL IRRIGATION TIMELINE
              const Text(
                "Critical Watering Stages",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailedTimeline(primaryBlue),

              const SizedBox(height: 12),
              _buildImprovedTechnicalGrid(primaryBlue),

              const SizedBox(height: 35),

              // 3. WEED MANAGEMENT
              _buildSectionHeader("Weed Management", Icons.eco, weedGreen),
              const SizedBox(height: 12),
              _buildWeedControlDashboard(weedGreen),
              const SizedBox(height: 12),
              _buildHerbicideTable(),

              const SizedBox(height: 35),

              // 4. HARVESTING & THRESHING
              _buildSectionHeader(
                "Harvesting & Threshing",
                Icons.agriculture,
                wheatOrange,
              ),
              const SizedBox(height: 16),
              _buildImprovedHarvestCard(wheatOrange),

              const SizedBox(height: 35),

              // 5. CROPPING SYSTEMS
              _buildSectionHeader(
                "Rotation & Systems",
                Icons.sync,
                Colors.teal,
              ),
              const SizedBox(height: 12),
              const Text(
                "Wheat is usually grown after Kharif crops. Common rotations include:",
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              _buildRotationChips(),
              const Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  "Note: A third 'catch crop' is often grown in specific regions.",
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  // --- 1. IMPROVED TECHNICAL GRID ---
  Widget _buildImprovedTechnicalGrid(Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Technical Guidelines",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Divider(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            children: [
              _gridItem(
                "Moisture",
                "40-50% Depletion",
                Icons.water_drop,
                color,
              ),
              _gridItem("Soil Type", "Clay Loam (80%)", Icons.landscape, color),
              _gridItem("IW:CPE", "0.7 – 0.9 Ratio", Icons.analytics, color),
              _gridItem("Count", "4–6 Waterings", Icons.repeat, color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gridItem(String label, String val, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
              Text(
                val,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 2. IMPROVED HARVEST CARD ---
  Widget _buildImprovedHarvestCard(Color color) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _harvestInfoRow(
                  Icons.check_circle,
                  "Maturity",
                  "Yellow/dry straw, hard grains.",
                  color,
                ),
                const SizedBox(height: 12),
                _harvestInfoRow(
                  Icons.speed,
                  "Moisture",
                  "Ideal moisture: 20–25%.",
                  color,
                ),
                const SizedBox(height: 12),
                _harvestInfoRow(
                  Icons.report_problem,
                  "Caution",
                  "Over-ripening causes shattering.",
                  color,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            color: color.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.lightbulb, size: 18, color: color),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Manual Tip: Dry for 3–4 days before threshing.",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _harvestInfoRow(
    IconData icon,
    String title,
    String desc,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color.withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: "$title: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- OTHER COMPONENTS (IRRIGATION, WEEDS, ROTATION) ---

  Widget _buildDetailedTimeline(Color color) {
    final stages = [
      {
        "title": "CRI Stage (20–25 DAS)",
        "desc": "Water helps strong roots & more tillers.",
        "icon": Icons.star,
        "isCritical": true,
      },
      {
        "title": "Jointing Stage",
        "desc": "Helps the plant grow tall and strong.",
        "icon": Icons.straighten,
      },
      {
        "title": "Flowering Stage",
        "desc": "Ensures a higher number of grains.",
        "icon": Icons.local_florist,
      },
      {
        "title": "Milk Stage",
        "desc": "Proper grain filling for heavier grains.",
        "icon": Icons.fitness_center,
      },
    ];

    return Column(
      children: stages.map((s) {
        int index = stages.indexOf(s);
        bool isCrit = s['isCritical'] == true;
        return IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  Icon(
                    s['icon'] as IconData,
                    color: isCrit ? Colors.red : color,
                    size: 20,
                  ),
                  if (index != stages.length - 1)
                    Expanded(
                      child: Container(width: 2, color: Colors.grey.shade300),
                    ),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCrit ? Colors.red.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s['desc'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeedControlDashboard(Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monocot Weeds (Phalaris, Wild Oat, etc.)",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const Divider(height: 20),
          Row(
            children: [
              _metric("1st Hand Weeding", "Day 20–25"),
              const SizedBox(width: 10),
              _metric("2nd Hand Weeding", "+2 Weeks"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHerbicideTable() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1.3),
        },
        children: [
          _row(["Type", "Chemical", "Rate/Time"], isHeader: true),
          _row(["Dicots", "2,4-D (EE)", "0.3kg/ha"]),
          _row(["Monocots", "Isoproturon", "1.0kg/ha"]),
          _row(["Pre-Em", "Pendimethalin", "Early"]),
        ],
      ),
    );
  }

  Widget _buildRotationChips() {
    final crops = [
      "Rice",
      "Maize",
      "Sorghum",
      "Millet",
      "Mungbean",
      "Pigeonpea",
      "Cotton",
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: crops
          .map(
            (c) => Chip(
              label: Text(c, style: const TextStyle(fontSize: 11)),
              backgroundColor: Colors.teal.withOpacity(0.05),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _metric(String title, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
            Text(
              val,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _row(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? Colors.grey.shade100 : Colors.white,
      ),
      children: cells
          .map(
            (c) => Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                c,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
