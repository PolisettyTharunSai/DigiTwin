import 'package:flutter/material.dart';
import '../widgets/wheat_card.dart';

class Section6SeedSpacing extends StatelessWidget {
  const Section6SeedSpacing({super.key});

  @override
  Widget build(BuildContext context) {
    return const WheatCard(
      title: "6️⃣ Seed Rate, Spacing & Crop Geometry",
      content: """
Seed Rate:
• Normal: 100–125 kg/ha
• Late sowing: +25%
• Broadcasting: 150 kg/ha
• Dibbling: 25–30 kg/ha

Spacing:
• Irrigated: 22.5 cm rows
• Rainfed: 25–30 cm × 5–6 cm
• Late sown: 15–16 cm
""",
    );
  }
}
