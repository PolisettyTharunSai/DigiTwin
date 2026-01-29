import 'package:flutter/material.dart';

class Step3Content extends StatelessWidget {
  const Step3Content({super.key});

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
              'assets/images/step3.png',
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
          "Temperature & Growth Stages",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Understanding how heat affects each stage helps you manage water and nutrients at the right time.",
          style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
        ),
        const SizedBox(height: 25),

        // 3. Temperature Impact Matrix
        _buildSectionHeader(
          "Temperature Effects",
          Icons.thermostat,
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildTemperatureMetric(
          "Vegetative Phase",
          "16°C – 22°C",
          "Ideal for leaves and roots. Above 22°C, plants become shorter and yield drops.",
          Colors.teal,
        ),
        const SizedBox(height: 10),
        _buildTemperatureMetric(
          "Grain Filling",
          "25°C",
          "Best for 4-5 weeks. High heat (>25°C) leads to lighter, shriveled grains.",
          Colors.deepOrange,
        ),

        const SizedBox(height: 30),

        // 4. Growth Timeline (Lines removed after last item)
        _buildSectionHeader(
          "Growth Timeline (North India)",
          Icons.speed,
          primaryPurple,
        ),
        const SizedBox(height: 15),

        _buildPhaseLabel("VEGETATIVE PHASE"),
        _buildTimelineStep(
          "Germination",
          "5–7 Days",
          "Seeds sprout and establish.",
        ),
        _buildTimelineStep(
          "CRI (Crown Root Initiation)",
          "20–25 Days",
          "MOST CRITICAL STAGE. Must irrigate and apply nutrients now.",
          isCritical: true,
        ),
        _buildTimelineStep(
          "Tillering",
          "15–45 Days",
          "Side shoots develop for extra yield.",
        ),
        _buildTimelineStep(
          "Jointing",
          "45–60 Days",
          "Rapid height growth starts.",
        ),

        const SizedBox(height: 15),

        _buildPhaseLabel("REPRODUCTIVE PHASE"),
        _buildTimelineStep(
          "Boot Leaf",
          "70–75 Days",
          "The ear is about to emerge.",
        ),
        _buildTimelineStep("Flowering", "85–90 Days", "Pollination occurs."),
        _buildTimelineStep(
          "Milking & Dough",
          "100–110 Days",
          "Grains turn from milky fluid to soft solids.",
        ),
        // Final step with isLast: true
        _buildTimelineStep(
          "Maturity",
          "115–120 Days",
          "Crop turns golden and ready to harvest.",
          isLast: true,
        ),

        const SizedBox(height: 30),

        // 5. Key Takeaways
        const Divider(height: 40, thickness: 1),
        const Text(
          "Key Takeaways",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _TipRow(
          icon: Icons.ac_unit_rounded,
          text: "Cool weather helps early growth",
          color: Colors.blue,
        ),
        _TipRow(
          icon: Icons.wb_sunny_rounded,
          text: "Moderate warmth is for grain filling",
          color: Colors.orange,
        ),
        _TipRow(
          icon: Icons.trending_down_rounded,
          text: "Very high temperature reduces yield",
          color: Colors.red,
        ),
        _TipRow(
          icon: Icons.event_available_rounded,
          text: "Time actions by DAS (Days After Sowing)",
          color: primaryPurple,
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureMetric(
    String phase,
    String temp,
    String desc,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                phase,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                temp,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    String title,
    String days,
    String desc, {
    bool isCritical = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isCritical ? Colors.red : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              // Conditional Vertical Line: Only show if NOT the last item
              if (!isLast)
                Container(
                  width: 2,
                  height: 50, // Adjusted height to match spacing
                  color: Colors.grey.shade200,
                ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isCritical ? Colors.red : Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        days,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _TipRow({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
