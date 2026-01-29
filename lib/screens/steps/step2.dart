import 'package:flutter/material.dart';

class Step2Content extends StatelessWidget {
  const Step2Content({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF7F3DFF);
    final double imageHeight = MediaQuery.of(context).size.height / 4;

    // Make content at least screen height minus some header space so parent scroll
    // handles all scrolling and resetting parent scroll brings this step to top.
    final double minContentHeight = MediaQuery.of(context).size.height - 200;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minContentHeight),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Header
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/step2.png',
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

            // 2. Title Section
            const Text(
              "Climate & Resilience",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Wheat is a hardy crop, but its yield depends heavily on temperature and light.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 25),

            // 3. Cold Weather Behavior (Cards)
            Text(
              "Cold Tolerance",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryPurple,
              ),
            ),
            const SizedBox(height: 12),
            _buildConditionCard(
              title: "Germination Power",
              subtitle: "Seeds sprout at 4°C+",
              detail:
                  "Growth properly accelerates once temperatures rise above 5°C with sunlight.",
              icon: Icons.wb_sunny_outlined,
              color: Colors.orange,
            ),
            _buildConditionCard(
              title: "Spring vs Winter Wheat",
              subtitle: "Survival: -9.4°C to -31.6°C",
              detail:
                  "Winter varieties are exceptionally tough, surviving extreme freezing temperatures.",
              icon: Icons.ac_unit,
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            // 4. The Hardening Process Section
            _buildHardeningSection(primaryPurple),

            const SizedBox(height: 30),

            // 5. Sunlight Section
            Text(
              "Role of Sunlight",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryPurple,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.2)),
              ),
              child: const Column(
                children: [
                  _BulletPoint(
                    text:
                        "Long-Day Crop: Wheat prefers extended daylight for faster flowering.",
                    icon: Icons.light_mode,
                  ),
                  SizedBox(height: 10),
                  _BulletPoint(
                    text:
                        "Short Days: Plant focuses more on leaf and tiller growth.",
                    icon: Icons.eco,
                  ),
                ],
              ),
            ),

            // Spacer so content fills viewport when short
            const SizedBox(height: 24),

            // Expand to fill remaining vertical space so parent scroll can work consistently
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _buildHardeningSection(Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "The Hardening Process",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "As wheat grows in cool conditions, it builds internal strength to survive freezing:",
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            _HardeningChip(label: "Higher Sugar"),
            SizedBox(width: 8),
            _HardeningChip(label: "More Nitrogen"),
            SizedBox(width: 8),
            _HardeningChip(label: "Dry Matter"),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          "This process reduces water in leaves and holds it tightly within cells so ice cannot damage the plant.",
          style: TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildConditionCard({
    required String title,
    required String subtitle,
    required String detail,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HardeningChip extends StatelessWidget {
  final String label;
  const _HardeningChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF7F3DFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF7F3DFF),
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  final IconData icon;
  const _BulletPoint({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.amber.shade800),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
