import 'package:flutter/material.dart';
import '../widgets/wheat_card.dart';

class Section7Nutrients extends StatelessWidget {
  const Section7Nutrients({super.key});

  @override
  Widget build(BuildContext context) {
    return const WheatCard(
      title: "7️⃣ Nutrient & Water Management",
      content: """
Nitrogen:
• Critical leaf N: 2.5%
• Irrigated: 120–150 kg/ha
• Rainfed: 40–60 kg/ha
• Split application recommended

Phosphorus:
• Leaf P: 0.1%
• Recommended: 60 kg P₂O₅
• Basal application preferred

Potassium:
• Usually not required
• General: 40–60 kg/ha

Micronutrients:
• Zn most common deficiency
• 25 kg ZnSO₄/ha
• Foliar spray if needed

Irrigation:
• 4–6 irrigations
• CRI most critical
• Flowering second critical
""",
    );
  }
}
