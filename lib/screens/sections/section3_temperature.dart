import 'package:flutter/material.dart';
import '../widgets/wheat_card.dart';

class Section3Temperature extends StatelessWidget {
  const Section3Temperature({super.key});

  @override
  Widget build(BuildContext context) {
    return const WheatCard(
      title: "3️⃣ Temperature Response & Growth Behaviour",
      content: """
Temperature Tolerance:
• Low temperature during vegetative phase
• High temperature during reproductive phase

Optimum Temperatures:
• Overall: 20–22°C
• Vegetative: 16–22°C
• Maximum leaf size at 22°C

High Temperature Effects:
• Reduced height, roots, tillers
• Heading accelerated at 22–34°C
• Heading retarded above 34°C

Grain Development:
• Optimum: 25°C for 4–5 weeks
• Above 25°C → reduced grain weight
""",
    );
  }
}
