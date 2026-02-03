import 'package:flutter/material.dart';

class Step1Content extends StatelessWidget {
  const Step1Content({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF7F3DFF);

    // Image height relative to screen height
    final double imageHeight = MediaQuery.of(context).size.height / 4;

    // Ensure the content takes at least the available height so the outer
    // SingleChildScrollView handles scrolling and the scrollbar reset works.
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
                  'assets/images/step1.png',
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

            // 2. Main Title & Scientific Name
            const Center(
              child: Column(
                children: [
                  Text(
                    "Common Wheat",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "(Triticum aestivum)",
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Quick Info Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _InfoChip(label: "Bread Wheat", icon: Icons.grass),
                _InfoChip(label: "Pan-India", icon: Icons.public),
              ],
            ),
            const SizedBox(height: 15),

            // 4. Description
            const Text(
              "This is the most commonly cultivated wheat in India. It is primarily used for making chapatis, bread, and various bakery products.",
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 25),

            // 5. Variety Types List
            Text(
              "Types of Common Wheat",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryPurple,
              ),
            ),
            const SizedBox(height: 12),

            // Card 1: Hard Red Winter
            _buildTypeCard(
              title: "Hard Red Winter",
              subtitle: "Commercial favorite. Best for bread making.",
              icon: Icons.agriculture,
              color: Colors.brown,
            ),

            // Card 2: Hard Red Spring
            _buildTypeCard(
              title: "Hard Red Spring",
              subtitle: "Grows in harsh climates. High protein content.",
              icon: Icons.fitness_center, // Represents strength/high protein
              color: Colors.amber,
            ),

            // Card 3: Soft Red Winter
            _buildTypeCard(
              title: "Soft Red Winter",
              subtitle: "Low protein. Best for cakes, biscuits, and cookies.",
              icon: Icons.cookie,
              color: Colors.deepOrangeAccent,
            ),

            // Card 4: White Wheat
            _buildTypeCard(
              title: "White Wheat",
              subtitle: "The preferred choice for pasta and specialty noodles.",
              icon: Icons.ramen_dining,
              color: Colors.blueGrey,
            ),

            // Spacer at bottom to give breathing room inside parent scroll
            const SizedBox(height: 24),
            // Expand to fill remaining space so IntrinsicHeight is satisfied.
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.3,
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

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoChip({required this.label, required this.icon, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF7F3DFF)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7F3DFF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
