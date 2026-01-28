import 'package:flutter/material.dart';
import '../widgets/wheat_card.dart';

class Section8WeedsHarvest extends StatelessWidget {
  const Section8WeedsHarvest({super.key});

  @override
  Widget build(BuildContext context) {
    return const WheatCard(
      title: "8️⃣ Weed Management, Harvesting & Cropping Systems",
      content: """
Major Weeds:
• Phalaris minor
• Avena fatua
• Polypogon monspeliensis

Control:
• Hand weeding before 20–25 DAS
• 2,4-D for dicots
• Isoproturon for monocots
• Pendimethalin pre-emergence

Harvesting:
• Yellow dry straw indicates maturity
• Ideal grain moisture: 20–25%
• Combine harvester preferred

Cropping Systems:
• Rice–wheat
• Maize–wheat
• Pulse–wheat
• Sometimes third catch crop
""",
    );
  }
}
