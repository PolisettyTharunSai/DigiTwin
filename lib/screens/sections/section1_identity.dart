import 'package:flutter/material.dart';
import '../widgets/wheat_card.dart';

class Section1Identity extends StatelessWidget {
  const Section1Identity({super.key});

  @override
  Widget build(BuildContext context) {
    return const WheatCard(
      title: "1️⃣ Crop Identity, Classification & Adaptability",
      content: """
Common Wheat (Triticum aestivum / T. vulgare)

• Bread wheat
• Most suitable for chapati and bakery
• Cultivated throughout India

Sub-divisions of Common Wheat:
• Hard red winter wheat – commercial class
• Hard red spring wheat – severe winters, high protein
• Soft red winter wheat – humid regions, cakes & cookies
• White wheat – pastry purposes
""",
    );
  }
}
