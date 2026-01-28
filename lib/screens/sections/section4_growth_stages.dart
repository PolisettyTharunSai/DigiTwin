import 'package:flutter/material.dart';
import '../widgets/wheat_card.dart';

class Section4GrowthStages extends StatelessWidget {
  const Section4GrowthStages({super.key});

  @override
  Widget build(BuildContext context) {
    return const WheatCard(
      title: "4️⃣ Crop Growth Stages & Duration (North India)",
      content: """
Vegetative Phase:
• Germination: 5–7 days
• CRI: 20–25 DAS
• Tillering: 15–45 DAS
• Jointing: 45–60 DAS
• Peak plant growth

Reproductive Phase:
• Boot leaf: 70–75 DAS
• Flowering: 85–90 DAS
• Milking: 100–105 DAS
• Dough: 105–110 DAS
• Maturity: 115–120 DAS
""",
    );
  }
}
